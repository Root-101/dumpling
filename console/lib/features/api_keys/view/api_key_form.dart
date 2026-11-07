import 'package:console/app_exporter.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

/// The form of a key: its name, a template and the permissions one by one, and
/// optionally the only configs it reaches. Creating it shows the key once
class ApiKeyForm extends StatefulWidget {
  /// Opens the form of [key], or of a new one
  static Future<void> open(ApiKeyCubit cubit, {ApiKeyModel? key}) {
    return showGeneralDialog(
      context: app.context,
      barrierDismissible: true,
      barrierLabel: app.intl.common.close,
      barrierColor: app.colors.neutral.black.withValues(alpha: 0.54),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) =>
          ApiKeyForm(cubit: cubit, apiKey: key),
      transitionBuilder: (context, animation, secondaryAnimation, child) =>
          FadeTransition(opacity: animation, child: child),
    );
  }

  final ApiKeyCubit cubit;

  /// Null for a new one
  final ApiKeyModel? apiKey;

  const ApiKeyForm({required this.cubit, this.apiKey, super.key});

  @override
  State<ApiKeyForm> createState() => _ApiKeyFormState();
}

class _ApiKeyFormState extends State<ApiKeyForm> {
  late final TextEditingController _name = TextEditingController(
    text: widget.apiKey?.name ?? '',
  );
  late bool _limit =
      (widget.apiKey?.limited ?? false) &&
      widget.apiKey!.permissions.any(ApiKeyPermissions.limitable.contains);
  late Set<String> _permissions = {
    ...?widget.apiKey?.permissions ??
        ApiKeyPermissions.templates[ApiKeyAccess.run],
  }..removeAll(_limit ? ApiKeyPermissions.notLimitable : const []);
  late final Set<String> _configs = {...?widget.apiKey?.configIds};

  bool get _editing => widget.apiKey != null;

  /// The limit only changes the configs and runs a key sees
  bool get _canLimit => _permissions.any(ApiKeyPermissions.limitable.contains);

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  bool get _valid =>
      _name.text.trim().isNotEmpty &&
      _permissions.isNotEmpty &&
      (!_limit || _configs.isNotEmpty);

