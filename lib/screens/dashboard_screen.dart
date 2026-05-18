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
        child: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              const _DashboardHeader(),
              TabBar(
                indicatorColor: AppColors.strokeStrong,
                indicatorWeight: 2,
                labelPadding: const EdgeInsets.symmetric(vertical: 12),
                tabs: [
                  Tab(
                    child: Text(
                      'ATTACK',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 3.0,
                        fontSize: 11,
                        color: AppColors.attackPrimary,
                      ),
                    ),
                  ),
                  Tab(
                    child: Text(
                      'DEFENCE',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 3.0,
                        fontSize: 11,
                        color: AppColors.defencePrimary,
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _TabBody(
                      habitsAsync: habitsAsync,
                      empty: const EmptySection(
                        label: 'No bad habits being broken.\nAdd one to start the clock.',
                        accent: AppColors.attackPrimary,
                      ),
                      list: ListView.builder(
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
                              ref.read(habitRepositoryProvider).deleteHabit(habit.id);
                            },
                            child: AttackHabitCard(habit: habit),
                          );
                        },
                      ),
                      isEmpty: attack.isEmpty,
                    ),
                    _TabBody(
                      habitsAsync: habitsAsync,
                      empty: const EmptySection(
                        label: 'No good habits being built.\nAdd one to set a target.',
                        accent: AppColors.defencePrimary,
                      ),
                      list: ListView.builder(
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
                              ref.read(habitRepositoryProvider).deleteHabit(habit.id);
                            },
                            child: DefenceHabitCard(habit: habit),
                          );
                        },
                      ),
                      isEmpty: defence.isEmpty,
                    ),
                  ],
                ),
              ),
            ],
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

class _TabBody extends StatelessWidget {
  const _TabBody({
    required this.habitsAsync,
    required this.empty,
    required this.list,
    required this.isEmpty,
  });

  final AsyncValue<Object?> habitsAsync;
  final Widget empty;
  final Widget list;
  final bool isEmpty;

  @override
  Widget build(BuildContext context) {
    return habitsAsync.when(
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
      data: (_) => isEmpty ? Center(child: empty) : list,
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'THE BATTLE LOG',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              height: 1.0,
              letterSpacing: -1.2,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          const _ConceptLine(
            label: 'ATTACK',
            labelColor: AppColors.attackPrimary,
            text: 'Endure and break. A race against the clock.',
          ),
          const SizedBox(height: 6),
          const _ConceptLine(
            label: 'DEFENCE',
            labelColor: AppColors.defencePrimary,
            text: 'Build and fortify. Consistency over time.',
          ),
          const SizedBox(height: 14),
          Container(height: 1, color: AppColors.strokeFaint),
        ],
      ),
    );
  }
}

class _ConceptLine extends StatelessWidget {
  const _ConceptLine({
    required this.label,
    required this.labelColor,
    required this.text,
  });

  final String label;
  final Color labelColor;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '$label: ',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: labelColor,
            ),
          ),
          TextSpan(
            text: text,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.1,
              color: AppColors.textSecondary,
            ),
          ),
        ],
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
