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
  static const Object _sentinel = Object();

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
    this.tooltipFadeInCurve = Curves.easeOut,
    this.tooltipFadeOutCurve = Curves.easeIn,
    this.tooltipScaleInCurve = Curves.easeOut,
    this.tooltipScaleOutCurve = Curves.easeIn,
    this.tooltipScaleBegin = 0.95,
    this.tooltipScaleEnd = 1.0,
    this.tooltipMinWidth,
    this.tooltipMaxWidth,
  }) : assert(cardWidth > 0, 'cardWidth must be positive.'),
       assert(cardElevation >= 0, 'cardElevation cannot be negative.'),
       assert(tooltipScaleBegin > 0, 'tooltipScaleBegin must be positive.'),
       assert(
         tooltipScaleEnd >= tooltipScaleBegin,
         'tooltipScaleEnd must be >= tooltipScaleBegin.',
       ),
       assert(
         tooltipMinWidth == null || tooltipMinWidth >= 0,
         'tooltipMinWidth cannot be negative.',
       ),
       assert(
         tooltipMaxWidth == null || tooltipMaxWidth > 0,
         'tooltipMaxWidth must be positive when provided.',
       ),
       assert(
         tooltipMinWidth == null ||
             tooltipMaxWidth == null ||
             tooltipMinWidth <= tooltipMaxWidth,
         'tooltipMinWidth must be <= tooltipMaxWidth.',
       );

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

  /// Curve used when fading the tooltip into view.
  final Curve tooltipFadeInCurve;

  /// Curve used when fading the tooltip out of view.
  final Curve tooltipFadeOutCurve;

  /// Curve used when scaling the tooltip into view.
  final Curve tooltipScaleInCurve;

  /// Curve used when scaling the tooltip out of view.
  final Curve tooltipScaleOutCurve;

  /// Starting scale factor applied to the tooltip during the show animation.
  final double tooltipScaleBegin;

  /// Ending scale factor applied to the tooltip during the show animation.
  final double tooltipScaleEnd;

  /// Minimum width constraint applied to the tooltip card.
  final double? tooltipMinWidth;

  /// Maximum width constraint applied to the tooltip card.
  ///
  /// Falls back to [cardWidth] when `null`.
  final double? tooltipMaxWidth;

  /// Creates a copy with the provided fields replaced.
  DashronymTheme copyWith({
    bool? underline,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
    TextStyle? acronymStyle,
    double? cardWidth,
    double? cardElevation,
    EdgeInsets? cardPadding,
    Duration? hoverShowDelay,
    Object? hoverHideDelay = _sentinel,
    Duration? tooltipFadeDuration,
    bool? enableHover,
    double? cardBorderRadius,
    IconData? cardIcon,
    IconData? cardCloseIcon,
    Color? cardIconColor,
    TextStyle? cardTitleStyle,
    TextStyle? cardSubtitleStyle,
    EdgeInsets? cardContentPadding,
    double? cardMinLeadingWidth,
    Offset? tooltipOffset,
    Curve? tooltipFadeInCurve,
    Curve? tooltipFadeOutCurve,
    Curve? tooltipScaleInCurve,
    Curve? tooltipScaleOutCurve,
    double? tooltipScaleBegin,
    double? tooltipScaleEnd,
    double? tooltipMinWidth,
    double? tooltipMaxWidth,
  }) {
    return DashronymTheme(
      underline: underline ?? this.underline,
      decorationStyle: decorationStyle ?? this.decorationStyle,
      decorationThickness: decorationThickness ?? this.decorationThickness,
      acronymStyle: acronymStyle ?? this.acronymStyle,
      cardWidth: cardWidth ?? this.cardWidth,
      cardElevation: cardElevation ?? this.cardElevation,
      cardPadding: cardPadding ?? this.cardPadding,
      hoverShowDelay: hoverShowDelay ?? this.hoverShowDelay,
      hoverHideDelay: identical(hoverHideDelay, _sentinel)
          ? this.hoverHideDelay
          : hoverHideDelay as Duration?,
      tooltipFadeDuration: tooltipFadeDuration ?? this.tooltipFadeDuration,
      enableHover: enableHover ?? this.enableHover,
      cardBorderRadius: cardBorderRadius ?? this.cardBorderRadius,
      cardIcon: cardIcon ?? this.cardIcon,
      cardCloseIcon: cardCloseIcon ?? this.cardCloseIcon,
      cardIconColor: cardIconColor ?? this.cardIconColor,
      cardTitleStyle: cardTitleStyle ?? this.cardTitleStyle,
      cardSubtitleStyle: cardSubtitleStyle ?? this.cardSubtitleStyle,
      cardContentPadding: cardContentPadding ?? this.cardContentPadding,
      cardMinLeadingWidth: cardMinLeadingWidth ?? this.cardMinLeadingWidth,
      tooltipOffset: tooltipOffset ?? this.tooltipOffset,
      tooltipFadeInCurve: tooltipFadeInCurve ?? this.tooltipFadeInCurve,
      tooltipFadeOutCurve: tooltipFadeOutCurve ?? this.tooltipFadeOutCurve,
      tooltipScaleInCurve: tooltipScaleInCurve ?? this.tooltipScaleInCurve,
      tooltipScaleOutCurve: tooltipScaleOutCurve ?? this.tooltipScaleOutCurve,
      tooltipScaleBegin: tooltipScaleBegin ?? this.tooltipScaleBegin,
      tooltipScaleEnd: tooltipScaleEnd ?? this.tooltipScaleEnd,
      tooltipMinWidth: tooltipMinWidth ?? this.tooltipMinWidth,
      tooltipMaxWidth: tooltipMaxWidth ?? this.tooltipMaxWidth,
    );
  }

  /// Returns a theme that falls back to [this] when [other] omits values.
  DashronymTheme merge(DashronymTheme? other) {
    if (other == null) return this;
    return copyWith(
      underline: other.underline,
      decorationStyle: other.decorationStyle,
      decorationThickness: other.decorationThickness,
      acronymStyle: other.acronymStyle,
      cardWidth: other.cardWidth,
      cardElevation: other.cardElevation,
      cardPadding: other.cardPadding,
      hoverShowDelay: other.hoverShowDelay,
      hoverHideDelay: other.hoverHideDelay,
      tooltipFadeDuration: other.tooltipFadeDuration,
      enableHover: other.enableHover,
      cardBorderRadius: other.cardBorderRadius,
      cardIcon: other.cardIcon,
      cardCloseIcon: other.cardCloseIcon,
      cardIconColor: other.cardIconColor,
      cardTitleStyle: other.cardTitleStyle,
      cardSubtitleStyle: other.cardSubtitleStyle,
      cardContentPadding: other.cardContentPadding,
      cardMinLeadingWidth: other.cardMinLeadingWidth,
      tooltipOffset: other.tooltipOffset,
      tooltipFadeInCurve: other.tooltipFadeInCurve,
      tooltipFadeOutCurve: other.tooltipFadeOutCurve,
      tooltipScaleInCurve: other.tooltipScaleInCurve,
      tooltipScaleOutCurve: other.tooltipScaleOutCurve,
      tooltipScaleBegin: other.tooltipScaleBegin,
      tooltipScaleEnd: other.tooltipScaleEnd,
      tooltipMinWidth: other.tooltipMinWidth,
      tooltipMaxWidth: other.tooltipMaxWidth,
    );
  }
}
