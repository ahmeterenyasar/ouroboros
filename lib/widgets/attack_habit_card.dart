import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/habit.dart';
import '../providers/habit_providers.dart';
import '../theme/app_colors.dart';

/// A card for a single Attack (bad-habit-breaking) habit.
///
/// Anatomy, top to bottom:
///   1. Header row: habit name (uppercase, tracked) + reset count chip.
///   2. The DAYS counter — the loudest element on screen.
///   3. A hairline rule.
///   4. The RESET / I BROKE IT action — crimson, sharp, weighted.
class AttackHabitCard extends ConsumerWidget {
  const AttackHabitCard({super.key, required this.habit});
  final Habit habit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final days = habit.daysSinceReset;
    final hours = habit.hoursIntoCurrentDay;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.attackBorder, width: 1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ─── Header ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    habit.name.toUpperCase(),
                    style: text.labelLarge?.copyWith(letterSpacing: 2.5),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _ResetCountChip(count: habit.totalResets),
              ],
            ),
          ),

          // ─── The counter ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 22),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  days.toString().padLeft(2, '0'),
                  style: GoogleFonts.inter(
                    fontSize: 88,
                    fontWeight: FontWeight.w800,
                    height: 0.85,
                    letterSpacing: -4,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 14),
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        days == 1 ? 'DAY' : 'DAYS',
                        style: text.labelMedium?.copyWith(
                          color: AppColors.attackBright,
                          letterSpacing: 3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        days == 0 ? '${hours}h in' : 'CLEAN',
                        style: text.bodyMedium?.copyWith(
                          color: AppColors.textTertiary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Hairline separator
          Container(height: 1, color: AppColors.strokeFaint),

          // ─── Reset action ────────────────────────────────────────────
          _ResetButton(
            onPressed: () => _confirmReset(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      builder: (ctx) => _ResetDialog(habitName: habit.name),
    );
    if (confirmed == true) {
      await ref.read(habitRepositoryProvider).registerReset(habit);
    }
  }
}

class _ResetCountChip extends StatelessWidget {
  const _ResetCountChip({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.strokeMid, width: 1),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(
        '$count RESETS',
        style: GoogleFonts.inter(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.5,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _ResetButton extends StatelessWidget {
  const _ResetButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: const BoxDecoration(
          color: AppColors.attackTint,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: AppColors.attackBright,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'I BROKE IT',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 3,
                color: AppColors.attackBright,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResetDialog extends StatelessWidget {
  const _ResetDialog({required this.habitName});
  final String habitName;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: const BorderSide(color: AppColors.attackBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'RESET STREAK',
              style: text.labelLarge?.copyWith(
                color: AppColors.attackBright,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Log a failure for "$habitName"? This action is permanent.',
              style: text.bodyLarge,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.strokeStrong),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(
                      'CANCEL',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.attackPrimary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context, true),
                    child: Text(
                      'CONFIRM',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
