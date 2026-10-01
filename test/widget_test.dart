import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:guestbook/main.dart';
import 'package:guestbook/screens/home_screen.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('app shell shows guestbook and about tab', (tester) async {
    await tester.pumpWidget(const GuestbookApp());
    await tester.pumpAndSettle();
    expect(find.text('Guestbook'), findsWidgets);
    await tester.tap(find.text('About'));
    await tester.pumpAndSettle();
    expect(find.text('Features'), findsOneWidget);
  });

  testWidgets('signing validates and lists newest first', (tester) async {
    tester.view.physicalSize = const Size(1080, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(home: HomeScreen(clock: () => DateTime(2026, 9, 30))),
    );
    await tester.tap(find.byKey(const Key('sign')));
    await tester.pump();
    expect(find.text('Please enter your name'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('name-field')), 'Ann Lee');
    await tester.enterText(find.byKey(const Key('message-field')), 'Lovely!');
    await tester.tap(find.byKey(const Key('sign')));
    await tester.pump();
    await tester.enterText(find.byKey(const Key('message-field')), 'Again');
    await tester.tap(find.byKey(const Key('sign')));
    await tester.pump();

    expect(find.text('AL'), findsNWidgets(2));
    final again = tester.getTopLeft(find.text('Again'));
    final lovely = tester.getTopLeft(find.text('Lovely!'));
    expect(again.dy, lessThan(lovely.dy));
    expect(find.text('just now'), findsNWidgets(2));
  });

  Widget home({double textScale = 1}) => MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
          child: HomeScreen(clock: () => DateTime(2026, 9, 30, 12)),
        ),
      );

  Future<void> sign(WidgetTester tester, String name, String message) async {
    await tester.enterText(find.byKey(const Key('name-field')), name);
    await tester.enterText(find.byKey(const Key('message-field')), message);
    await tester.ensureVisible(find.byKey(const Key('sign')));
    await tester.tap(find.byKey(const Key('sign')));
    await tester.pumpAndSettle();
  }

  testWidgets('delete can be undone', (tester) async {
    await tester.pumpWidget(home());
    await tester.pumpAndSettle();
    await sign(tester, 'Ann Lee', 'Hello there');
    ScaffoldMessenger.of(tester.element(find.byType(HomeScreen)))
        .removeCurrentSnackBar();
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Delete entry by Ann Lee'));
    await tester.pumpAndSettle();
    expect(find.text('No signatures yet. Be the first!'), findsOneWidget);
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(find.text('Hello there'), findsOneWidget);
  });

  testWidgets('a 40-emoji name is accepted', (tester) async {
    await tester.pumpWidget(home());
    await tester.pumpAndSettle();
    await sign(tester, '😀' * 40, 'Hi');
    expect(find.textContaining('at most'), findsNothing);
    expect(find.text('No signatures yet. Be the first!'), findsNothing);
  });

  testWidgets('meets tap-target, label and contrast guidelines', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(home());
    await tester.pumpAndSettle();
    await sign(tester, 'Ann Lee', 'Hello there');
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    handle.dispose();
  });

  testWidgets('lays out at 200% text scale on a phone without overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 740);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(home(textScale: 2));
    await tester.pumpAndSettle();
    await sign(tester, 'Ann Lee', 'Hello there');
    expect(tester.takeException(), isNull);
  });
}
