import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:ouroboros/main.dart';
import 'package:ouroboros/models/habit.dart';
import 'package:ouroboros/providers/database_provider.dart';

void main() {
  testWidgets('Dashboard renders sections', (WidgetTester tester) async {
    final dir = await Directory.systemTemp.createTemp('attack_defence_test_');
    final isar = await Isar.open(
      [HabitSchema],
      name: 'attack_defence_test',
      directory: dir.path,
      inspector: false,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          isarProvider.overrideWith((ref) => Future.value(isar)),
        ],
        child: const AttackDefenceApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('ATTACK'), findsWidgets);
    expect(find.text('DEFENCE'), findsWidgets);

    await isar.close(deleteFromDisk: true);
    await dir.delete(recursive: true);
  });
}
