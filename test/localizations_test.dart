import 'package:dashronym/dashronym.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('DashronymLocalizations returns fallback strings when not in tree', () {
    final strings = DashronymLocalizations(const Locale('en'));

    expect(
      strings.tooltipMessage('SDK', 'Software Development Kit'),
      'Show definition for SDK.\nSoftware Development Kit',
    );
    expect(
      strings.semanticsHintShow('SDK'),
      'Double tap to show definition for SDK.',
    );
    expect(
      strings.semanticsHintHide('SDK'),
      'Double tap to hide definition for SDK.',
    );
    expect(strings.announceTooltipShown('SDK'), 'Showing definition for SDK.');
    expect(strings.closeButtonTooltip('SDK'), 'Hide definition for SDK');
  });
}
