<p align="center">
  <img src="assets/icon/app_icon.png" width="120" alt="Ouroboros App Icon" />
</p>

<h1 align="center">Ouroboros</h1>

<p align="center">
  A local-first habit tracker built on a single, uncompromising idea:<br/>
  every habit is either something you are <strong>breaking</strong> or something you are <strong>building</strong>.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.19+-02569B?logo=flutter&logoColor=white" />
  <img src="https://img.shields.io/badge/Dart-3.3+-0175C2?logo=dart&logoColor=white" />
  <img src="https://img.shields.io/badge/Isar-on--device-black" />
  <img src="https://img.shields.io/badge/Riverpod-state-orange" />
</p>

---

## The Concept

Ouroboros divides all habits into two opposing modes:

| Mode | Goal | Mechanic |
|------|------|----------|
| **ATTACK** | Break a bad habit | Endurance clock — counts days since your last failure. Tap *I Broke It* to log a reset and restart the counter. |
| **DEFENCE** | Build a good habit | Target counter — hit your completion goal per **Daily / Weekly / Monthly / Continuous** period. Tracks your all-time success rate across past periods. |

Every byte stays on-device. No accounts, no sync, no cloud.

---

## Screenshots

> _Add screenshots here._

---

## Getting Started

```bash
# Install dependencies
flutter pub get

# (Re)generate the Isar adapter.
# A working copy is already committed — only needed when you change the Habit model.
dart run build_runner build --delete-conflicting-outputs

# Run
flutter run
```

**Requirements:** Flutter 3.19+ · Dart 3.3+

---

## Project Structure

```
lib/
├── main.dart                     # App entry — opens Isar then calls runApp
├── models/
│   ├── habit.dart                # Isar collection + all computed getters
│   └── habit.g.dart              # Generated Isar adapter (build_runner)
├── providers/
│   ├── database_provider.dart    # Isar singleton (FutureProvider)
│   └── habit_providers.dart      # Reactive stream + write-side repository
├── screens/
│   ├── dashboard_screen.dart     # Tab view: Attack / Defence lists
│   └── add_habit_screen.dart     # New habit form with type toggle
├── widgets/
│   ├── attack_habit_card.dart    # Day counter + crimson reset button
│   ├── defence_habit_card.dart   # Segmented progress bar + log / undo + all-time rate
│   ├── section_header.dart       # Editorial-style section title
│   └── empty_section.dart        # Empty state placeholder
└── theme/
    ├── app_colors.dart           # Palette tokens
    └── app_theme.dart            # Typography, decoration, button themes
```

---

## Design Language

> *Minimalist dark surrealism.*

| Token | Value | Use |
|-------|-------|-----|
| `voidBlack` | `#000000` | Page background — true black |
| `surface` | `#0A0A0A` | Card surfaces |
| `attackPrimary` | `#B23A3A` | Muted crimson — danger / reset |
| `defencePrimary` | `#E8E8E8` | Cold white — discipline |
| `strokeFaint` | `#1F1F1F` | Hairline separators |

**Principles:**

- **No shadows.** Cards use 1 px hairline borders — nothing blurred.
- **Sharp corners.** 4 px radius maximum, applied consistently.
- **Weight, not family.** Inter throughout, ranging from `w400` body copy to `w800` aggressive counters at `letterSpacing: -2.5`.
- **Crimson is rationed.** Appears only on Attack cards and the reset CTA. Everything else is grayscale.

---

## Data Model

A single Isar collection — `Habit` — represents both types. The `type` field switches the semantics of `actionLogs`:

- `HabitType.attack` → each entry is a **reset event** (a failure timestamp).
- `HabitType.defence` → each entry is a **completion event** (a success timestamp).

Computed getters on the model (`daysSinceReset`, `completionsThisPeriod`, `pastPeriodCount`, `allTimeRate`, etc.) keep widgets completely stateless.

---

## State Management

| Provider | Type | Role |
|----------|------|------|
| `isarProvider` | `FutureProvider<Isar>` | Opens the database once at startup |
| `habitsStreamProvider` | `StreamProvider<List<Habit>>` | Watches the collection for live changes |
| `attackHabitsProvider` | `Provider<List<Habit>>` | Filtered + sorted slice for Attack |
| `defenceHabitsProvider` | `Provider<List<Habit>>` | Filtered + sorted slice for Defence |
| `habitRepositoryProvider` | `Provider<HabitRepository>` | Write-side CRUD (create / reset / log / undo / delete) |

Writes go through the repository. Isar's `watch()` broadcasts the change back through the stream automatically — no manual `ref.invalidate()` anywhere.

---

## License

MIT
