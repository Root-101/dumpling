import 'package:console/app_exporter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

/// Dialog of a destination in three steps: its type, the connection with the
/// test of the bucket root, and its folders, each new one tested too (always
/// by the service). Once saved it reloads the list
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

  /// 0: type, 1: connection and the test of the root, 2: folders and theirs
  int _step = 0;

  late String _type;
  bool _pathStyle = false;
  List<String> _folders = [];
  String? _folderError;

  /// What the last test of the bucket root found; a change of the connection
  /// clears it
  ConnectionCheckModel? _check;

  /// The folders that took a test object with this connection; editing, the
  /// saved ones until the connection changes
  Set<String> _checkedFolders = {};

  /// Why the last test of the folders failed
  String? _foldersCheckError;

  /// The folders of the test in progress
  List<String> _foldersUnderTest = const [];

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
      if (_editing) _checkedFolders = {..._folders};
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

  /// With [folders] it tests only those (none: the bucket root)
  DestinationDraft _draft({List<String>? folders}) => DestinationDraft(
    name: _nameController.text.trim(),
    type: _type,
    endpoint: _endpointController.text.trim(),
    region: _regionController.text.trim(),
    bucket: _bucketController.text.trim(),
    accessKeyId: _accessKeyController.text.trim(),
    secretKey: _secretController.text,
    pathStyle: _pathStyle,
    folders: folders ?? _folders,
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
    DestinationFormField.endpoint,
    DestinationFormField.region,
    DestinationFormField.bucket,
    DestinationFormField.accessKeyId,
    DestinationFormField.secretKey,
    'settings.path_style',
  };

  static const int _lastStep = 2;

  bool get _connected => _check != null && _check!.status != CheckStatus.failed;

  List<String> get _pendingFolders =>
      _folders.where((f) => !_checkedFolders.contains(f)).toList();

  /// What *Next* waits for: a test of the root that connects, and on the last
  /// step the test of the new folders
  String? get _blockedNote => _step == 1 && !_connected
      ? app.intl.connections.testToContinue
      : _step == _lastStep && _pendingFolders.isNotEmpty
      ? app.intl.destinations.checkFoldersToSave
      : null;

  /// *Next* checks the fields of the step on screen; on the last one it saves
  void _next() {
    if (_busy || !_validate() || _blockedNote != null) return;
    if (_step == _lastStep) {
      cubit.save(_draft(), tested: _check != null);
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

  /// The connection step tests the bucket root
  void _test() {
    if (_busy || !_validate()) return;
    cubit.test(_draft(folders: const []));
  }

  /// The last step tests the folders not tested yet, or all of them again
  void _checkFolders() {
    if (_busy) return;
    final pending = _pendingFolders;
    _foldersUnderTest = pending.isEmpty ? _folders : pending;
    cubit.test(_draft(folders: _foldersUnderTest));
  }

  /// A change of the connection makes its tests stale; any clears the API
  /// error of [field]
  void _changed(String field) {
    setState(() {
      // neither the name nor the folders are part of the connection
      if (field != DestinationFormField.folders &&
          field != DestinationFormField.name) {
        _check = null;
        _checkedFolders = {};
        _foldersCheckError = null;
      }
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

  void _moveFolder(int from, int to) {
    setState(() => _folders = reordered(_folders, from, to));
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
            _formError = null;
            if (_step < _lastStep) {
              _check = state.check;
            } else if (state.check.status == CheckStatus.failed) {
              _foldersCheckError =
                  state.check.message ?? app.intl.connections.failedTitle;
              // one of them failed: none of the ones tested counts as writable
              _checkedFolders = _checkedFolders.difference(
                _foldersUnderTest.toSet(),
              );
            } else {
              _checkedFolders = {..._checkedFolders, ..._foldersUnderTest};
              _foldersCheckError = null;
            }
          });
        }
        if (state is DestinationFormProcessingErrorState) {
          setState(() {
            _serverErrors = state.fieldErrors;
            _formError = state.fieldErrors.isEmpty
                ? state.exception.message
                : null;
            final fields = state.fieldErrors.keys;
            if (fields.contains(DestinationFormField.type) ||
                fields.contains(DestinationFormField.name)) {
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
        fullHeight: true,
        steps: [
          app.intl.destinations.stepType,
          app.intl.destinations.stepConnection,
          app.intl.destinations.stepFolders,
        ],
        current: _step,
        blockedNote: _blockedNote,
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
            onPressed: _blockedNote == null ? _next : null,
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
                  AppFormInput(
                    controller: _nameController,
                    label: app.intl.destinations.name,
                    hint: app.intl.destinations.nameHint,
                    helperText: app.intl.destinations.nameHelp,
                    autofocus: !_editing,
                    maxLength: _nameMaxLength,
                    warningText: CanvasGeometry.longName(_nameController.text)
                        ? app.intl.common.longName
                        : null,
                    errorText: _serverErrors[DestinationFormField.name],
                    validator: _required,
                    onChange: (_) => _changed(DestinationFormField.name),
                    onSubmitted: (_) => _next(),
                  ),
                  app.dimensions.padding.l.gap(),
                  StepTitle(app.intl.destinations.typeTitle),
                  app.dimensions.padding.m.gap(),
                  _buildTypes(),
                ],
                1 => [
                  _buildSummary(full: false),
                  const StepDivider(),
                  StepTitle(app.intl.destinations.connectionTitle),
                  app.dimensions.padding.l.gap(),
                  if (_type == DestinationTypes.s3) ...[
                    ..._buildS3(),
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
                ],
                _ => [
                  _buildSummary(),
                  const StepDivider(),
                  StepTitle(app.intl.destinations.foldersTitle),
                  app.dimensions.padding.m.gap(),
                  ..._buildFolders(),
                  app.dimensions.padding.l.gap(),
                  _buildFoldersCheck(),
                ],
              },
            ],
          ),
        ),
      ),
    );
  }

  /// What the last step saves: name, endpoint/bucket and the tested root; not
  /// [full], the type and name picked in the first step
  Widget _buildSummary({bool full = true}) {
    String shown(TextEditingController c) =>
        c.text.trim().isEmpty ? '—' : c.text.trim();
    if (!full) {
      return StepSummary([
        SummaryCell(
          label: app.intl.destinations.columnType,
          value: DestinationTypeLook.labelOf(_type),
        ),
        SummaryCell(
          label: app.intl.destinations.name,
          value: _nameController.text.trim().isEmpty
              ? '—'
              : _nameController.text.trim(),
        ),
      ]);
    }
    final host = Uri.tryParse(_endpointController.text.trim())?.host ?? '';
    final bucket = shown(_bucketController);
    return StepSummary([
      SummaryCell(
        label: app.intl.destinations.name,
        value: shown(_nameController),
      ),
      SummaryCell(
        label: app.intl.destinations.bucket,
        value: host.isEmpty ? bucket : '$host/$bucket',
      ),
      // the last step is reached only after a test of the root that connected
      SummaryCell(
        label: app.intl.connections.connection,
        value: app.intl.destinations.rootWritable,
        color: app.colors.status.success,
      ),
    ]);
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

  /// The folders in one box, as the canvas draws them: a row per folder with
  /// whether it took the test object, or the root when there are none, and
  /// the field that adds one
  List<Widget> _buildFolders() {
    final folderError =
        _folderError ?? _serverErrors[DestinationFormField.folders];
    final border = BorderSide(
      color: app.colors.neutral.grey5.withValues(alpha: 0.5),
    );
    return [
      Text(
        app.intl.destinations.foldersHelp,
        style: TextStyle(fontSize: 12, color: app.colors.neutral.grey3),
      ),
      app.dimensions.padding.m.gap(),
      Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: app.colors.primary.background2,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: app.colors.neutral.grey5),
        ),
        child: BlocBuilder<DestinationFormCubit, DestinationFormState>(
          builder: (context, state) {
            final testing = state is DestinationFormTestInProgressState;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ReorderableListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  buildDefaultDragHandles: false,
                  onReorderItem: _moveFolder,
                  proxyDecorator: (child, _, _) => Material(
                    color: app.colors.primary.background2,
                    elevation: 6,
                    child: child,
                  ),
                  children: [
                    for (final (index, folder) in _folders.indexed)
                      _FolderRow(
                        key: ValueKey(folder),
                        index: index,
                        path: folder,
                        // a backup writes to it: the service would refuse it
                        locked: (widget.folderUsage[folder] ?? 0) > 0,
                        state: _checkedFolders.contains(folder)
                            ? _FolderState.writable
                            : testing && _foldersUnderTest.contains(folder)
                            ? _FolderState.checking
                            : _FolderState.notChecked,
                        border: border,
                        onRemove: () => _removeFolder(folder),
                      ),
                  ],
                ),
                if (_folders.isEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(border: Border(bottom: border)),
                    child: Row(
                      children: [
                        app.assets.icons.actions.check.build(
                          size: 16,
                          color: app.colors.status.success,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            app.intl.destinations.foldersRootChecked,
                            style: TextStyle(
                              fontSize: 13,
                              color: app.colors.neutral.grey3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: AppFormInput(
                          controller: _folderController,
                          hint: app.intl.destinations.folderHint,
                          errorText: folderError,
                          onChange: (_) {
                            if (_folderError != null) {
                              setState(() => _folderError = null);
                            }
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
                ),
              ],
            );
          },
        ),
      ),
    ];
  }

  /// How the folders' tests went, and the button that tests the new ones
  Widget _buildFoldersCheck() {
    final t = app.intl.destinations;
    final pending = _pendingFolders.length;
    final error = _foldersCheckError;
    final (note, color) = error != null
        ? (error, app.colors.primary.error)
        : pending > 0
        ? (t.foldersPending(n: pending), app.colors.status.warning)
        : _folders.isEmpty
        ? (t.foldersRootCheckedShort, app.colors.neutral.grey3)
        : (t.foldersAllChecked, app.colors.status.success);
    return Row(
      children: [
        Expanded(
          child: Text(note, style: TextStyle(fontSize: 12, color: color)),
        ),
        if (_folders.isNotEmpty) ...[
          app.dimensions.padding.s.gap(),
          BlocBuilder<DestinationFormCubit, DestinationFormState>(
            builder: (context, state) {
              final testing = state is DestinationFormTestInProgressState;
              return PrimaryButton.secondary(
                onPressed: testing ? null : _checkFolders,
                title: testing
                    ? t.checkingFolders
                    : pending > 0
                    ? t.checkFolders(n: pending)
                    : t.checkAgain,
                color: app.colors.surface.control,
                h: 36,
                horizontalPadding: 14,
              );
            },
          ),
        ],
      ],
    );
  }
}

