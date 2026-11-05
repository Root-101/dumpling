import 'dart:convert';

import 'package:console/app_exporter.dart';
import 'package:material_ui/material_ui.dart';

/// Export of workspaces to a JSON file, downloaded by the browser
abstract final class WorkspaceExport {
  /// [workspace], or every one when null
  static Future<void> run({WorkspaceModel? workspace}) async {
    try {
      final file = await app.di.find<WorkspaceRepo>().export(
        slug: workspace?.slug,
        token: app.di.find<AuthCubit>().auth?.accessToken,
      );
      final day = DateTime.now().toIso8601String().substring(0, 10);
      final name = workspace == null
          ? 'dumpling-export-$day.json'
          : 'dumpling-${workspace.slug}-$day.json';
      BrowserWindow.download(
        utf8.encode(const JsonEncoder.withIndent('  ').convert(file)),
        name,
        contentType: 'application/json',
      );
      final context = app.context;
      if (!context.mounted) return;
      app.snack.showSuccess(
        message: app.intl.workspaces.transfer.exported(file: name),
        context: context,
      );
    } catch (e) {
      final context = app.context;
      if (!context.mounted) return;
      app.snack.showError(
        message: ExceptionConverter.parse(e).message,
        context: context,
      );
    }
  }
}

/// A workspace of the chosen file, and the name it will get here
typedef _Incoming = ({
  String name,
  String as,
  Color? color,
  int sources,
  int destinations,
  int configs,
  int runs,
});

/// What the dialog holds: the file read, or why it can't be imported
class _ImportState {
  final String? fileName;
  final int size;
  final DateTime? exportedAt;
  final Map<String, dynamic>? file;
  final List<_Incoming> rows;
  final String? error;
  final bool importing;

  const _ImportState({
    this.fileName,
    this.size = 0,
    this.exportedAt,
    this.file,
    this.rows = const [],
    this.error,
    this.importing = false,
  });

  bool get ready => file != null && rows.isNotEmpty && !importing;
}

/// Dialog that imports an export: a file dropped on it or chosen, what it
/// adds, and the import. A name already taken gets `Name (2)`, as the service
/// names it
class WorkspaceImportDialog extends StatefulWidget {
  static const String loadingId = 'workspace-import';

  static Future<void> open(BuildContext context) async {
    final state = ValueNotifier(const _ImportState());
    await FormDialogTemplate.show(
      context: context,
      title: app.intl.workspaces.transfer.importTitle,
      description: app.intl.workspaces.transfer.importDescription,
      loadingId: loadingId,
      width: 600,
      actions: [
        PrimaryButton.secondary(
          onPressed: () => Navigator.of(context).pop(),
          title: app.intl.common.cancel,
          h: 40,
          w: 100,
        ),
        ValueListenableBuilder(
          valueListenable: state,
          builder: (context, s, _) => PrimaryButton.primary(
            onPressed: s.ready ? () => _import(context, state) : null,
            isLoading: s.importing,
            title: s.file == null
                ? app.intl.workspaces.transfer.import
                : app.intl.workspaces.transfer.importCount(n: s.rows.length),
            color: app.colors.primary.primaryAction,
            h: 40,
            horizontalPadding: 20,
          ),
        ),
      ],
      child: WorkspaceImportDialog._(state),
    );
    state.dispose();
  }

  static Future<void> _import(
    BuildContext context,
    ValueNotifier<_ImportState> state,
  ) async {
    final s = state.value;
    state.value = _ImportState(
      fileName: s.fileName,
      size: s.size,
      exportedAt: s.exportedAt,
      file: s.file,
      rows: s.rows,
      importing: true,
    );
    app.loading.show(id: loadingId);
    try {
      final created = await app.di.find<WorkspaceRepo>().import(
        file: s.file!,
        token: app.di.find<AuthCubit>().auth?.accessToken,
      );
      app.loading.hide(id: loadingId);
      if (context.mounted) Navigator.of(context).pop();
      app.di.find<WorkspaceCubit>().load();
      final root = app.context;
      if (!root.mounted) return;
      app.snack.showSuccess(
        message: app.intl.workspaces.transfer.imported(n: created.length),
        context: root,
      );
    } catch (e) {
      app.loading.hide(id: loadingId);
      final exception = ExceptionConverter.parse(e);
      state.value = _ImportState(
        fileName: s.fileName,
        size: s.size,
        exportedAt: s.exportedAt,
        file: s.file,
        rows: s.rows,
        error: switch (exception.data) {
          final List<ValidationError> errors when errors.isNotEmpty => {
            for (final v in errors) v.message,
          }.join('\n'),
          _ => exception.message,
        },
      );
    }
  }

