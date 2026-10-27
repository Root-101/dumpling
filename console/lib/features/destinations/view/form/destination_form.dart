import 'package:console/app_exporter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

/// Dialog of a destination in three steps: its type, the connection, and its
/// folders with the test of that connection (always run by the service). Once
/// saved it reloads the list
class DestinationForm extends StatefulWidget {
  /// Opens the dialog with its own [DestinationFormCubit]. With [destination]
  /// it edits it; with [duplicate] too it creates a copy (the secret key isn't
  /// copied: the API never returns it). [folderUsage] locks the folders a
  /// backup writes to
  static Future<void> open(
    BuildContext context, {
    required String workspace,
    required List<DestinationTypeModel> types,
    DestinationModel? destination,
    bool duplicate = false,
    Map<String?, int> folderUsage = const {},
  }) async {
    final editing = destination != null && !duplicate;
    final formCubit = DestinationFormCubit(
      app.di.find(),
      app.di.find(),
      workspace: workspace,
      destinationId: editing ? destination.id : null,
    );

    await StepsDialogTemplate.show(
      context: context,
      dialog: BlocProvider.value(
        value: formCubit,
        child: DestinationForm(
          types: types,
          destination: destination,
          duplicate: duplicate,
          folderUsage: editing ? folderUsage : const {},
        ),
      ),
    );
    await formCubit.close();
  }

  /// Id of the dialog's [LoadingOverlay]
  static const String loadingId = 'destination-form';

  final List<DestinationTypeModel> types;
  final DestinationModel? destination;
  final bool duplicate;
  final Map<String?, int> folderUsage;

  const DestinationForm({
    required this.types,
    this.destination,
    this.duplicate = false,
    this.folderUsage = const {},
    super.key,
  });

  @override
  State<DestinationForm> createState() => _DestinationFormState();
}

class _DestinationFormState extends State<DestinationForm> {
  static const int _nameMaxLength = 64;
  static const int _maxFolders = 50;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _endpointController = TextEditingController();
  final _bucketController = TextEditingController();
  final _regionController = TextEditingController();
  final _accessKeyController = TextEditingController();
  final _secretController = TextEditingController();
  final _folderController = TextEditingController();

  /// 0: type, 1: connection, 2: folders and the test
  int _step = 0;

  late String _type;
  bool _pathStyle = false;
  List<String> _folders = [];
  String? _folderError;

  /// What the last test of the form found; any change clears it
  ConnectionCheckModel? _check;

  /// After the first submit attempt it validates on every change
  bool _submitted = false;

  /// API errors per field; cleared when that field is edited
  Map<String, String> _serverErrors = const {};

  /// API error that doesn't belong to a field
  String? _formError;

  late final DestinationFormCubit cubit = context.read<DestinationFormCubit>();

  bool get _editing => widget.destination != null && !widget.duplicate;

  @override
  void initState() {
    super.initState();
    final destination = widget.destination;
    _type =
        destination?.type ??
        widget.types.where((t) => t.enabled).firstOrNull?.type ??
        DestinationTypes.s3;
    if (destination != null) {
      _nameController.text = widget.duplicate
          ? app.intl.destinations.copyName(name: destination.name)
          : destination.name;
      _folders = [...destination.folders];
    }
    final s3 = destination?.s3;
    if (s3 != null) {
      _endpointController.text = s3.endpoint;
      _bucketController.text = s3.bucket;
      _regionController.text = s3.region;
      _accessKeyController.text = s3.accessKeyId;
      _pathStyle = s3.pathStyle;
    }
  }

