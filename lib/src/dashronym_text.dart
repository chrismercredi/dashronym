import 'package:flutter/material.dart';

import 'config.dart';
import 'acronym_parser.dart';
import 'acronym_inline.dart';
import 'registry.dart';
import 'dashronym_theme.dart';

/// Renders text with inline, accessible glossary tooltips for matched acronyms.
///
/// This widget scans [text] using the provided [AcronymRegistry] and replaces
/// matches with interactive [WidgetSpan]s (see [AcronymInline]) while
/// preserving your typography, layout, and semantics. Non-matching text is
/// emitted as regular [TextSpan]s. The result is painted by a [RichText]
/// configured from the surrounding [DefaultTextStyle] and the provided
/// constructor parameters.
///
/// Example:
/// ```dart
/// final registry = AcronymRegistry({
///   'SDK': 'Software Development Kit',
///   'API': 'Application Programming Interface',
/// });
///
/// const theme = DashronymTheme(underline: true);
///
/// const text = 'Install the SDK to use the API.';
///
/// DashronymText(
///   text,
///   registry: registry,
///   theme: theme,
///   style: TextStyle(fontSize: 14),
/// )
/// ```
class DashronymText extends StatelessWidget {
  /// Creates a text widget that decorates matched acronyms with glossary tooltips.
  const DashronymText(
    this.text, {
    super.key,
    required this.registry,
    this.config = const DashronymConfig(),
    this.theme = const DashronymTheme(),
    this.tooltipBuilder,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaler,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
  });

  /// The plain text to render and scan for acronyms.
  final String text;

  /// Acronym definitions used to resolve matches found in [text].
  final AcronymRegistry registry;

  /// Parser options such as markers, min/max lengths, and bare acronym support.
  final DashronymConfig config;

  /// Visual customization for the inline trigger and the tooltip card.
  final DashronymTheme theme;

  /// Optional builder for a custom tooltip widget.
  ///
  /// When provided, this is passed down to the underlying inline controls so
  /// you can replace the stock [DashronymTooltipCard] while keeping the same
  /// trigger, overlay, and semantics behavior.
  final DashronymTooltipBuilder? tooltipBuilder;

  /// Base text style for the output spans.
  ///
  /// If `null` or if [TextStyle.inherit] is `true`, this is merged with
  /// [DefaultTextStyle.of] to produce the effective style.
  final TextStyle? style;

  /// Strut configuration forwarded to the underlying [RichText].
  final StrutStyle? strutStyle;

  /// Horizontal alignment for the rendered text.
  final TextAlign? textAlign;

  /// Explicit text direction override (otherwise inherited).
  final TextDirection? textDirection;

  /// Locale used to select fonts.
  final Locale? locale;

  /// Whether the text should soft-wrap at line breaks.
  final bool? softWrap;

  /// Overflow behavior at the layout boundary.
  final TextOverflow? overflow;

  /// Modern text scaling configuration.
  final TextScaler? textScaler;

  /// Maximum number of lines to display.
  final int? maxLines;

  /// Optional semantics label read by accessibility services.
  ///
  /// When provided, the visual [RichText] is excluded from semantics and this
  /// label is exposed instead.
  final String? semanticsLabel;

  /// Basis for computing text width.
  final TextWidthBasis? textWidthBasis;

  /// Text height behavior override.
  final TextHeightBehavior? textHeightBehavior;

  /// Selection highlight color.
  final Color? selectionColor;

  @override
  Widget build(BuildContext context) {
    final defaultTextStyle = DefaultTextStyle.of(context);
    final providedStyle = style;

    // Derive effective style by merging with the inherited default.
    TextStyle resolvedStyle;
    if (providedStyle == null || providedStyle.inherit) {
      resolvedStyle = defaultTextStyle.style.merge(providedStyle);
    } else {
      resolvedStyle = providedStyle;
    }
    if (MediaQuery.boldTextOf(context)) {
      resolvedStyle = resolvedStyle.merge(
        const TextStyle(fontWeight: FontWeight.bold),
      );
    }

    // Resolve layout defaults from the ambient DefaultTextStyle.
    final effectiveTextAlign =
        textAlign ?? defaultTextStyle.textAlign ?? TextAlign.start;
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
    final effectiveTextScaler = textScaler ?? MediaQuery.textScalerOf(context);

    // Parse the text into spans with inline tooltip widgets.
    final spans = DashronymParser(
      registry: registry,
      config: config,
      theme: theme,
      baseStyle: resolvedStyle,
      tooltipBuilder: tooltipBuilder,
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

    // If a semantics label is provided, expose it and hide the visual tree.
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
