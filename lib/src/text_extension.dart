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
  /// Returns a [RichText] that replaces matched acronyms with interactive
  /// glossary tooltips.
  ///
  /// The call parses [data] (or preserves [textSpan] unchanged when this
  /// [Text] was created with `Text.rich`) using the supplied [registry] and
  /// formatting preferences from [config] and [theme]. Matched acronyms are
  /// rendered as tappable/keyboard-activatable widgets that reveal inline
  /// definitions without breaking reading flow. Screen readers get appropriate
  /// semantics for showing/hiding the tooltip content.
  ///
  /// The returned widget keeps typography consistent with the surrounding
  /// context by merging the effective [TextStyle] with [DefaultTextStyle] and
  /// honoring bold-text accessibility ([MediaQuery.boldTextOf]).
  ///
  /// Example:
  /// ```dart
  /// final registry = AcronymRegistry({
  ///   'SDK': 'Software Development Kit',
  ///   'API': 'Application Programming Interface',
  /// });
  ///
  /// Text('Install the SDK to use the API.')
  ///     .dashronyms(registry: registry);
  /// ```
  ///
  /// Returns a [Text.rich] that contains either the original [textSpan] (when
  /// provided) or a [TextSpan] built from parsed children.
  Widget dashronyms({
    /// Acronym dictionary used to match and expand inline terms.
    required AcronymRegistry registry,

    /// Parsing behavior such as tokenization and matching rules.
    DashronymConfig config = const DashronymConfig(),

    /// Visual behavior for triggers and tooltips (underline, offsets, timings).
    DashronymTheme theme = const DashronymTheme(),

    /// Optional overrides mirroring [Text]'s constructor so callers can adjust
    /// presentation while letting this method manage the content.
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

        // Derive the effective style by merging with the inherited default.
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
