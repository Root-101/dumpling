import 'package:console/app_exporter.dart';
import 'package:material_ui/material_ui.dart';

/// A config in a dialog of three steps: its name and schedule, its output
/// (object key and compression), and a review of everything with what the
/// next run writes. It edits a copy; the canvas applies it to its draft (saved
/// with the canvas) and Backups saves it right away
class ConfigDialog extends StatefulWidget {
  /// [onSave] gets the edited copy: null closes the dialog, a message stays
  /// in it. [onDelete], when given, is the *Delete config* of the footer
  static Future<void> open({
    required BackupConfig config,
    required SourceNode? source,
    required DestinationNode? destination,
    required Future<String?> Function(BackupConfig config) onSave,
    VoidCallback? onDelete,
    BuildContext? context,
  }) => StepsDialogTemplate.show(
    context: context,
    dialog: ConfigDialog(
      config: config,
      source: source,
      destination: destination,
      onSave: onSave,
      onDelete: onDelete,
    ),
  );

  final BackupConfig config;
  final SourceNode? source;
  final DestinationNode? destination;
  final Future<String?> Function(BackupConfig config) onSave;
  final VoidCallback? onDelete;

  const ConfigDialog({
    required this.config,
    required this.source,
    required this.destination,
    required this.onSave,
    this.onDelete,
    super.key,
  });

  @override
  State<ConfigDialog> createState() => _ConfigDialogState();
}

class _ConfigDialogState extends State<ConfigDialog> {
  static const int _lastStep = 2;

  late BackupConfig _c = widget.config;
  int _step = 0;
  bool _saving = false;
  String? _error;

  String? get _nameError => ConfigRules.name(_c.name);
  String? get _cronError => ConfigRules.cron(_c.schedule);
  String? get _keyError => ConfigRules.objectKey(_c.objectKey);

  bool get _stepValid => switch (_step) {
    0 => _nameError == null && _cronError == null,
    1 => _keyError == null,
    _ => _nameError == null && _cronError == null && _keyError == null,
  };

  void _set(BackupConfig c) => setState(() {
    _c = c;
    _error = null;
  });

