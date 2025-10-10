/// Parsing and matching configuration for dashronyms.
///
/// Controls which acronyms are considered matches, which marker pairs are
/// honored, and how bare uppercase words are interpreted.
///
/// Matching modes:
/// * Marker-based: detects acronyms wrapped by accepted pairs from [acceptMarkers]
///   (e.g., `"()"` recognizes `(SDK)`).
/// * Bare acronyms: when [enableBareAcronyms] is `true`, matches ALL-CAPS
///   words within [minLen]…[maxLen].
///
/// Invariants:
/// * [minLen] > 0
/// * [maxLen] >= [minLen]
///
/// Example:
/// ```dart
/// const config = DashronymConfig(
///   enableBareAcronyms: true,
///   minLen: 2,
///   maxLen: 10,
///   acceptMarkers: ['()', '""', "''"], // (ABC), "ABC", 'ABC'
/// );
/// ```
class DashronymConfig {
  /// Creates a configuration for acronym parsing and matching.
  ///
  /// By default, only marker-wrapped acronyms are matched; set
  /// [enableBareAcronyms] to `true` to also consider ALL-CAPS words.
  const DashronymConfig({
    this.enableBareAcronyms = false,
    this.minLen = 2,
    this.maxLen = 10,
    this.acceptMarkers = const ['()', "''", '""'],
  }) : assert(minLen > 0, 'minLen must be greater than zero.'),
       assert(maxLen >= minLen, 'maxLen must be >= minLen.');

  /// Whether bare ALL-CAPS words are matched against the registry.
  ///
  /// When `true`, tokens like `SDK` or `API` (length-bounded by [minLen] and
  /// [maxLen]) are considered even without marker characters.
  final bool enableBareAcronyms;

  /// Minimum allowed length for a bare acronym match.
  final int minLen;

  /// Maximum allowed length for a bare acronym match.
  final int maxLen;

  /// Marker pairs recognized by the parser.
  ///
  /// Each string must contain exactly two characters representing the left and
  /// right markers, e.g. `"()"` for `(ABC)`, `""` for `"ABC"`, and `''` for
  /// `'ABC'`. Pairs are treated literally (escaped as needed in regex).
  final List<String> acceptMarkers;
}