  final ValueNotifier<_ImportState> _state;

  const WorkspaceImportDialog._(this._state);

  @override
  State<WorkspaceImportDialog> createState() => _WorkspaceImportDialogState();
}

class _WorkspaceImportDialogState extends State<WorkspaceImportDialog> {
  late final void Function() _stopDrop;
  bool _over = false;

  @override
  void initState() {
    super.initState();
    _stopDrop = BrowserWindow.listenFileDrop(
      onFile: _read,
      onOver: (over) {
        if (mounted && over != _over) setState(() => _over = over);
      },
    );
  }

  @override
  void dispose() {
    _stopDrop();
    super.dispose();
  }

  Future<void> _pick() async {
    final file = await BrowserWindow.pickFile(accept: '.json,application/json');
    if (file != null) _read(file);
  }

  /// Reads [picked] as an export: its workspaces, or why it isn't one
  void _read(PickedFile picked) {
    final t = app.intl.workspaces.transfer;
    Map<String, dynamic>? json;
    try {
      final decoded = jsonDecode(utf8.decode(picked.bytes));
      if (decoded is Map<String, dynamic> &&
          decoded['format'] == 'dumpling' &&
          decoded['workspaces'] is List) {
        json = decoded;
      }
    } on FormatException {
      json = null;
    }
    if (json == null) {
      widget._state.value = _ImportState(
        fileName: picked.name,
        size: picked.bytes.length,
        error: t.notAnExport,
      );
      return;
    }

    final taken = {
      for (final w in app.di.find<WorkspaceCubit>().state.data.workspaces)
        w.name,
    };
    int count(Object? list) => list is List ? list.length : 0;
    final rows = <_Incoming>[];
    for (final w in (json['workspaces'] as List).whereType<Map>()) {
      final data = w['workspace'] is Map ? w['workspace'] as Map : const {};
      final canvas = w['canvas'] is Map ? w['canvas'] as Map : const {};
      final name = '${data['name'] ?? ''}'.trim();
      final as = _freeName(name, taken);
      taken.add(as);
      rows.add((
        name: name,
        as: as,
        color: data['color'] is int ? Color(data['color'] as int) : null,
        sources: count(canvas['sources']),
        destinations: count(canvas['destinations']),
        configs: count(canvas['configs']),
        runs: count(w['runs']),
      ));
    }
    widget._state.value = _ImportState(
      fileName: picked.name,
      size: picked.bytes.length,
      exportedAt: DateTime.tryParse('${json['exported_at']}'),
      file: json,
      rows: rows,
    );
  }

