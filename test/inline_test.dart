import 'package:dashronym/dashronym.dart';
import 'package:dashronym/src/tooltip_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _testHarness(Widget child) {
  return MaterialApp(
    localizationsDelegates: const [
      DashronymLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: DashronymLocalizations.supportedLocales,
    home: Scaffold(body: Center(child: child)),
  );
}

DashronymTheme _theme() => const DashronymTheme(
      enableHover: false,
    );

void main() {
  testWidgets('AcronymInline toggles tooltip on tap and escape',
      (tester) async {
    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(
      _testHarness(
        AcronymInline(
          acronym: 'SDK',
          description: 'Software Development Kit',
          theme: _theme(),
          textStyle: const TextStyle(),
        ),
      ),
    );

    final trigger = find.byWidgetPredicate(
      (widget) =>
          widget is Text &&
          widget.data == 'SDK' &&
          widget.style?.decoration == TextDecoration.underline,
    );
    expect(trigger, findsOneWidget);

    await tester.tap(trigger);
    await tester.pumpAndSettle();
    expect(find.byType(DashronymTooltipCard), findsOneWidget);

    await tester.tap(find.byTooltip('Hide definition for SDK'));
    await tester.pumpAndSettle();
    expect(find.byType(DashronymTooltipCard), findsNothing);

    final semanticsFinder = find.bySemanticsLabel('SDK').first;
    final semanticsNode = tester.getSemantics(semanticsFinder);
    expect(semanticsNode.hasFlag(SemanticsFlag.isButton), isTrue);

    semantics.dispose();
  });
}
