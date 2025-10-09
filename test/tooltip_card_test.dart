import 'package:dashronym/dashronym.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('DashronymTooltipCard decorates semantics and styles', (
    tester,
  ) async {
    final onClose = ValueNotifier(false);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          DashronymLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: DashronymLocalizations.supportedLocales,
        home: Material(
          child: DashronymTooltipCard(
            acronym: 'SDK',
            description: 'Software Development Kit',
            theme: const DashronymTheme(),
            onClose: () => onClose.value = true,
          ),
        ),
      ),
    );

    final semantics = tester.getSemantics(find.byType(DashronymTooltipCard));
    expect(semantics.label, contains('Definition for SDK'));
    expect(semantics.value, contains('Software Development Kit'));

    await tester.tap(find.byTooltip('Hide definition for SDK'));
    await tester.pump();
    expect(onClose.value, isTrue);
  });
}
