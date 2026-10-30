import 'package:console/app_exporter.dart';
import 'package:material_ui/material_ui.dart';

/// Asks the path of a new folder of [destination], checked like the
/// Destinations screen does; [onAdd] gets it clean (`orders`, `eu/billing`)
class AddFolderDialog extends StatefulWidget {
  static Future<void> open(
    BuildContext context, {
    required DestinationNode destination,
    required ValueChanged<String> onAdd,
  }) {
    final formKey = GlobalKey<_AddFolderDialogState>();
    return FormDialogTemplate.show(
      context: context,
      width: 440,
      title: app.intl.canvas.addFolderTitle(name: destination.name),
      description: [
        app.intl.canvas.addFolderDescription,
        if (destination.folders.isEmpty) app.intl.canvas.addFolderRoot,
      ].join(' '),
      actions: [
        PrimaryButton.secondary(
          onPressed: () => Navigator.of(context).pop(),
          title: app.intl.common.cancel,
          h: 40,
          w: 100,
        ),
        PrimaryButton.primary(
          onPressed: () => formKey.currentState?.submit(),
          title: app.intl.common.add,
          color: app.colors.primary.primaryAction,
          h: 40,
          w: 100,
        ),
      ],
      child: AddFolderDialog(
        key: formKey,
        destination: destination,
        onAdd: onAdd,
      ),
    );
  }

  final DestinationNode destination;
  final ValueChanged<String> onAdd;

  const AddFolderDialog({
    required this.destination,
    required this.onAdd,
    super.key,
  });

  @override
  State<AddFolderDialog> createState() => _AddFolderDialogState();
}

class _AddFolderDialogState extends State<AddFolderDialog> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void submit() {
    final path = FolderPath.clean(_controller.text);
    final error = FolderPath.error(path, widget.destination.folders);
    setState(() => _error = error);
    if (error != null) return;
    widget.onAdd(path);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AppFormInput(
      controller: _controller,
      label: app.intl.canvas.folder,
      hint: app.intl.destinations.folderHint,
      autofocus: true,
      errorText: _error,
      onChange: (_) {
        if (_error != null) setState(() => _error = null);
      },
      onSubmitted: (_) => submit(),
    );
  }
}
