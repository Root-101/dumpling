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
                Text(t.schedule.toUpperCase(), style: section),
                const SizedBox(height: 12),
                _FrequencyPicker(
                  value: schedule == null ? null : Frequency.of(schedule),
                  onChanged: cubit.setFrequency,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _Field(label: t.cron, value: schedule ?? defaults),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _Field(label: t.timeZone, value: 'UTC'),
                    ),
                  ],
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
                TextFormField(
                  // a new config gets a new field with its key
                  key: ValueKey('key-${c.id}'),
                  initialValue: c.objectKey,
                  onChanged: cubit.setObjectKey,
                  style: AppText.mono.copyWith(
                    fontSize: 12,
                    color: colors.text.primary,
                  ),
                  decoration: InputDecoration(
                    hintText: defaults,
                    isDense: true,
                    filled: true,
                    fillColor: colors.surface.surface1,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: app.dimensions.radius.s,
                      borderSide: BorderSide(color: colors.surface.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: app.dimensions.radius.s,
                      borderSide: BorderSide(
                        color: colors.brand.primary,
                        width: 2,
                      ),
                    ),
                  ),
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
                Row(
                  children: [
                    Expanded(
                      child: _Field(
                        label: t.compression,
                        value: c.compression ?? defaults,
                      ),
                    ),
                  ],
                ),
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
                        '${dest!.detail} · $base',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        c.objectKey == null
                            ? defaults
                            : 's3://$base/${CanvasCubit.resolveKey(c.objectKey!, db!.settings['database'] ?? db.name)}',
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FrequencyPicker extends StatelessWidget {
  /// Null: the default of the workspace, none of them
  final Frequency? value;
  final ValueChanged<Frequency> onChanged;

  const _FrequencyPicker({required this.value, required this.onChanged});

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
          for (final f in Frequency.values)
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
                    child: Text(f.label),
                  ),
                ),
              ),
            ),
        ],
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
