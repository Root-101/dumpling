import 'dart:async';

import 'package:console/app_exporter.dart';
import 'package:material_ui/material_ui.dart';

/// The service stopped answering after the screen loaded: what was loaded
/// stays, this says so over it and tries again every [every]
class OfflineBanner extends StatefulWidget {
  final VoidCallback onRetry;
  final int every;

  const OfflineBanner({required this.onRetry, this.every = 10, super.key});

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner> {
  late int _left = widget.every;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_left > 1) return setState(() => _left--);
      setState(() => _left = widget.every);
      widget.onRetry();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = app.intl.errors;
    final amber = app.colors.brand.accent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: amber.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: amber.withValues(alpha: 0.35)),
      ),
      child: Row(
        spacing: 12,
        children: [
          app.assets.icons.actions.warning.build(size: 18, color: amber),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: TextStyle(fontSize: 13, color: app.colors.neutral.grey2),
                children: [
                  TextSpan(
                    text: '${t.offlineBanner} ',
                    style: TextStyle(fontWeight: FontWeight.w700, color: amber),
                  ),
                  TextSpan(
                    text: '${t.offlineKept} ${t.retryingIn(seconds: _left)}',
                  ),
                ],
              ),
            ),
          ),
          OutlinedButton(
            onPressed: () {
              setState(() => _left = widget.every);
              widget.onRetry();
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: amber,
              side: BorderSide(color: amber),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(t.retryNow),
          ),
        ],
      ),
    );
  }
}