  @override
  void dispose() {
    for (final controller in [
      _nameController,
      _endpointController,
      _bucketController,
      _regionController,
      _accessKeyController,
      _secretController,
      _folderController,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  DestinationDraft _draft() => DestinationDraft(
    name: _nameController.text.trim(),
    type: _type,
    endpoint: _endpointController.text.trim(),
    region: _regionController.text.trim(),
    bucket: _bucketController.text.trim(),
    accessKeyId: _accessKeyController.text.trim(),
    secretKey: _secretController.text,
    pathStyle: _pathStyle,
    folders: _folders,
  );

  bool _validate() {
    if (!_submitted) setState(() => _submitted = true);
    return _formKey.currentState?.validate() ?? false;
  }

  bool get _busy =>
      cubit.state is DestinationFormProcessInProgressState ||
      cubit.state is DestinationFormTestInProgressState;

  /// The fields of the connection step; an error of the service in one of
  /// them takes the form back there
  static const Set<String> _connectionFields = {
    DestinationFormField.name,
    DestinationFormField.endpoint,
    DestinationFormField.region,
    DestinationFormField.bucket,
    DestinationFormField.accessKeyId,
    DestinationFormField.secretKey,
    'settings.path_style',
  };

  static const int _lastStep = 2;

  /// *Next* checks the fields of the step on screen; on the last one it saves
  void _next() {
    if (_busy || !_validate()) return;
    if (_step == _lastStep) {
      cubit.save(_draft());
      return;
    }
    setState(() {
      _step++;
      // the next step validates once its own Next is pressed
      _submitted = false;
    });
  }

  void _back() {
    if (_step == 0) {
      Navigator.of(context).pop();
      return;
    }
    setState(() => _step--);
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

  void _addFolder() {
    final path = FolderPath.clean(_folderController.text);
    final error = path.isEmpty
        ? app.intl.destinations.folderEmpty
        : !FolderPath.isValid(path)
        ? app.intl.destinations.folderInvalid
        : _folders.contains(path)
        ? app.intl.destinations.folderRepeated
        : null;
    setState(() => _folderError = error);
    if (error != null || _folders.length >= _maxFolders) return;
    _folderController.clear();
    setState(() => _folders = [..._folders, path]);
    _changed(DestinationFormField.folders);
  }

  void _removeFolder(String path) {
    setState(() => _folders = _folders.where((f) => f != path).toList());
    _changed(DestinationFormField.folders);
  }

  String? _required(String? v) =>
      v == null || v.trim().isEmpty ? app.intl.common.required : null;

  @override
  Widget build(BuildContext context) {
    return BlocListener<DestinationFormCubit, DestinationFormState>(
      listener: (context, state) {
        if (state is DestinationFormProcessInProgressState) {
          app.loading.show(id: DestinationForm.loadingId);
        } else {
          app.loading.hide(id: DestinationForm.loadingId);
        }
        if (state is DestinationFormTestedState) {
          setState(() {
            _check = state.check;
            _formError = null;
          });
        }
        if (state is DestinationFormProcessingErrorState) {
          setState(() {
            _serverErrors = state.fieldErrors;
            _formError = state.fieldErrors.isEmpty
                ? state.exception.message
                : null;
            final fields = state.fieldErrors.keys;
            if (fields.contains(DestinationFormField.type)) {
              _step = 0;
            } else if (fields.any(_connectionFields.contains)) {
              _step = 1;
            }
          });
        }
        if (state is DestinationFormProcessingOKState) {
          Navigator.of(context).pop();
          app.di.find<DestinationCubit>().reload();
          final name = state.destination.name;
          app.snack.showSuccess(
            message: _editing
                ? app.intl.destinations.saved(name: name)
                : app.intl.destinations.created(name: name),
            context: app.context,
          );
        }
      },
      child: StepsDialogTemplate(
        title: _editing
            ? app.intl.destinations.editTitle
            : app.intl.destinations.newTitle,
        description: app.intl.destinations.formDescription,
        icon: app.assets.icons.nodes.bucket,
        loadingId: DestinationForm.loadingId,
        steps: [
          app.intl.destinations.stepType,
          app.intl.destinations.stepConnection,
          app.intl.destinations.stepFolders,
        ],
        current: _step,
        actions: [
          PrimaryButton.secondary(
            onPressed: _back,
            title: _step == 0 ? app.intl.common.cancel : app.intl.common.back,
            h: 40,
            horizontalPadding: 16,
          ),
          _NextButton(
            title: _step < _lastStep
                ? app.intl.common.next
                : _editing
                ? app.intl.common.saveChanges
                : app.intl.destinations.createButton,
            onPressed: _next,
          ),
        ],
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
              ...switch (_step) {
                0 => [
                  StepTitle(app.intl.destinations.typeTitle),
                  app.dimensions.padding.m.gap(),
                  _buildTypes(),
                ],
                1 => [
                  StepTitle(app.intl.destinations.connectionTitle),
                  app.dimensions.padding.l.gap(),
                  if (_type == DestinationTypes.s3) ..._buildS3(),
                ],
                _ => [
                  StepTitle(app.intl.destinations.foldersTitle),
                  app.dimensions.padding.m.gap(),
                  ..._buildFolders(),
                  app.dimensions.padding.xl.gap(),
                  BlocBuilder<DestinationFormCubit, DestinationFormState>(
                    builder: (context, state) => ConnectionTestBanner(
                      check: _check,
                      testing: state is DestinationFormTestInProgressState,
                      onTest: _test,
                      idleSub: app.intl.destinations.testIdle,
                      connectedSub: (_) => app.intl.destinations.connectedSub(
                        bucket: _bucketController.text.trim(),
                      ),
                    ),
                  ),
                ],
              },
            ],
          ),
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
                  look: DestinationTypeLook.lookOf(type.type),
                  label: DestinationTypeLook.labelOf(type.type),
                  sub: DestinationTypeLook.subOf(type.type),
                  selected: type.type == _type,
                  // a saved destination of a type no longer available keeps it
                  enabled:
                      type.enabled || type.type == widget.destination?.type,
                  onTap: () {
                    if (type.type == _type) return;
                    setState(() => _type = type.type);
                    _changed(DestinationFormField.type);
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  List<Widget> _buildS3() {
    final gap = app.dimensions.padding.sm;
    return [
      AppFormInput(
        controller: _nameController,
        label: app.intl.destinations.name,
        hint: app.intl.destinations.nameHint,
        autofocus: !_editing,
        maxLength: _nameMaxLength,
        errorText: _serverErrors[DestinationFormField.name],
        validator: _required,
        onChange: (_) => _changed(DestinationFormField.name),
        onSubmitted: (_) => _next(),
      ),
      app.dimensions.padding.l.gap(),
      AppFormInput(
        controller: _endpointController,
        label: app.intl.destinations.endpoint,
        hint: 'https://s3.us-east-1.amazonaws.com',
        helperText: app.intl.destinations.endpointHelp,
        errorText: _serverErrors[DestinationFormField.endpoint],
        validator: (v) {
          final uri = Uri.tryParse(v?.trim() ?? '');
          return _required(v) ??
              (uri != null &&
                      (uri.scheme == 'http' || uri.scheme == 'https') &&
                      uri.host.isNotEmpty
                  ? null
                  : app.intl.destinations.endpointHelp);
        },
        onChange: (_) => _changed(DestinationFormField.endpoint),
        onSubmitted: (_) => _next(),
      ),
      app.dimensions.padding.l.gap(),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: AppFormInput(
              controller: _bucketController,
              label: app.intl.destinations.bucket,
              hint: 'bucket-backups',
              errorText: _serverErrors[DestinationFormField.bucket],
              validator: _required,
              onChange: (_) => _changed(DestinationFormField.bucket),
              onSubmitted: (_) => _next(),
            ),
          ),
          gap.gap(),
          Expanded(
            child: AppFormInput(
              controller: _regionController,
              label:
                  '${app.intl.destinations.region} ${app.intl.common.optional}',
              hint: 'us-east-1',
              errorText: _serverErrors[DestinationFormField.region],
              onChange: (_) => _changed(DestinationFormField.region),
              onSubmitted: (_) => _next(),
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
              controller: _accessKeyController,
              label: app.intl.destinations.accessKeyId,
              errorText: _serverErrors[DestinationFormField.accessKeyId],
              validator: _required,
              onChange: (_) => _changed(DestinationFormField.accessKeyId),
              onSubmitted: (_) => _next(),
            ),
          ),
          gap.gap(),
          Expanded(
            child: AppFormPasswordInput(
              controller: _secretController,
              label: app.intl.destinations.secretKey,
              hint: _editing ? app.intl.destinations.secretKeepHint : null,
              helperText: app.intl.destinations.secretHelp,
              errorText: _serverErrors[DestinationFormField.secretKey],
              // editing, an empty one keeps the saved secret key
              validator: _editing ? null : _required,
              onChange: (_) => _changed(DestinationFormField.secretKey),
              onSubmitted: (_) => _next(),
            ),
          ),
        ],
      ),
      app.dimensions.padding.l.gap(),
      DecoratedBox(
        decoration: BoxDecoration(
          color: app.colors.primary.background2,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: app.colors.neutral.grey5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: AppSwitchTile(
            title: app.intl.destinations.pathStyle,
            subtitle: app.intl.destinations.pathStyleHelp,
            value: _pathStyle,
            onChanged: () {
              setState(() => _pathStyle = !_pathStyle);
              _changed('settings.path_style');
            },
          ),
        ),
      ),
      app.dimensions.padding.m.gap(),
      Text(
        app.intl.destinations.permissions,
        style: TextStyle(fontSize: 12, color: app.colors.neutral.grey4),
      ),
    ];
  }

  List<Widget> _buildFolders() {
    final folderError =
        _folderError ?? _serverErrors[DestinationFormField.folders];
    return [
      Text(
        app.intl.destinations.foldersHelp,
        style: TextStyle(fontSize: 12, color: app.colors.neutral.grey3),
      ),
      if (_folders.isNotEmpty) ...[
        app.dimensions.padding.m.gap(),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final folder in _folders)
              _FolderChip(
                path: folder,
                // a backup writes to it: the service would refuse it
                locked: (widget.folderUsage[folder] ?? 0) > 0,
                onRemove: () => _removeFolder(folder),
              ),
          ],
        ),
      ],
      app.dimensions.padding.m.gap(),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: AppFormInput(
              controller: _folderController,
              hint: app.intl.destinations.folderHint,
              errorText: folderError,
              onChange: (_) {
                if (_folderError != null) setState(() => _folderError = null);
              },
              onSubmitted: (_) => _addFolder(),
            ),
          ),
          app.dimensions.padding.s.gap(),
          PrimaryButton.secondary(
            onPressed: _addFolder,
            title: app.intl.destinations.addFolder,
            color: app.colors.surface.control,
            h: 42,
            horizontalPadding: 14,
          ),
        ],
      ),
    ];
  }
}

