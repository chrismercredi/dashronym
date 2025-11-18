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
    expect(theme.tooltipFadeInCurve, Curves.easeOut);
    expect(theme.tooltipFadeOutCurve, Curves.easeIn);
    expect(theme.tooltipScaleInCurve, Curves.easeOut);
    expect(theme.tooltipScaleOutCurve, Curves.easeIn);
    expect(theme.tooltipScaleBegin, 0.95);
    expect(theme.tooltipScaleEnd, 1.0);
    expect(theme.tooltipMinWidth, isNull);
    expect(theme.tooltipMaxWidth, isNull);
  });

  test('DashronymTheme accepts custom overrides', () {
    const theme = DashronymTheme(
      underline: false,
      decorationStyle: TextDecorationStyle.double,
      cardWidth: 200,
      cardElevation: 4,
      hoverShowDelay: Duration.zero,
      hoverHideDelay: Duration(milliseconds: 400),
      tooltipFadeDuration: Duration(milliseconds: 250),
      enableHover: false,
      cardBorderRadius: 4,
      cardIcon: Icons.star,
      cardCloseIcon: Icons.cancel,
      tooltipOffset: Offset(2, 8),
      tooltipFadeInCurve: Curves.easeInOut,
      tooltipFadeOutCurve: Curves.easeInExpo,
      tooltipScaleInCurve: Curves.decelerate,
      tooltipScaleOutCurve: Curves.linear,
      tooltipScaleBegin: 0.8,
      tooltipScaleEnd: 1.1,
      tooltipMinWidth: 120,
      tooltipMaxWidth: 260,
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
    expect(theme.tooltipFadeInCurve, Curves.easeInOut);
    expect(theme.tooltipFadeOutCurve, Curves.easeInExpo);
    expect(theme.tooltipScaleInCurve, Curves.decelerate);
    expect(theme.tooltipScaleOutCurve, Curves.linear);
    expect(theme.tooltipScaleBegin, 0.8);
    expect(theme.tooltipScaleEnd, 1.1);
    expect(theme.tooltipMinWidth, 120);
    expect(theme.tooltipMaxWidth, 260);
  });

  test('DashronymTheme.copyWith overrides selected fields', () {
    const base = DashronymTheme(
      hoverHideDelay: Duration(milliseconds: 300),
      tooltipScaleBegin: 0.9,
      tooltipMinWidth: 100,
    );

    final copy = base.copyWith(
      underline: false,
      hoverHideDelay: null,
      tooltipScaleEnd: 1.05,
      tooltipMaxWidth: 280,
    );

    expect(copy.underline, isFalse);
    expect(copy.hoverHideDelay, isNull);
    expect(copy.tooltipScaleBegin, 0.9);
    expect(copy.tooltipScaleEnd, 1.05);
    expect(copy.tooltipMinWidth, 100);
    expect(copy.tooltipMaxWidth, 280);
  });

  test('DashronymTheme.copyWith retains hoverHideDelay when omitted', () {
    const base = DashronymTheme(hoverHideDelay: Duration(milliseconds: 120));
    final copy = base.copyWith(cardWidth: 400);
    expect(copy.hoverHideDelay, const Duration(milliseconds: 120));
    expect(copy.cardWidth, 400);
  });

  test('DashronymTheme.merge prefers other values when provided', () {
    const base = DashronymTheme(cardWidth: 320);
    const other = DashronymTheme(
      cardWidth: 280,
      tooltipScaleBegin: 0.85,
      tooltipScaleEnd: 1.0,
    );

    final merged = base.merge(other);

    expect(merged.cardWidth, 280);
    expect(merged.tooltipScaleBegin, 0.85);
    expect(merged.tooltipScaleEnd, 1.0);
  });
}
