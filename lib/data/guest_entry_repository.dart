import '../logic/guestbook.dart';
import 'list_repository.dart';

typedef GuestEntryRepository = ListRepository<GuestEntry>;

/// Device storage for entries (shared_preferences, JSON).
const GuestEntryRepository deviceGuestEntryRepository =
    SharedPreferencesListRepository<GuestEntry>(
  storageKey: 'guestbook_entries_v1',
  fromJson: GuestEntry.fromJson,
  toJson: guestEntryToJson,
);
