/// A tiny, generic least-recently-used (LRU) cache.
///
/// Stores up to [capacity] key–value pairs. When inserting a new key while the
/// cache is full, the least-recently-used entry is evicted. A successful [get]
/// marks that entry as most-recently-used (MRU).
///
/// This implementation uses a `LinkedHashMap` (the default for `{}`) to preserve
/// insertion order. Calling [get] removes and re-inserts the key to move it to
/// the end (MRU position). Assigning an existing key via [put] updates its
/// value **without** changing its recency.
///
/// Example:
/// ```dart
/// final cache = Lru<String, int>(capacity: 2);
/// cache.put('a', 1);   // cache: [a]
/// cache.put('b', 2);   // cache: [a, b]
/// cache.get('a');      // marks 'a' as MRU; order ~ [b, a]
/// cache.put('c', 3);   // evicts 'b' (LRU), cache: [a, c]
/// print(cache.get('b')); // null
/// print(cache.get('a')); // 1
/// ```
///
/// Notes:
/// * [capacity] must be greater than zero (checked with an assert).
/// * [get] returns `null` when [key] is absent.
/// * Not thread-safe; synchronize externally if used across isolates.
class Lru<K, V> {
  /// Creates an LRU cache that can hold up to [capacity] entries.
  ///
  /// The [capacity] must be greater than zero.
  Lru({required this.capacity}) : assert(capacity > 0, 'capacity must be > 0');

  /// Maximum number of entries the cache will hold.
  final int capacity;

  // Uses LinkedHashMap semantics to track insertion order.
  final _map = <K, V>{};

  /// Returns the value for [key], or `null` if absent, and marks it MRU if found.
  ///
  /// On a hit, the entry's recency is updated by removing and re-inserting it.
  V? get(K key) {
    final v = _map.remove(key);
    if (v != null) _map[key] = v; // mark MRU
    return v;
  }

  /// Inserts or updates [value] for [key], evicting the LRU entry if needed.
  ///
  /// If [key] is new and the cache is at [capacity], the least-recently-used
  /// entry is removed before inserting the new one.
  ///
  /// If [key] already exists, its value is updated; its recency is **not**
  /// changed (only [get] promotes an entry to MRU).
  void put(K key, V value) {
    if (_map.length >= capacity && !_map.containsKey(key)) {
      _map.remove(_map.keys.first);
    }
    _map[key] = value;
  }
}
