import 'package:dashronym/src/dashronym_theme.dart';
import 'package:dashronym/src/tooltip_constraints.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const theme = DashronymTheme(
    tooltipMinWidth: 200,
    tooltipMaxWidth: 480,
    enableHover: false,
  );

  group('TooltipConstraintsResolver.resolve', () {
    test('caps width using overlay and viewport gutters', () {
      const constraints = BoxConstraints(maxWidth: 640);
      const mediaQuery = MediaQueryData(size: Size(800, 600));

      final resolved = TooltipConstraintsResolver.resolve(
        constraints: constraints,
        mediaQuery: mediaQuery,
        theme: theme,
      );

      expect(resolved.maxWidth, theme.tooltipMaxWidth);
      expect(resolved.minWidth, theme.tooltipMinWidth);
    });

    test('clamps minimum width when max width is tighter', () {
      const constraints = BoxConstraints(maxWidth: 200);
      const mediaQuery = MediaQueryData(size: Size(210, 400));

      final resolved = TooltipConstraintsResolver.resolve(
        constraints: constraints,
        mediaQuery: mediaQuery,
        theme: theme,
      );

      expect(resolved.maxWidth, greaterThanOrEqualTo(resolved.minWidth));
      expect(resolved.maxWidth, lessThan(theme.tooltipMinWidth!));
      expect(resolved.minWidth, resolved.maxWidth);
    });

    test('applies theme card width when max is unconstrained in portrait', () {
      const constraints = BoxConstraints(maxWidth: double.infinity);
      const mediaQuery = MediaQueryData(size: Size(1024, 1366));

      final resolved = TooltipConstraintsResolver.resolve(
        constraints: constraints,
        mediaQuery: mediaQuery,
        theme: theme,
      );

      expect(resolved.maxWidth, 360);
    });

    test('returns unconstrained max width in landscape without theme cap', () {
      const constraints = BoxConstraints(maxWidth: 900);
      const mediaQuery = MediaQueryData(size: Size(1024, 600));

      const landscapeTheme = DashronymTheme(enableHover: false);

      final resolved = TooltipConstraintsResolver.resolve(
        constraints: constraints,
        mediaQuery: mediaQuery,
        theme: landscapeTheme,
      );

      expect(resolved.maxWidth, 600);
      expect(resolved.minWidth, 0);
    });

    test('returns zero max width when gutters exceed overlay width', () {
      const constraints = BoxConstraints(maxWidth: 12);
      const mediaQuery = MediaQueryData(size: Size(20, 400));
      const tightTheme = DashronymTheme(enableHover: false);

      final resolved = TooltipConstraintsResolver.resolve(
        constraints: constraints,
        mediaQuery: mediaQuery,
        theme: tightTheme,
      );

      expect(resolved.maxWidth, 0);
      expect(resolved.minWidth, 0);
    });
  });
}
