/// Tiny generic LRU cache used by the parser.
class Lru<K, V> {
  Lru({required this.capacity}) : assert(capacity > 0, 'capacity must be > 0');
  final int capacity;
  final _map = <K, V>{};

  V? get(K key) {
    final v = _map.remove(key);
    if (v != null) _map[key] = v; // mark MRU
    return v;
  }

  void put(K key, V value) {
    if (_map.length >= capacity && !_map.containsKey(key)) {
      _map.remove(_map.keys.first);
    }
    _map[key] = value;
  }
}
