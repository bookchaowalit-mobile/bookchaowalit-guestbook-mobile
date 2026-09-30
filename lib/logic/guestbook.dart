/// Guestbook entries, validation and relative-time labels.
library;

class GuestLimits {
  static const nameMax = 40;
  static const messageMax = 280;
}

class GuestEntry {
  GuestEntry({
    required String name,
    required String message,
    required this.signedAt,
  })  : name = name.trim().replaceAll(RegExp(r'\s+'), ' '),
        message = message.trim();

  final String name;
  final String message;
  final DateTime signedAt;

  Map<String, Object?> toJson() => {
        'name': name,
        'message': message,
        'signedAt': signedAt.toIso8601String(),
      };

  static GuestEntry fromJson(Map<String, Object?> json) => GuestEntry(
        name: json['name'] as String,
        message: json['message'] as String,
        signedAt: DateTime.parse(json['signedAt'] as String),
      );
}

Map<String, Object?> guestEntryToJson(GuestEntry entry) => entry.toJson();

String? validateName(String? value) {
  final v = (value ?? '').trim();
  if (v.isEmpty) return 'Please enter your name';
  if (v.length > GuestLimits.nameMax) {
    return 'Name must be at most ${GuestLimits.nameMax} characters';
  }
  return null;
}

String? validateMessage(String? value) {
  final v = (value ?? '').trim();
  if (v.isEmpty) return 'Please write a message';
  if (v.length > GuestLimits.messageMax) {
    return 'Message must be at most ${GuestLimits.messageMax} characters';
  }
  return null;
}

/// Newest first; stable for equal timestamps (later insert first).
List<GuestEntry> newestFirst(List<GuestEntry> entries) {
  final indexed = entries.asMap().entries.toList()
    ..sort((a, b) {
      final c = b.value.signedAt.compareTo(a.value.signedAt);
      return c != 0 ? c : b.key.compareTo(a.key);
    });
  return indexed.map((e) => e.value).toList();
}

/// Short relative label such as `just now`, `5 min ago`, `3 h ago`,
/// `2 days ago`, falling back to `YYYY-MM-DD` after a week.
String relativeTime(DateTime then, DateTime now) {
  final d = now.difference(then);
  if (d.isNegative || d.inSeconds < 60) return 'just now';
  if (d.inMinutes < 60) return '${d.inMinutes} min ago';
  if (d.inHours < 24) return '${d.inHours} h ago';
  if (d.inDays < 7) return d.inDays == 1 ? 'yesterday' : '${d.inDays} days ago';
  String two(int v) => v.toString().padLeft(2, '0');
  return '${then.year}-${two(then.month)}-${two(then.day)}';
}

/// Initials for an avatar: first letters of up to two words.
String initialsOf(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
  final letters = parts.take(2).map((p) => p.characters.first.toUpperCase());
  final s = letters.join();
  return s.isEmpty ? '?' : s;
}

extension on String {
  // Code-point iteration so emoji outside the BMP are not split in half.
  Iterable<String> get characters => runes.map(String.fromCharCode);
}
