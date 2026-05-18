import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../models/habit.dart';
import 'database_provider.dart';

class HabitRepository {
  const HabitRepository(this._isar);
  final Isar _isar;

  Stream<List<Habit>> watchHabits() {
    return _isar.habits.where().sortByStartDateDesc().watch(fireImmediately: true);
  }

  Future<void> createHabit(Habit habit) async {
    await _isar.writeTxn(() async {
      await _isar.habits.put(habit);
    });
  }

  Future<void> registerReset(Habit habit) async {
    if (habit.type != HabitType.attack) {
      throw StateError('registerReset can only be used with attack habits.');
    }

    await _isar.writeTxn(() async {
      final dbHabit = await _isar.habits.get(habit.id);
      if (dbHabit == null) {
        throw StateError('Habit ${habit.id} was not found.');
      }
      dbHabit.actionLogs = [...dbHabit.actionLogs, DateTime.now()];
      await _isar.habits.put(dbHabit);
    });
  }

  Future<void> registerCompletion(Habit habit) async {
    if (habit.type != HabitType.defence) {
      throw StateError(
        'registerCompletion can only be used with defence habits.',
      );
    }

    await _isar.writeTxn(() async {
      final dbHabit = await _isar.habits.get(habit.id);
      if (dbHabit == null) {
        throw StateError('Habit ${habit.id} was not found.');
      }
      dbHabit.actionLogs = [...dbHabit.actionLogs, DateTime.now()];
      await _isar.habits.put(dbHabit);
    });
  }

  Future<void> undoLastCompletion(Habit habit) async {
    if (habit.type != HabitType.defence) {
      throw StateError(
        'undoLastCompletion can only be used with defence habits.',
      );
    }

    await _isar.writeTxn(() async {
      final dbHabit = await _isar.habits.get(habit.id);
      if (dbHabit == null) {
        throw StateError('Habit ${habit.id} was not found.');
      }
      if (dbHabit.actionLogs.isEmpty) {
        throw StateError('There is no completion to undo.');
      }
      dbHabit.actionLogs = dbHabit.actionLogs.sublist(
        0,
        dbHabit.actionLogs.length - 1,
      );
      await _isar.habits.put(dbHabit);
    });
  }

  Future<void> deleteHabit(int id) async {
    await _isar.writeTxn(() async {
      await _isar.habits.delete(id);
    });
  }
}

final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  final isar = ref.watch(isarProvider).valueOrNull;
  if (isar == null) {
    throw StateError('Database is not ready yet.');
  }
  return HabitRepository(isar);
});

final habitsStreamProvider = StreamProvider<List<Habit>>((ref) async* {
  final isar = await ref.watch(isarProvider.future);
  yield* isar.habits.where().sortByStartDateDesc().watch(fireImmediately: true);
});

final attackHabitsProvider = Provider<List<Habit>>((ref) {
  final habits = ref.watch(habitsStreamProvider).valueOrNull ?? <Habit>[];
  final filtered = habits.where((h) => h.type == HabitType.attack).toList();
  filtered.sort((a, b) => b.daysSinceReset.compareTo(a.daysSinceReset));
  return filtered;
});

final defenceHabitsProvider = Provider<List<Habit>>((ref) {
  final habits = ref.watch(habitsStreamProvider).valueOrNull ?? <Habit>[];
  final filtered = habits.where((h) => h.type == HabitType.defence).toList();
  filtered.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  return filtered;
});
