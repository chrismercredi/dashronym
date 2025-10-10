import 'dart:collection';

/// A read-only registry mapping acronyms to their descriptions.
///
/// Keys are normalized at construction time. When [caseInsensitive] is `true`
/// (the default), all keys are stored uppercased and lookups normalize the
/// query key the same way. When `false`, keys are stored and matched
/// exactly as provided.
///
/// Example:
/// ```dart
/// final reg = AcronymRegistry({
///   'SDK': 'Software Development Kit',
///   'api': 'Application Programming Interface',
/// });
///
/// // Case-insensitive by default:
/// print(reg.contains('sdk')); // true
/// print(reg.descriptionOf('Api')); // "Application Programming Interface"
/// ```
class AcronymRegistry {
  /// Creates a registry from [entries].
  ///
  /// When [caseInsensitive] is `true`, all keys in [entries] are converted to
  /// upper case during construction. When `false`, keys are kept as-is.
  AcronymRegistry(Map<String, String> entries, {this.caseInsensitive = true}) {
    if (caseInsensitive) {
      for (final e in entries.entries) {
        _map[e.key.toUpperCase()] = e.value;
      }
    } else {
      _map.addAll(entries);
    }
  }

  /// Whether lookups are case-insensitive.
  ///
  /// If `true`, [contains] and [descriptionOf] normalize query keys to upper
  /// case before matching.
  final bool caseInsensitive;

  // Backing store. Uses HashMap for O(1) average lookups.
  final Map<String, String> _map = HashMap<String, String>();

  /// Returns whether the registry has an entry for [key].
  ///
  /// If [caseInsensitive] is `true`, [key] is matched in a case-insensitive
  /// manner (by uppercasing it).
  bool contains(String key) => caseInsensitive
      ? _map.containsKey(key.toUpperCase())
      : _map.containsKey(key);

  /// Returns the description associated with [key], or `null` if absent.
  ///
  /// If [caseInsensitive] is `true`, [key] is uppercased before lookup.
  String? descriptionOf(String key) =>
      caseInsensitive ? _map[key.toUpperCase()] : _map[key];
}
