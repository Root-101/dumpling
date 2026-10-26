import 'package:console/app_exporter.dart';
import 'package:material_ui/material_ui.dart';

/// The folders of a destination, opened under its row: how many backups
/// write to each one, and the way to add a folder or delete an unused one
class DestinationFolders extends StatefulWidget {
  final DestinationModel destination;

  /// Backups per folder (null: the bucket root)
  final int Function(String? folder) usageOf;
  final ValueChanged<String> onAdd;
  final ValueChanged<String> onDelete;

  const DestinationFolders({
    required this.destination,
    required this.usageOf,
    required this.onAdd,
    required this.onDelete,
    super.key,
  });

  @override
  State<DestinationFolders> createState() => _DestinationFoldersState();
}

class _DestinationFoldersState extends State<DestinationFolders> {
  final _controller = TextEditingController();
  bool _adding = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _add() {
    final path = FolderPath.clean(_controller.text);
    final error = FolderPath.error(path, widget.destination.folders);
    setState(() => _error = error);
    if (error != null) return;
    widget.onAdd(path);
    _controller.clear();
    setState(() => _adding = false);
  }

  void _cancel() {
    _controller.clear();
    setState(() {
      _adding = false;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final line = BorderSide(color: app.colors.neutral.grey5);
    final folders = widget.destination.folders;
    return Padding(
      padding: const EdgeInsets.fromLTRB(60, 0, 12, 12),
      child: Container(
        decoration: BoxDecoration(border: Border(left: line)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final folder in folders) _buildFolder(folder),
            if (folders.isEmpty)
              SizedBox(
                height: 40,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      app.intl.destinations.noFolders,
                      style: TextStyle(
                        fontSize: 12,
                        color: app.colors.neutral.grey4,
                      ),
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 0, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: _adding ? _buildInput() : _buildAddButton(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFolder(String folder) {
    final used = widget.usageOf(folder);
    final shown = FolderPath.show(folder);
    return SizedBox(
      height: 44,
      child: Row(
        children: [
          Container(width: 12, height: 1, color: app.colors.neutral.grey5),
          const SizedBox(width: 10),
          app.assets.icons.nodes.folder.build(
            size: 16,
            color: app.colors.primary.secondary,
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
          SizedBox(
            width: 110,
            child: Text(
              used > 0
                  ? app.intl.destinations.folderUsed(n: used)
                  : app.intl.destinations.notUsedYet,
              style: TextStyle(fontSize: 12, color: app.colors.neutral.grey3),
            ),
          ),
          PrimaryButton.svgIcon(
            icon: app.assets.icons.actions.delete,
            tooltipMessage: used > 0
                ? app.intl.destinations.folderLocked
                : app.intl.destinations.deleteFolder(path: shown),
            iconColor: used > 0
                ? app.colors.neutral.grey5
                : app.colors.status.error,
            backgroundColor: app.colors.neutral.transparent,
            buttonSize: 30,
            iconSize: 14,
            onPressed: used > 0 ? null : () => widget.onDelete(folder),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    final radius = app.dimensions.border.borderRadius.s;
    return InkWell(
      borderRadius: radius,
      onTap: () => setState(() => _adding = true),
      child: DashedBorder(
        color: app.colors.neutral.grey5,
        strokeWidth: 1,
        radius: 8,
        child: SizedBox(
          height: 34,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                app.assets.icons.actions.add.build(
                  size: 14,
                  color: app.colors.neutral.grey3,
                ),
                const SizedBox(width: 6),
                Text(
                  app.intl.destinations.addFolder,
                  style: TextStyle(
                    fontSize: 13,
                    color: app.colors.neutral.grey3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 260,
          child: AppFormInput(
            controller: _controller,
            hint: app.intl.destinations.folderHint,
            autofocus: true,
            height: 36,
            errorText: _error,
            onChange: (_) {
              if (_error != null) setState(() => _error = null);
            },
            onSubmitted: (_) => _add(),
          ),
        ),
        app.dimensions.padding.s.gap(),
        PrimaryButton.primary(
          onPressed: _add,
          title: app.intl.common.add,
          color: app.colors.primary.primaryAction,
          h: 36,
          w: 72,
        ),
        app.dimensions.padding.s.gap(),
        PrimaryButton.secondary(
          onPressed: _cancel,
          title: app.intl.common.cancel,
          h: 36,
          horizontalPadding: 12,
        ),
      ],
    );
  }
}
