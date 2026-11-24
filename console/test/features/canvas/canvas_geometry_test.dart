import 'package:console/app_exporter.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadAppFonts);

  test('a name is long when it would be cut on its own node', () {
    // a config shares its line with the cron: Nightly full still fits
    expect(
      CanvasGeometry.longName(
        'Nightly full',
        CanvasGeometry.configNameRoom('0 2 * * *'),
      ),
      isFalse,
    );
    expect(
      CanvasGeometry.longName(
        'Nightly full backup of orders',
        CanvasGeometry.configNameRoom('0 2 * * *'),
      ),
      isTrue,
    );
    // the same name fits a destination and not a source, narrower
    const name = 'production-replica-db';
    expect(
      CanvasGeometry.longName(name, CanvasGeometry.sourceNameRoom),
      isTrue,
    );
    expect(
      CanvasGeometry.longName(name, CanvasGeometry.destinationNameRoom),
      isFalse,
    );
  });
}
