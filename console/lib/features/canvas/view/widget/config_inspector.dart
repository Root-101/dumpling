import 'package:console/app_exporter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

/// Side panel with the settings of the selected config
class ConfigInspector extends StatelessWidget {
  final CanvasData data;
  final BackupConfig config;

  const ConfigInspector({required this.data, required this.config, super.key});

  @override
  Widget build(BuildContext context) {
    final colors = app.colors;
    final cubit = context.read<CanvasCubit>();
    final c = config;
    final db = data.source(c.sourceId);
    final dest = data.destination(c.destinationId);
    final folder = c.folderId == null ? null : FolderPath.show(c.folderId!);
    final base = '${dest?.bucket ?? ''}${folder ?? ''}';
    final t = app.intl.canvas.inspector;
    final dbName = db?.name ?? t.noSource;
    final schedule = c.schedule;
    final defaults = app.intl.canvas.workspaceDefault;
    final next = c.nextRun;
    // a run uses the saved config: a new one has to be saved first
    final unsaved = c.id.startsWith(CanvasCubit.newPrefix);
    final running = c.lastRun?.running ?? false;
    // an orphan config (no source or no destination) never runs
    final missing = db == null && dest == null
        ? t.missingBoth
        : db == null
        ? t.missingSource
        : dest == null
        ? t.missingDestination
        : null;
    final section = AppText.overline.copyWith(
      fontSize: 12,
      color: colors.brand.primary,
    );

    return Container(
      width: 340,
      decoration: BoxDecoration(
        color: colors.surface.surface2,
        border: Border(left: BorderSide(color: colors.surface.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: colors.surface.border.withValues(alpha: 0.4),
                ),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.title.toUpperCase(),
                        style: AppText.overline.copyWith(
                          color: colors.brand.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        c.name,
                        style: const TextStyle(
                          fontSize: 17,
                          height: 24 / 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$dbName → ${dest == null ? t.noDestination : base}',
                        style: AppText.mono.copyWith(
                          fontSize: 12,
                          color: colors.text.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                AppIconButton(
                  tooltip: t.close,
                  background: colors.surface.control.withValues(alpha: 0.75),
                  onPressed: () => cubit.select(null),
                  icon: app.assets.icons.actions.close.build(
                    size: 16,
                    color: colors.text.secondary,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _Label(t.name),
                const SizedBox(height: 6),
                _Input(
                  key: ValueKey('name-${c.id}'),
                  value: c.name,
                  maxLength: ConfigRules.maxNameLength,
                  error: ConfigRules.name(c.name),
                  onChanged: cubit.setName,
                ),
                const SizedBox(height: 22),
                Text(t.schedule.toUpperCase(), style: section),
                const SizedBox(height: 12),
                _Segmented<Frequency>(
                  values: Frequency.values,
                  labelOf: (f) => f.label,
                  value: schedule == null ? null : Frequency.of(schedule),
                  onChanged: cubit.setFrequency,
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Label(t.cron),
                          const SizedBox(height: 6),
                          _Input(
                            key: ValueKey('cron-${c.id}'),
                            value: schedule ?? '',
                            hint: defaults,
                            mono: true,
                            error: ConfigRules.cron(schedule),
                            onChanged: cubit.setSchedule,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: _Field(label: t.timeZone, value: 'UTC'),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  t.cronHelp,
                  style: TextStyle(fontSize: 12, color: colors.text.subtle),
                ),
                const SizedBox(height: 12),
                AppSwitchTile(
                  title: t.enabled,
                  subtitle: c.enabled ? t.enabledOn : t.enabledOff,
                  value: c.enabled,
                  onChanged: () => cubit.setEnabled(!c.enabled),
                ),
                const SizedBox(height: 12),
                _Box(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            t.nextRun.toUpperCase(),
                            style: AppText.overline.copyWith(
                              letterSpacing: 0.6,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    if (next == null)
                      Text(
                        // the service computes it on save
                        '—',
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.text.secondary,
                        ),
                      )
                    else
                      AppDateTime(
                        time: next,
                        alignment: CrossAxisAlignment.start,
                      ),
                  ],
                ),
                const SizedBox(height: 22),
                Text(t.output.toUpperCase(), style: section),
                const SizedBox(height: 12),
                _Label(t.objectKey),
                const SizedBox(height: 6),
                _Input(
                  key: ValueKey('key-${c.id}'),
                  value: c.objectKey ?? '',
                  hint: defaults,
                  mono: true,
                  maxLength: ConfigRules.maxObjectKeyLength,
                  error: ConfigRules.objectKey(c.objectKey),
                  onChanged: cubit.setObjectKey,
                ),
                const SizedBox(height: 6),
                Text(
                  dest == null
                      ? t.connectDestination
                      : folder != null
                      ? t.relativeToFolder(folder: folder)
                      : t.relativeToRoot(bucket: dest.bucket),
                  style: TextStyle(fontSize: 12, color: colors.text.subtle),
                ),
                const SizedBox(height: 12),
                _Label(t.compression),
                const SizedBox(height: 6),
                _Segmented<String>(
                  values: ConfigRules.compressions,
                  labelOf: (v) => v == 'gzip' ? 'gzip' : t.compressionNone,
                  value: c.compression,
                  onChanged: cubit.setCompression,
                ),
                if (c.compression == null) ...[
                  const SizedBox(height: 6),
                  Text(
                    defaults,
                    style: TextStyle(fontSize: 12, color: colors.text.subtle),
                  ),
                ],
                const SizedBox(height: 22),
                Text(t.writes.toUpperCase(), style: section),
                const SizedBox(height: 10),
                _Box(
                  children: [
                    if (missing != null)
                      Text(
                        missing,
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.brand.accent,
                        ),
                      )
                    else ...[
                      Text(
                        '${DestinationTypeLook.labelOf(dest!.type)} · $base',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        c.objectKey == null
                            ? defaults
                            : 's3://$base/${CanvasCubit.resolveKey(c.objectKey!, db!.settings['database'] ?? db.name)}${ConfigRules.extension(db, c.compression)}',
                        style: AppText.mono.copyWith(
                          fontSize: 11,
                          color: colors.brand.accent,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: colors.surface.surface1,
              border: Border(
                top: BorderSide(
                  color: colors.surface.border.withValues(alpha: 0.4),
                ),
              ),
            ),
            child: Row(
              children: [
                AppButton(
                  label: app.intl.canvas.deleteConfig,
                  type: AppButtonType.danger,
                  onPressed: () => cubit.deleteConfig(c.id),
                ),
                const Spacer(),
                Tooltip(
                  message: unsaved
                      ? app.intl.canvas.run.needsSave
                      : app.intl.canvas.run.help,
                  child: AppButton(
                    label: running
                        ? app.intl.canvas.runStatus.running
                        : app.intl.canvas.run.button,
                    type: AppButtonType.secondary,
                    onPressed: unsaved || running || missing != null
                        ? null
                        : () => cubit.runNow(c.id),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// One of [values]; null: the default of the workspace, none of them
class _Segmented<T> extends StatelessWidget {
  final List<T> values;
  final String Function(T value) labelOf;
  final T? value;
  final ValueChanged<T> onChanged;

  const _Segmented({
    required this.values,
    required this.labelOf,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = app.colors;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.surface.control,
        borderRadius: app.dimensions.radius.m,
      ),
      child: Row(
        children: [
          for (final f in values)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Semantics(
                  selected: f == value,
                  inMutuallyExclusiveGroup: true,
                  child: TextButton(
                    onPressed: () => onChanged(f),
                    style: TextButton.styleFrom(
                      minimumSize: const Size(0, 32),
                      padding: EdgeInsets.zero,
                      backgroundColor: f == value
                          ? colors.brand.primarySelected
                          : Colors.transparent,
                      foregroundColor: f == value
                          ? colors.text.primary
                          : colors.text.muted,
                      textStyle: TextStyle(
                        fontFamily: AppText.sans,
                        fontSize: 12,
                        fontWeight: f == value
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),
                    child: Text(labelOf(f)),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// A text field that follows [value] when it changes from outside (the
/// frequency writes the cron), without moving the cursor while typing
class _Input extends StatefulWidget {
  final String value;
  final String? hint;
  final String? error;
  final bool mono;
  final int? maxLength;
  final ValueChanged<String> onChanged;

  const _Input({
    required this.value,
    required this.onChanged,
    this.hint,
    this.error,
    this.mono = false,
    this.maxLength,
    super.key,
  });

  @override
  State<_Input> createState() => _InputState();
}

class _InputState extends State<_Input> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.value,
  );

  @override
  void didUpdateWidget(covariant _Input oldWidget) {
    super.didUpdateWidget(oldWidget);
    // what the cubit keeps is trimmed: only a real change replaces the text
    if (widget.value.trim() != _controller.text.trim()) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = app.colors;
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: app.dimensions.radius.s,
          borderSide: BorderSide(color: color, width: width),
        );
    return TextField(
      controller: _controller,
      onChanged: widget.onChanged,
      maxLength: widget.maxLength,
      style: (widget.mono ? AppText.mono : const TextStyle()).copyWith(
        fontSize: widget.mono ? 12 : 13,
        color: colors.text.primary,
      ),
      decoration: InputDecoration(
        hintText: widget.hint,
        errorText: widget.error,
        errorMaxLines: 5,
        counterText: '',
        isDense: true,
        filled: true,
        fillColor: colors.surface.surface1,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        enabledBorder: border(colors.surface.border),
        focusedBorder: border(colors.brand.primary, 2),
        errorBorder: border(colors.status.error),
        focusedErrorBorder: border(colors.status.error, 2),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;

  const _Label(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: app.colors.text.secondary,
    ),
  );
}

/// Read only value with its label
class _Field extends StatelessWidget {
  final String label;
  final String value;

  const _Field({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colors = app.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label(label),
        const SizedBox(height: 6),
        Container(
          height: 42,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: colors.surface.surface1,
            borderRadius: app.dimensions.radius.s,
            border: Border.all(color: colors.surface.border),
          ),
          child: Text(
            value,
            style: const TextStyle(fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _Box extends StatelessWidget {
  final List<Widget> children;

  const _Box({required this.children});

  @override
  Widget build(BuildContext context) {
    final colors = app.colors;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surface.surface1,
        borderRadius: app.dimensions.radius.m,
        border: Border.all(color: colors.surface.border.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}
