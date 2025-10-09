import 'package:flutter/material.dart';

import 'config.dart';
import 'parser.dart';
import 'registry.dart';
import 'theme.dart';

/// A widget that renders a string with dashronym tooltips applied.
class DashronymText extends StatelessWidget {
  const DashronymText(
    this.text, {
    super.key,
    required this.registry,
    this.config = const DashronymConfig(),
    this.theme = const DashronymTheme(),
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaleFactor,
    this.textScaler,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
  });

  /// The plain text this widget renders.
  final String text;

  /// The acronym definitions this widget looks up.
  final AcronymRegistry registry;

  /// The parser configuration applied when scanning [text].
  final DashronymConfig config;

  /// The visual customization for tooltip and inline styling.
  final DashronymTheme theme;

  /// The base text style applied to the rendered spans.
  final TextStyle? style;

  /// The strut configuration forwarded to [RichText].
  final StrutStyle? strutStyle;

  /// The horizontal alignment for the rendered text.
  final TextAlign? textAlign;

  /// The explicit text direction override.
  final TextDirection? textDirection;

  /// The locale used to select fonts.
  final Locale? locale;

  /// Whether this text should soft wrap.
  final bool? softWrap;

  /// The overflow behaviour at the edge of the layout box.
  final TextOverflow? overflow;

  /// The linear text scaling factor (deprecated in Flutter but still surfaced).
  final double? textScaleFactor;

  /// The modern text scaling configuration.
  final TextScaler? textScaler;

  /// The maximum number of lines to display.
  final int? maxLines;

  /// The semantics label read by accessibility services.
  final String? semanticsLabel;

  /// The basis used to calculate text width.
  final TextWidthBasis? textWidthBasis;

  /// The text height behaviour override.
  final TextHeightBehavior? textHeightBehavior;

  /// The selection highlight colour.
  final Color? selectionColor;

  @override
  Widget build(BuildContext context) {
    assert(
      textScaler == null || textScaleFactor == null,
      'textScaleFactor is deprecated and cannot be specified when textScaler is specified.',
    );

    final defaultTextStyle = DefaultTextStyle.of(context);
    final providedStyle = style;
    TextStyle resolvedStyle;
    if (providedStyle == null || providedStyle.inherit) {
      resolvedStyle = defaultTextStyle.style.merge(providedStyle);
    } else {
      resolvedStyle = providedStyle;
    }
    if (MediaQuery.boldTextOf(context)) {
      resolvedStyle =
          resolvedStyle.merge(const TextStyle(fontWeight: FontWeight.bold));
    }

    final effectiveTextAlign = textAlign ?? defaultTextStyle.textAlign ?? TextAlign.start;
    final effectiveSoftWrap = softWrap ?? defaultTextStyle.softWrap;
    final effectiveMaxLines = maxLines ?? defaultTextStyle.maxLines;
    final effectiveOverflow =
        overflow ?? resolvedStyle.overflow ?? defaultTextStyle.overflow;
    final effectiveTextWidthBasis =
        textWidthBasis ?? defaultTextStyle.textWidthBasis;
    final effectiveTextHeightBehavior =
        textHeightBehavior ??
        defaultTextStyle.textHeightBehavior ??
        DefaultTextHeightBehavior.maybeOf(context);

    final effectiveTextScaler = switch ((textScaler, textScaleFactor)) {
      (final TextScaler scaler, _) => scaler,
      (null, final double scale) => TextScaler.linear(scale),
      (null, null) => MediaQuery.textScalerOf(context),
    };

    final spans = DashronymParser(
      registry: registry,
      config: config,
      theme: theme,
      baseStyle: resolvedStyle,
    ).parseToSpans(text);

    Widget result = RichText(
      textAlign: effectiveTextAlign,
      textDirection: textDirection,
      locale: locale,
      softWrap: effectiveSoftWrap,
      overflow: effectiveOverflow,
      textScaler: effectiveTextScaler,
      maxLines: effectiveMaxLines,
      strutStyle: strutStyle,
      textWidthBasis: effectiveTextWidthBasis,
      textHeightBehavior: effectiveTextHeightBehavior,
      selectionColor: selectionColor,
      text: TextSpan(style: resolvedStyle, children: spans),
    );

    if (semanticsLabel != null) {
      result = Semantics(
        label: semanticsLabel,
        textDirection: textDirection,
        child: ExcludeSemantics(excluding: true, child: result),
      );
    }

    return result;
  }
}
