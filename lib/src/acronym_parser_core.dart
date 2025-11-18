import 'config.dart';
import 'acronym_tokens.dart';
import 'lru_cache.dart';
import 'registry.dart';

/// Pure-Dart acronym parser that produces [DashronymToken]s.
///
/// This parser is responsible for locating acronyms based on [DashronymConfig]
/// and [AcronymRegistry]. It does not know about Flutter, widgets, or spans.
///
/// Results are memoized in an internal [Lru] cache keyed by the input text and
/// configuration so repeated parsing of identical content avoids recomputation.
class DashronymParserCore {
  /// Creates a core parser backed by [registry] and [config].
  DashronymParserCore({required this.registry, required this.config});

  /// Dictionary of acronyms and their descriptions used for matching.
  final AcronymRegistry registry;

  /// Parsing options such as markers, minimum/maximum lengths, and bare acronym
  /// support.
  final DashronymConfig config;

  /// Shared LRU cache of previously parsed inputs.
  ///
  /// Keyed by the input text plus those [DashronymConfig] fields that influence
  /// matching. The registry is treated as immutable.
  static final Lru<String, List<DashronymToken>> _cache =
      Lru<String, List<DashronymToken>>(capacity: 256);

  /// Converts [input] into a sequence of [DashronymToken]s.
  ///
  /// * Respects marker pairs from [DashronymConfig.acceptMarkers].
  /// * When [DashronymConfig.enableBareAcronyms] is `true`, matches bare
  ///   `[A-Z]{2,}` tokens within [DashronymConfig.minLen]…[DashronymConfig.maxLen].
  /// * Only acronyms present in [registry] are turned into [AcronymToken]s;
  ///   other segments are merged into [TextToken]s.
  /// * Returns cached results when the cache key (input + [config]) matches a
  ///   prior invocation.
  List<DashronymToken> parse(String input) {
    final cacheKey = [
      input,
      config.enableBareAcronyms,
      config.minLen,
      config.maxLen,
      config.acceptMarkers.join(),
    ].join('__');

    final cached = _cache.get(cacheKey);
    if (cached != null) return cached;

    final tokens = <DashronymToken>[];
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
      tokens.add(TextToken(text));
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
            tokens.add(
              AcronymToken(
                acronym: ac,
                description: registry.descriptionOf(ac)!,
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
            tokens.add(
              AcronymToken(
                acronym: ac,
                description: registry.descriptionOf(ac)!,
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

    final result = List<DashronymToken>.unmodifiable(tokens);
    _cache.put(cacheKey, result);
    return result;
  }
}
