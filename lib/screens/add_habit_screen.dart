import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/habit.dart';
import '../providers/habit_providers.dart';
import '../theme/app_colors.dart';

class AddHabitScreen extends ConsumerStatefulWidget {
  const AddHabitScreen({super.key});

  @override
  ConsumerState<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends ConsumerState<AddHabitScreen> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  HabitType _type = HabitType.attack;
  PeriodType _period = PeriodType.daily;
  int _targetCount = 1;
  bool _isSaving = false;

  DateTime _startDate = DateTime.now();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'NEW HABIT',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            letterSpacing: 2.2,
            fontSize: 14,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Define the fight.',
                  style: text.headlineLarge?.copyWith(
                    fontSize: 34,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nameController,
                  maxLength: 40,
                  style: text.titleMedium,
                  decoration: const InputDecoration(
                    labelText: 'Habit name',
                    hintText: 'e.g. Doom Scrolling',
                    counterText: '',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Name is required.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                _StartDateField(
                  value: _startDate,
                  onTap: _pickStartDate,
                ),
                const SizedBox(height: 18),
                Text(
                  'TYPE',
                  style: text.labelLarge?.copyWith(
                    color: AppColors.textSecondary,
                    letterSpacing: 2.2,
                  ),
                ),
                const SizedBox(height: 10),
                SegmentedButton<HabitType>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(
                      value: HabitType.attack,
                      label: Text('ATTACK'),
                    ),
                    ButtonSegment(
                      value: HabitType.defence,
                      label: Text('DEFENCE'),
                    ),
                  ],
                  selected: {_type},
                  onSelectionChanged: (selection) {
                    setState(() {
                      _type = selection.first;
                    });
                  },
                ),
                if (_type == HabitType.defence) ...[
                  const SizedBox(height: 24),
                  DropdownButtonFormField<PeriodType>(
                    initialValue: _period,
                    decoration: const InputDecoration(labelText: 'Period'),
                    items: const [
                      DropdownMenuItem(
                        value: PeriodType.daily,
                        child: Text('Daily'),
                      ),
                      DropdownMenuItem(
                        value: PeriodType.weekly,
                        child: Text('Weekly'),
                      ),
                      DropdownMenuItem(
                        value: PeriodType.monthly,
                        child: Text('Monthly'),
                      ),
                      DropdownMenuItem(
                        value: PeriodType.continuous,
                        child: Text('Continuous'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _period = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  _TargetCountInput(
                    value: _targetCount,
                    onChanged: (value) => setState(() => _targetCount = value),
                  ),
                ],
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: _type == HabitType.attack ? AppColors.attackPrimary : AppColors.defenceBright,
                      foregroundColor: _type == HabitType.attack ? Colors.white : AppColors.voidBlack,
                    ),
                    child: Text(
                      _isSaving ? 'SAVING...' : 'CREATE HABIT',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2.4,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickStartDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final min = DateTime(2000);

    if (Platform.isIOS) {
      DateTime temp = _startDate;
      await showCupertinoModalPopup<void>(
        context: context,
        builder: (ctx) {
          return CupertinoTheme(
            data: const CupertinoThemeData(
              brightness: Brightness.dark,
            ),
            child: SafeArea(
              top: false,
              child: Container(
                color: AppColors.surface,
                height: 320,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      child: Row(
                        children: [
                          CupertinoButton(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            onPressed: () => Navigator.of(ctx).pop(),
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
                          const Spacer(),
                          CupertinoButton(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            onPressed: () {
                              setState(() => _startDate = temp);
                              Navigator.of(ctx).pop();
                            },
                            child: Text(
                              'DONE',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 2,
                                color: AppColors.defencePrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: AppColors.strokeFaint),
                    Expanded(
                      child: CupertinoDatePicker(
                        mode: CupertinoDatePickerMode.date,
                        initialDateTime: temp.isAfter(today) ? today : temp,
                        minimumDate: min,
                        maximumDate: today,
                        onDateTimeChanged: (d) {
                          temp = DateTime(d.year, d.month, d.day);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
      return;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate.isAfter(today) ? today : _startDate,
      firstDate: min,
      lastDate: today,
      builder: (ctx, child) {
        final dark = ThemeData.dark(useMaterial3: true).copyWith(
          colorScheme: const ColorScheme.dark(
            surface: AppColors.surface,
            primary: AppColors.defencePrimary,
            onPrimary: AppColors.voidBlack,
            onSurface: AppColors.textPrimary,
          ),
          dialogTheme: const DialogThemeData(
            backgroundColor: AppColors.surface,
          ),
        );
        return Theme(data: dark, child: child!);
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = DateTime(picked.year, picked.month, picked.day);
      });
    }
  }

  Future<void> _save() async {
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final start = DateTime(_startDate.year, _startDate.month, _startDate.day);

      final habit = Habit()
        ..name = _nameController.text.trim()
        ..type = _type
        ..periodType = _type == HabitType.attack ? PeriodType.continuous : _period
        ..targetCount = _type == HabitType.attack ? 1 : _targetCount
        ..startDate = start
        ..actionLogs = <DateTime>[];

      await ref.read(habitRepositoryProvider).createHabit(habit);
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.attackPrimary,
          content: Text('Failed to save habit: $error'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}

class _StartDateField extends StatelessWidget {
  const _StartDateField({required this.value, required this.onTap});

  final DateTime value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(value.year, value.month, value.day);
    final label = selected == today ? 'TODAY' : _formatDate(selected);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppColors.strokeMid, width: 1),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'START DATE',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.2,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    style: text.titleMedium?.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            const Icon(
              CupertinoIcons.calendar,
              size: 18,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  static String _formatDate(DateTime d) {
    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    return '${d.day.toString().padLeft(2, '0')} ${months[d.month - 1]} ${d.year}';
  }
}

class _TargetCountInput extends StatelessWidget {
  const _TargetCountInput({
    required this.value,
    required this.onChanged,
  });

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.strokeMid, width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: Row(
        children: [
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Target count',
              style: text.bodyLarge?.copyWith(color: AppColors.textSecondary),
            ),
          ),
          IconButton(
            onPressed: value > 1 ? () => onChanged(value - 1) : null,
            icon: const Icon(Icons.remove, size: 18),
            color: AppColors.textSecondary,
          ),
          Text(
            '$value',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              letterSpacing: 0.4,
            ),
          ),
          IconButton(
            onPressed: () => onChanged(value + 1),
            icon: const Icon(Icons.add, size: 18),
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}
