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
    expect(theme.enableHover, isTrue);
    expect(theme.cardBorderRadius, 12);
    expect(theme.cardIcon, Icons.info_outline);
    expect(theme.cardCloseIcon, Icons.close);
    expect(theme.tooltipOffset, const Offset(0, 6));
  });

  test('DashronymTheme accepts custom overrides', () {
    const theme = DashronymTheme(
      underline: false,
      decorationStyle: TextDecorationStyle.double,
      cardWidth: 200,
      cardElevation: 4,
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
    expect(theme.enableHover, isFalse);
    expect(theme.cardBorderRadius, 4);
    expect(theme.cardIcon, Icons.star);
    expect(theme.cardCloseIcon, Icons.cancel);
    expect(theme.tooltipOffset, const Offset(2, 8));
  });
}
