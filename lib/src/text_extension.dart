import 'package:flutter/material.dart';

import 'config.dart';
import 'dashronym_text.dart';
import 'registry.dart';
import 'dashronym_theme.dart';
import 'acronym_inline.dart';

/// Convenience APIs for turning a plain [Text] into a glossary-aware widget.
///
/// Use this extension when you already have a [Text] widget and want to add
/// inline glossary tooltips without restructuring your tree. For new widgets,
/// you can also use [DashronymText] directly.
extension DashronymsTextX on Text {
  /// Returns a [DashronymText] that decorates matches with glossary tooltips.
  Widget dashronyms({
    required AcronymRegistry registry,
    DashronymConfig config = const DashronymConfig(),
    DashronymTheme theme = const DashronymTheme(),
    DashronymTooltipBuilder? tooltipBuilder,
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
    if (data == null) {
      // When constructed with Text.rich, fall back to the original widget.
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

    return DashronymText(
      data!,
      key: key,
      registry: registry,
      config: config,
      theme: theme,
      tooltipBuilder: tooltipBuilder,
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
      textWidthBasis: textWidthBasis ?? this.textWidthBasis,
      textHeightBehavior: textHeightBehavior ?? this.textHeightBehavior,
      selectionColor: selectionColor ?? this.selectionColor,
    );
  }
}
