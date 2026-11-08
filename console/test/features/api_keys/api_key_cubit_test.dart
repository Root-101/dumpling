import 'package:console/app_exporter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../support/fixtures.dart';

class _MockRepo extends Mock implements ApiKeyRepo {}

class _MockConfigs extends Mock implements ConfigRepo {}

class _MockSources extends Mock implements SourceRepo {}

class _MockDestinations extends Mock implements DestinationRepo {}

class _MockAuth extends Mock implements AuthCubit {}

ApiKeyModel apiKey(
  String id, {
  List<String>? permissions,
  List<String> configIds = const [],
  String? key,
}) => ApiKeyModel(
  id: 'key_$id',
  name: id,
  permissions: permissions ?? ApiKeyPermissions.templates[ApiKeyAccess.run]!,
  configIds: configIds,
  createdAt: DateTime.utc(2026, 10, 2),
  key: key,
);

void main() {
  late _MockRepo repo;
  late _MockConfigs configs;
  late _MockSources sources;
  late _MockDestinations destinations;
  late _MockAuth auth;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    registerFallbackValue(
      const ApiKeyDraft(name: '', permissions: [], configIds: []),
    );
  });

  setUp(() {
    repo = _MockRepo();
    configs = _MockConfigs();
    sources = _MockSources();
    destinations = _MockDestinations();
    auth = _MockAuth();
    when(() => auth.auth).thenReturn(session());
    when(() => repo.list(workspace: 'production', token: 'jwt')).thenAnswer(
      (_) async => [
        apiKey('deploy', configIds: ['cfg_orders']),
        apiKey(
          'grafana',
          permissions: ApiKeyPermissions.templates[ApiKeyAccess.read]!,
        ),
        apiKey('provisioning', permissions: ['source.list', 'source.create']),
      ],
    );
    when(() => configs.list(workspace: 'production', token: 'jwt'))
        .thenAnswer((_) async => [config('orders', 'bucket')]);
    when(() => sources.list(workspace: 'production', token: 'jwt'))
        .thenAnswer((_) async => [source('orders')]);
    when(() => destinations.list(workspace: 'production', token: 'jwt'))
        .thenAnswer((_) async => [destination('bucket')]);
  });

  Future<ApiKeyCubit> loaded() async {
    final cubit = ApiKeyCubit(repo, configs, sources, destinations, auth);
    await cubit.load('production');
    return cubit;
  }

  List<String> visible(ApiKeyCubit cubit) =>
      cubit.state.data.visibleKeys.map((k) => k.name).toList();

  test('a key is named by the template its permissions match', () {
    expect(
      ApiKeyAccess.of(ApiKeyPermissions.templates[ApiKeyAccess.run]!.reversed),
      ApiKeyAccess.run,
    );
    expect(ApiKeyAccess.of(ApiKeyPermissions.all), ApiKeyAccess.full);
    expect(ApiKeyAccess.of(['config.run']), ApiKeyAccess.custom);
    // every permission of the form has its group, label and tooltip
    final grouped = [
      for (final (_, ps) in ApiKeyPermissions.groups) ...ps.map((p) => p.key),
    ];
    expect(grouped, ApiKeyPermissions.all);
  });

  test('a limited key matches the template without the canvas', () {
    final full = ApiKeyPermissions.of(ApiKeyAccess.full, limited: true);
    expect(full, isNot(contains('canvas.get')));
    expect(full, isNot(contains('config.create')));
    expect(ApiKeyAccess.of(full, limited: true), ApiKeyAccess.full);
    expect(ApiKeyAccess.of(full), ApiKeyAccess.custom);
    expect(
      apiKey(
        'deploy',
        permissions: ApiKeyPermissions.of(ApiKeyAccess.read, limited: true),
        configIds: ['cfg_orders'],
      ).access,
      ApiKeyAccess.read,
    );
    // every limited permission is one of the form, as the service lists them
    expect(
      ApiKeyPermissions.all.toSet(),
      containsAll([
        ...ApiKeyPermissions.limitable,
        ...ApiKeyPermissions.notLimitable,
      ]),
    );
  });

  test('the route of a config goes from its source to its bucket', () async {
    final data = (await loaded()).state.data;
    expect(data.routeOf(config('orders', 'bucket')), 'orders-db → bucket');
    expect(
      data.routeOf(config('orders', 'bucket', folder: 'daily')),
      'orders-db → bucket/daily',
    );
  });

  test('searches and filters by access, config and permission', () async {
    final cubit = await loaded();
    expect(visible(cubit), ['deploy', 'grafana', 'provisioning']);
    expect(cubit.state.data.sourceNames, {'orders': 'orders-db'});

    cubit.search('GRAF');
    expect(visible(cubit), ['grafana']);
    cubit
      ..clearFilters()
      ..filterAccess(ApiKeyAccess.custom);
    expect(visible(cubit), ['provisioning']);

    // a config: the keys limited to it and those that reach every config
    cubit
      ..clearFilters()
      ..filterConfig('cfg_orders');
    expect(visible(cubit), ['deploy', 'grafana', 'provisioning']);
    cubit.filterConfig(ApiKeyData.unlimited);
    expect(visible(cubit), ['grafana', 'provisioning']);

    cubit
      ..clearFilters()
      ..filterPermission('config.run');
    expect(visible(cubit), ['deploy']);
    expect(cubit.state.data.filtered, isTrue);
    cubit.clearFilters();
    expect(cubit.state.data.filtered, isFalse);
  });

  test('a new key is added with its text; a change replaces it', () async {
    when(
      () => repo.save(
        workspace: 'production',
        draft: any(named: 'draft'),
        token: 'jwt',
      ),
    ).thenAnswer((_) async => apiKey('new', key: 'dmp_x_secret'));
    final cubit = await loaded();
    final created = await cubit.save(
      const ApiKeyDraft(name: 'new', permissions: ['run.list'], configIds: []),
    );
    expect(created?.key, 'dmp_x_secret');
    expect(visible(cubit), ['deploy', 'grafana', 'provisioning', 'new']);

    when(
      () => repo.save(
        workspace: 'production',
        draft: any(named: 'draft'),
        id: 'key_grafana',
        token: 'jwt',
      ),
    ).thenAnswer((_) async => apiKey('grafana-ro'));
    await cubit.save(
      const ApiKeyDraft(name: 'grafana-ro', permissions: [], configIds: []),
      id: 'key_grafana',
    );
    expect(visible(cubit), ['deploy', 'grafana-ro', 'provisioning', 'new']);
  });

  test('a reorder the service refuses goes back as it was', () async {
    when(
      () => repo.reorder(
        workspace: 'production',
        ids: any(named: 'ids'),
        token: 'jwt',
      ),
    ).thenThrow(apiError());
    final cubit = await loaded();
    await cubit.reorder(2, 0);
    expect(cubit.state, isA<ApiKeyProcessingErrorState>());
    expect(visible(cubit), ['deploy', 'grafana', 'provisioning']);
  });

  test('a deleted key leaves the list', () async {
    when(
      () =>
          repo.delete(workspace: 'production', id: 'key_deploy', token: 'jwt'),
    ).thenAnswer((_) async {});
    final cubit = await loaded();
    await cubit.delete(cubit.state.data.keys.first);
    expect(cubit.state, isA<ApiKeyProcessingOKState>());
    expect(visible(cubit), ['grafana', 'provisioning']);
  });
}
