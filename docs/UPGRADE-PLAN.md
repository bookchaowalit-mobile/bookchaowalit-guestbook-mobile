# Upgrade Plan — Guestbook Mobile

## Current state

Score: 7.5/10 — persisted guestbook with unicode-correct limits and initials, calendar-aware relative times, undo, a11y guideline tests and fail-closed signing; no icon or E2E flow yet.

## Backlog

### P0
- None open. (Release signing now fails closed without `android/key.properties`.)

### P1
- Replace the template launcher icon with a real app icon (the application ID `com.bookchaowalit.*` is already set).
- Add a Maestro smoke flow for the main journey.
- Add a CI job that builds a signed release bundle from repository secrets (keystore decoded at runtime, never committed).

### P2
- Tablet layout (NavigationRail).
- Localisation (Thai/English) for UI strings.

## Done in this pass (pass 3)

- Bug fix: name/message limits used `String.length` (UTF-16) while the `TextField` counter counts grapheme clusters, so a 21–40 emoji name showed `40/40` yet failed "at most 40 characters". Validators now count visible characters (`characters`, now a direct dependency).
- Bug fix: avatar initials split grapheme clusters — `🇹🇭 Thai` gave a lone regional-indicator letter, family emoji lost their joiners and decomposed accents lost the accent. Initials now take whole graphemes.
- Bug fix: "yesterday" meant 24–48 hours ago, so an entry signed 33 hours earlier (the day before yesterday) read "yesterday". Past 24 hours the label now counts calendar days.
- P1 done: deleting an entry offers Undo; the delete tooltip names the author; decorative initials are excluded from semantics.
- Edge-case unit tests for the above plus whitespace/`null` validation, message line breaks, JSON round trip and equal-timestamp ordering. Widget tests: undo, 40-emoji name, a11y guidelines, 200% text scale at phone width.

## Done in pass 2

- Release builds no longer sign with the debug key: `android/app/build.gradle.kts` reads the ignored `android/key.properties` and a Gradle guard fails any release assemble/bundle without it (pattern from `bookchaowalit-goal-tracker-mobile`). Root `.gitignore` also ignores `key.properties`, `*.jks`, `*.keystore`; README documents the setup. Not build-verified here (no Android SDK/Gradle in this environment).
- Entries now persist on device via `lib/data/list_repository.dart` (`ListRepository` interface, `shared_preferences` JSON store that skips malformed records, in-memory store for tests); the home screen loads on start, saves after signing and shows an error line when storage fails.
- Added a delete button per entry (owner moderation now that entries persist) and fixed the "for this session" copy on the home and About screens.
- Added repository tests (round trip, empty, malformed records, non-list payload) and widget tests for restore/delete and load failure.

## Done in pass 1

- Replaced the Expo/npm CI (which could never fail) with fail-closed Flutter CI: `dart format` check, `flutter analyze`, `flutter test`, debug APK on `main`.
- Implemented the core feature (sign a local guestbook; entries stay on this device) with pure-Dart logic in `lib/logic/`.
- Replaced placeholder Explore/Profile tabs with an About screen describing features and privacy.
- Added unit tests for the logic and widget tests for the main journey.
- Removed unused `go_router` / `flutter_riverpod` dependencies; README now matches the code.
