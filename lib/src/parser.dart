import 'package:flutter/material.dart';

import 'config.dart';
import 'inline.dart';
import 'lru.dart';
import 'registry.dart';
import 'theme.dart';

/// Internal parser that turns a string into [InlineSpan] runs with tooltip widgets.
///
/// Maintains an in-memory [Lru] cache so repeated calls for the same input and
/// configuration avoid redoing the parsing work.
class DashronymParser {
  DashronymParser({
    required this.registry,
    required this.config,
    required this.theme,
    required this.baseStyle,
  });

  final AcronymRegistry registry;
  final DashronymConfig config;
  final DashronymTheme theme;
  final TextStyle? baseStyle;

  static final _cache = Lru<String, List<InlineSpan>>(capacity: 256);

  /// Converts [input] into a series of inline spans with glossary tooltips.
  ///
  /// Returns cached spans when the input, theme, and config match a previously
  /// parsed string.
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

    final markerRegexes = config.acceptMarkers.map((pair) {
      assert(pair.length == 2, 'Marker must be two chars like "()"');
      final l = RegExp.escape(pair[0]);
      final r = RegExp.escape(pair[1]);
      return RegExp('$l([A-Za-z0-9]{${config.minLen},${config.maxLen}})$r');
    }).toList();

    final bare = RegExp(r'\b([A-Z]{2,})\b');

    void flushBuffer() {
      final text = buffer.toString();
      if (text.isEmpty) return;
      spans.add(TextSpan(text: text));
      buffer = StringBuffer();
    }

    while (i < input.length) {
      var matched = false;

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

      buffer.writeCharCode(input.codeUnitAt(i));
      i += 1;
    }

    flushBuffer();

    final result = List<InlineSpan>.unmodifiable(spans);
    _cache.put(cacheKey, result);
    return result;
  }
}