  Future<void> _next() async {
    if (!_stepValid || _saving) return;
    if (_step < _lastStep) {
      setState(() => _step++);
      return;
    }
    setState(() => _saving = true);
    final error = await widget.onSave(_c);
    if (!mounted) return;
    if (error == null) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _saving = false;
      _error = error;
    });
  }

  void _back() {
    if (_step == 0) {
      Navigator.of(context).pop();
    } else {
      setState(() => _step--);
    }
  }

  // ---------- what the steps show ----------

  String get _base {
    final dest = widget.destination;
    final folder = _c.folderId == null ? null : FolderPath.show(_c.folderId!);
    return '${dest?.bucket ?? ''}${folder ?? ''}';
  }

  String get _route {
    final t = app.intl.canvas.inspector;
    return '${widget.source?.name ?? t.noSource} → '
        '${widget.destination == null ? t.noDestination : _base}';
  }

  String get _frequency {
    final schedule = _c.schedule;
    return schedule == null
        ? app.intl.canvas.workspaceDefault
        : Frequency.of(schedule).label;
  }

  /// The one the service computed, while the schedule is the saved one
  DateTime? get _nextRun =>
      _c.schedule == widget.config.schedule && _c.enabled ? _c.nextRun : null;

  String get _compression => switch (_c.compression) {
    null => app.intl.canvas.workspaceDefault,
    'gzip' => 'gzip',
    _ => app.intl.canvas.inspector.compressionNone,
  };

  /// `s3://bucket/folder/2026/10/27.dump.gz`, or why it writes nothing
  (String text, bool missing) get _writes {
    final t = app.intl.canvas.inspector;
    final db = widget.source;
    final dest = widget.destination;
    if (db == null && dest == null) return (t.missingBoth, true);
    if (db == null) return (t.missingSource, true);
    if (dest == null) return (t.missingDestination, true);
    final key = _c.objectKey;
    if (key == null) return (app.intl.canvas.workspaceDefault, false);
    final resolved = CanvasCubit.resolveKey(
      key,
      db.settings['database'] ?? db.name,
    );
    return (
      's3://$_base/$resolved${ConfigRules.extension(db, _c.compression)}',
      false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = app.intl.canvas.inspector;
    return StepsDialogTemplate(
      title: _c.name.trim().isEmpty ? widget.config.name : _c.name,
      description: _route,
      icon: app.assets.icons.nodes.clock,
      width: 640,
      steps: [t.schedule, t.output, t.review],
      current: _step,
      footerLeading: widget.onDelete == null
          ? null
          : AppButton(
              label: app.intl.canvas.deleteConfig,
              type: AppButtonType.danger,
              onPressed: () {
                Navigator.of(context).pop();
                widget.onDelete!();
              },
            ),
      actions: [
        PrimaryButton.secondary(
          onPressed: _back,
          title: _step == 0 ? app.intl.common.cancel : app.intl.common.back,
          h: 40,
          horizontalPadding: 16,
        ),
        PrimaryButton.primary(
          onPressed: _stepValid ? _next : null,
          isLoading: _saving,
          title: _saving
              ? app.intl.common.saving
              : _step < _lastStep
              ? app.intl.common.next
              : app.intl.common.saveChanges,
          color: app.colors.primary.primaryAction,
          h: 40,
          horizontalPadding: 20,
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_error != null) ...[
            AppFormAlert(title: _error!),
            app.dimensions.padding.l.gap(),
          ],
          ...switch (_step) {
            0 => _schedule(),
            1 => _output(),
            _ => _review(),
          },
        ],
      ),
    );
  }

  List<Widget> _schedule() {
    final t = app.intl.canvas.inspector;
    final colors = app.colors;
    final schedule = _c.schedule;
    final next = _nextRun;
    return [
      StepTitle(t.schedule),
      const SizedBox(height: 14),
      _Label(t.configName),
      const SizedBox(height: 6),
      _Input(
        value: _c.name,
        maxLength: ConfigRules.maxNameLength,
        error: _nameError,
        onChanged: (v) => _set(_c.copyWith(name: v)),
      ),
      const SizedBox(height: 6),
      if (_nameError == null && CanvasGeometry.longName(_c.name))
        AppFieldWarning(app.intl.common.longName)
      else
        _Help(t.nameHelp),
      const SizedBox(height: 16),
      _Label(t.frequency),
      const SizedBox(height: 6),
      AppSegmented<Frequency>(
        values: Frequency.values,
        labelOf: (f) => f.label,
        value: schedule == null ? null : Frequency.of(schedule),
        onChanged: (f) {
          if (f == Frequency.cron) return;
          _set(_c.copyWith(schedule: Frequency.apply(f, schedule)));
        },
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
                  value: schedule ?? '',
                  hint: app.intl.canvas.workspaceDefault,
                  mono: true,
                  error: _cronError,
                  onChanged: (v) => _set(_c.copyWith(schedule: v.trim())),
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
      _Help(t.cronHelp),
      const SizedBox(height: 12),
      AppSwitchTile(
        title: t.enabled,
        subtitle: _c.enabled ? t.enabledOn : t.enabledOff,
        value: _c.enabled,
        onChanged: () => _set(_c.copyWith(enabled: !_c.enabled)),
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
              if (schedule != null)
                Text(
                  schedule,
                  style: AppText.mono.copyWith(
                    fontSize: 12,
                    color: colors.text.secondary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          if (next == null)
            Text(
              // the service computes it on save
              _c.enabled ? t.nextRunOnSave : t.enabledOff,
              style: TextStyle(fontSize: 12, color: colors.text.secondary),
            )
          else
            AppDateTime(time: next, alignment: CrossAxisAlignment.start),
        ],
      ),
    ];
  }

  List<Widget> _output() {
    final t = app.intl.canvas.inspector;
    final dest = widget.destination;
    final folder = _c.folderId == null ? null : FolderPath.show(_c.folderId!);
    return [
      _SectionHeader(n: 1, title: t.schedule),
      const SizedBox(height: 10),
      _Summary(
        title: _c.name,
        sub: [
          _frequency,
          ?_c.schedule,
          if (_nextRun case final next?)
            app.intl.time.utc(
              time: app.dateFormatter.time.format(next.toUtc()),
            ),
        ].join(' · '),
        onEdit: () => setState(() => _step = 0),
      ),
      const SizedBox(height: 28),
      _SectionHeader(n: 2, title: t.output),
      const SizedBox(height: 14),
      _Label(t.objectKey),
      const SizedBox(height: 6),
      _Input(
        value: _c.objectKey ?? '',
        hint: app.intl.canvas.workspaceDefault,
        mono: true,
        maxLength: ConfigRules.maxObjectKeyLength,
        error: _keyError,
        onChanged: (v) {
          final key = v.trim();
          _set(_c.copyWith(objectKey: () => key.isEmpty ? null : key));
        },
      ),
      const SizedBox(height: 6),
      _Help(
        dest == null
            ? t.connectDestination
            : folder != null
            ? t.relativeToFolder(folder: folder)
            : t.relativeToRoot(bucket: dest.bucket),
      ),
      const SizedBox(height: 16),
      _Label(t.compression),
      const SizedBox(height: 6),
      AppSegmented<String>(
        values: ConfigRules.compressions,
        labelOf: (v) => v == 'gzip' ? 'gzip' : t.compressionNone,
        value: _c.compression,
        onChanged: (v) => _set(_c.copyWith(compression: v)),
      ),
    ];
  }

  List<Widget> _review() {
    final t = app.intl.canvas.inspector;
    final colors = app.colors;
    final next = _nextRun;
    final (writes, missing) = _writes;
    return [
      _ReviewBlock(
        title: '1 · ${t.schedule}',
        onEdit: () => setState(() => _step = 0),
        rows: [
          (t.configName, Text(_c.name)),
          (t.frequency, Text(_frequency)),
          (
            t.cron,
            Text(
              _c.schedule ?? app.intl.canvas.workspaceDefault,
              style: AppText.mono.copyWith(fontSize: 13),
            ),
          ),
          (
            t.nextRun,
            next == null
                ? Text(_c.enabled ? t.nextRunOnSave : t.enabledOff)
                : AppDateTime(
                    time: next,
                    alignment: CrossAxisAlignment.start,
                    style: const TextStyle(fontSize: 13),
                  ),
          ),
        ],
      ),
      const SizedBox(height: 14),
      _ReviewBlock(
        title: '2 · ${t.output}',
        onEdit: () => setState(() => _step = 1),
        rows: [
          (t.source, Text(widget.source?.name ?? t.noSource)),
          (
            t.destination,
            Text(widget.destination == null ? t.noDestination : _base),
          ),
          (
            t.objectKey,
            Text(
              _c.objectKey ?? app.intl.canvas.workspaceDefault,
              style: AppText.mono.copyWith(fontSize: 13),
            ),
          ),
          (t.compression, Text(_compression)),
        ],
      ),
      const SizedBox(height: 14),
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.brand.accent.withValues(alpha: 0.06),
          borderRadius: app.dimensions.radius.m,
          border: Border.all(color: colors.brand.accent.withValues(alpha: 0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 4,
          children: [
            Text(
              t.writes.toUpperCase(),
              style: AppText.overline.copyWith(
                color: colors.brand.accent,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              writes,
              style: missing
                  ? TextStyle(fontSize: 12, color: colors.brand.accent)
                  : AppText.mono.copyWith(
                      fontSize: 12,
                      color: colors.brand.accent,
                    ),
            ),
          ],
        ),
      ),
    ];
  }
}

/// `1 · NAME & SCHEDULE`, the number apart
class _SectionHeader extends StatelessWidget {
  final int n;
  final String title;

  const _SectionHeader({required this.n, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '$n · ',
            style: TextStyle(color: app.colors.text.subtle),
          ),
          TextSpan(text: title),
        ],
      ),
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
    );
  }
}

