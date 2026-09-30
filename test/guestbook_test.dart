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
}
