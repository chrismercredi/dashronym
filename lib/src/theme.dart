import 'package:flutter/material.dart';

/// Visual customization for inline acronym and its overlay card.
class DashronymTheme {
  const DashronymTheme({
    this.underline = true,
    this.decorationStyle = TextDecorationStyle.dotted,
    this.decorationThickness,
    this.acronymStyle,
    this.cardWidth = 320,
    this.cardElevation = 8,
    this.cardPadding = const EdgeInsets.all(8),
    this.hoverShowDelay = const Duration(milliseconds: 250),
    this.enableHover = true,
  })  : assert(cardWidth > 0, 'cardWidth must be positive.'),
        assert(cardElevation >= 0, 'cardElevation cannot be negative.');

  /// Whether this theme underlines matched acronyms.
  final bool underline;

  /// The decoration style applied when [underline] is true.
  final TextDecorationStyle decorationStyle;

  /// The explicit underline thickness, or null to defer to the text style.
  final double? decorationThickness;

  /// The style override used for acronym text.
  final TextStyle? acronymStyle;

  /// The maximum width this tooltip card uses.
  final double cardWidth;

  /// The Material elevation of the tooltip card.
  final double cardElevation;

  /// The padding applied inside the tooltip card.
  final EdgeInsets cardPadding;

  /// The delay before showing the card on hover.
  final Duration hoverShowDelay;

  /// Whether this theme enables hover-triggered cards on desktop platforms.
  final bool enableHover;
}
