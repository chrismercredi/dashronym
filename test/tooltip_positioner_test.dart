import 'dart:math' as math;

import 'package:dashronym/src/tooltip_positioner.dart';
import 'package:dashronym/src/theme.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const theme = DashronymTheme(tooltipOffset: Offset(0, 6), enableHover: false);

  group('AcronymTooltipPositioner.baseFollowerOffset', () {
    test('returns offset below anchor for LTR', () {
      final anchorSize = const Size(120, 20);
      final offset = AcronymTooltipPositioner.baseFollowerOffset(
        anchorSize: anchorSize,
        theme: theme,
        direction: TextDirection.ltr,
      );

      expect(offset.dx, 0);
      expect(offset.dy, anchorSize.height + theme.tooltipOffset.dy);
    });

    test('uses tooltip offset for RTL layout without pre-shift', () {
      const rtlTheme = DashronymTheme(
        cardWidth: 300,
        tooltipOffset: Offset(4, 6),
        enableHover: false,
      );
      final anchorSize = const Size(120, 20);

      final offset = AcronymTooltipPositioner.baseFollowerOffset(
        anchorSize: anchorSize,
        theme: rtlTheme,
        direction: TextDirection.rtl,
      );

      expect(offset.dx, rtlTheme.tooltipOffset.dx);
      expect(offset.dy, anchorSize.height + rtlTheme.tooltipOffset.dy);
    });
  });

  group('AcronymTooltipPositioner.resolveFollowerOffset', () {
    test('matches base offset when tooltip fits inside viewport', () {
      const overlaySize = Size(400, 400);
      const anchorTopLeft = Offset(50, 10);
      const anchorSize = Size(100, 20);
      const tooltipSize = Size(150, 80);
      const padding = EdgeInsets.zero;

      final offset = AcronymTooltipPositioner.resolveFollowerOffset(
        overlaySize: overlaySize,
        anchorTopLeft: anchorTopLeft,
        anchorSize: anchorSize,
        tooltipSize: tooltipSize,
        theme: theme,
        padding: padding,
        keyboardInset: 0,
        direction: TextDirection.ltr,
      );

      expect(
        offset,
        AcronymTooltipPositioner.baseFollowerOffset(
          anchorSize: anchorSize,
          theme: theme,
          direction: TextDirection.ltr,
        ),
      );
    });

    test('clamps horizontally when tooltip would overflow right edge', () {
      const overlaySize = Size(200, 300);
      const anchorTopLeft = Offset(150, 10);
      const anchorSize = Size(80, 20);
      const tooltipSize = Size(180, 80);

      final offset = AcronymTooltipPositioner.resolveFollowerOffset(
        overlaySize: overlaySize,
        anchorTopLeft: anchorTopLeft,
        anchorSize: anchorSize,
        tooltipSize: tooltipSize,
        theme: theme,
        padding: EdgeInsets.zero,
        keyboardInset: 0,
        direction: TextDirection.ltr,
      );

      // Desired left would exceed the viewport; follower clamps to the margin,
      // then applies the default nudge to stay off the edge.
      expect(anchorTopLeft.dx + offset.dx, 8);
    });

    test('flips above anchor when space below is insufficient', () {
      const overlaySize = Size(400, 400);
      const anchorTopLeft = Offset(50, 340);
      const anchorSize = Size(80, 20);
      const tooltipSize = Size(180, 80);

      final offset = AcronymTooltipPositioner.resolveFollowerOffset(
        overlaySize: overlaySize,
        anchorTopLeft: anchorTopLeft,
        anchorSize: anchorSize,
        tooltipSize: tooltipSize,
        theme: theme,
        padding: EdgeInsets.zero,
        keyboardInset: 0,
        direction: TextDirection.ltr,
      );

      final actualTop = anchorTopLeft.dy + offset.dy;
      expect(
        actualTop + tooltipSize.height,
        lessThan(overlaySize.height - 8),
      ); // respects margin
      expect(
        actualTop,
        anchorTopLeft.dy - tooltipSize.height - theme.tooltipOffset.dy,
      );
    });

    test('nudges inward when clamped to horizontal edge and space remains', () {
      const overlaySize = Size(300, 200);
      const anchorTopLeft = Offset(260, 10);
      const anchorSize = Size(80, 20);
      const tooltipSize = Size(180, 80);
      final offset = AcronymTooltipPositioner.resolveFollowerOffset(
        overlaySize: overlaySize,
        anchorTopLeft: anchorTopLeft,
        anchorSize: anchorSize,
        tooltipSize: tooltipSize,
        theme: theme,
        padding: EdgeInsets.zero,
        keyboardInset: 0,
        direction: TextDirection.ltr,
      );

      final actualLeft = anchorTopLeft.dx + offset.dx;
      // Expected max left before nudge would be 112; default nudge moves it inward.
      expect(actualLeft, 104);
    });

    test('nudges inward when clamped to left edge and space remains', () {
      const overlaySize = Size(300, 200);
      const anchorTopLeft = Offset(0, 10);
      const anchorSize = Size(80, 20);
      const tooltipSize = Size(200, 80);

      final offset = AcronymTooltipPositioner.resolveFollowerOffset(
        overlaySize: overlaySize,
        anchorTopLeft: anchorTopLeft,
        anchorSize: anchorSize,
        tooltipSize: tooltipSize,
        theme: theme,
        padding: EdgeInsets.zero,
        keyboardInset: 0,
        direction: TextDirection.ltr,
      );

      final actualLeft = anchorTopLeft.dx + offset.dx;
      expect(actualLeft, 16); // 8 margin + 8 nudge.
    });

    test('reserves vertical margin when space is constrained', () {
      const overlaySize = Size(200, 120);
      const anchorTopLeft = Offset(20, 30);
      const anchorSize = Size(80, 20);
      const tooltipSize = Size(180, 110);

      final offset = AcronymTooltipPositioner.resolveFollowerOffset(
        overlaySize: overlaySize,
        anchorTopLeft: anchorTopLeft,
        anchorSize: anchorSize,
        tooltipSize: tooltipSize,
        theme: theme,
        padding: EdgeInsets.zero,
        keyboardInset: 0,
        direction: TextDirection.ltr,
      );

      final actualTop = anchorTopLeft.dy + offset.dy;
      final expectedMargin = math.max(
        0.0,
        (overlaySize.height - tooltipSize.height) / 2.0,
      );
      expect(actualTop, expectedMargin);
      expect(
        actualTop + tooltipSize.height,
        lessThanOrEqualTo(overlaySize.height),
      );
    });

    test('collapses horizontal margin when tooltip spans viewport width', () {
      const overlaySize = Size(200, 300);
      const anchorTopLeft = Offset(60, 20);
      const anchorSize = Size(80, 20);
      const tooltipSize = Size(200, 120);

      final offset = AcronymTooltipPositioner.resolveFollowerOffset(
        overlaySize: overlaySize,
        anchorTopLeft: anchorTopLeft,
        anchorSize: anchorSize,
        tooltipSize: tooltipSize,
        theme: theme,
        padding: EdgeInsets.zero,
        keyboardInset: 0,
        direction: TextDirection.ltr,
      );

      final actualLeft = anchorTopLeft.dx + offset.dx;
      expect(actualLeft, 0);
      expect(actualLeft + tooltipSize.width, overlaySize.width);
    });

    test('clamps to padding when tooltip wider than overlay', () {
      const overlaySize = Size(160, 200);
      const anchorTopLeft = Offset(40, 20);
      const anchorSize = Size(80, 20);
      const tooltipSize = Size(200, 80);

      final offset = AcronymTooltipPositioner.resolveFollowerOffset(
        overlaySize: overlaySize,
        anchorTopLeft: anchorTopLeft,
        anchorSize: anchorSize,
        tooltipSize: tooltipSize,
        theme: theme,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        keyboardInset: 0,
        direction: TextDirection.ltr,
      );

      final actualLeft = anchorTopLeft.dx + offset.dx;
      expect(actualLeft, 12);
    });

    test('collapses vertical margin when tooltip height fills viewport', () {
      const overlaySize = Size(300, 240);
      const anchorTopLeft = Offset(40, 80);
      const anchorSize = Size(80, 20);
      const tooltipSize = Size(220, 240);

      final offset = AcronymTooltipPositioner.resolveFollowerOffset(
        overlaySize: overlaySize,
        anchorTopLeft: anchorTopLeft,
        anchorSize: anchorSize,
        tooltipSize: tooltipSize,
        theme: theme,
        padding: EdgeInsets.zero,
        keyboardInset: 0,
        direction: TextDirection.ltr,
      );

      final actualTop = anchorTopLeft.dy + offset.dy;
      expect(actualTop, 0);
    });
  });
}
