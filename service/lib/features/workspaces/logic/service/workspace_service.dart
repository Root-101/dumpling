import 'package:service/dumpling.dart';

class WorkspaceService {
  /// Characters of a slug before its `-2`, `-3`… suffix.
  static const int maxSlugLength = 48;

  final WorkspaceTableRepo repo;

  WorkspaceService() : repo = WorkspaceTableRepo(di.find());

  Future<List<WorkspaceModel>> list() async =>
      (await repo.getAll()).map(WorkspaceModel.fromRow).toList();

  Future<WorkspaceModel> get(String slug) async {
    final row = await repo.get(slug);
    if (row == null) {
      throw NotFoundException(
        detail: intl.errors.workspaces.notFound(slug: slug),
      );
    }
    return WorkspaceModel.fromRow(row);
  }

  Future<WorkspaceModel> create(WorkspaceRequest request) async {
    final slug = await _freeSlug(slugOf(request.trimmedName));
    await repo.insert(slug: slug, request: request);
    logger.info('Workspace created', fields: {'workspace': slug});
    return get(slug);
  }

  /// Replaces its data; the slug stays.
  Future<WorkspaceModel> update(String slug, WorkspaceRequest request) async {
    await get(slug);
    await repo.update(slug: slug, request: request);
    logger.info('Workspace updated', fields: {'workspace': slug});
    return get(slug);
  }

  /// Deletes the workspace with everything in it. The backup files already in
  /// the buckets stay where they are.
  Future<void> delete(String slug) async {
    await get(slug);
    await repo.delete(slug);
    logger.info('Workspace deleted', fields: {'workspace': slug});
  }

  /// [base], or `base-2`, `base-3`… when it is taken.
  Future<String> _freeSlug(String base) async {
    final taken = await repo.slugsStartingWith(base);
    if (!taken.contains(base)) return base;
    var n = 2;
    while (taken.contains('$base-$n')) {
      n++;
    }
    return '$base-$n';
  }

  static const Map<String, String> _accents = {
    'á': 'a', 'à': 'a', 'ä': 'a', 'â': 'a', 'ã': 'a', //
    'é': 'e', 'è': 'e', 'ë': 'e', 'ê': 'e', //
    'í': 'i', 'ì': 'i', 'ï': 'i', 'î': 'i', //
    'ó': 'o', 'ò': 'o', 'ö': 'o', 'ô': 'o', 'õ': 'o', //
    'ú': 'u', 'ù': 'u', 'ü': 'u', 'û': 'u', //
    'ñ': 'n', 'ç': 'c',
  };

  /// `Staging EU · Ñandú` → `staging-eu-nandu`: lowercase letters, digits and
  /// single hyphens; `workspace` when nothing is left.
  static String slugOf(String name) {
    final lower = name.toLowerCase().split('').map((c) => _accents[c] ?? c);
    var slug = lower
        .join()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    if (slug.length > maxSlugLength) {
      slug = slug.substring(0, maxSlugLength).replaceAll(RegExp(r'-+$'), '');
    }
    return slug.isEmpty ? 'workspace' : slug;
  }
}
