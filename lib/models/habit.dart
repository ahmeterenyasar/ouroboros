import 'package:isar/isar.dart';

part 'habit.g.dart';

enum HabitType {
  attack,
  defence,
}

enum PeriodType {
  daily,
  weekly,
  monthly,
  continuous,
}

@collection
class Habit {
  Id id = Isar.autoIncrement;

  late String name;

  @enumerated
  late HabitType type;

  @enumerated
  late PeriodType periodType;

  int targetCount = 1;

  late DateTime startDate;

  List<DateTime> actionLogs = [];

  Habit();

  @ignore
  DateTime get _now => DateTime.now();

  @ignore
  DateTime get streakAnchor {
    if (type != HabitType.attack) return startDate;
    if (actionLogs.isEmpty) return startDate;
    return actionLogs.reduce((a, b) => a.isAfter(b) ? a : b);
  }

  @ignore
  int get daysSinceReset {
    if (type != HabitType.attack) return 0;
    final diff = _now.difference(streakAnchor);
    return diff.inDays;
  }

  @ignore
  int get hoursIntoCurrentDay {
    if (type != HabitType.attack) return 0;
    final diff = _now.difference(streakAnchor);
    return diff.inHours - (diff.inDays * 24);
  }

  @ignore
  int get totalResets => type == HabitType.attack ? actionLogs.length : 0;

  @ignore
  DateTime get currentPeriodStart {
    final now = _now;
    switch (periodType) {
      case PeriodType.daily:
        return DateTime(now.year, now.month, now.day);
      case PeriodType.weekly:
        // ISO week starts Monday.
        final weekday = now.weekday; // Mon = 1 … Sun = 7
        final monday = now.subtract(Duration(days: weekday - 1));
        return DateTime(monday.year, monday.month, monday.day);
      case PeriodType.monthly:
        return DateTime(now.year, now.month, 1);
      case PeriodType.continuous:
        return startDate;
    }
  }

  @ignore
  int get completionsThisPeriod {
    if (type != HabitType.defence) return 0;
    final start = currentPeriodStart;
    final end = currentPeriodEndExclusive;
    return actionLogs.where((d) => !d.isBefore(start) && d.isBefore(end)).length;
  }

  @ignore
  DateTime get currentPeriodEndExclusive {
    final start = currentPeriodStart;
    switch (periodType) {
      case PeriodType.daily:
        return start.add(const Duration(days: 1));
      case PeriodType.weekly:
        return start.add(const Duration(days: 7));
      case PeriodType.monthly:
        return DateTime(start.year, start.month + 1, 1);
      case PeriodType.continuous:
        return DateTime(9999);
    }
  }

  @ignore
  double get progress {
    if (type != HabitType.defence || targetCount <= 0) return 0;
    final ratio = completionsThisPeriod / targetCount;
    return ratio > 1.0 ? 1.0 : ratio;
  }

  @ignore
  bool get isPeriodComplete => type == HabitType.defence && completionsThisPeriod >= targetCount;

  @ignore
  String get progressLabel => '$completionsThisPeriod / $targetCount';

  @ignore
  String get periodLabel {
    switch (periodType) {
      case PeriodType.daily:
        return 'TODAY';
      case PeriodType.weekly:
        return 'THIS WEEK';
      case PeriodType.monthly:
        return 'THIS MONTH';
      case PeriodType.continuous:
        return 'TOTAL';
    }
  }
}
