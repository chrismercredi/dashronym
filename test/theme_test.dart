import 'package:dashronym/dashronym.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('DashronymTheme exposes default values', () {
    const theme = DashronymTheme();

    expect(theme.underline, isTrue);
    expect(theme.decorationStyle, TextDecorationStyle.dotted);
    expect(theme.cardWidth, 320);
    expect(theme.cardElevation, 8);
    expect(theme.hoverShowDelay, const Duration(milliseconds: 250));
    expect(theme.hoverHideDelay, isNull);
    expect(theme.enableHover, isTrue);
    expect(theme.cardBorderRadius, 12);
    expect(theme.cardIcon, Icons.info_outline);
    expect(theme.cardCloseIcon, Icons.close);
    expect(theme.tooltipOffset, const Offset(0, 6));
    expect(theme.tooltipFadeDuration, const Duration(milliseconds: 150));
  });

  test('DashronymTheme accepts custom overrides', () {
    const theme = DashronymTheme(
      underline: false,
      decorationStyle: TextDecorationStyle.double,
      cardWidth: 200,
      cardElevation: 4,
      hoverShowDelay: Duration.zero,
      hoverHideDelay: const Duration(milliseconds: 400),
      tooltipFadeDuration: const Duration(milliseconds: 250),
      enableHover: false,
      cardBorderRadius: 4,
      cardIcon: Icons.star,
      cardCloseIcon: Icons.cancel,
      tooltipOffset: Offset(2, 8),
    );

    expect(theme.underline, isFalse);
    expect(theme.decorationStyle, TextDecorationStyle.double);
    expect(theme.cardWidth, 200);
    expect(theme.cardElevation, 4);
    expect(theme.hoverShowDelay, Duration.zero);
    expect(theme.hoverHideDelay, const Duration(milliseconds: 400));
    expect(theme.enableHover, isFalse);
    expect(theme.cardBorderRadius, 4);
    expect(theme.cardIcon, Icons.star);
    expect(theme.cardCloseIcon, Icons.cancel);
    expect(theme.tooltipOffset, const Offset(2, 8));
    expect(theme.tooltipFadeDuration, const Duration(milliseconds: 250));
  });
}