/// What a step before left, with the way back to it
class _Summary extends StatelessWidget {
  final String title;
  final String sub;
  final VoidCallback onEdit;

  const _Summary({
    required this.title,
    required this.sub,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final colors = app.colors;
    return _Box(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    sub,
                    style: TextStyle(fontSize: 12, color: colors.text.muted),
                  ),
                ],
              ),
            ),
            _EditButton(onPressed: onEdit),
          ],
        ),
      ],
    );
  }
}

/// A step in the review: its fields, label over value, and *Edit*
class _ReviewBlock extends StatelessWidget {
  final String title;
  final List<(String, Widget)> rows;
  final VoidCallback onEdit;

  const _ReviewBlock({
    required this.title,
    required this.rows,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final colors = app.colors;
    return _Box(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title.toUpperCase(),
                style: AppText.overline.copyWith(
                  fontSize: 12,
                  color: colors.brand.primary,
                ),
              ),
            ),
            _EditButton(onPressed: onEdit),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          runSpacing: 12,
          children: [
            for (final (label, value) in rows)
              FractionallySizedBox(
                widthFactor: 0.5,
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 2,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 11,
                          color: colors.text.subtle,
                        ),
                      ),
                      DefaultTextStyle.merge(
                        style: TextStyle(
                          fontSize: 13,
                          color: colors.text.primary,
                        ),
                        child: value,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _EditButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _EditButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return PrimaryButton.secondary(
      onPressed: onPressed,
      title: app.intl.common.edit,
      color: app.colors.surface.control,
      h: 32,
      horizontalPadding: 12,
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
    // what the draft keeps is trimmed: only a real change replaces the text
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

class _Help extends StatelessWidget {
  final String text;

  const _Help(this.text);

  @override
  Widget build(BuildContext context) =>
      Text(text, style: TextStyle(fontSize: 12, color: app.colors.text.subtle));
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
