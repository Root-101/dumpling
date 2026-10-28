import 'dart:async';

import 'package:console/app_exporter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

enum _Tab { general, defaults, danger }

/// The settings of a workspace in a dialog: who it is on top, and in tabs its
/// general data (read, or edited after *Edit*), the defaults of its new
/// configs and its deletion. Saving sends everything: the service replaces it
class WorkspaceSettings extends StatefulWidget {
  /// Opens the dialog with its own [WorkspaceFormCubit]
  static Future<void> open(BuildContext context, WorkspaceModel workspace) {
    final cubit = WorkspaceFormCubit(app.di.find(), app.di.find());
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: app.intl.common.close,
      barrierColor: app.colors.neutral.black.withValues(alpha: 0.62),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) => BlocProvider(
        create: (_) => cubit,
        child: WorkspaceSettings(workspace: workspace),
      ),
      transitionBuilder: (context, animation, secondaryAnimation, child) =>
          FadeTransition(opacity: animation, child: child),
    );
  }

  /// Id of the dialog's [LoadingOverlay]
  static const String loadingId = 'workspace-settings';

  /// What a workspace starts with on the service, when it sends none
  static const WorkspaceDefaults fallbackDefaults = (
    schedule: '0 2 * * *',
    compression: 'gzip',
    objectKey: '{db}/{yyyy}-{MM}-{dd}-{run_id}',
  );

  final WorkspaceModel workspace;

  const WorkspaceSettings({required this.workspace, super.key});

  @override
  State<WorkspaceSettings> createState() => _WorkspaceSettingsState();
}

class _WorkspaceSettingsState extends State<WorkspaceSettings> {
  static const int _nameMaxLength = 64;
  static const int _descriptionMaxLength = 256;

  /// The saved values: what *Discard* goes back to
  late WorkspaceModel _saved = widget.workspace;

  _Tab _tab = _Tab.general;
  bool _editing = false;
  bool _changed = false;
  bool _justSaved = false;
  Timer? _savedTimer;

  final _name = TextEditingController();
  final _description = TextEditingController();
  final _cron = TextEditingController();
  final _objectKey = TextEditingController();
  Color? _color;
  String _compression = 'gzip';

  /// API errors per field; cleared when that field is edited
  Map<String, String> _serverErrors = const {};
  String? _formError;
  bool _submitted = false;

  WorkspaceDefaults get _defaults =>
      _saved.defaults ?? WorkspaceSettings.fallbackDefaults;

  bool get _dirty => _editing || _changed;

  @override
  void initState() {
    super.initState();
    _reset();
  }

  @override
  void dispose() {
    _savedTimer?.cancel();
    for (final c in [_name, _description, _cron, _objectKey]) {
      c.dispose();
    }
    super.dispose();
  }

  /// Back to the saved values
  void _reset() {
    _name.text = _saved.name;
    _description.text = _saved.description ?? '';
    _color = _saved.color;
    _cron.text = _defaults.schedule;
    _objectKey.text = _defaults.objectKey;
    _compression = _defaults.compression;
    _editing = false;
    _changed = false;
    _submitted = false;
    _serverErrors = const {};
    _formError = null;
  }

  void _touch([String? field]) => setState(() {
    _changed = true;
    _justSaved = false;
    if (field != null && _serverErrors.containsKey(field)) {
      _serverErrors = {..._serverErrors}..remove(field);
    }
  });

  String? get _nameError => _name.text.trim().isEmpty
      ? app.intl.common.required
      : _serverErrors[WorkspaceFormField.name];

  String? get _cronError =>
      ConfigRules.cron(_cron.text) ??
      _serverErrors[WorkspaceFormField.schedule];

  String? get _objectKeyError {
    final key = _objectKey.text.trim();
    if (key.isEmpty) return app.intl.common.required;
    return ConfigRules.objectKey(key) ??
        _serverErrors[WorkspaceFormField.objectKey];
  }