  /// As the service does it: `name`, or `name (2)`, `name (3)`…
  static String _freeName(String name, Set<String> taken) {
    if (!taken.contains(name)) return name;
    var n = 2;
    while (taken.contains('$name ($n)')) {
      n++;
    }
    return '$name ($n)';
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget._state,
      builder: (context, s, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: app.dimensions.padding.l,
        children: [
          if (s.error != null) AppFormAlert(title: s.error!),
          if (s.fileName == null) _buildDropZone() else _buildFile(s),
          if (s.file != null) ...[_buildRows(s), _buildNote()],
        ],
      ),
    );
  }

  Widget _buildDropZone() {
    final t = app.intl.workspaces.transfer;
    final colors = app.colors;
    return DashedBorder(
      color: _over ? colors.primary.primaryFaded : colors.neutral.grey5,
      radius: 12,
      child: Container(
        constraints: const BoxConstraints(minHeight: 220),
        decoration: BoxDecoration(
          color: _over
              ? colors.primary.primaryFaded.withValues(alpha: 0.08)
              : colors.neutral.transparent,
          borderRadius: app.dimensions.border.borderRadius.m,
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 12,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: colors.surface.control,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: app.assets.icons.actions.export.build(
                size: 22,
                color: colors.primary.primaryLight,
              ),
            ),
            Column(
              spacing: 2,
              children: [
                Text(
                  t.drop,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  t.dropHint,
                  style: TextStyle(fontSize: 13, color: colors.neutral.grey4),
                ),
              ],
            ),
            PrimaryButton.secondary(
              onPressed: _pick,
              title: t.choose,
              icon: app.assets.icons.nodes.folder,
              color: colors.surface.control,
              h: 38,
              horizontalPadding: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFile(_ImportState s) {
    final t = app.intl.workspaces.transfer;
    final colors = app.colors;
    final kb = (s.size / 1024).ceil();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colors.primary.background2,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.neutral.grey5),
      ),
      child: Row(
        spacing: 12,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colors.surface.control,
              borderRadius: app.dimensions.border.borderRadius.s,
            ),
            alignment: Alignment.center,
            child: app.assets.icons.actions.file.build(
              size: 18,
              color: colors.primary.primaryLight,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.fileName!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: app.textTheme.bodyMedium!.copyWith(
                    fontFamily: AppText.monoFamily,
                    fontSize: 13,
                  ),
                ),
                Text(
                  s.exportedAt == null
                      ? '$kb KB'
                      : '$kb KB · ${t.exportedAt(time: '${app.dateFormatter.time.format(s.exportedAt!.toUtc())} UTC')}',
                  style: TextStyle(fontSize: 12, color: colors.neutral.grey4),
                ),
              ],
            ),
          ),
          PrimaryButton.secondary(
            onPressed: s.importing
                ? null
                : () => widget._state.value = const _ImportState(),
            title: t.change,
            h: 32,
            horizontalPadding: 12,
          ),
        ],
      ),
    );
  }

  Widget _buildRows(_ImportState s) {
    final t = app.intl.workspaces.transfer;
    final colors = app.colors;
    final line = BorderSide(color: colors.neutral.grey5.withValues(alpha: 0.5));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        Text(
          t.toAdd(n: s.rows.length),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: colors.neutral.grey5.withValues(alpha: 0.75),
            ),
          ),
          child: Column(
            children: [
              for (final (i, r) in s.rows.indexed)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    border: i < s.rows.length - 1 ? Border(bottom: line) : null,
                  ),
                  child: Row(
                    spacing: 12,
                    children: [
                      WorkspaceAvatar(
                        initial: WorkspaceModel(slug: '', name: r.name).initial,
                        color: r.color,
                        size: 30,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 8,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  r.name,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (r.as != r.name) ...[
                                  Text(
                                    t.as,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: colors.neutral.grey4,
                                    ),
                                  ),
                                  Text(
                                    r.as,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: colors.primary.primaryLight,
                                    ),
                                  ),
                                  _NameTakenBadge(label: t.nameTaken),
                                ],
                              ],
                            ),
                            Text(
                              t.counts(
                                sources: r.sources,
                                destinations: r.destinations,
                                configs: r.configs,
                                runs: r.runs,
                              ),
                              style: TextStyle(
                                fontSize: 12,
                                color: colors.neutral.grey4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNote() {
    final colors = app.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colors.primary.primaryFaded.withValues(alpha: 0.10),
        borderRadius: app.dimensions.border.borderRadius.s,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: app.assets.icons.actions.lock.build(
              size: 16,
              color: colors.primary.primaryLight,
            ),
          ),
          Expanded(
            child: Text(
              app.intl.workspaces.transfer.keyNote,
              style: TextStyle(fontSize: 13, color: colors.neutral.grey3),
            ),
          ),
        ],
      ),
    );
  }
}

class _NameTakenBadge extends StatelessWidget {
  final String label;

  const _NameTakenBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    final color = app.colors.primary.secondary;
    return Container(
      height: 20,
      padding: const EdgeInsets.symmetric(horizontal: 7),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: app.dimensions.border.borderRadius.xs,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
