import 'package:dashronym/dashronym.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('DashronymConfig exposes sensible defaults', () {
    const config = DashronymConfig();
    expect(config.enableBareAcronyms, isFalse);
    expect(config.minLen, 2);
    expect(config.maxLen, 10);
    expect(config.acceptMarkers, ['()', "''", '""']);
  });

  test('DashronymConfig respects custom markers and lengths', () {
    const markers = ['[]', '{}'];
    const config = DashronymConfig(
      enableBareAcronyms: true,
      minLen: 3,
      maxLen: 6,
      acceptMarkers: markers,
    );

    expect(config.enableBareAcronyms, isTrue);
    expect(config.minLen, 3);
    expect(config.maxLen, 6);
    expect(config.acceptMarkers, markers);
  });
}
