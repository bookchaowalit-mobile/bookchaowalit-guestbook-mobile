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
}
