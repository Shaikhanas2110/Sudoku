# Sudoku Flutter

A polished, single-codebase Flutter Sudoku app with a home hub, unlockable
difficulty tiers, Fast Pencil auto-notes, Smart Hints, and a real settings
page — no third-party state management packages required.

## Features

- **Home hub** — coin/streak badges, a promo/tournament carousel, a daily
  challenge banner, and a live "Best Score" that updates as you play.
- **New Game sheet** — six difficulty tiers (Beginner → Extreme). Expert and
  Extreme start locked and unlock automatically once you've won enough games
  at the tier below (progress is tracked for real, not hardcoded).
- **Classic gameplay** — score, mistake counter (3-strike limit), pause/resume
  timer, selection/peer/same-number highlighting, and a number pad that shows
  how many of each digit remain.
- **Fast Pencil** — instantly computes and fills every valid candidate number
  for every empty cell on the board, in one tap.
- **Manual pencil mode, Undo, Erase, and Smart Hint** (limited uses per game).
- **Settings page** — sound/vibration toggles, same-number highlighting
  toggle, a working Dark Mode switch, live play stats, and a reset-progress
  action.
- **Bottom navigation** — Home / Battle / Explore / Personal (Personal hosts
  the Settings screen; Battle/Explore are placeholders for future modes).

## Tech stack

- Flutter (Material 3), Dart ≥ 3.0
- No external state-management package — a small `ChangeNotifier` +
  `InheritedNotifier` (`ProfileState` / `ProfileScope`) shares coins, streak,
  best score, unlocks, and settings across the app.
- No backend — all progress lives in memory for the current app session.

## Project structure

```
lib/
├── main.dart                  # App entry point, theme + ProfileScope wiring
├── logic/
│   └── sudoku_logic.dart      # Puzzle generation, validation, candidate calc
├── models/
│   ├── difficulty.dart        # Difficulty tiers, points, unlock rules
│   ├── board_size.dart        # Board size option (Fast 9x9 / locked 16x16)
│   ├── new_game_selection.dart
│   ├── move.dart               # Undo history primitives
│   └── sudoku_cell.dart
├── state/
│   └── profile_state.dart     # Coins, streak, stats, unlocks, settings
├── screens/
│   ├── root_shell.dart        # Bottom nav shell
│   ├── home_screen.dart
│   ├── game_screen.dart
│   ├── settings_screen.dart
│   └── placeholder_screen.dart
├── widgets/
│   ├── new_game_sheet.dart    # Difficulty picker bottom sheet
│   ├── game/                  # Board, number pad, control buttons
│   └── home/                  # Promo cards, daily challenge banner, badges
├── theme/
│   └── app_theme.dart         # Light/dark ThemeData + shared colors
└── utils/
    └── formatting.dart        # Number/time formatting helpers
```

## Getting started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable
  channel recommended)
- Android Studio / Xcode for platform toolchains, or a connected
  device/emulator

### Run it

```bash
flutter pub get
flutter run
```

### Build a release APK

```bash
flutter build apk --release
```

> **Android `compileSdk` note:** if you hit an AAR metadata error mentioning
> `compileSdk 33` vs `34`, open `android/app/build.gradle` (or
> `build.gradle.kts`) and bump `compileSdkVersion`/`compileSdk` to `34` or
> higher (and `targetSdk` to match), or simply run `flutter upgrade` if your
> project inherits `flutter.compileSdkVersion` from the Flutter SDK template.

## Known limitations

- **No persistence** — coins, best score, unlocks, and settings reset when
  the app restarts. Wiring up `shared_preferences` (or similar) is the
  natural next step.
- **Dark Mode** switches the core theme (backgrounds, app bars) but a few
  widgets (e.g. the promo cards) still use fixed colors, so they won't
  re-theme yet.
- **Daily streak** is a static demo value — real day-over-day tracking needs
  persisted timestamps.
- **Sound effects** toggle is wired into settings but not yet connected to
  actual audio playback (no audio package/assets included).
- **16×16 board size** is shown in the New Game sheet but intentionally
  locked — only the classic 9×9 engine is implemented.

## Contributing

Issues and PRs are welcome. If you pick up one of the limitations above,
please keep new dependencies minimal and consistent with the existing code
style.

## License

Add your preferred license here (e.g. MIT) before publishing.