enum _FolderState { writable, checking, notChecked }

/// A folder of the form: its path, whether it took the test object, and the
/// button that removes it
class _FolderRow extends StatelessWidget {
  final int index;
  final String path;
  final bool locked;
  final _FolderState state;
  final BorderSide border;
  final VoidCallback onRemove;

  const _FolderRow({
    required this.index,
    required this.path,
    required this.locked,
    required this.state,
    required this.border,
    required this.onRemove,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final shown = FolderPath.show(path);
    final t = app.intl.destinations;
    final (label, color) = switch (state) {
      _FolderState.writable => (t.folderWritable, app.colors.status.success),
      _FolderState.checking => (t.checkingFolders, app.colors.status.running),
      _FolderState.notChecked => (
        t.folderNotChecked,
        app.colors.status.warning,
      ),
    };
    return Container(
      height: 46,
      padding: const EdgeInsets.only(left: 12, right: 8),
      decoration: BoxDecoration(border: Border(bottom: border)),
      child: Row(
        children: [
          AppDragHandle(index: index),
          const SizedBox(width: 10),
          app.assets.icons.nodes.folder.build(
            size: 16,
            color: app.colors.neutral.grey3,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              shown,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: AppText.monoFamily,
                fontSize: 13,
              ),
            ),
          ),
          if (state == _FolderState.checking)
            SizedBox.square(
              dimension: 12,
              child: CircularProgressIndicator(strokeWidth: 2, color: color),
            )
          else
            (state == _FolderState.writable
                    ? app.assets.icons.actions.check
                    : app.assets.icons.actions.warning)
                .build(size: 14, color: color),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 12, color: color)),
          const SizedBox(width: 10),
          Tooltip(
            message: locked ? t.folderLocked : t.deleteFolder(path: shown),
            child: InkWell(
              borderRadius: BorderRadius.circular(7),
              onTap: locked ? null : onRemove,
              child: SizedBox.square(
                dimension: 30,
                child: Center(
                  child: app.assets.icons.actions.close.build(
                    size: 14,
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

  /// null: waiting for a test
  final VoidCallback? onPressed;

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
