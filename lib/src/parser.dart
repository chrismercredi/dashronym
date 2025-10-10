import 'package:flutter/material.dart';

import 'config.dart';
import 'inline.dart';
import 'lru.dart';
import 'registry.dart';
import 'theme.dart';

/// Parses text into [InlineSpan] runs with embedded acronym tooltip widgets.
///
/// The parser scans an input string for acronyms using marker pairs from
/// [DashronymConfig.acceptMarkers] (e.g., `"(" + ")"` to match `(SDK)`) and,
/// optionally, bare ALL-CAPS words ([DashronymConfig.enableBareAcronyms]).
/// Matches that are present in the provided [AcronymRegistry] are replaced with
/// [AcronymInline] widgets; all other text is emitted as [TextSpan].
///
/// Performance:
/// Results are memoized in an internal [Lru] cache keyed by the input plus
/// relevant [DashronymConfig], [DashronymTheme], and base text style, so
/// repeated parsing of the same content avoids recomputation.
///
/// Example:
/// ```dart
/// final registry = AcronymRegistry({
///   'SDK': 'Software Development Kit',
///   'API': 'Application Programming Interface',
/// });
///
/// final spans = DashronymParser(
///   registry: registry,
///   config: const DashronymConfig(enableBareAcronyms: true),
///   theme: const DashronymTheme(),
///   baseStyle: const TextStyle(fontSize: 14),
/// ).parseToSpans('Install the (SDK) to access the API.');
///
/// final widget = Text.rich(TextSpan(children: spans));
/// ```
class DashronymParser {
  /// Creates a parser that converts matched acronyms into inline tooltip widgets.
  DashronymParser({
    required this.registry,
    required this.config,
    required this.theme,
    required this.baseStyle,
  });

  /// Dictionary of acronyms and their descriptions used for matching.
  final AcronymRegistry registry;

  /// Parsing options such as marker pairs, minimum/maximum lengths,
  /// and whether to consider bare ALL-CAPS words.
  final DashronymConfig config;

  /// Visual and interaction parameters for produced [AcronymInline] widgets.
  final DashronymTheme theme;

  /// Base [TextStyle] applied to text runs and passed to inline widgets.
  final TextStyle? baseStyle;

  /// Shared LRU cache of previously parsed inputs.
  ///
  /// Keyed by a concatenation of the input text and the effective configuration
  /// and theme parameters that affect output spans.
  static final _cache = Lru<String, List<InlineSpan>>(capacity: 256);

  /// Converts [input] into a sequence of [InlineSpan]s with glossary tooltips.
  ///
  /// * Respects marker pairs from [DashronymConfig.acceptMarkers].
  /// * When [DashronymConfig.enableBareAcronyms] is `true`, matches bare
  ///   `[A-Z]{2,}` tokens within [DashronymConfig.minLen]…[DashronymConfig.maxLen].
  /// * Only acronyms present in [registry] are turned into [AcronymInline]s.
  /// * Returns cached results when the cache key (input + config + theme +
  ///   [baseStyle]) matches a prior invocation.
  List<InlineSpan> parseToSpans(String input) {
    final cacheKey = [
      input,
      config.enableBareAcronyms,
      config.minLen,
      config.maxLen,
      config.acceptMarkers.join(),
      theme.underline,
      theme.decorationStyle,
      theme.decorationThickness,
      theme.acronymStyle?.hashCode,
      theme.cardWidth,
      theme.cardElevation,
      theme.cardPadding.hashCode,
      theme.hoverShowDelay.inMilliseconds,
      (theme.hoverHideDelay ?? theme.hoverShowDelay).inMilliseconds,
      theme.tooltipFadeDuration.inMilliseconds,
      theme.enableHover,
      theme.cardBorderRadius,
      theme.cardIcon.codePoint,
      theme.cardIcon.fontFamily,
      theme.cardCloseIcon.codePoint,
      theme.cardCloseIcon.fontFamily,
      theme.cardIconColor?.toARGB32(),
      theme.cardTitleStyle?.hashCode,
      theme.cardSubtitleStyle?.hashCode,
      theme.cardContentPadding.hashCode,
      theme.cardMinLeadingWidth,
      theme.tooltipOffset.dx,
      theme.tooltipOffset.dy,
      baseStyle?.hashCode ?? 0,
    ].join('__');
    final cached = _cache.get(cacheKey);
    if (cached != null) return cached;

    final spans = <InlineSpan>[];
    var buffer = StringBuffer();
    var i = 0;

    // Build regexes for each accepted marker pair, e.g. '(' and ')'.
    final markerRegexes = config.acceptMarkers.map((pair) {
      assert(pair.length == 2, 'Marker must be two chars like "()"');
      final l = RegExp.escape(pair[0]);
      final r = RegExp.escape(pair[1]);
      return RegExp('$l([A-Za-z0-9]{${config.minLen},${config.maxLen}})$r');
    }).toList();

    // Bare ALL-CAPS word (>=2 chars); final length check happens below.
    final bare = RegExp(r'\b([A-Z]{2,})\b');

    void flushBuffer() {
      final text = buffer.toString();
      if (text.isEmpty) return;
      spans.add(TextSpan(text: text));
      buffer = StringBuffer();
    }

    while (i < input.length) {
      var matched = false;

      // Try marker-based matches first.
      for (final rx in markerRegexes) {
        final m = rx.matchAsPrefix(input, i);
        if (m != null) {
          final ac = m.group(1)!;
          if (registry.contains(ac)) {
            flushBuffer();
            spans.add(
              WidgetSpan(
                alignment: PlaceholderAlignment.baseline,
                baseline: TextBaseline.alphabetic,
                child: AcronymInline(
                  acronym: ac,
                  description: registry.descriptionOf(ac)!,
                  theme: theme,
                  textStyle: baseStyle,
                ),
              ),
            );
            i = m.end;
            matched = true;
            break;
          }
        }
      }
      if (matched) continue;

      // Optionally match bare ALL-CAPS tokens.
      if (config.enableBareAcronyms) {
        final m = bare.matchAsPrefix(input, i);
        if (m != null) {
          final ac = m.group(1)!;
          if (ac.length >= config.minLen &&
              ac.length <= config.maxLen &&
              registry.contains(ac)) {
            flushBuffer();
            spans.add(
              WidgetSpan(
                alignment: PlaceholderAlignment.baseline,
                baseline: TextBaseline.alphabetic,
                child: AcronymInline(
                  acronym: ac,
                  description: registry.descriptionOf(ac)!,
                  theme: theme,
                  textStyle: baseStyle,
                ),
              ),
            );
            i = m.end;
            continue;
          }
        }
      }

      // No match; emit the current character as plain text.
      buffer.writeCharCode(input.codeUnitAt(i));
      i += 1;
    }

    flushBuffer();

    final result = List<InlineSpan>.unmodifiable(spans);
    _cache.put(cacheKey, result);
    return result;
  }
}
