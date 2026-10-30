import 'package:console/app_exporter.dart';
import 'package:material_ui/material_ui.dart';

/// The canvas while it loads: its grid and columns, a few nodes in blocks
/// where the nodes go, and its two bars
class CanvasSkeleton extends StatelessWidget {
  const CanvasSkeleton({super.key});

  /// What the nodes take, as the editor centers them at start
  static const double _width = 1056;

  @override
  Widget build(BuildContext context) {
    final colors = app.colors;
    Widget label(double left, String text) => Positioned(
      left: left,
      top: 60,
      child: Text(text, style: AppText.overline),
    );
    final columns = app.intl.canvas.columns;
    return AppShimmer(
      child: LayoutBuilder(
        builder: (context, constraints) => Stack(
          children: [
            Positioned.fill(
              child: ColoredBox(
                color: colors.surface.background,
                child: CustomPaint(
                  painter: GridLinePainter(
                    color: colors.primary.primaryFaded.withValues(alpha: 0.05),
                  ),
                ),
              ),
            ),
            Positioned(
              left: ((constraints.maxWidth - _width) / 2).clamp(0, 1e9),
              top: 0,
              width: _width,
              height: 600,
              child: Stack(
                children: [
                  label(40, columns.sources.toUpperCase()),
                  label(380, columns.configs.toUpperCase()),
                  label(760, columns.destinations.toUpperCase()),
                  _node(40, 110, CanvasGeometry.sourceSize.width, [
                    AppSkeleton.named(0.64, 0.44),
                    const AppSkeleton(factor: 0.7, height: 9, dim: true),
                  ]),
                  _node(40, 270, CanvasGeometry.sourceSize.width, [
                    AppSkeleton.named(0.54, 0.44),
                    const AppSkeleton(factor: 0.62, height: 9, dim: true),
                  ]),
                  _node(380, 104, CanvasGeometry.configSize.width, [
                    AppSkeleton.named(0.6, 0.36),
                    AppSkeleton.lines(0.8, 0.66),
                  ]),
                  _node(380, 264, CanvasGeometry.configSize.width, [
                    AppSkeleton.named(0.5, 0.36),
                    AppSkeleton.lines(0.8, 0.66),
                  ]),
                  _node(760, 90, CanvasGeometry.destinationWidth, [
                    AppSkeleton.named(0.58, 0.7),
                    const AppSkeleton(factor: 0.44, height: 9, dim: true),
                    const AppSkeleton(factor: 0.38, height: 9, dim: true),
                    const AppSkeleton(height: 26, radius: 6, dim: true),
                  ]),
                ],
              ),
            ),
            Positioned(left: 16, top: 16, child: _bar(const [84, 104])),
            Positioned(
              left: 16,
              bottom: 16,
              child: _bar(const [32, 32, 72, 32, 48, 32]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _node(double left, double top, double width, List<Widget> rows) {
    final colors = app.colors;
    return Positioned(
      left: left,
      top: top,
      width: width,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: colors.surface.surface1,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.surface.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: rows,
        ),
      ),
    );
  }

  Widget _bar(List<double> widths) => Container(
    padding: const EdgeInsets.all(6),
    decoration: BoxDecoration(
      color: app.colors.surface.surface1,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: app.colors.surface.border),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 6,
      children: [
        for (final w in widths) AppSkeleton(width: w, height: 28, radius: 6),
      ],
    ),
  );
}
