import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guestbook/data/list_repository.dart';
import 'package:guestbook/data/guest_entry_repository.dart';
import 'package:guestbook/logic/guestbook.dart';
import 'package:guestbook/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final sample = GuestEntry(
    name: 'Ann Lee',
    message: 'Lovely app',
    signedAt: DateTime.utc(2026, 1, 2, 3, 4),
  );

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('round-trips entries through shared_preferences', () async {
    await deviceGuestEntryRepository.save([sample]);
    final loaded = await deviceGuestEntryRepository.load();
    expect(loaded, hasLength(1));
    expect(loaded.single.toJson(), sample.toJson());
  });

  test('empty storage loads an empty list', () async {
    expect(await deviceGuestEntryRepository.load(), isEmpty);
  });

  test('skips malformed records and rejects non-list payloads', () async {
    SharedPreferences.setMockInitialValues({
      'guestbook_entries_v1': jsonEncode([
        sample.toJson(),
        {'id': 'x'},
        42,
      ]),
    });
    expect(await deviceGuestEntryRepository.load(), hasLength(1));

    SharedPreferences.setMockInitialValues({'guestbook_entries_v1': '{}'});
    expect(deviceGuestEntryRepository.load(), throwsFormatException);
  });

  testWidgets('home screen restores saved entries and saves changes',
      (tester) async {
    final repo = InMemoryListRepository<GuestEntry>([sample]);
    await tester.pumpWidget(MaterialApp(home: HomeScreen(repository: repo)));
    await tester.pumpAndSettle();
    expect(find.text('Ann Lee'), findsWidgets);

    await tester.tap(find.byTooltip('Delete entry by Ann Lee'));
    await tester.pumpAndSettle();
    expect(await repo.load(), isEmpty);
  });

  testWidgets('shows an error when saved entries cannot be read',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: HomeScreen(repository: _FailingRepository())),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('storage-error')), findsOneWidget);
  });
}

class _FailingRepository implements ListRepository<GuestEntry> {
  @override
  Future<List<GuestEntry>> load() async => throw const FormatException('bad');

  @override
  Future<void> save(List<GuestEntry> items) async => throw StateError('full');
}
