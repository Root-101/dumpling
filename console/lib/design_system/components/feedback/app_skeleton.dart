import 'package:console/app_exporter.dart';
import 'package:material_ui/material_ui.dart';

/// A screen still loading: its content as [AppSkeleton] blocks, with a light
/// that sweeps over each one. One animation for all the blocks under it; none
/// when the system asks for less motion
class AppShimmer extends StatefulWidget {
  final Widget child;

  const AppShimmer({required this.child, super.key});

  @override
  State<AppShimmer> createState() => _AppShimmerState();
}

class _AppShimmerState extends State<AppShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
    label: app.intl.common.loading,
    liveRegion: true,
    child: ExcludeSemantics(
      child: _ShimmerScope(animation: _controller, child: widget.child),
    ),
  );
}

class _ShimmerScope extends InheritedWidget {
  final Animation<double> animation;

  const _ShimmerScope({required this.animation, required super.child});

  @override
  bool updateShouldNotify(_ShimmerScope oldWidget) =>
      animation != oldWidget.animation;
}

/// A block in place of a text, a badge or a button. [factor] instead of
/// [width]: that part of the width it has
class AppSkeleton extends StatelessWidget {
  final double? width;
  final double? factor;
  final double height;
  final double radius;

  /// For what is secondary: labels, meta
  final bool dim;

  const AppSkeleton({
    this.width,
    this.factor,
    this.height = 12,
    this.radius = 5,
    this.dim = false,
    super.key,
  });

  /// Two lines one over the other, like a name and its meta
  static Widget lines(double top, double bottom) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: 7,
    children: [
      AppSkeleton(factor: top, height: 11),
      AppSkeleton(factor: bottom, height: 9, dim: true),
    ],
  );

  /// A badge and the [lines] beside it; without [bottom], one line
  static Widget named(double top, [double? bottom, double badge = 30]) => Row(
    spacing: 10,
    children: [
      AppSkeleton(width: badge, height: badge, radius: 8),
      Expanded(
        child: bottom == null
            ? AppSkeleton(factor: top, height: 12)
            : lines(top, bottom),
      ),
    ],
  );

  /// The toolbar of a list: the search as wide as on the screen, then
  /// [buttons] of these widths, and the view toggle after a divider
  static Widget toolbar(List<double> buttons, {bool toggle = false}) => Row(
    spacing: app.dimensions.padding.sm,
    children: [
      const Expanded(child: AppSkeleton(height: 40, radius: 8)),
      for (final w in buttons) AppSkeleton(width: w, height: 40, radius: 8),
      if (toggle) ...[
        Container(width: 1, height: 28, color: app.colors.neutral.grey5),
        const AppSkeleton(width: 76, height: 40, radius: 8),
      ],
    ],
  );

  @override
  Widget build(BuildContext context) {
    final colors = app.colors.surface;
    final base = dim ? colors.skeletonDim : colors.skeleton;
    final animation = context
        .dependOnInheritedWidgetOfExactType<_ShimmerScope>()
        ?.animation;
    final still =
        animation == null ||
        (MediaQuery.maybeDisableAnimationsOf(context) ?? false);
    final radius = BorderRadius.circular(this.radius);
    Widget box = still
        ? DecoratedBox(
            decoration: BoxDecoration(color: base, borderRadius: radius),
          )
        : AnimatedBuilder(
            animation: animation,
            builder: (context, _) {
              final light = Color.alphaBlend(
                app.colors.primary.primaryFaded.withValues(alpha: 0.10),
                base,
              );
              return DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: radius,
                  gradient: LinearGradient(
                    colors: [base, light, base],
                    stops: const [0.3, 0.5, 0.7],
                    transform: _Slide(animation.value * 2 - 1),
                  ),
                ),
              );
            },
          );
    box = SizedBox(width: width, height: height, child: box);
    final factor = this.factor;
    return factor == null
        ? box
        : FractionallySizedBox(
            widthFactor: factor,
            alignment: AlignmentDirectional.centerStart,
            child: box,
          );
  }
}

/// The light from one side of the block to the other
class _Slide extends GradientTransform {
  final double offset;

  const _Slide(this.offset);

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) =>
      Matrix4.translationValues(bounds.width * offset, 0, 0);
}

/// The dot and word of a status
class AppStatusSkeleton extends StatelessWidget {
  const AppStatusSkeleton({super.key});

  @override
  Widget build(BuildContext context) => const Row(
    spacing: 6,
    children: [
      AppSkeleton(width: 7, height: 7, radius: 4),
      AppSkeleton(width: 70, height: 10, dim: true),
    ],
  );
}

/// The menu button at the end of a row
class AppActionSkeleton extends StatelessWidget {
  const AppActionSkeleton({super.key});

  @override
  Widget build(BuildContext context) => const Align(
    alignment: AlignmentDirectional.centerEnd,
    child: AppSkeleton(width: 32, height: 32, radius: 8, dim: true),
  );
}

/// A [DetailStat]: its label, value and what it means
class AppStatSkeleton extends StatelessWidget {
  const AppStatSkeleton({super.key});

  @override
  Widget build(BuildContext context) => const DetailPanel(
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10,
      children: [
        AppSkeleton(factor: 0.4, height: 10, dim: true),
        Row(
          spacing: 8,
          children: [
            AppSkeleton(width: 56, height: 24),
            AppSkeleton(width: 90, height: 10, dim: true),
          ],
        ),
      ],
    ),
  );
}
