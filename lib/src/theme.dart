import 'package:flutter/material.dart';

/// Visual customization for inline acronym triggers and their tooltip cards.
///
/// Supply an instance to dashronym APIs (e.g., the inline acronym widget or
/// text extension) to control underline behavior, hover timing, tooltip
/// animation, card geometry, and iconography.
///
/// Example:
/// ```dart
/// const theme = DashronymTheme(
///   underline: true,
///   decorationStyle: TextDecorationStyle.dotted,
///   tooltipFadeDuration: Duration(milliseconds: 200),
///   cardWidth: 300,
///   cardBorderRadius: 10,
///   cardIcon: Icons.info_outline,
///   tooltipOffset: Offset(0, 8),
/// );
/// ```
class DashronymTheme {
  /// Creates a theme describing trigger styling and tooltip card presentation.
  ///
  /// Asserts that [cardWidth] is positive and [cardElevation] is non-negative.
  const DashronymTheme({
    this.underline = true,
    this.decorationStyle = TextDecorationStyle.dotted,
    this.decorationThickness,
    this.acronymStyle,
    this.cardWidth = 320,
    this.cardElevation = 8,
    this.cardPadding = const EdgeInsets.all(8),
    this.hoverShowDelay = const Duration(milliseconds: 250),
    this.hoverHideDelay,
    this.tooltipFadeDuration = const Duration(milliseconds: 150),
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

  /// Whether matched acronyms are underlined in the inline trigger.
  final bool underline;

  /// The [TextDecorationStyle] used when [underline] is `true`.
  final TextDecorationStyle decorationStyle;

  /// The underline thickness; when `null`, the base text style decides.
  final double? decorationThickness;

  /// Style override for the inline acronym text (e.g., weight or color).
  final TextStyle? acronymStyle;

  /// Maximum width of the tooltip card in logical pixels.
  final double cardWidth;

  /// Material elevation of the tooltip card.
  final double cardElevation;

  /// Inner padding for the tooltip card's content area.
  final EdgeInsets cardPadding;

  /// Delay before showing the tooltip when the pointer hovers the trigger.
  final Duration hoverShowDelay;

  /// Delay before hiding after the pointer leaves the trigger.
  ///
  /// If `null`, defaults to [hoverShowDelay].
  final Duration? hoverHideDelay;

  /// Duration of the tooltip's fade in/out animation.
  final Duration tooltipFadeDuration;

  /// Enables hover-triggered behavior on desktop/web when `true`.
  final bool enableHover;

  /// Corner radius for the tooltip card's rounded rectangle.
  final double cardBorderRadius;

  /// Leading icon displayed inside the tooltip card.
  final IconData cardIcon;

  /// Trailing close icon used by the tooltip's dismiss button.
  final IconData cardCloseIcon;

  /// Color applied to icons inside the tooltip card; falls back to theme.
  final Color? cardIconColor;

  /// Text style for the acronym title in the card.
  final TextStyle? cardTitleStyle;

  /// Text style for the description subtitle in the card.
  final TextStyle? cardSubtitleStyle;

  /// Extra padding applied to the [ListTile] content within the card.
  final EdgeInsets cardContentPadding;

  /// Minimum width reserved for the card's leading widget.
  final double cardMinLeadingWidth;

  /// Offset of the tooltip relative to the inline trigger's origin.
  final Offset tooltipOffset;
}