  Future<void> _save() async {
    final draft = ApiKeyDraft(
      name: _name.text.trim(),
      // in the order the service lists them
      permissions: [
        for (final p in ApiKeyPermissions.all)
          if (_permissions.contains(p)) p,
      ],
      configIds: _limit ? _configs.toList() : const [],
    );
    final saved = await widget.cubit.save(draft, id: widget.apiKey?.id);
    if (saved == null || !mounted) return;
    Navigator.of(context).pop();
    if (saved.key != null) {
      await ApiKeyCreatedDialog.open(
        saved,
        workspace: widget.cubit.state.data.workspace!,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = app.intl.apiKeys;
    final colors = app.colors;
    final data = widget.cubit.state.data;
    final access = ApiKeyAccess.of(_permissions, limited: _limit);
    final label = TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: colors.text.primary,
    );
    return FormDialogTemplate(
      title: _editing ? t.editTitle(name: widget.apiKey!.name) : t.newTitle,
      width: 760,
      actions: [
        Expanded(
          child: Text(
            _limit
                ? t.summarySome(
                    configs: _configs.length,
                    n: _permissions.length,
                  )
                : t.summaryAll(n: _permissions.length),
            style: TextStyle(fontSize: 12, color: colors.neutral.grey4),
          ),
        ),
        PrimaryButton.secondary(
          onPressed: () => Navigator.of(context).pop(),
          title: app.intl.common.cancel,
          h: 40,
          horizontalPadding: 16,
        ),
        PrimaryButton.primary(
          onPressed: _valid ? _save : null,
          title: _editing ? t.save : t.createButton,
          color: colors.primary.primaryAction,
          h: 40,
          horizontalPadding: 20,
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 18,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 6,
            children: [
              Text(t.name, style: label),
              AppFormInput(
                controller: _name,
                autofocus: !_editing,
                maxLength: 64,
                onChange: (_) => setState(() {}),
              ),
              Text(
                t.nameHint,
                style: TextStyle(fontSize: 12, color: colors.neutral.grey4),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 8,
            children: [
              Text(t.access, style: label),
              Row(
                spacing: 10,
                children: [
                  for (final (template, sub) in [
                    (ApiKeyAccess.run, t.runSub),
                    (ApiKeyAccess.read, t.readSub),
                    (ApiKeyAccess.full, t.fullSub),
                  ])
                    Expanded(
                      child: _TemplateCard(
                        title: template.label,
                        subtitle: sub,
                        selected: access == template,
                        onTap: () => setState(
                          () => _permissions = {
                            ...ApiKeyPermissions.of(template, limited: _limit),
                          },
                        ),
                      ),
                    ),
                ],
              ),
              _PermissionGrid(
                selected: _permissions,
                custom: access == ApiKeyAccess.custom,
                locked: _limit ? ApiKeyPermissions.notLimitable : const [],
                onToggle: (key) => setState(() {
                  if (!_permissions.remove(key)) _permissions.add(key);
                  if (!_canLimit) _limit = false;
                }),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 8,
            children: [
              AppSwitchTile(
                title: t.limit,
                subtitle: _canLimit ? t.limitHint : t.limitOff,
                value: _limit,
                onChanged: _canLimit
                    ? () => setState(() {
                        _limit = !_limit;
                        if (_limit) {
                          _permissions.removeAll(
                            ApiKeyPermissions.notLimitable,
                          );
                        }
                      })
                    : null,
              ),
              if (_limit)
                data.configs.isEmpty
                    ? Text(
                        t.noConfigs,
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.neutral.grey4,
                        ),
                      )
                    : Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final config in data.configs)
                            _CheckChip(
                              label: config.name,
                              trailing: data.sourceNames[config.sourceId],
                              selected: _configs.contains(config.id),
                              onTap: () => setState(() {
                                if (!_configs.remove(config.id)) {
                                  _configs.add(config.id);
                                }
                              }),
                            ),
                        ],
                      ),
            ],
          ),
          if (_editing)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: colors.primary.primaryFaded.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                t.renewNote,
                style: TextStyle(
                  fontSize: 12,
                  color: colors.primary.primaryLight,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// A template of the form: its name, what it is for, and whether the
/// permissions are exactly its own
class _TemplateCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _TemplateCard({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = app.colors;
    return Semantics(
      selected: selected,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? colors.primary.primaryFaded.withValues(alpha: 0.14)
                : colors.primary.background2,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected
                  ? colors.primary.primaryFaded
                  : colors.neutral.grey5,
            ),
          ),
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
                subtitle,
                style: TextStyle(fontSize: 12, color: colors.neutral.grey3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Every permission a key can have, by resource, each with a tooltip of what
/// it allows
class _PermissionGrid extends StatelessWidget {
  final Set<String> selected;
  final bool custom;

  /// Off and disabled: what a key limited to some configs can't have
  final List<String> locked;
  final void Function(String key) onToggle;

  const _PermissionGrid({
    required this.selected,
    required this.custom,
    required this.locked,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final t = app.intl.apiKeys;
    final colors = app.colors;
    final groups = ApiKeyPermissions.groups;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colors.primary.background2,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.neutral.grey5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 10,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  t.permissions(
                    n: selected.length,
                    total: ApiKeyPermissions.all.length,
                  ),
                  style: TextStyle(fontSize: 12, color: colors.neutral.grey3),
                ),
              ),
              if (custom)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: colors.primary.secondary.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    t.custom,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: colors.primary.secondary,
                    ),
                  ),
                ),
            ],
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              const gap = 16.0;
              final width = (constraints.maxWidth - 2 * gap) / 3;
              return Wrap(
                spacing: gap,
                runSpacing: 12,
                children: [
                  for (final (title, permissions) in groups)
                    SizedBox(
                      width: width,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 2,
                        children: [
                          Text(title, style: AppText.overline),
                          Wrap(
                            spacing: 12,
                            runSpacing: 4,
                            children: [
                              for (final p in permissions)
                                Tooltip(
                                  message: locked.contains(p.key)
                                      ? t.notLimitable
                                      : '${p.description} (${p.key})',
                                  child: _CheckLabel(
                                    label: p.label,
                                    selected: selected.contains(p.key),
                                    onTap: locked.contains(p.key)
                                        ? null
                                        : () => onToggle(p.key),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

/// A box and its word, as a checkbox; dimmed without [onTap]
class _CheckLabel extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const _CheckLabel({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = app.colors;
    return Semantics(
      checked: selected,
      button: true,
      enabled: onTap != null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Opacity(
          opacity: onTap == null ? 0.4 : 1,
          child: SizedBox(
            height: 26,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 6,
              children: [
                _CheckBox(selected: selected),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: selected
                        ? colors.text.primary
                        : colors.neutral.grey3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CheckBox extends StatelessWidget {
  final bool selected;

  const _CheckBox({required this.selected});

  @override
  Widget build(BuildContext context) {
    final colors = app.colors;
    return Container(
      width: 16,
      height: 16,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected ? colors.primary.primaryAction : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: selected ? colors.primary.primaryFaded : colors.neutral.grey4,
        ),
      ),
      child: selected
          ? app.assets.icons.actions.check.build(
              size: 11,
              color: colors.neutral.white,
            )
          : null,
    );
  }
}

/// A config to limit the key to: its name, the source it dumps and a box
class _CheckChip extends StatelessWidget {
  final String label;
  final String? trailing;
  final bool selected;
  final VoidCallback onTap;

  const _CheckChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final colors = app.colors;
    return Semantics(
      checked: selected,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: selected
                ? colors.primary.primaryFaded.withValues(alpha: 0.14)
                : colors.primary.background2,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected
                  ? colors.primary.primaryFaded
                  : colors.neutral.grey5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 8,
            children: [
              _CheckBox(selected: selected),
              Text(label, style: const TextStyle(fontSize: 13)),
              if (trailing != null)
                Text(
                  trailing!,
                  style: AppText.mono.copyWith(
                    fontSize: 11,
                    color: colors.neutral.grey4,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The key just created, the only time it is shown: copy it, and how to use it
class ApiKeyCreatedDialog extends StatefulWidget {
  static Future<void> open(ApiKeyModel key, {required String workspace}) =>
      app.dialog.open(
        dialog: ApiKeyCreatedDialog(apiKey: key, workspace: workspace),
      );

  final ApiKeyModel apiKey;
  final String workspace;

  const ApiKeyCreatedDialog({
    required this.apiKey,
    required this.workspace,
    super.key,
  });

  @override
  State<ApiKeyCreatedDialog> createState() => _ApiKeyCreatedDialogState();
}

class _ApiKeyCreatedDialogState extends State<ApiKeyCreatedDialog> {
  bool _copied = false;

  @override
  Widget build(BuildContext context) {
    final t = app.intl.apiKeys;
    final colors = app.colors;
    final key = widget.apiKey;
    final text = key.key!;
    final example =
        'curl -X POST ${Environment.serviceUrl}/api/workspaces/${widget.workspace}/configs/CONFIG_ID/run \\\n'
        '  -H "Authorization: Bearer \$DUMPLING_KEY" -d \'{"label": "v1.4.2"}\'';
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: AppDialogFrame(
        color: colors.primary.backgroundForm,
        child: SizedBox(
          width: 680,
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
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: colors.status.success.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: app.assets.icons.actions.check.build(
                        size: 20,
                        color: colors.status.success,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 4,
                        children: [
                          Text(
                            t.readyTitle(name: key.name),
                            style: const TextStyle(
                              fontSize: 18,
                              height: 26 / 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            t.readyWarning,
                            style: TextStyle(
                              fontSize: 13,
                              color: colors.primary.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
                  decoration: BoxDecoration(
                    color: colors.primary.background2,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: colors.primary.primaryFaded),
                  ),
                  child: Row(
                    spacing: 8,
                    children: [
                      Expanded(
                        child: SelectableText(
                          text,
                          style: AppText.mono.copyWith(fontSize: 13),
                        ),
                      ),
                      PrimaryButton.primary(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: text));
                          setState(() => _copied = true);
                        },
                        title: _copied ? t.copied : t.copy,
                        color: colors.primary.primaryAction,
                        h: 34,
                        horizontalPadding: 12,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 8,
                  children: [
                    Text(
                      t.use,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: colors.surface.background,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: colors.surface.control),
                      ),
                      child: SelectableText(
                        example,
                        style: AppText.mono.copyWith(
                          fontSize: 12,
                          height: 18 / 12,
                          color: colors.primary.primaryLight,
                        ),
                      ),
                    ),
                    Text(
                      t.basicNote(id: key.id),
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.neutral.grey4,
                      ),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: PrimaryButton.secondary(
                    onPressed: () => Navigator.of(context).pop(),
                    title: t.done,
                    h: 40,
                    horizontalPadding: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
