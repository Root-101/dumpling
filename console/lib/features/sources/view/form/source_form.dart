import 'package:console/app_exporter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

/// Drawer of a source: its type, how it connects (fields or a connection URL)
/// and the test of that connection, always run by the service. Once saved it
/// reloads the list
class SourceForm extends StatefulWidget {
  /// Opens the drawer with its own [SourceFormCubit]. With [source] it edits
  /// it; with [duplicate] too it creates a copy (the password isn't copied:
  /// the API never returns it)
  static Future<void> open(
    BuildContext context, {
    required String workspace,
    required List<SourceTypeModel> types,
    SourceModel? source,
    bool duplicate = false,
  }) async {
    final editing = source != null && !duplicate;
    final formKey = GlobalKey<_SourceFormState>();
    final formCubit = SourceFormCubit(
      app.di.find(),
      app.di.find(),
      workspace: workspace,
      sourceId: editing ? source.id : null,
    );

    await FormDrawerTemplate.showAsDialog(
      context: context,
      title: editing ? app.intl.sources.editTitle : app.intl.sources.newTitle,
      description: app.intl.sources.formDescription,
      icon: app.assets.icons.nodes.database,
      loadingId: loadingId,
      footerActions: [
        PrimaryButton.secondary(
          onPressed: () => Navigator.of(context).pop(),
          title: app.intl.common.cancel,
          h: 40,
          w: 100,
        ),
        BlocProvider.value(
          value: formCubit,
          child: _SaveButton(
            editing: editing,
            onPressed: () => formKey.currentState?.submit(),
          ),
        ),
      ],
      child: BlocProvider.value(
        value: formCubit,
        child: SourceForm(
          key: formKey,
          types: types,
          source: source,
          duplicate: duplicate,
        ),
      ),
    );
    await formCubit.close();
  }

  /// Id of the drawer's [LoadingOverlay]
  static const String loadingId = 'source-form';

  final List<SourceTypeModel> types;
  final SourceModel? source;
  final bool duplicate;

  const SourceForm({
    required this.types,
    this.source,
    this.duplicate = false,
    super.key,
  });

  @override
  State<SourceForm> createState() => _SourceFormState();
}

class _SourceFormState extends State<SourceForm> {
  static const int _nameMaxLength = 64;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _urlController = TextEditingController();
  final _hostController = TextEditingController();
  final _portController = TextEditingController();
  final _databaseController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  late String _type;
  bool _byUrl = false;
  String _dumpFormat = PostgresSettingsModel.custom;

  /// What the last test of the form found; any change clears it
  ConnectionCheckModel? _check;

  /// After the first submit attempt it validates on every change
  bool _submitted = false;

  /// API errors per field; cleared when that field is edited
  Map<String, String> _serverErrors = const {};

  /// API error that doesn't belong to a field
  String? _formError;

  late final SourceFormCubit cubit = context.read<SourceFormCubit>();

  bool get _editing => widget.source != null && !widget.duplicate;

  @override
  void initState() {
    super.initState();
    final source = widget.source;
    _type =
        source?.type ??
        widget.types.where((t) => t.enabled).firstOrNull?.type ??
        SourceTypes.postgres;
    final pg = source?.postgres;
    if (source != null) {
      _nameController.text = widget.duplicate
          ? app.intl.sources.copyName(name: source.name)
          : source.name;
    }
    if (pg != null) {
      _hostController.text = pg.host;
      _portController.text = '${pg.port}';
      _databaseController.text = pg.database;
      _usernameController.text = pg.username;
      _dumpFormat = pg.dumpFormat;
    }
  }

