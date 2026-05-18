import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../models/habit.dart';

const _databaseName = 'attack_defence_db';

final isarProvider = FutureProvider<Isar>((ref) async {
  final existing = Isar.getInstance(_databaseName);
  if (existing != null && existing.isOpen) return existing;

  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open(
    [HabitSchema],
    name: _databaseName,
    directory: dir.path,
    inspector: true,
  );

  ref.onDispose(() {
    if (isar.isOpen) {
      isar.close();
    }
  });

  return isar;
});
