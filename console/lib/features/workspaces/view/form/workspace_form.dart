import 'package:console/app_exporter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

/// Dialog of a new workspace: name, description and color. Once created it
/// reloads the list and opens the new workspace
class WorkspaceForm extends StatefulWidget {
  /// Opens the dialog with its own [WorkspaceFormCubit]
  static Future<void> open(BuildContext context) async {
    final formKey = GlobalKey<_WorkspaceFormState>();
    final formCubit = WorkspaceFormCubit(app.di.find(), app.di.find());

    await FormDialogTemplate.show(
      context: context,
      title: app.intl.workspaces.formTitle,
      description: app.intl.workspaces.formDescription,
      loadingId: loadingId,
      actions: [
        PrimaryButton.secondary(
          onPressed: () => Navigator.of(context).pop(),
          title: app.intl.common.cancel,
          h: 40,
          w: 100,
        ),
        BlocProvider.value(
          value: formCubit,
          child: _CreateButton(onPressed: () => formKey.currentState?.submit()),
        ),
      ],
      child: BlocProvider.value(
        value: formCubit,
        child: WorkspaceForm(key: formKey),
      ),
    );
    await formCubit.close();
  }

  /// Id of the dialog's [LoadingOverlay]
  static const String loadingId = 'workspace-form';

  const WorkspaceForm({super.key});

  @override
  State<WorkspaceForm> createState() => _WorkspaceFormState();
}

class _WorkspaceFormState extends State<WorkspaceForm> {
  static const int _nameMaxLength = 64;
  static const int _descriptionMaxLength = 256;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  Color? _color = app.colors.palette.violet;

  /// After the first submit attempt it validates on every change
  bool _submitted = false;

  /// API errors per field; cleared when that field is edited
  Map<String, String> _serverErrors = const {};

  /// API error that doesn't belong to a field
  String? _formError;

  late final WorkspaceFormCubit cubit = context.read<WorkspaceFormCubit>();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void submit() {
    if (cubit.state is WorkspaceFormProcessInProgressState) return;
    if (!_submitted) setState(() => _submitted = true);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final description = _descriptionController.text.trim();
    cubit.create(
      WorkspaceDraft(
        name: _nameController.text.trim(),
        description: description.isEmpty ? null : description,
        color: _color,
      ),
    );
  }

  void _clearError(String field) {
    if (!_serverErrors.containsKey(field)) return;
    setState(() => _serverErrors = {..._serverErrors}..remove(field));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WorkspaceFormCubit, WorkspaceFormState>(
      listener: (context, state) {
        if (state is WorkspaceFormProcessInProgressState) {
          app.loading.show(id: WorkspaceForm.loadingId);
        } else {
          app.loading.hide(id: WorkspaceForm.loadingId);
        }
        if (state is WorkspaceFormProcessingErrorState) {
          setState(() {
            _serverErrors = state.fieldErrors;
            _formError = state.fieldErrors.isEmpty
                ? state.exception.message
                : null;
          });
        }
        if (state is WorkspaceFormProcessingOKState) {
          Navigator.of(context).pop();
          app.di.find<WorkspaceCubit>().load();
          app.snack.showSuccess(
            message: app.intl.workspaces.created(name: state.workspace.name),
            context: app.context,
          );
          RouteNames.openWorkspace(state.workspace.slug);
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // The avatar follows the name and the color as they change
                Padding(
                  padding: const EdgeInsets.only(bottom: 1),
                  child: ListenableBuilder(
                    listenable: _nameController,
                    builder: (context, _) => WorkspaceAvatar(
                      initial: WorkspaceModel(
                        slug: '',
                        name: _nameController.text.trim(),
                      ).initial,
                      color: _color,
                      size: 42,
                    ),
                  ),
                ),
                app.dimensions.padding.m.gap(),
                Expanded(
                  child: AppFormInput(
                    controller: _nameController,
                    label: app.intl.workspaces.name,
                    hint: app.intl.workspaces.nameHint,
                    autofocus: true,
                    maxLength: _nameMaxLength,
                    errorText: _serverErrors[WorkspaceFormField.name],
                    validator: (v) => v == null || v.trim().isEmpty
                        ? app.intl.common.required
                        : null,
                    onChange: (_) => _clearError(WorkspaceFormField.name),
                    onSubmitted: (_) => submit(),
                  ),
                ),
              ],
            ),
            app.dimensions.padding.l.gap(),
            AppFormInput(
              controller: _descriptionController,
              label:
                  '${app.intl.workspaces.descriptionLabel} ${app.intl.common.optional}',
              hint: app.intl.workspaces.descriptionHint,
              maxLength: _descriptionMaxLength,
              errorText: _serverErrors[WorkspaceFormField.description],
              onChange: (_) => _clearError(WorkspaceFormField.description),
              onSubmitted: (_) => submit(),
            ),
            app.dimensions.padding.l.gap(),
            Text(
              app.intl.workspaces.color,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            app.dimensions.padding.s.gap(),
            AppColorPicker(
              value: _color,
              allowNone: false,
              contrastAgainst: app.colors.neutral.white,
              onChanged: (color) => setState(() => _color = color),
            ),
            app.dimensions.padding.l.gap(),
            Text(
              app.intl.workspaces.emptyCanvas,
              style: TextStyle(fontSize: 12, color: app.colors.neutral.grey4),
            ),
          ],
        ),
      ),
    );
  }
}

/// *Create workspace*, disabled while it is being created
class _CreateButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _CreateButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkspaceFormCubit, WorkspaceFormState>(
      builder: (context, state) {
        final loading = state is WorkspaceFormProcessInProgressState;
        return PrimaryButton.primary(
          onPressed: onPressed,
          isLoading: loading,
          title: loading
              ? app.intl.workspaces.creating
              : app.intl.workspaces.createButton,
          color: app.colors.primary.primaryAction,
          h: 40,
          w: 180,
        );
      },
    );
  }
}
