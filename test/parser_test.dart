import 'package:dashronym/dashronym.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

DashronymParser _parser() => DashronymParser(
  registry: AcronymRegistry({'SDK': 'Software Development Kit'}),
  config: const DashronymConfig(enableBareAcronyms: true),
  theme: const DashronymTheme(),
  baseStyle: const TextStyle(),
);

void main() {
  test('DashronymParser converts acronyms into widget spans', () {
    final spans = _parser().parseToSpans('Using (SDK) daily.');

    final widgetSpans = spans.whereType<WidgetSpan>().toList(growable: false);
    expect(widgetSpans, hasLength(1));
    expect(
      spans.map((span) => span.runtimeType),
      containsAll([TextSpan, WidgetSpan]),
    );
  });

  test('DashronymParser caches spans for identical input', () {
    final parser = _parser();
    final first = parser.parseToSpans('Using (SDK) daily.');
    final second = parser.parseToSpans('Using (SDK) daily.');

    expect(identical(first, second), isTrue);
  });

  test('DashronymParser matches bare acronyms within length bounds', () {
    final parser = DashronymParser(
      registry: AcronymRegistry({
        'SDK': 'Software Development Kit',
        'CI': 'Continuous Integration',
      }),
      config: const DashronymConfig(
        enableBareAcronyms: true,
        minLen: 2,
        maxLen: 3,
      ),
      theme: const DashronymTheme(),
      baseStyle: const TextStyle(),
    );

    final spans = parser.parseToSpans('SDK tooling and CI runs');
    final widgetSpans = spans.whereType<WidgetSpan>().toList(growable: false);

    expect(widgetSpans.length, 2);
  });
}
