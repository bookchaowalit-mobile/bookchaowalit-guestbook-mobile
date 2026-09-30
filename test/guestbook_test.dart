import 'package:flutter_test/flutter_test.dart';
import 'package:guestbook/logic/guestbook.dart';

void main() {
  test('validation', () {
    expect(validateName(' '), 'Please enter your name');
    expect(validateName('x' * 41), contains('at most 40'));
    expect(validateName('Ann'), isNull);
    expect(validateMessage(null), 'Please write a message');
    expect(validateMessage('x' * 281), contains('at most 280'));
    expect(validateMessage('Hi!'), isNull);
  });

  test('entries are trimmed and sorted newest first', () {
    final t = DateTime(2026, 9, 30, 12);
    final a = GuestEntry(name: '  Ann   Lee ', message: ' hi ', signedAt: t);
    final b = GuestEntry(name: 'Bo', message: 'yo', signedAt: t);
    final c = GuestEntry(
      name: 'Cy',
      message: 'old',
      signedAt: t.subtract(const Duration(days: 1)),
    );
    expect(a.name, 'Ann Lee');
    expect(a.message, 'hi');
    expect(newestFirst([c, a, b]).map((e) => e.name), ['Bo', 'Ann Lee', 'Cy']);
  });

  test('relativeTime', () {
    final now = DateTime(2026, 9, 30, 12);
    expect(relativeTime(now, now), 'just now');
    expect(relativeTime(now.add(const Duration(minutes: 5)), now), 'just now');
    expect(relativeTime(now.subtract(const Duration(minutes: 5)), now),
        '5 min ago');
    expect(
        relativeTime(now.subtract(const Duration(hours: 3)), now), '3 h ago');
    expect(
        relativeTime(now.subtract(const Duration(days: 1)), now), 'yesterday');
    expect(
        relativeTime(now.subtract(const Duration(days: 3)), now), '3 days ago');
    expect(relativeTime(DateTime(2026, 9, 1), now), '2026-09-01');
  });

  test('initialsOf', () {
    expect(initialsOf('ann lee smith'), 'AL');
    expect(initialsOf('Bo'), 'B');
    expect(initialsOf('  '), '?');
    expect(initialsOf('😀 face'), '😀F');
  });

  group('edge cases (pass 3)', () {
    test('limits count visible characters like the TextField counter', () {
      expect(validateName('😀' * GuestLimits.nameMax), isNull);
      expect(validateName('😀' * (GuestLimits.nameMax + 1)), isNotNull);
      expect(validateMessage('น้ำ' * GuestLimits.messageMax), isNull);
      expect(validateMessage('a' * (GuestLimits.messageMax + 1)), isNotNull);
      expect(validateName(null), 'Please enter your name');
      expect(validateMessage(' \n '), 'Please write a message');
    });

    test('initials keep whole graphemes', () {
      expect(initialsOf('🇹🇭 Thai'), '🇹🇭T');
      expect(initialsOf('👨‍👩‍👧 family'), '👨‍👩‍👧F');
      expect(initialsOf('e\u0301mile zola'), 'E\u0301Z');
      expect(initialsOf('สมชาย ใจดี'), 'สใ');
    });

    test('relativeTime uses calendar days past 24 hours', () {
      final now = DateTime(2026, 9, 30, 8);
      // 33 hours ago is 2026-09-28 23:00: the day before yesterday.
      expect(relativeTime(now.subtract(const Duration(hours: 33)), now),
          '2 days ago');
      expect(relativeTime(DateTime(2026, 9, 29, 7), now), 'yesterday');
      expect(relativeTime(DateTime(2026, 9, 29, 23), now), '9 h ago');
      expect(relativeTime(now.subtract(const Duration(seconds: 59)), now),
          'just now');
      expect(relativeTime(now.subtract(const Duration(minutes: 60)), now),
          '1 h ago');
      expect(relativeTime(DateTime(2026, 9, 24, 9), now), '6 days ago');
      expect(relativeTime(DateTime(2026, 9, 23, 9), now), '2026-09-23');
    });

    test('names collapse inner whitespace; messages keep line breaks', () {
      final e = GuestEntry(
        name: '  Ann \t  Lee ',
        message: ' line 1\nline 2 ',
        signedAt: DateTime(2026),
      );
      expect(e.name, 'Ann Lee');
      expect(e.message, 'line 1\nline 2');
      final back = GuestEntry.fromJson(e.toJson());
      expect(back.message, e.message);
      expect(back.signedAt, e.signedAt);
    });

    test('newestFirst on empty and equal timestamps', () {
      expect(newestFirst(const []), isEmpty);
      final t = DateTime(2026);
      final a = GuestEntry(name: 'A', message: 'm', signedAt: t);
      final b = GuestEntry(name: 'B', message: 'm', signedAt: t);
      expect(newestFirst([a, b]).map((e) => e.name), ['B', 'A']);
    });
  });
}
