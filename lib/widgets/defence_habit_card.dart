import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/habit.dart';
import '../providers/habit_providers.dart';
import '../theme/app_colors.dart';

/// A card for a single Defence (good-habit-building) habit.
///
/// The progress visual is a segmented bar (one cell per required completion).
/// It avoids the cliché circular progress ring and reinforces the
/// "track-style, lap-counter" feeling.
class DefenceHabitCard extends ConsumerWidget {
  const DefenceHabitCard({super.key, required this.habit});
  final Habit habit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final filled = habit.completionsThisPeriod;
    final target = habit.targetCount;
    final complete = habit.isPeriodComplete;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(
          color: complete ? AppColors.defenceBorder : AppColors.strokeFaint,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ─── Header ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 6),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    habit.name.toUpperCase(),
                    style: text.labelLarge?.copyWith(letterSpacing: 2.5),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  habit.periodLabel,
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.8,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),

          // ─── Progress fraction ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  filled.toString(),
                  style: GoogleFonts.inter(
                    fontSize: 56,
                    fontWeight: FontWeight.w800,
                    height: 0.85,
                    letterSpacing: -2.5,
                    color: complete
                        ? AppColors.defenceBright
                        : AppColors.textPrimary,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8, left: 4),
                  child: Text(
                    '/ $target',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textTertiary,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const Spacer(),
                if (complete)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.defenceBorder,
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Text(
                        'COMPLETE',
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2,
                          color: AppColors.defenceBright,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ─── Segmented progress bar ────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
            child: _SegmentedProgress(filled: filled, total: target),
          ),

          // Hairline separator
          Container(height: 1, color: AppColors.strokeFaint),

          // ─── Log action ────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                flex: 4,
                child: InkWell(
                  onTap: complete
                      ? null
                      : () => ref
                          .read(habitRepositoryProvider)
                          .registerCompletion(habit),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: complete
                          ? Colors.transparent
                          : AppColors.defenceTint,
                    ),
                    child: Center(
                      child: Text(
                        complete ? 'NICE WORK' : 'LOG COMPLETION',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 3,
                          color: complete
                              ? AppColors.textTertiary
                              : AppColors.defenceBright,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Container(width: 1, height: 50, color: AppColors.strokeFaint),
              Expanded(
                child: InkWell(
                  onTap: filled == 0
                      ? null
                      : () => ref
                          .read(habitRepositoryProvider)
                          .undoLastCompletion(habit),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Icon(
                        Icons.undo,
                        size: 16,
                        color: filled == 0
                            ? AppColors.textTertiary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Renders `total` thin cells; the first `filled` are lit.
class _SegmentedProgress extends StatelessWidget {
  const _SegmentedProgress({required this.filled, required this.total});
  final int filled;
  final int total;

  @override
  Widget build(BuildContext context) {
    // For very large targets, fall back to a continuous bar so cells
    // don't shrink to imperceptible slivers.
    if (total > 30) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: Stack(
          children: [
            Container(height: 6, color: AppColors.surfaceMuted),
            FractionallySizedBox(
              widthFactor: (filled / total).clamp(0.0, 1.0),
              child: Container(height: 6, color: AppColors.defencePrimary),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 6,
      child: Row(
        children: List.generate(total, (i) {
          final lit = i < filled;
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: i == total - 1 ? 0 : 3),
              decoration: BoxDecoration(
                color: lit ? AppColors.defencePrimary : AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          );
        }),
      ),
    );
  }
}
