import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:service/dumpling.dart';

class CanvasService {
  final AppDatabase db;
  final CanvasRepo repo;
  final SourceTableRepo sources;
  final DestinationTableRepo destinations;
  final ConfigTableRepo configs;
  final RunTableRepo runs;
  final WorkspaceService workspaces;
  final BackupEngine engine;
  final Secrets secrets;

  CanvasService()
    : db = di.find(),
      repo = CanvasRepo(di.find()),
      sources = SourceTableRepo(di.find()),
      destinations = DestinationTableRepo(di.find()),
      configs = ConfigTableRepo(di.find()),
      runs = RunTableRepo(di.find()),
      workspaces = WorkspaceService(),
      engine = di.find(),
      secrets = Secrets();

  Future<CanvasModel> get(
    String workspace, {
    Map<String, String> ids = const {},
  }) async {
    await workspaces.get(workspace);
    final last = await runs.lastByConfig(workspace);
    return CanvasModel(
      sources: (await sources.getAll(workspace))
          .map(SourceModel.fromRow)
          .toList(),
      destinations: (await destinations.getAll(workspace))
          .map(DestinationModel.fromRow)
          .toList(),
      configs: [
        for (final row in await configs.getAll(workspace))
          ConfigModel.fromRow(row, lastRun: last[row.id]),
      ],
      positions: await repo.get(workspace),
      ids: ids,
    );
  }

