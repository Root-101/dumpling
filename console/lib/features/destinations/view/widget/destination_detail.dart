import 'package:console/app_exporter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

/// A destination in a dialog: how it is doing, the backups that write to
/// each of its folders, its last connection check and the connection itself.
/// It follows the list, so a test or an edit made from it shows here too
class DestinationDialog extends StatelessWidget {
  static Future<void> open(
    DestinationModel destination, {
    required ValueChanged<DestinationModel> onEdit,
  }) => app.dialog.open(
    dialog: DestinationDialog(destination: destination, onEdit: onEdit),
  );

  /// As the list had it when it opened; the list's newer one replaces it
  final DestinationModel destination;

  /// Opens the form over the dialog
  final ValueChanged<DestinationModel> onEdit;

  const DestinationDialog({
    required this.destination,
    required this.onEdit,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final t = app.intl.destinations;
    final data = context.select<DestinationCubit, DestinationData>(
      (c) => c.state.data,
    );
    final d =
        data.destinations.where((e) => e.id == destination.id).firstOrNull ??
        destination;
    final testing = data.testing.contains(d.id);
    final check = d.lastCheck;
    final folders = d.folders.length;
    final s3 = d.s3;
    return DetailDialogTemplate(
      header: DetailHeader(
        look: DestinationTypeLook.lookOf(d.type),
        name: d.name,
        status: testing
            ? app.intl.connections.testing
            : ConnectionStatusLabel.labelOf(check),
        statusColor: testing
            ? app.colors.status.running
            : ConnectionStatusLabel.colorOf(check),
        description: t.detailDescription,
        testing: testing,
        onTest: () => context.read<DestinationCubit>().test(d),
        onEdit: () => onEdit(d),
      ),
      stats: [
        DetailStat(t.statBackups, '${data.usageOf(d)}', t.statBackupsSub),
        DetailStat(
          t.statFolders,
          folders == 0 ? t.bucketRoot : '$folders',
          t.statFoldersSub,
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
        _Folders(destination: d, data: data),
        ConnectionCheckPanel(
          check: check,
          testing: testing,
          idleSub: t.testIdle,
          connectedSub: (_) => t.connectedSub(bucket: s3?.bucket ?? d.name),
        ),
      ],
      aside: DetailFields(
        title: app.intl.connections.connection,
        items: [
          (t.columnType, DestinationTypeLook.labelOf(d.type), false),
          if (s3 != null) ...[
            (t.endpoint, s3.endpoint, true),
            (t.region, s3.region.isEmpty ? '—' : s3.region, true),
            (t.bucket, s3.bucket, true),
            (t.accessKey, DetailFields.masked(s3.accessKeyId), true),
            (t.pathStyle, s3.pathStyle ? t.on : t.off, false),
          ],
        ],
        action: app.intl.connections.editConnection,
        onAction: () => onEdit(d),
      ),
    );
  }
}

/// Each folder (or the root, without folders) and the backups writing there
class _Folders extends StatelessWidget {
  final DestinationModel destination;
  final DestinationData data;

  const _Folders({required this.destination, required this.data});

  @override
  Widget build(BuildContext context) {
    final t = app.intl.destinations;
    final colors = app.colors;
    final divider = BorderSide(
      color: colors.neutral.white.withValues(alpha: 0.06),
    );
    final folders = destination.folders.isEmpty
        ? const <String?>[null]
        : destination.folders;
    Widget row(List<Widget> cells, {double height = 52, TextStyle? style}) =>
        Container(
          constraints: BoxConstraints(minHeight: height),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(border: Border(bottom: divider)),
          child: DefaultTextStyle.merge(
            style: style,
            child: Row(
              spacing: 12,
              children: [
                Expanded(flex: 10, child: cells[0]),
                Expanded(flex: 14, child: cells[1]),
              ],
            ),
          ),
        );
    return DetailPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DetailPanelTitle(t.sectionFolders),
          row(
            [Text(t.columnFolder), Text(t.columnWrittenBy)],
            height: 38,
            style: TextStyle(fontSize: 12, color: colors.neutral.grey3),
          ),
          for (final folder in folders)
            row([
              Row(
                children: [
                  app.assets.icons.nodes.folder.build(
                    size: 15,
                    color: colors.primary.primaryFaded,
                  ),
                  8.gap(),
                  Flexible(
                    child: Text(
                      folder == null ? t.bucketRoot : FolderPath.show(folder),
                      style: AppText.mono.copyWith(fontSize: 13),
                    ),
                  ),
                ],
              ),
              _writers(data.writersOf(destination, folder)),
            ]),
        ],
      ),
    );
  }

  Widget _writers(List<ConfigModel> configs) {
    if (configs.isEmpty) {
      return Text(
        app.intl.destinations.notUsedYet,
        style: TextStyle(fontSize: 13, color: app.colors.neutral.grey4),
      );
    }
    return Text(
      configs.map((c) => c.name).join(', '),
      style: const TextStyle(fontSize: 14),
    );
  }
}
