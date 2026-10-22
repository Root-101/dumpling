import 'package:flutter/rendering.dart';
import 'package:material_ui/material_ui.dart';

/// A [Stack] that paints AND takes pointers outside of its own size. A plain
/// Stack ignores taps on children that overflow it (a port half outside its
/// node, a node dragged out of the world box)
class UnboundedStack extends Stack {
  const UnboundedStack({super.key, super.children})
    : super(clipBehavior: Clip.none);

  @override
  RenderStack createRenderObject(BuildContext context) =>
      _RenderUnboundedStack(textDirection: Directionality.maybeOf(context));
}

class _RenderUnboundedStack extends RenderStack {
  _RenderUnboundedStack({super.textDirection}) : super(clipBehavior: Clip.none);

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (hitTestChildren(result, position: position)) {
      result.add(BoxHitTestEntry(this, position));
      return true;
    }
    return false;
  }
}
