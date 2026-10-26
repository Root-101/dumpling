import 'package:material_ui/material_ui.dart';

/// Makes all the text of the app selectable with the mouse. It goes in the
/// `builder` of `MaterialApp`, above the `Navigator`, so it covers screens,
/// dialogs and drawers. It has its own [Overlay] because there is none there yet
/// to paint the selection's handles
class AppSelectionArea extends StatefulWidget {
  final Widget child;

  const AppSelectionArea({required this.child, super.key});

  @override
  State<AppSelectionArea> createState() => _AppSelectionAreaState();
}

class _AppSelectionAreaState extends State<AppSelectionArea> {
  late final OverlayEntry _entry = OverlayEntry(
    // without its menu (Select all): the right click is the canvas's, and the
    // menu, above the Navigator, has no route to dismiss it. Ctrl+C copies
    builder: (context) =>
        SelectionArea(contextMenuBuilder: null, child: widget.child),
  );

  @override
  void didUpdateWidget(covariant AppSelectionArea oldWidget) {
    super.didUpdateWidget(oldWidget);
    _entry.markNeedsBuild();
  }

  @override
  Widget build(BuildContext context) {
    return Overlay(initialEntries: [_entry]);
  }
}
