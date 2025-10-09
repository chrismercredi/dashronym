/// Parsing and matching configuration for dashronyms.
///
/// Controls which acronyms are considered matches, which marker pairs are
/// honored, and how bare uppercase words are interpreted.
class DashronymConfig {
  const DashronymConfig({
    this.enableBareAcronyms = false,
    this.minLen = 2,
    this.maxLen = 10,
    this.acceptMarkers = const ['()', "''", '""'],
  }) : assert(minLen > 0, 'minLen must be greater than zero.'),
       assert(maxLen >= minLen, 'maxLen must be >= minLen.');

  /// Whether this config matches bare ALL-CAPS acronyms in the registry.
  final bool enableBareAcronyms;

  /// The minimum length a bare acronym must have.
  final int minLen;

  /// The maximum length a bare acronym may have.
  final int maxLen;

  /// The marker pairs recognized by this parser, such as `"()"` -> `(ABC)`.
  final List<String> acceptMarkers;
}
