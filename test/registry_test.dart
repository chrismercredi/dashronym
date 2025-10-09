import 'package:dashronym/dashronym.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AcronymRegistry stores entries case-insensitively by default', () {
    final registry = AcronymRegistry({'SDK': 'Software Development Kit'});

    expect(registry.contains('SDK'), isTrue);
    expect(registry.contains('sdk'), isTrue);
    expect(registry.descriptionOf('sdk'), 'Software Development Kit');
  });

  test('AcronymRegistry respects case sensitivity when disabled', () {
    final registry = AcronymRegistry(
      {'API': 'Application Programming Interface'},
      caseInsensitive: false,
    );

    expect(registry.contains('API'), isTrue);
    expect(registry.contains('api'), isFalse);
    expect(registry.descriptionOf('api'), isNull);
  });
}