/// A folder of the form, with the button that removes it
class _FolderChip extends StatelessWidget {
  final String path;
  final bool locked;
  final VoidCallback onRemove;

  const _FolderChip({
    required this.path,
    required this.locked,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final shown = FolderPath.show(path);
    return Container(
      height: 32,
      padding: const EdgeInsets.only(left: 10, right: 4),
      decoration: BoxDecoration(
        color: app.colors.primary.background2,
        borderRadius: app.dimensions.border.borderRadius.s,
        border: Border.all(color: app.colors.neutral.grey5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            shown,
            style: const TextStyle(
              fontFamily: AppText.monoFamily,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 4),
          Tooltip(
            message: locked
                ? app.intl.destinations.folderLocked
                : app.intl.destinations.deleteFolder(path: shown),
            child: InkWell(
              borderRadius: BorderRadius.circular(5),
              onTap: locked ? null : onRemove,
              child: SizedBox(
                width: 22,
                height: 22,
                child: Center(
                  child: app.assets.icons.actions.close.build(
                    size: 12,
                    color: locked
                        ? app.colors.neutral.grey5
                        : app.colors.neutral.grey3,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// *Next*, and on the last step *Create destination* / *Save changes*,
/// disabled while it is being tested or saved
class _NextButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;

  const _NextButton({required this.title, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DestinationFormCubit, DestinationFormState>(
      builder: (context, state) {
        final loading = state is DestinationFormProcessInProgressState;
        return PrimaryButton.primary(
          onPressed: state is DestinationFormTestInProgressState
              ? null
              : onPressed,
          isLoading: loading,
          title: loading ? app.intl.common.saving : title,
          color: app.colors.primary.primaryAction,
          h: 40,
          horizontalPadding: 20,
        );
      },
    );
  }
}
