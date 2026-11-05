import 'package:drift/drift.dart' show Value;
import 'package:service/dumpling.dart';

/// Export and import of workspaces ([TransferFile]): how the data crosses a
/// version of 0.x that changes the schema.
class TransferService {
  final WorkspaceService workspaces;
  final WorkspaceTableRepo workspaceRepo;
  final CanvasService canvas;
  final SourceTableRepo sources;
  final DestinationTableRepo destinations;
  final RunTableRepo runs;
  final Secrets secrets;

  TransferService()
    : workspaces = WorkspaceService(),
      workspaceRepo = WorkspaceTableRepo(di.find()),
      canvas = CanvasService(),
      sources = SourceTableRepo(di.find()),
      destinations = DestinationTableRepo(di.find()),
      runs = RunTableRepo(di.find()),
      secrets = Secrets();

  /// [slug], or every workspace when null.
  Future<Map<String, Object?>> export({String? slug}) async {
    final now = DateTime.now();
    final list = slug == null
        ? await workspaces.list()
        : [await workspaces.get(slug)];
    return TransferFile.toJson(exportedAt: now, [
      for (final w in list)
        TransferWorkspace(
          workspace: w,
          canvas: await canvas.get(w.slug),
          secrets: {
            for (final s in await sources.getAll(w.slug))
              s.id: s.secretsEncrypted,
            for (final d in await destinations.getAll(w.slug))
              d.destination.id: d.destination.secretsEncrypted,
          },
          runs: await runs.finishedSince(
            w.slug,
            now.subtract(TransferFile.runsSince),
          ),
        ),
    ]);
  }

  /// Adds the workspaces of [request], all or none: everything is checked
  /// before the first one is written, and a failure deletes the ones already
  /// added. A name already taken gets the first free `Name (2)`. Every node
  /// and run gets a new id, so the same file can be imported twice.
  Future<List<WorkspaceModel>> import(ImportRequest request) async {
    final prepared = [
      for (final (i, w) in request.workspaces.indexed) _prepare(i, w),
    ];

    final taken = {for (final w in await workspaceRepo.getAll()) w.name};
    final created = <String>[];
    try {
      for (final (w, canvasRequest) in prepared) {
        final name = _freeName(w.workspace.trimmedName, taken);
        taken.add(name);
        final workspace = await workspaces.create(
          WorkspaceRequest(
            name: name,
            description: w.workspace.description,
            color: w.workspace.color,
            defaultSchedule: w.workspace.defaultSchedule,
            defaultCompression: w.workspace.defaultCompression,
            defaultObjectKey: w.workspace.defaultObjectKey,
          ),
        );
        created.add(workspace.slug);
        final saved = await canvas.save(workspace.slug, canvasRequest);
        for (final run in w.runs) {
          await runs.insert(
            run.copyWith(
              id: Value(Secrets.newId('run_')),
              workspaceSlug: Value(workspace.slug),
              configId: Value(saved.ids[_newId(run.configId.value)]),
            ),
          );
        }
      }
    } catch (_) {
      for (final slug in created) {
        await workspaces.delete(slug);
      }
      rethrow;
    }
    logger.info('Workspaces imported', fields: {'workspaces': created});
    return [for (final slug in created) await workspaces.get(slug)];
  }

  /// The canvas of [w] as a save of new nodes (`new_` and the id in the file),
  /// its secrets decrypted into the settings; a 422 if it isn't valid or the
  /// secrets don't decrypt with this `SECRETS_ENCRYPTION_KEY`.
  (ImportedWorkspace, CanvasRequest) _prepare(int i, ImportedWorkspace w) {
    final prefix = 'workspaces[$i]';
    final context = ConstraintValidatorContext();

    List<Map<String, dynamic>> nodes(String name) => [
      for (final node in (w.canvas[name] as List<Object?>? ?? const []))
        if (node is Map<String, dynamic>) node,
    ];

    Map<String, dynamic> withSecrets(String name, Map<String, dynamic> node) {
      final id = node['id'];
      final stored = w.secrets[id];
      var plain = const <String, String>{};
      if (id is String && stored != null) {
        try {
          plain = secrets.decrypt(id, stored);
        } on Object {
          context
              .field('$prefix.secrets.$id', id)
              .custom((_) => intl.errors.transfer.secrets);
        }
      }
      final settings = node['settings'];
      return {
        ...node,
        'id': _newId(id),
        'settings': {
          if (settings is Map<String, dynamic>) ...settings,
          ...plain,
        },
      };
    }

    final request = CanvasRequest.fromJson({
      'sources': [for (final s in nodes('sources')) withSecrets('sources', s)],
      'destinations': [
        for (final d in nodes('destinations')) withSecrets('destinations', d),
      ],
      'configs': [
        for (final c in nodes('configs'))
          {
            ...c,
            'id': _newId(c['id']),
            'source_id': _newId(c['source_id']),
            'destination_id': _newId(c['destination_id']),
          },
      ],
    });
    context
      ..merge(request.validate(), prefix: '$prefix.canvas')
      ..throwOnFailure();
    return (w, request);
  }

  /// The id a node of the file has in the save that imports it.
  static String? _newId(Object? id) =>
      id is String ? '${CanvasNode.newPrefix}$id' : null;

  /// [name], or `name (2)`, `name (3)`… when it is taken, within the length
  /// of a name.
  static String _freeName(String name, Set<String> taken) {
    if (!taken.contains(name)) return name;
    for (var n = 2; ; n++) {
      final suffix = ' ($n)';
      final base = name.length + suffix.length > WorkspaceRequest.maxNameLength
          ? name.substring(0, WorkspaceRequest.maxNameLength - suffix.length)
          : name;
      final candidate = '${base.trimRight()}$suffix';
      if (!taken.contains(candidate)) return candidate;
    }
  }
}
