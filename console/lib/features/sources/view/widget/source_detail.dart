import 'package:console/app_exporter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

/// A source in a dialog: how it is doing, the backups that dump it (where,
/// when, how the last run went and when the next one is), its last connection
/// check and the connection itself. It follows the list, so a test or an edit
/// made from it shows here too
class SourceDialog extends StatelessWidget {
  static void open(
    SourceModel source, {
    required ValueChanged<SourceModel> onEdit,
  }) => app.dialog.open(
    dialog: SourceDialog(source: source, onEdit: onEdit),
  );

  /// As the list had it when it opened; the list's newer one replaces it
  final SourceModel source;

  /// Opens the form over the dialog
  final ValueChanged<SourceModel> onEdit;

  const SourceDialog({required this.source, required this.onEdit, super.key});

  @override
  Widget build(BuildContext context) {
    final t = app.intl.sources;
    final data = context.select<SourceCubit, SourceData>((c) => c.state.data);
    final s =
        data.sources.where((e) => e.id == source.id).firstOrNull ?? source;
    final testing = data.testing.contains(s.id);
    final check = s.lastCheck;
    final pg = s.postgres;
    final uses = data.usesOf(s);
    final lastRun = [for (final c in uses) ?c.lastRun].fold<RunModel?>(
      null,
      (a, b) => a == null || b.startedAt.isAfter(a.startedAt) ? b : a,
    );
    final size = lastRun?.sizeBytes;
    final destinations = {for (final c in uses) c.destinationId}.length;
    return DetailDialogTemplate(
      header: DetailHeader(
        look: SourceTypeLook.lookOf(s.type),
        name: s.name,
        status: testing
            ? app.intl.connections.testing
            : ConnectionStatusLabel.labelOf(check),
        statusColor: testing
            ? app.colors.status.running
            : ConnectionStatusLabel.colorOf(check),
        description: t.detailDescription(type: SourceTypeLook.labelOf(s.type)),
        testing: testing,
        onTest: () => context.read<SourceCubit>().test(s),
        onEdit: () => onEdit(s),
      ),
      stats: [
        DetailStat(
          t.statBackups,
          '${uses.length}',
          t.statDestinations(n: destinations),
        ),
        DetailStat(
          t.statLastBackup,
          size == null ? '—' : app.storageFormatter.formatSize(size),
          lastRun == null ? '' : RunStatusLabel.labelOf(lastRun.status),
        ),
        DetailStat(
          app.intl.connections.lastCheck,
          testing
              ? app.intl.connections.testing
              : ConnectionStatusLabel.labelOf(check),
          check == null
              ? ''
              : app.intl.time.utc(
                  time: app.dateFormatter.time.format(check.checkedAt.toUtc()),
                ),
        ),
      ],
      main: [
        _Uses(configs: uses),
        ConnectionCheckPanel(
          check: check,
          testing: testing,
          idleSub: t.testIdle,
          connectedSub: (c) => [
            t.connectedAs(user: pg?.username ?? ''),
            if (c.serverVersion != null) 'PostgreSQL ${c.serverVersion}',
            ?c.toolVersion,
          ].join(' · '),
        ),
      ],
      aside: DetailFields(
        title: app.intl.connections.connection,
        items: [
          (
            t.columnType,
            [SourceTypeLook.labelOf(s.type), ?check?.serverVersion].join(' '),
            false,
          ),
          if (pg != null) ...[
            (t.host, pg.host, true),
            (t.port, '${pg.port}', true),
            (t.database, pg.database, true),
            (t.username, pg.username, true),
            (t.password, t.passwordStored, false),
            (
              t.dumpFormat,
              pg.dumpFormat == PostgresSettingsModel.plain
                  ? t.formatPlain
                  : t.formatCustom,
              false,
            ),
          ],
        ],
        action: app.intl.connections.editConnection,
        onAction: () => onEdit(s),
      ),
    );
  }
}

/// The backups that dump the source: where, when, the last run and the next
class _Uses extends StatelessWidget {
  final List<ConfigModel> configs;

  const _Uses({required this.configs});

  @override
  Widget build(BuildContext context) {
    final t = app.intl.sources;
    final colors = app.colors;
    final divider = BorderSide(
      color: colors.neutral.white.withValues(alpha: 0.06),
    );
    final muted = TextStyle(fontSize: 12, color: colors.neutral.grey4);
    Widget row(List<Widget> cells, {double height = 58, TextStyle? style}) =>
        Container(
          constraints: BoxConstraints(minHeight: height),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(border: Border(bottom: divider)),
          child: DefaultTextStyle.merge(
            style: style,
            child: Row(
              spacing: 12,
              children: [
                for (final (i, cell) in cells.indexed)
                  Expanded(flex: const [15, 10, 12, 10][i], child: cell),
              ],
            ),
          ),
        );
    return DetailPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DetailPanelTitle(
            t.sectionUses,
            trailing: InkWell(
              onTap: () {
                Navigator.of(context).pop();
                RouteNames.openWorkspace(
                  app.di.find<SourceCubit>().state.data.workspace!,
                  section: RouteNames.canvas,
                );
              },
              child: Text(
                t.openEditor,
                style: TextStyle(
                  fontSize: 13,
                  color: colors.primary.primaryFaded,
                ),
              ),
            ),
          ),
          if (configs.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(t.noUses, style: muted.copyWith(fontSize: 13)),
            )
          else ...[
            row(
              [
                Text(t.columnBackup),
                Text(t.columnSchedule),
                Text(t.columnLastRun),
                Text(t.columnNextRun),
              ],
              height: 38,
              style: TextStyle(fontSize: 12, color: colors.neutral.grey3),
            ),
            for (final config in configs)
              row([
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      config.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      [
                        ?config.lastRun?.destinationName,
                        config.folder == null
                            ? app.intl.destinations.bucketRoot
                            : FolderPath.show(config.folder!),
                      ].join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.mono.copyWith(
                        fontSize: 12,
                        color: colors.neutral.grey4,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      config.schedule,
                      style: AppText.mono.copyWith(fontSize: 13),
                    ),
                    Text(config.enabled ? t.cronUtc : t.paused, style: muted),
                  ],
                ),
                switch (config.lastRun) {
                  null => Text(t.neverRun, style: muted),
                  final run => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RunStatusLabel(run.status),
                      AppDateTime(
                        time: run.startedAt,
                        alignment: CrossAxisAlignment.start,
                      ),
                    ],
                  ),
                },
                switch (config.nextRun) {
                  null => Text('—', style: muted),
                  final next => AppDateTime(
                    time: next,
                    alignment: CrossAxisAlignment.start,
                  ),
                },
              ]),
          ],
        ],
      ),
    );
  }
}
