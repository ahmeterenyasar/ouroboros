import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/habit_providers.dart';
import '../theme/app_colors.dart';
import '../widgets/attack_habit_card.dart';
import '../widgets/defence_habit_card.dart';
import '../widgets/empty_section.dart';
import '../widgets/section_header.dart';
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
          data: (_) => CustomScrollView(
            slivers: [
              // ─── Masthead ─────────────────────────────────────────
              const SliverToBoxAdapter(child: _Masthead()),

              // ─── ATTACK section ───────────────────────────────────
              SliverToBoxAdapter(
                child: SectionHeader(
                  label: 'ATTACK',
                  count: attack.length,
                  accent: AppColors.attackPrimary,
                ),
              ),
              if (attack.isEmpty)
                const SliverToBoxAdapter(
                  child: EmptySection(
                    label: 'No bad habits being broken.\nAdd one to start the clock.',
                    accent: AppColors.attackPrimary,
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => AttackHabitCard(habit: attack[i]),
                    childCount: attack.length,
                  ),
                ),

              // ─── DEFENCE section ──────────────────────────────────
              SliverToBoxAdapter(
                child: SectionHeader(
                  label: 'DEFENCE',
                  count: defence.length,
                  accent: AppColors.defencePrimary,
                ),
              ),
              if (defence.isEmpty)
                const SliverToBoxAdapter(
                  child: EmptySection(
                    label: 'No good habits being built.\nAdd one to set a target.',
                    accent: AppColors.defencePrimary,
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => DefenceHabitCard(habit: defence[i]),
                    childCount: defence.length,
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 120)),
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

/// Top-of-page masthead. No AppBar — we want generous breathing room
/// and the bigger label.
class _Masthead extends StatelessWidget {
  const _Masthead();

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'ATTACK',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 3,
                  color: AppColors.attackPrimary,
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                width: 8,
                height: 1,
                color: AppColors.strokeStrong,
              ),
              Text(
                'DEFENCE',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 3,
                  color: AppColors.defencePrimary,
                ),
              ),
              const Spacer(),
              Text(
                _dateLabel(now),
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.5,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'A daily\nbattle log.',
            style: GoogleFonts.inter(
              fontSize: 34,
              fontWeight: FontWeight.w800,
              height: 1.0,
              letterSpacing: -1.4,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  String _dateLabel(DateTime d) {
    const months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    return '${d.day.toString().padLeft(2, '0')} ${months[d.month - 1]} ${d.year}';
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