  void _save() {
    final cubit = context.read<WorkspaceFormCubit>();
    if (cubit.state is WorkspaceFormProcessInProgressState) return;
    setState(() => _submitted = true);
    if (_nameError != null) return setState(() => _tab = _Tab.general);
    if (_cronError != null || _objectKeyError != null) {
      return setState(() => _tab = _Tab.defaults);
    }
    final description = _description.text.trim();
    cubit.update(
      _saved.slug,
      WorkspaceDraft(
        name: _name.text.trim(),
        description: description.isEmpty ? null : description,
        color: _color,
        defaults: (
          schedule: _cron.text.trim(),
          compression: _compression,
          objectKey: _objectKey.text.trim(),
        ),
      ),
    );
  }

  void _askDelete() {
    showDialog<void>(
      context: context,
      barrierColor: app.colors.neutral.black.withValues(alpha: 0.5),
      builder: (_) => _DeleteDialog(
        workspace: _saved,
        stats: widget.workspace.stats,
        onConfirm: () => context.read<WorkspaceFormCubit>().delete(_saved),
      ),
    );
  }

  void _onState(BuildContext context, WorkspaceFormState state) {
    if (state is WorkspaceFormProcessInProgressState) {
      app.loading.show(id: WorkspaceSettings.loadingId);
    } else {
      app.loading.hide(id: WorkspaceSettings.loadingId);
    }
    if (state is WorkspaceFormProcessingErrorState) {
      setState(() {
        _serverErrors = state.fieldErrors;
        _formError = state.fieldErrors.isEmpty ? state.exception.message : null;
        if (_serverErrors.keys.any((k) => k.startsWith('defaults.'))) {
          _tab = _Tab.defaults;
        } else if (_serverErrors.isNotEmpty) {
          _tab = _Tab.general;
        }
      });
    }
    if (state is WorkspaceFormProcessingOKState) {
      app.di.find<WorkspaceCubit>().load();
      if (state.deleted) {
        Navigator.of(context).pop();
        app.snack.showSuccess(
          message: app.intl.workspaces.settings.deleted(name: _saved.name),
          context: app.context,
        );
        return;
      }
      _savedTimer?.cancel();
      _savedTimer = Timer(const Duration(milliseconds: 2500), () {
        if (mounted) setState(() => _justSaved = false);
      });
      setState(() {
        _saved = state.workspace;
        _reset();
        _justSaved = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 16,
              children: [
                if (_formError != null) AppFormAlert(title: _formError!),
                ...switch (_tab) {
                  _Tab.general when _editing => _buildEdit(),
                  _Tab.general => _buildGeneral(),
                  _Tab.defaults => _buildDefaults(),
                  _Tab.danger => [_buildDanger()],
                },
              ],
            ),
          ),
        ),
        _buildFooter(),
      ],
    );
    return BlocListener<WorkspaceFormCubit, WorkspaceFormState>(
      listener: _onState,
      child: Align(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
          child: AppDialogFrame(
            color: app.colors.primary.backgroundForm,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 880, maxHeight: 680),
              child: SizedBox.expand(
                child: LoadingOverlay(
                  id: WorkspaceSettings.loadingId,
                  overlayWidgetBuilder: LoadingOverlayStyles.form,
                  child: content,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final colors = app.colors;
    final t = app.intl.workspaces.settings;
    final description = _description.text.trim();
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      decoration: BoxDecoration(
        color: colors.primary.background2,
        border: Border(
          bottom: BorderSide(
            color: colors.neutral.grey5.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: [
          Row(
            children: [
              WorkspaceAvatar(
                initial: WorkspaceModel(
                  slug: '',
                  name: _name.text.trim(),
                ).initial,
                color: _color,
                size: 48,
              ),
              14.gap(),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    Text(
                      t.title.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w700,
                        color: colors.primary.primaryFaded,
                      ),
                    ),
                    Text(
                      _name.text.trim(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 22,
                        height: 28 / 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (description.isNotEmpty)
                      Text(
                        description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: colors.neutral.grey3,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            spacing: 24,
            children: [
              for (final tab in _Tab.values)
                _TabButton(
                  label: switch (tab) {
                    _Tab.general => t.general,
                    _Tab.defaults => t.defaults,
                    _Tab.danger => t.danger,
                  },
                  selected: _tab == tab,
                  danger: tab == _Tab.danger,
                  onTap: () => setState(() => _tab = tab),
                ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildGeneral() {
    final t = app.intl.workspaces.settings;
    final stats = widget.workspace.stats;
    final created = _saved.createdAt;
    final description = _saved.description;
    return [
      Row(
        spacing: 12,
        children: [
          DetailStat(app.intl.workspaces.sources, '${stats?.sources ?? 0}', ''),
          DetailStat(
            app.intl.workspaces.destinations,
            '${stats?.destinations ?? 0}',
            '',
          ),
          DetailStat(app.intl.workspaces.backups, '${stats?.configs ?? 0}', ''),
          DetailStat(
            t.created,
            created == null
                ? '—'
                : app.dateFormatter.m.format(created.toLocal()),
            '',
          ),
        ],
      ),
      DetailPanel(
        child: Column(
          children: [
            _InfoRow(
              label: app.intl.workspaces.name,
              child: Text(
                _saved.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            _InfoRow(
              label: t.id,
              child: _SlugChip(slug: _saved.slug),
            ),
            _InfoRow(
              label: app.intl.workspaces.descriptionLabel,
              child: Text(
                description == null || description.isEmpty
                    ? t.noDescription
                    : description,
                style: TextStyle(
                  fontSize: 14,
                  color: description == null || description.isEmpty
                      ? app.colors.neutral.grey4
                      : null,
                ),
              ),
            ),
            _InfoRow(
              label: app.intl.workspaces.color,
              last: true,
              child: Row(
                spacing: 8,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _saved.color ?? app.colors.palette.violet,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Text(
                    (_saved.color ?? app.colors.palette.violet).toHex(),
                    style: AppText.mono.copyWith(fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _buildEdit() {
    return [
      AppFormInput(
        controller: _name,
        label: app.intl.workspaces.name,
        hint: app.intl.workspaces.nameHint,
        autofocus: true,
        maxLength: _nameMaxLength,
        errorText: _submitted ? _nameError : null,
        onChange: (_) => _touch(WorkspaceFormField.name),
        onSubmitted: (_) => _save(),
      ),
      AppFormInput(
        controller: _description,
        label:
            '${app.intl.workspaces.descriptionLabel} ${app.intl.common.optional}',
        hint: app.intl.workspaces.descriptionHint,
        maxLength: _descriptionMaxLength,
        errorText: _serverErrors[WorkspaceFormField.description],
        onChange: (_) => _touch(WorkspaceFormField.description),
        onSubmitted: (_) => _save(),
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          _Label(app.intl.workspaces.color),
          AppColorPicker(
            value: _color,
            allowNone: false,
            contrastAgainst: app.colors.neutral.white,
            onChanged: (color) {
              _color = color;
              _touch();
            },
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildDefaults() {
    final t = app.intl.workspaces.settings;
    final cron = _cron.text.trim();
    return [
      Text(
        t.defaultsHint,
        style: TextStyle(fontSize: 13, color: app.colors.neutral.grey3),
      ),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 6,
              children: [
                _Label(t.schedule),
                AppSegmented<Frequency>(
                  values: Frequency.values,
                  labelOf: (f) => f.label,
                  value: Frequency.of(cron),
                  onChanged: (f) {
                    if (f == Frequency.cron) return;
                    _cron.text = Frequency.apply(f, cron)!;
                    _touch(WorkspaceFormField.schedule);
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 6,
              children: [
                _Label(t.compression),
                AppSegmented<String>(
                  values: ConfigRules.compressions,
                  labelOf: (v) => v == 'gzip' ? 'gzip' : t.compressionNone,
                  value: _compression,
                  onChanged: (v) {
                    _compression = v;
                    _touch(WorkspaceFormField.compression);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      AppFormInput(
        controller: _cron,
        label: t.cron,
        helperText: t.cronHelp,
        errorText: _cronError,
        onChange: (_) => _touch(WorkspaceFormField.schedule),
        onSubmitted: (_) => _save(),
      ),
      AppFormInput(
        controller: _objectKey,
        label: t.objectKey,
        helperText: t.objectKeyHelp,
        maxLength: ConfigRules.maxObjectKeyLength,
        errorText: _objectKeyError,
        onChange: (_) => _touch(WorkspaceFormField.objectKey),
        onSubmitted: (_) => _save(),
      ),
    ];
  }

  Widget _buildDanger() {
    final t = app.intl.workspaces.settings;
    final error = app.colors.primary.error;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: error.withValues(alpha: 0.04),
        borderRadius: app.dimensions.border.borderRadius.m,
        border: Border.all(color: error.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Text(
                  t.deleteTitle,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  t.deleteDescription,
                  style: TextStyle(
                    fontSize: 13,
                    color: app.colors.neutral.grey3,
                  ),
                ),
              ],
            ),
          ),
          16.gap(),
          PrimaryButton.primary(
            onPressed: _askDelete,
            title: t.deleteButton,
            color: app.colors.primary.errorAction,
            h: 40,
            horizontalPadding: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    final colors = app.colors;
    final t = app.intl.workspaces.settings;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        color: colors.primary.background2,
        border: Border(
          top: BorderSide(color: colors.neutral.grey5.withValues(alpha: 0.5)),
        ),
      ),
      // as high with or without its buttons: the tabs don't move it
      constraints: const BoxConstraints(minHeight: 68),
      child: Row(
        spacing: 10,
        children: _dirty
            ? [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: colors.primary.secondary,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(t.unsaved, style: const TextStyle(fontSize: 13)),
                ),
                PrimaryButton.secondary(
                  onPressed: () => setState(_reset),
                  title: t.discard,
                  color: colors.primary.background3,
                  h: 40,
                  horizontalPadding: 16,
                ),
                PrimaryButton.primary(
                  onPressed: _save,
                  title: app.intl.common.saveChanges,
                  color: colors.primary.primaryAction,
                  h: 40,
                  horizontalPadding: 18,
                ),
              ]
            : [
                Expanded(
                  child: Text(
                    t.description,
                    style: TextStyle(fontSize: 12, color: colors.neutral.grey4),
                  ),
                ),
                if (_justSaved)
                  Row(
                    spacing: 6,
                    children: [
                      app.assets.icons.actions.check.build(
                        size: 16,
                        color: colors.status.success,
                      ),
                      Text(
                        t.saved,
                        style: TextStyle(
                          fontSize: 13,
                          color: colors.status.success,
                        ),
                      ),
                    ],
                  ),
                if (_tab == _Tab.general)
                  PrimaryButton.primary(
                    onPressed: () => setState(() => _editing = true),
                    title: app.intl.common.edit,
                    icon: app.assets.icons.actions.edit,
                    color: colors.primary.primaryAction,
                    h: 40,
                    horizontalPadding: 16,
                  ),
              ],
      ),
    );
  }
}

/// A tab of the header, underlined while [selected]; the danger one in red
class _TabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final bool danger;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.selected,
    required this.danger,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = app.colors;
    final line = danger ? colors.primary.error : colors.primary.primaryFaded;
    return Semantics(
      selected: selected,
      button: true,
      child: InkWell(
        onTap: onTap,
        mouseCursor: SystemMouseCursors.click,
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 2),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: selected ? line : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: selected
                  ? colors.neutral.white
                  : danger
                  ? colors.status.error
                  : colors.neutral.grey3,
            ),
          ),
        ),
      ),
    );
  }
}

/// Label on the left, value on the right, a line under it but the [last]
class _InfoRow extends StatelessWidget {
  final String label;
  final Widget child;
  final bool last;

  const _InfoRow({required this.label, required this.child, this.last = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 48),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: last
            ? null
            : Border(
                bottom: BorderSide(
                  color: app.colors.neutral.grey5.withValues(alpha: 0.5),
                ),
              ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 160,
            child: Text(
              label,
              style: TextStyle(fontSize: 13, color: app.colors.neutral.grey3),
            ),
          ),
          16.gap(),
          Expanded(
            child: Align(alignment: Alignment.centerLeft, child: child),
          ),
        ],
      ),
    );
  }
}

/// The slug in monospace and the button that copies it
class _SlugChip extends StatelessWidget {
  final String slug;

  const _SlugChip({required this.slug});

  @override
  Widget build(BuildContext context) {
    final t = app.intl.workspaces.settings;
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: app.colors.surface.control,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            slug,
            style: AppText.mono.copyWith(
              fontSize: 12,
              color: app.colors.neutral.grey2,
            ),
          ),
        ),
        PrimaryButton.svgIcon(
          icon: app.assets.icons.actions.duplicate,
          tooltipMessage: t.copyId,
          backgroundColor: app.colors.neutral.transparent,
          iconColor: app.colors.neutral.grey3,
          buttonSize: 30,
          iconSize: 14,
          onPressed: () {
            Clipboard.setData(ClipboardData(text: slug));
            app.snack.showSuccess(message: t.copied, context: app.context);
          },
        ),
      ],
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
      color: app.colors.neutral.grey2,
    ),
  );
}

/// Deleting asks for the name of the workspace, typed
class _DeleteDialog extends StatefulWidget {
  final WorkspaceModel workspace;
  final WorkspaceStatsModel? stats;
  final VoidCallback onConfirm;

  const _DeleteDialog({
    required this.workspace,
    required this.stats,
    required this.onConfirm,
  });

  @override
  State<_DeleteDialog> createState() => _DeleteDialogState();
}

class _DeleteDialogState extends State<_DeleteDialog> {
  final _typed = TextEditingController();

  @override
  void dispose() {
    _typed.dispose();
    super.dispose();
  }

  bool get _ok => _typed.text.trim() == widget.workspace.name;

  @override
  Widget build(BuildContext context) {
    final colors = app.colors;
    final t = app.intl.workspaces.settings;
    final stats = widget.stats;
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: AppDialogFrame(
        color: colors.primary.backgroundForm,
        child: SizedBox(
          width: 480,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 16,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 12,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: colors.primary.error.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: app.assets.icons.actions.warning.build(
                          size: 20,
                          color: colors.primary.error,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 4,
                        children: [
                          Text(
                            t.deleteConfirmTitle(name: widget.workspace.name),
                            style: const TextStyle(
                              fontSize: 18,
                              height: 26 / 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            t.deleteConfirm(
                              sources: stats?.sources ?? 0,
                              destinations: stats?.destinations ?? 0,
                              configs: stats?.configs ?? 0,
                            ),
                            style: TextStyle(
                              fontSize: 13,
                              color: colors.neutral.grey3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 6,
                  children: [
                    Text.rich(
                      TextSpan(
                        style: const TextStyle(fontSize: 13),
                        children: [
                          TextSpan(text: '${t.typeBefore} '),
                          TextSpan(
                            text: widget.workspace.name,
                            style: AppText.mono.copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          TextSpan(text: ' ${t.typeAfter}'),
                        ],
                      ),
                    ),
                    AppFormInput(
                      controller: _typed,
                      autofocus: true,
                      onChange: (_) => setState(() {}),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  spacing: 10,
                  children: [
                    PrimaryButton.secondary(
                      onPressed: () => Navigator.of(context).pop(),
                      title: app.intl.common.cancel,
                      color: colors.primary.background3,
                      h: 40,
                      w: 100,
                    ),
                    PrimaryButton.primary(
                      onPressed: _ok
                          ? () {
                              Navigator.of(context).pop();
                              widget.onConfirm();
                            }
                          : null,
                      title: t.deleteButton,
                      color: colors.primary.errorAction,
                      h: 40,
                      horizontalPadding: 16,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
