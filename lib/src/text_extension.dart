import 'package:flutter/material.dart';

import 'config.dart';
import 'parser.dart';
import 'registry.dart';
import 'theme.dart';

/// Extension on [Text] for ergonomic dashronym usage.
extension DashronymsTextX on Text {
  /// Returns a [RichText] that replaces matched acronyms with interactive
  /// glossary tooltips.
  ///
  /// Parses [data] (or [textSpan] when present) using the supplied [registry]
  /// and formatting preferences so screen readers and pointer users can reveal
  /// inline definitions without leaving the flow of text.
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
  }) {
    // If this [Text] was created with [Text.rich], preserve it as-is.
    if (data == null) {
      return Text.rich(
        textSpan!,
        key: key,
        style: style ?? this.style,
        strutStyle: strutStyle ?? this.strutStyle,
        textAlign: textAlign ?? this.textAlign,
        textDirection: textDirection ?? this.textDirection,
        locale: locale ?? this.locale,
        softWrap: softWrap ?? this.softWrap,
        overflow: overflow ?? this.overflow,
        textScaler: textScaler ?? this.textScaler,
        maxLines: maxLines ?? this.maxLines,
        semanticsLabel: semanticsLabel ?? this.semanticsLabel,
        semanticsIdentifier: semanticsIdentifier,
        textWidthBasis: textWidthBasis ?? this.textWidthBasis,
        textHeightBehavior: textHeightBehavior ?? this.textHeightBehavior,
        selectionColor: selectionColor ?? this.selectionColor,
      );
    }

    return Builder(
      builder: (context) {
        final defaultTextStyle = DefaultTextStyle.of(context);

        TextStyle? effectiveStyle = style ?? this.style;
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
        ).parseToSpans(data!);

        return Text.rich(
          TextSpan(style: effectiveStyle, children: spans),
          key: key,
          style: style ?? this.style,
          strutStyle: strutStyle ?? this.strutStyle,
          textAlign: textAlign ?? this.textAlign,
          textDirection: textDirection ?? this.textDirection,
          locale: locale ?? this.locale,
          softWrap: softWrap ?? this.softWrap,
          overflow: overflow ?? this.overflow,
          textScaler: textScaler ?? this.textScaler,
          maxLines: maxLines ?? this.maxLines,
          semanticsLabel: semanticsLabel ?? this.semanticsLabel,
          semanticsIdentifier: semanticsIdentifier,
          textWidthBasis: textWidthBasis ?? this.textWidthBasis,
          textHeightBehavior: textHeightBehavior ?? this.textHeightBehavior,
          selectionColor: selectionColor ?? this.selectionColor,
        );
      },
    );
  }
}
