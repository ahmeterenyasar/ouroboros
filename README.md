# Attack & Defence

A local-first habit tracker that splits habits into two opposing psychological modes:

- **Attack** — *breaking* bad habits. Time-based endurance. The app counts the days since your last failure; pressing **I Broke It** logs a reset and zeroes the counter.
- **Defence** — *building* good habits. Goal-oriented. Hit a target count of completions per **Daily / Weekly / Monthly / Continuous** period.

Built with **Flutter**, **Riverpod**, and **Isar**. Every byte stays on-device.

---

## Getting started

```bash
flutter pub get

# (Re)generate the Isar adapter. A working copy is committed,
# but always regenerate if you change the Habit model.
dart run build_runner build --delete-conflicting-outputs

flutter run
```

Requirements: Flutter 3.19+, Dart 3.3+.

---

## Project structure

```
lib/
├── main.dart                     # Entry; opens Isar then runApp
├── models/
│   ├── habit.dart                # Isar collection + helper getters
│   └── habit.g.dart              # Generated adapter (build_runner)
├── providers/
│   ├── database_provider.dart    # Isar singleton FutureProvider
│   └── habit_providers.dart      # Reactive list + write-side repository
├── screens/
│   ├── dashboard_screen.dart     # Slivers: Attack section + Defence section
│   └── add_habit_screen.dart     # Form with segmented Attack/Defence toggle
├── widgets/
│   ├── section_header.dart       # Editorial-style section title
│   ├── attack_habit_card.dart    # Big day counter + crimson reset button
│   ├── defence_habit_card.dart   # Segmented progress bar + log/undo
│   └── empty_section.dart        # Placeholder for empty sections
└── theme/
    ├── app_colors.dart           # Palette tokens
    └── app_theme.dart            # Typography, decoration, button themes
```

---

## Design language

> *Minimalist dark surrealism.*

| Token       | Use                                            |
| ----------- | ---------------------------------------------- |
| `voidBlack` | `#000000` — page background, true black        |
| `surface`   | `#0A0A0A` — card surfaces                      |
| `attackPrimary` | `#B23A3A` — muted crimson; danger / reset  |
| `defencePrimary`| `#E8E8E8` — cold neon white; discipline    |
| `strokeFaint`   | `#1F1F1F` — hairline separators            |

Principles:

- **No shadows.** Cards are bordered by 1px hairlines, never blurred.
- **Sharp corners.** 4px max radius anywhere in the system.
- **Typographic hierarchy via weight, not family.** Inter only, but ranging from `w400` body to `w800` aggressive counters at `letterSpacing: -2.5`.
- **Crimson is rationed.** It only appears on Attack cards and the reset CTA. Everywhere else is grayscale.

---

## Data model

A single Isar collection — `Habit` — represents both habit types. The `type` enum switches the meaning of `actionLogs`:

- `HabitType.attack` → each entry is a **reset event** (a failure).
- `HabitType.defence` → each entry is a **completion event** (a success).

The model exposes computed getters (`daysSinceReset`, `completionsThisPeriod`, `progress`, `isPeriodComplete`, etc.) so widgets stay dumb.

---

## State management

| Provider                  | Type                              | Role                                  |
| ------------------------- | --------------------------------- | ------------------------------------- |
| `isarProvider`            | `FutureProvider<Isar>`            | Opens the DB once at startup          |
| `habitsStreamProvider`    | `StreamProvider<List<Habit>>`     | Watches the collection for changes    |
| `attackHabitsProvider`    | `Provider<List<Habit>>`           | Filtered slice for the Attack section |
| `defenceHabitsProvider`   | `Provider<List<Habit>>`           | Filtered slice for the Defence section|
| `habitRepositoryProvider` | `Provider<HabitRepository>`       | Write-side CRUD (create / reset / log)|

Writes go through the repository; Isar's `watch()` broadcasts the change back through the stream — no manual `ref.invalidate()` calls anywhere.