  /// Makes the workspace what [request] says, all or nothing: a 422 naming
  /// the field when a node is unknown, a config points at a node that isn't
  /// there or a secret is missing. Then the schedules follow the configs.
  Future<CanvasModel> save(String workspace, CanvasRequest request) async {
    final defaults = (await workspaces.get(workspace)).defaults;
    // The configs before the save, to drop the schedules of those it deletes
    late final Set<String> before;

    // The reads and the writes in one transaction: another save can't change
    // the workspace in between
    final ids = await db.transaction(() async {
      before = {for (final c in await configs.getAll(workspace)) c.id};
      final savedSources = {
        for (final row in await sources.getAll(workspace)) row.id: row,
      };
      final savedDestinations = {
        for (final row in await destinations.getAll(workspace))
          row.destination.id: row,
      };

      // The id each node keeps, or gets when it is new
      final ids = <String, String>{};
      final context = ConstraintValidatorContext();
      void resolve(
        String name,
        List<CanvasNode<Object>> nodes,
        Set<String> saved,
        String prefix,
      ) {
        for (final (i, node) in nodes.indexed) {
          if (node.isNew) {
            ids[node.id] = Secrets.newId(prefix);
          } else if (saved.contains(node.id)) {
            ids[node.id] = node.id;
          } else {
            context
                .field('$name[$i].id', node.id)
                .custom((_) => intl.errors.validations.unknownNode);
          }
        }
      }

      resolve(
        'sources',
        request.sources,
        savedSources.keys.toSet(),
        SourceService.idPrefix,
      );
      resolve(
        'destinations',
        request.destinations,
        savedDestinations.keys.toSet(),
        DestinationService.idPrefix,
      );
      resolve('configs', request.configs, before, ConfigService.idPrefix);

      // The configs point at nodes of the request, by the id it uses
      final sourceIds = {for (final s in request.sources) s.id};
      final folders = {
        for (final d in request.destinations) d.id: d.request.cleanFolders,
      };
      for (final (i, node) in request.configs.indexed) {
        final config = node.request;
        final destinationFolders = folders[config.destinationId];
        context
          ..field('configs[$i].source_id', config.sourceId).custom(
            (id) => sourceIds.contains(id)
                ? null
                : intl.errors.validations.unknownSource,
          )
          ..field('configs[$i].destination_id', config.destinationId).custom(
            (_) => destinationFolders == null
                ? intl.errors.validations.unknownDestination
                : null,
          );
        if (destinationFolders != null) {
          context
              .field('configs[$i].folder', config.cleanFolder)
              .custom((f) => ConfigRequest.folderError(f, destinationFolders));
        }
      }
      context.throwOnFailure();

      // What goes first: the configs hold the others by foreign key
      final kept = ids.values.toSet();
      for (final id in before.difference(kept)) {
        await configs.delete(id);
      }
      for (final id in savedSources.keys.toSet().difference(kept)) {
        await sources.delete(id);
      }
      for (final id in savedDestinations.keys.toSet().difference(kept)) {
        await destinations.delete(id);
      }

      // shortcut: every node saved gets a new updated_at, even unchanged
      // ones; compare with the stored row if the console ever shows it
      for (final (i, node) in request.sources.indexed) {
        final id = ids[node.id]!;
        final source = node.request;
        final settings = source.settings!;
        final saved = savedSources[id];
        final stored = saved != null && saved.type == source.sourceType
            ? secrets.decrypt(id, saved.secretsEncrypted)
            : const <String, String>{};
        final values = Secrets.require(settings.requiredSecrets, {
          ...stored,
          ...settings.secrets,
        }, field: 'sources[$i].settings');
        if (saved == null) {
          await sources.insert(
            id: id,
            workspace: workspace,
            name: source.trimmedName,
            type: source.sourceType!,
            settings: jsonEncode(settings),
            secretsEncrypted: secrets.encrypt(id, values),
          );
        } else {
          await sources.update(
            id: id,
            name: source.trimmedName,
            type: source.sourceType!,
            settings: jsonEncode(settings),
            secretsEncrypted: secrets.encrypt(id, values),
          );
        }
      }

      for (final (i, node) in request.destinations.indexed) {
        final id = ids[node.id]!;
        final destination = node.request;
        final settings = destination.settings!;
        final saved = savedDestinations[id]?.destination;
        final stored =
            saved != null && saved.type == destination.destinationType
            ? secrets.decrypt(id, saved.secretsEncrypted)
            : const <String, String>{};
        final values = Secrets.require(settings.requiredSecrets, {
          ...stored,
          ...settings.secrets,
        }, field: 'destinations[$i].settings');
        if (saved == null) {
          await destinations.insert(
            id: id,
            workspace: workspace,
            name: destination.trimmedName,
            type: destination.destinationType!,
            settings: jsonEncode(settings),
            secretsEncrypted: secrets.encrypt(id, values),
            folders: destination.cleanFolders,
          );
        } else {
          await destinations.update(
            id: id,
            name: destination.trimmedName,
            type: destination.destinationType!,
            settings: jsonEncode(settings),
            secretsEncrypted: secrets.encrypt(id, values),
            folders: destination.cleanFolders,
          );
        }
      }

      for (final node in request.configs) {
        final id = ids[node.id]!;
        final config = node.request;
        final values = config.values(
          defaults,
          sourceId: ids[config.sourceId]!,
          destinationId: ids[config.destinationId]!,
          folder: config.cleanFolder,
        );
        if (before.contains(id)) {
          await configs.update(id, values);
        } else {
          await configs.insert(
            values.copyWith(id: Value(id), workspaceSlug: Value(workspace)),
          );
        }
      }

      await repo.replace(workspace, {
        for (final node in [
          ...request.sources,
          ...request.destinations,
          ...request.configs,
        ])
          if (node.position != null) ids[node.id]!: node.position!,
      });
      return ids;
    });

    // Once committed: the schedules follow the configs
    final after = await configs.getAll(workspace);
    for (final id in before.difference({for (final c in after) c.id})) {
      engine.unschedule(id);
    }
    after.forEach(engine.schedule);
    logger.info(
      'Canvas saved',
      fields: {
        'workspace': workspace,
        'sources': request.sources.length,
        'destinations': request.destinations.length,
        'configs': request.configs.length,
      },
    );
    return get(
      workspace,
      ids: {
        for (final MapEntry(:key, :value) in ids.entries)
          if (key != value) key: value,
      },
    );
  }
}
