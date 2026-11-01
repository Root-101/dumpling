import 'package:console/app_exporter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';

/// Shown while the app initializes, right after the splash of `web/index.html`
/// (removed on the first frame) and the same as it, as in the design: the
/// grid with a glow, the mark, the name, a text and a bar
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = app.colors;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeConfig.theme,
      localizationsDelegates: appLocalizationsDelegates,
      supportedLocales: appSupportedLocales,
      builder: (context, child) => Scaffold(
        backgroundColor: colors.surface.background,
        body: CustomPaint(
          painter: GridLinePainter(
            color: colors.brand.primary.withValues(alpha: 0.05),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              OverflowBox(
                maxWidth: 760,
                maxHeight: 760,
                child: Container(
                  width: 760,
                  height: 760,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        colors.brand.primary.withValues(alpha: 0.14),
                        colors.brand.primary.withValues(alpha: 0.05),
                        colors.brand.primary.withValues(alpha: 0),
                      ],
                      stops: const [0, 0.38, 0.7],
                    ),
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const DumplingLogo(height: 96),
                  const SizedBox(height: 28),
                  Semantics(
                    label: 'Dumpling',
                    child: SvgPicture.asset(
                      app.assets.name,
                      width: 262,
                      height: 70,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    context.intl.app.splashText,
                    style: TextStyle(
                      fontSize: 16,
                      height: 24 / 16,
                      color: colors.neutral.grey4,
                    ),
                  ),
                  const SizedBox(height: 28),
                  const _LoadingBar(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The bar of `.splash-bar` in `web/index.html`: a segment of 40 % that
/// crosses the track every 1.4 s, still at 30 % when the system asks for less
/// motion
class _LoadingBar extends StatefulWidget {
  const _LoadingBar();

  @override
  State<_LoadingBar> createState() => _LoadingBarState();
}

class _LoadingBarState extends State<_LoadingBar>
    with SingleTickerProviderStateMixin {
  static const double _width = 220;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.of(context).disableAnimations;
    final radius = BorderRadius.circular(2);
    return ClipRRect(
      borderRadius: radius,
      child: Container(
        width: _width,
        height: 4,
        color: app.colors.surface.control,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            // `ease-in-out`, from -40 % to 100 % of the track; still, at 30 %
            final t = still
                ? 0.5
                : Curves.easeInOut.transform(_controller.value);
            return Stack(
              children: [
                Positioned(
                  left: _width * (-0.4 + 1.4 * t),
                  width: _width * 0.4,
                  top: 0,
                  bottom: 0,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: app.colors.brand.primary,
                      borderRadius: radius,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
