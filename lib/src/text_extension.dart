import 'package:flutter/material.dart';

import 'config.dart';
import 'parser.dart';
import 'registry.dart';
import 'theme.dart';

/// Convenience APIs for turning a plain [Text] into a glossary-aware widget.
///
/// The extension parses the text for known acronyms (via [AcronymRegistry]) and
/// replaces matches with interactive, accessible tooltip triggers while
/// preserving the original [Text] configuration (alignment, style, maxLines,
/// semantics, etc.).
extension DashronymsTextX on Text {
  /// Returns a [RichText] with inline glossary tooltips.
  ///
  /// Delegates to [dashronymsText] so the same documentation is available when
  /// calling the top-level helper directly.
  Widget dashronyms({
    required AcronymRegistry registry,
    DashronymConfig config = const DashronymConfig(),
    DashronymTheme theme = const DashronymTheme(),
    TextStyle? style,
    StrutStyle? strutStyle,
    TextAlign? textAlign,
    TextDirection? textDirection,
    Locale? locale,
    bool? softWrap,
    TextOverflow? overflow,
    int? maxLines,
    String? semanticsLabel,
    TextWidthBasis? textWidthBasis,
    TextHeightBehavior? textHeightBehavior,
    TextScaler? textScaler,
    Color? selectionColor,
  }) => dashronymsText(
    this,
    registry: registry,
    config: config,
    theme: theme,
    style: style,
    strutStyle: strutStyle,
    textAlign: textAlign,
    textDirection: textDirection,
    locale: locale,
    softWrap: softWrap,
    overflow: overflow,
    maxLines: maxLines,
    semanticsLabel: semanticsLabel,
    textWidthBasis: textWidthBasis,
    textHeightBehavior: textHeightBehavior,
    textScaler: textScaler,
    selectionColor: selectionColor,
  );
}

/// Returns a [RichText] that replaces matched acronyms with interactive tooltip
/// triggers.
///
/// The function parses [text.data] (or preserves [Text.textSpan] when the
/// source was created with `Text.rich`) using [registry] plus formatting
/// preferences from [config] and [theme]. Matches are rendered as widgets that
/// reveal inline definitions without breaking reading flow, while honoring
/// typography, semantics, and accessibility settings inherited from the
/// surrounding context.
Widget dashronymsText(
  Text text, {

  /// Acronym dictionary used to match and expand inline terms.
  required AcronymRegistry registry,

  /// Parsing behavior such as tokenization and matching rules.
  DashronymConfig config = const DashronymConfig(),

  /// Visual behavior for triggers and tooltips (underline, offsets, timings).
  DashronymTheme theme = const DashronymTheme(),

  /// Optional overrides mirroring [Text]'s constructor so callers can adjust
  /// presentation while letting this function manage the content.
  TextStyle? style,
  StrutStyle? strutStyle,
  TextAlign? textAlign,
  TextDirection? textDirection,
  Locale? locale,
  bool? softWrap,
  TextOverflow? overflow,
  int? maxLines,
  String? semanticsLabel,
  TextWidthBasis? textWidthBasis,
  TextHeightBehavior? textHeightBehavior,
  TextScaler? textScaler,
  Color? selectionColor,
}) {
  if (text.data == null) {
    return Text.rich(
      text.textSpan!,
      key: text.key,
      style: style ?? text.style,
      strutStyle: strutStyle ?? text.strutStyle,
      textAlign: textAlign ?? text.textAlign,
      textDirection: textDirection ?? text.textDirection,
      locale: locale ?? text.locale,
      softWrap: softWrap ?? text.softWrap,
      overflow: overflow ?? text.overflow,
      textScaler: textScaler ?? text.textScaler,
      maxLines: maxLines ?? text.maxLines,
      semanticsLabel: semanticsLabel ?? text.semanticsLabel,
      semanticsIdentifier: text.semanticsIdentifier,
      textWidthBasis: textWidthBasis ?? text.textWidthBasis,
      textHeightBehavior: textHeightBehavior ?? text.textHeightBehavior,
      selectionColor: selectionColor ?? text.selectionColor,
    );
  }

  return Builder(
    builder: (context) {
      final defaultTextStyle = DefaultTextStyle.of(context);

      TextStyle? effectiveStyle = style ?? text.style;
      if (effectiveStyle == null || effectiveStyle.inherit) {
        effectiveStyle = defaultTextStyle.style.merge(effectiveStyle);
      }
      if (MediaQuery.boldTextOf(context)) {
        effectiveStyle = effectiveStyle.merge(
          const TextStyle(fontWeight: FontWeight.bold),
        );
      }

      final spans = DashronymParser(
        registry: registry,
        config: config,
        theme: theme,
        baseStyle: effectiveStyle,
      ).parseToSpans(text.data!);

      return Text.rich(
        TextSpan(style: effectiveStyle, children: spans),
        key: text.key,
        style: style ?? text.style,
        strutStyle: strutStyle ?? text.strutStyle,
        textAlign: textAlign ?? text.textAlign,
        textDirection: textDirection ?? text.textDirection,
        locale: locale ?? text.locale,
        softWrap: softWrap ?? text.softWrap,
        overflow: overflow ?? text.overflow,
        textScaler: textScaler ?? text.textScaler,
        maxLines: maxLines ?? text.maxLines,
        semanticsLabel: semanticsLabel ?? text.semanticsLabel,
        semanticsIdentifier: text.semanticsIdentifier,
        textWidthBasis: textWidthBasis ?? text.textWidthBasis,
        textHeightBehavior: textHeightBehavior ?? text.textHeightBehavior,
        selectionColor: selectionColor ?? text.selectionColor,
      );
    },
  );
}
