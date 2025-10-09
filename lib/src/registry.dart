import 'dart:collection';

/// Registry of acronyms and their descriptions.
///
/// Stores canonical (usually uppercased) keys for robust matching.
class AcronymRegistry {
  AcronymRegistry(Map<String, String> entries, {this.caseInsensitive = true}) {
    if (caseInsensitive) {
      for (final e in entries.entries) {
        _map[e.key.toUpperCase()] = e.value;
      }
    } else {
      _map.addAll(entries);
    }
  }

  /// Whether this registry performs case-insensitive lookups.
  final bool caseInsensitive;

  final Map<String, String> _map = HashMap<String, String>();

  /// Whether this registry has an entry for [key].
  bool contains(String key) => caseInsensitive
      ? _map.containsKey(key.toUpperCase())
      : _map.containsKey(key);

  /// The description associated with [key], or null when absent.
  String? descriptionOf(String key) =>
      caseInsensitive ? _map[key.toUpperCase()] : _map[key];
}
