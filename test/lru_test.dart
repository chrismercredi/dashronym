import 'package:dashronym/dashronym.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Lru evicts least recently used entries', () {
    final cache = Lru<int, String>(capacity: 2);
    cache.put(1, 'one');
    cache.put(2, 'two');

    expect(cache.get(1), 'one'); // mark 1 as most recent
    cache.put(3, 'three'); // should evict key 2

    expect(cache.get(2), isNull);
    expect(cache.get(1), 'one');
    expect(cache.get(3), 'three');
  });

  test('Lru returns null when key missing', () {
    final cache = Lru<int, String>(capacity: 1);
    expect(cache.get(42), isNull);
  });
}