  @override
  void dispose() {
    for (final controller in [
      _nameController,
      _urlController,
      _hostController,
      _portController,
      _databaseController,
      _usernameController,
      _passwordController,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  SourceDraft _draft() => SourceDraft(
    name: _nameController.text.trim(),
    type: _type,
    connectionUrl: _byUrl ? _urlController.text.trim() : null,
    host: _hostController.text.trim(),
    port: int.tryParse(_portController.text.trim()),
    database: _databaseController.text.trim(),
    username: _usernameController.text.trim(),
    password: _byUrl ? null : _passwordController.text,
    dumpFormat: _dumpFormat,
  );

  bool _validate() {
    if (!_submitted) setState(() => _submitted = true);
    return _formKey.currentState?.validate() ?? false;
  }

  bool get _busy =>
      cubit.state is SourceFormProcessInProgressState ||
      cubit.state is SourceFormTestInProgressState;

  void submit() {
    if (_busy || !_validate()) return;
    cubit.save(_draft());
  }

  void _test() {
    if (_busy || !_validate()) return;
    cubit.test(_draft());
  }

  /// A change makes the last test stale and clears the API error of [field]
  void _changed(String field) {
    setState(() {
      _check = null;
      if (_serverErrors.containsKey(field)) {
        _serverErrors = {..._serverErrors}..remove(field);
      }
    });
  }

  String? _required(String? v) =>
      v == null || v.trim().isEmpty ? app.intl.common.required : null;

  @override
  Widget build(BuildContext context) {
    return BlocListener<SourceFormCubit, SourceFormState>(
      listener: (context, state) {
        if (state is SourceFormProcessInProgressState) {
          app.loading.show(id: SourceForm.loadingId);
        } else {
          app.loading.hide(id: SourceForm.loadingId);
        }
        if (state is SourceFormTestedState) {
          setState(() {
            _check = state.check;
            _formError = null;
          });
        }
        if (state is SourceFormProcessingErrorState) {
          setState(() {
            _serverErrors = state.fieldErrors;
            _formError = state.fieldErrors.isEmpty
                ? state.exception.message
                : null;
          });
        }
        if (state is SourceFormProcessingOKState) {
          Navigator.of(context).pop();
          app.di.find<SourceCubit>().reload();
          app.snack.showSuccess(
            message: _editing
                ? app.intl.sources.saved(name: state.source.name)
                : app.intl.sources.created(name: state.source.name),
            context: app.context,
          );
        }
      },
      child: Form(
        key: _formKey,
        autovalidateMode: _submitted
            ? AutovalidateMode.always
            : AutovalidateMode.disabled,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_formError != null) ...[
              AppFormAlert(title: _formError!),
              app.dimensions.padding.l.gap(),
            ],
            FormSectionTitle(app.intl.sources.sectionType),
            app.dimensions.padding.m.gap(),
            _buildTypes(),
            if (_type == SourceTypes.postgres) ...[
              app.dimensions.padding.xxl.gap(),
              FormSectionTitle(app.intl.sources.sectionConnection),
              app.dimensions.padding.m.gap(),
              ..._buildPostgres(),
              app.dimensions.padding.xxl.gap(),
              BlocBuilder<SourceFormCubit, SourceFormState>(
                builder: (context, state) => ConnectionTestBanner(
                  check: _check,
                  testing: state is SourceFormTestInProgressState,
                  onTest: _test,
                  idleSub: app.intl.sources.testIdle,
                  connectedSub: (check) => [
                    app.intl.sources.connectedAs(
                      user: _byUrl
                          ? _urlParts()?.username ?? ''
                          : _usernameController.text.trim(),
                    ),
                    if (check.serverVersion != null)
                      'PostgreSQL ${check.serverVersion}',
                    ?check.toolVersion,
                  ].join(' · '),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTypes() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final gap = app.dimensions.padding.sm;
        final width = (constraints.maxWidth - 2 * gap) / 3;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final type in widget.types)
              SizedBox(
                width: width,
                child: TypeTile(
                  look: SourceTypeLook.lookOf(type.type),
                  label: SourceTypeLook.labelOf(type.type),
                  sub: SourceTypeLook.toolOf(type.type),
                  selected: type.type == _type,
                  // a saved source of a type no longer available keeps it
                  enabled: type.enabled || type.type == widget.source?.type,
                  onTap: () {
                    if (type.type == _type) return;
                    setState(() => _type = type.type);
                    _changed(SourceFormField.type);
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  List<Widget> _buildPostgres() {
    final gap = app.dimensions.padding.sm;
    return [
      AppFormInput(
        controller: _nameController,
        label: app.intl.sources.name,
        hint: app.intl.sources.nameHint,
        autofocus: !_editing,
        maxLength: _nameMaxLength,
        errorText: _serverErrors[SourceFormField.name],
        validator: _required,
        onChange: (_) => _changed(SourceFormField.name),
        onSubmitted: (_) => submit(),
      ),
      app.dimensions.padding.l.gap(),
      _label(app.intl.sources.connectWith),
      app.dimensions.padding.s.gap(),
      _Segmented(
        options: [app.intl.sources.byFields, app.intl.sources.byUrl],
        selected: _byUrl ? 1 : 0,
        onChanged: (index) {
          setState(() => _byUrl = index == 1);
          _changed(SourceFormField.connectionUrl);
        },
      ),
      app.dimensions.padding.l.gap(),
      if (_byUrl)
        ..._buildUrl()
      else ...[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: AppFormInput(
                controller: _hostController,
                label: app.intl.sources.host,
                hint: 'pg-prod-01.internal',
                errorText: _serverErrors[SourceFormField.host],
                validator: _required,
                onChange: (_) => _changed(SourceFormField.host),
                onSubmitted: (_) => submit(),
              ),
            ),
            gap.gap(),
            Expanded(
              child: AppFormInput(
                controller: _portController,
                label: app.intl.sources.port,
                hint: '${PostgresSettingsModel.defaultPort}',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                errorText: _serverErrors[SourceFormField.port],
                validator: (v) {
                  final port = int.tryParse(v?.trim() ?? '');
                  return v == null ||
                          v.trim().isEmpty ||
                          (port != null && port >= 1 && port <= 65535)
                      ? null
                      : app.intl.sources.portInvalid;
                },
                onChange: (_) => _changed(SourceFormField.port),
                onSubmitted: (_) => submit(),
              ),
            ),
          ],
        ),
        app.dimensions.padding.l.gap(),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AppFormInput(
                controller: _databaseController,
                label: app.intl.sources.database,
                hint: 'orders',
                errorText: _serverErrors[SourceFormField.database],
                validator: _required,
                onChange: (_) => _changed(SourceFormField.database),
                onSubmitted: (_) => submit(),
              ),
            ),
            gap.gap(),
            Expanded(
              child: AppFormInput(
                controller: _usernameController,
                label: app.intl.sources.username,
                hint: 'dumpling_backup',
                errorText: _serverErrors[SourceFormField.username],
                validator: _required,
                onChange: (_) => _changed(SourceFormField.username),
                onSubmitted: (_) => submit(),
              ),
            ),
          ],
        ),
        app.dimensions.padding.l.gap(),
        AppFormPasswordInput(
          controller: _passwordController,
          label: app.intl.sources.password,
          hint: _editing ? app.intl.sources.passwordKeepHint : null,
          helperText: app.intl.sources.passwordHelp,
          errorText: _serverErrors[SourceFormField.password],
          // editing, an empty one keeps the saved password
          validator: _editing ? null : _required,
          onChange: (_) => _changed(SourceFormField.password),
          onSubmitted: (_) => submit(),
        ),
      ],
      app.dimensions.padding.l.gap(),
      _label(app.intl.sources.dumpFormat),
      app.dimensions.padding.s.gap(),
      _Segmented(
        options: [app.intl.sources.formatCustom, app.intl.sources.formatPlain],
        selected: _dumpFormat == PostgresSettingsModel.plain ? 1 : 0,
        onChanged: (index) {
          setState(
            () => _dumpFormat = index == 1
                ? PostgresSettingsModel.plain
                : PostgresSettingsModel.custom,
          );
          _changed(SourceFormField.dumpFormat);
        },
      ),
      if (_serverErrors[SourceFormField.dumpFormat] case final error?)
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            error,
            style: TextStyle(fontSize: 12, color: app.colors.primary.error),
          ),
        ),
    ];
  }

  List<Widget> _buildUrl() {
    final parts = _urlParts();
    final empty = _urlController.text.trim().isEmpty;
    return [
      AppFormInput(
        controller: _urlController,
        label: app.intl.sources.connectionUrl,
        hint: 'postgresql://user:password@host:5432/database',
        obscureText: false,
        errorText: _serverErrors[SourceFormField.connectionUrl],
        helperText: parts != null || empty
            ? (_editing
                  ? app.intl.sources.urlHelpEditing
                  : app.intl.sources.urlHelp)
            : null,
        validator: (v) =>
            _required(v) ??
            (_urlParts() == null ? app.intl.sources.urlInvalid : null),
        onChange: (_) => _changed(SourceFormField.connectionUrl),
        onSubmitted: (_) => submit(),
      ),
      if (parts != null) ...[
        app.dimensions.padding.m.gap(),
        Row(
          children: [
            for (final (index, (label, value)) in [
              (app.intl.sources.host, parts.host),
              (app.intl.sources.port, '${parts.port}'),
              (app.intl.sources.database, parts.database ?? '—'),
              (app.intl.sources.username, parts.username ?? '—'),
            ].indexed) ...[
              if (index > 0) app.dimensions.padding.s.gap(),
              Expanded(
                child: _UrlPart(label: label, value: value),
              ),
            ],
          ],
        ),
      ],
    ];
  }

  /// The URL read like the service does, without the password; null when it
  /// isn't a PostgreSQL one
  ({String host, int port, String? database, String? username})? _urlParts() {
    final uri = Uri.tryParse(_urlController.text.trim());
    if (uri == null ||
        !const ['postgresql', 'postgres'].contains(uri.scheme) ||
        uri.host.isEmpty) {
      return null;
    }
    String? part(String value) {
      if (value.isEmpty) return null;
      try {
        return Uri.decodeComponent(value);
      } catch (_) {
        return value;
      }
    }

    final colon = uri.userInfo.indexOf(':');
    return (
      host: uri.host,
      port: uri.hasPort ? uri.port : PostgresSettingsModel.defaultPort,
      database: part(uri.path.replaceFirst('/', '')),
      username: part(
        colon < 0 ? uri.userInfo : uri.userInfo.substring(0, colon),
      ),
    );
  }

  Widget _label(String text) => Text(
    text,
    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
  );
}

/// Two or more choices in one control, like *Fields · Connection URL*
class _Segmented extends StatelessWidget {
  final List<String> options;
  final int selected;
  final ValueChanged<int> onChanged;

  const _Segmented({
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(7);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: app.colors.surface.control,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          for (final (index, option) in options.indexed) ...[
            if (index > 0) const SizedBox(width: 4),
            Expanded(
              child: Semantics(
                inMutuallyExclusiveGroup: true,
                checked: index == selected,
                child: Material(
                  color: index == selected
                      ? app.colors.primary.purple
                      : app.colors.neutral.transparent,
                  borderRadius: radius,
                  child: InkWell(
                    borderRadius: radius,
                    onTap: index == selected ? null : () => onChanged(index),
                    child: SizedBox(
                      height: 34,
                      child: Center(
                        child: Text(
                          option,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: index == selected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: index == selected
                                ? app.colors.neutral.white
                                : app.colors.neutral.grey3,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// A part read from the connection URL: *Host · pg-billing.internal*
class _UrlPart extends StatelessWidget {
  final String label;
  final String value;

  const _UrlPart({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: app.colors.primary.background2,
        borderRadius: app.dimensions.border.borderRadius.s,
        border: Border.all(
          color: app.colors.neutral.grey5.withValues(alpha: 0.7),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 11, color: app.colors.neutral.grey4),
          ),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: AppText.monoFamily,
              fontSize: 12,
              color: app.colors.neutral.grey2,
            ),
          ),
        ],
      ),
    );
  }
}

/// *Create source* / *Save changes*, disabled while it is being saved
class _SaveButton extends StatelessWidget {
  final bool editing;
  final VoidCallback onPressed;

  const _SaveButton({required this.editing, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SourceFormCubit, SourceFormState>(
      builder: (context, state) {
        final loading = state is SourceFormProcessInProgressState;
        return PrimaryButton.primary(
          onPressed: state is SourceFormTestInProgressState ? null : onPressed,
          isLoading: loading,
          title: loading
              ? app.intl.common.saving
              : editing
              ? app.intl.common.saveChanges
              : app.intl.sources.createButton,
          color: app.colors.primary.primaryAction,
          h: 40,
          w: 160,
        );
      },
    );
  }
}
