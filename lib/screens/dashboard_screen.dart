import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/habit_providers.dart';
import '../theme/app_colors.dart';
import '../widgets/attack_habit_card.dart';
import '../widgets/defence_habit_card.dart';
import '../widgets/empty_section.dart';
import 'add_habit_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitsStreamProvider);
    final attack = ref.watch(attackHabitsProvider);
    final defence = ref.watch(defenceHabitsProvider);

    return Scaffold(
      body: SafeArea(
        child: habitsAsync.when(
          loading: () => const Center(
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          error: (e, st) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Database error: $e',
                style: const TextStyle(color: AppColors.attackBright),
              ),
            ),
          ),
          data: (_) => DefaultTabController(
            length: 2,
            child: Column(
              children: [
                // TabBar with minimal styling
                Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: AppColors.strokeFaint, width: 1),
                    ),
                  ),
                  child: TabBar(
                    indicatorColor: AppColors.defencePrimary,
                    indicatorWeight: 2,
                    labelStyle: GoogleFonts.inter(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2.8,
                      fontSize: 11,
                    ),
                    unselectedLabelStyle: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.8,
                      fontSize: 11,
                    ),
                    labelColor: AppColors.defencePrimary,
                    unselectedLabelColor: AppColors.textTertiary,
                    tabs: const [
                      Tab(text: 'ATTACK'),
                      Tab(text: 'DEFENCE'),
                    ],
                  ),
                ),
                // TabBarView
                Expanded(
                  child: TabBarView(
                    children: [
                      // Attack Tab
                      if (attack.isEmpty)
                        const Center(
                          child: EmptySection(
                            label:
                                'No bad habits being broken.\nAdd one to start the clock.',
                            accent: AppColors.attackPrimary,
                          ),
                        )
                      else
                        ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: attack.length,
                          itemBuilder: (_, i) {
                            final habit = attack[i];
                            return Dismissible(
                              key: ValueKey(habit.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                color: const Color(0xFF8B0000),
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                child: const Icon(
                                  CupertinoIcons.trash,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              onDismissed: (_) {
                                ref
                                    .read(habitRepositoryProvider)
                                    .deleteHabit(habit.id);
                              },
                              child: AttackHabitCard(habit: habit),
                            );
                          },
                        ),
                      // Defence Tab
                      if (defence.isEmpty)
                        const Center(
                          child: EmptySection(
                            label:
                                'No good habits being built.\nAdd one to set a target.',
                            accent: AppColors.defencePrimary,
                          ),
                        )
                      else
                        ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: defence.length,
                          itemBuilder: (_, i) {
                            final habit = defence[i];
                            return Dismissible(
                              key: ValueKey(habit.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                color: const Color(0xFF8B0000),
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                child: const Icon(
                                  CupertinoIcons.trash,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              onDismissed: (_) {
                                ref
                                    .read(habitRepositoryProvider)
                                    .deleteHabit(habit.id);
                              },
                              child: DefenceHabitCard(habit: habit),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _AddFab(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const AddHabitScreen(),
            fullscreenDialog: true,
          ),
        ),
      ),
    );
  }
}

class _AddFab extends StatelessWidget {
  const _AddFab({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.strokeStrong, width: 1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Material(
        color: AppColors.defenceBright,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(3)),
        ),
        child: InkWell(
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add, size: 16, color: AppColors.voidBlack),
                const SizedBox(width: 8),
                Text(
                  'NEW HABIT',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.5,
                    color: AppColors.voidBlack,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
