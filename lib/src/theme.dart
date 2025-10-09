import 'package:flutter/material.dart';

/// Visual customization for inline acronym triggers and their tooltip cards.
///
/// Configure underline treatment, card styling, pointer/keyboard behavior,
/// and tooltip positioning by supplying a tailored instance to dashronym APIs.
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
    this.cardBorderRadius = 12,
    this.cardIcon = Icons.info_outline,
    this.cardCloseIcon = Icons.close,
    this.cardIconColor,
    this.cardTitleStyle,
    this.cardSubtitleStyle,
    this.cardContentPadding = const EdgeInsets.symmetric(
      horizontal: 8,
      vertical: 4,
    ),
    this.cardMinLeadingWidth = 24,
    this.tooltipOffset = const Offset(0, 6),
  }) : assert(cardWidth > 0, 'cardWidth must be positive.'),
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

  /// The border radius used for the tooltip card.
  final double cardBorderRadius;

  /// The leading icon shown inside the tooltip.
  final IconData cardIcon;

  /// The trailing icon used for the close button.
  final IconData cardCloseIcon;

  /// The color applied to icons inside the tooltip card.
  final Color? cardIconColor;

  /// The text style used for the acronym title.
  final TextStyle? cardTitleStyle;

  /// The text style used for the description subtitle.
  final TextStyle? cardSubtitleStyle;

  /// Additional padding applied to the [ListTile] content.
  final EdgeInsets cardContentPadding;

  /// Minimum width reserved for the leading widget.
  final double cardMinLeadingWidth;

  /// Offset applied to the tooltip relative to the trigger.
  final Offset tooltipOffset;
}
