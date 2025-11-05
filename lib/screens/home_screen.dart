import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/streak_provider.dart';
import '../providers/goal_provider.dart';
import '../providers/habit_provider.dart';
import '../services/reward_calculator.dart';
import '../widgets/streak_display.dart';
import '../models/habit.dart';
import '../models/streak.dart';
import 'habits_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _selectedHabitId;

  @override
  void initState() {
    super.initState();
    // Check if streaks need resetting when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StreakProvider>().checkAllStreaks();
      final habits = context.read<HabitProvider>().activeHabits;
      if (habits.isNotEmpty && _selectedHabitId == null) {
        setState(() {
          _selectedHabitId = habits.first.id;
        });
      }
    });
  }

  IconData _getIconForHabit(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'fasting':
        return Icons.favorite;
      case 'youtube':
        return Icons.play_circle;
      default:
        return Icons.check_circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final streakProvider = context.watch<StreakProvider>();
    final goalProvider = context.watch<GoalProvider>();
    final habitProvider = context.watch<HabitProvider>();
    final activeGoal = goalProvider.getActiveGoal();
    final activeHabits = habitProvider.activeHabits;

    final currencyFormat = NumberFormat.currency(symbol: '£', decimalDigits: 2);

    // Calculate combined rewards from all habits
    double combinedRewardPerDay = 0.0;
    double combinedTotalSaved = 0.0;
    int? daysRemaining;

    if (activeGoal != null && activeHabits.isNotEmpty) {
      combinedRewardPerDay = RewardCalculator.calculateCombinedRewardPerDay(
        activeGoal,
        streakProvider.streaks,
      );
      combinedTotalSaved = RewardCalculator.calculateTotalSavedFromAllHabits(
        activeGoal,
        streakProvider.streaks,
      );
      
      // Estimate days remaining based on combined reward
      final remaining = activeGoal.targetAmount - combinedTotalSaved;
      if (remaining > 0 && combinedRewardPerDay > 0) {
        daysRemaining = (remaining / combinedRewardPerDay).ceil();
      } else if (remaining <= 0) {
        daysRemaining = 0;
      }
    }

    // Get selected habit streak
    Streak? selectedHabitStreak;
    Habit? selectedHabit;
    if (_selectedHabitId != null && activeHabits.isNotEmpty) {
      try {
        selectedHabit = activeHabits.firstWhere((h) => h.id == _selectedHabitId);
        selectedHabitStreak = streakProvider.getStreakForHabit(_selectedHabitId!);
      } catch (e) {
        selectedHabit = activeHabits.first;
        _selectedHabitId = selectedHabit.id;
        selectedHabitStreak = streakProvider.getStreakForHabit(_selectedHabitId!);
      }
    } else if (activeHabits.isNotEmpty) {
      selectedHabit = activeHabits.first;
      _selectedHabitId = selectedHabit.id;
      selectedHabitStreak = streakProvider.getStreakForHabit(_selectedHabitId!);
    }

    final selectedStreak = selectedHabitStreak ?? 
        (_selectedHabitId != null 
            ? Streak(habitId: _selectedHabitId!) 
            : const Streak(habitId: ''));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vice App'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Habit',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HabitsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await habitProvider.loadData();
          await streakProvider.loadData();
          await goalProvider.loadData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Combined Streak Display
              if (activeHabits.isNotEmpty)
                StreakDisplay(
                  currentStreak: selectedStreak.currentStreak,
                  longestStreak: selectedStreak.longestStreak,
                  rewardPerDay: activeGoal != null
                      ? RewardCalculator.calculateRewardPerDay(activeGoal, selectedStreak)
                      : 0.0,
                )
              else
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const Icon(Icons.add_circle_outline, size: 48),
                        const SizedBox(height: 16),
                        const Text('No Habits Yet'),
                        const SizedBox(height: 8),
                        const Text('Add habits to start tracking!'),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HabitsScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Add Habit'),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 24),

              // Habit Selection
              if (activeHabits.isNotEmpty) ...[
                Text(
                  'Select Habit to Mark',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: activeHabits.map((habit) {
                    final isSelected = _selectedHabitId == habit.id;
                    final isTodayMarked = streakProvider.isTodayMarked(habit.id);

                    return FilterChip(
                      selected: isSelected,
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getIconForHabit(habit.icon),
                            size: 18,
                            color: isSelected
                                ? Theme.of(context).colorScheme.onPrimary
                                : null,
                          ),
                          const SizedBox(width: 4),
                          Text(habit.name),
                          if (isTodayMarked) ...[
                            const SizedBox(width: 4),
                            Icon(
                              Icons.check_circle,
                              size: 16,
                              color: isSelected
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : Colors.green,
                            ),
                          ],
                        ],
                      ),
                      onSelected: (selected) {
                        setState(() {
                          _selectedHabitId = habit.id;
                        });
                      },
                      showCheckmark: false,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Mark Habit Button
                if (_selectedHabitId != null && selectedHabit != null)
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: FilledButton.icon(
                      key: ValueKey(streakProvider.isTodayMarked(_selectedHabitId!)),
                      onPressed: streakProvider.isTodayMarked(_selectedHabitId!)
                          ? null
                          : () async {
                              await streakProvider.markTodayAsCompleted(_selectedHabitId!);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${selectedHabit!.name} marked! Keep it up! 🎉'),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                      icon: Icon(
                        streakProvider.isTodayMarked(_selectedHabitId!)
                            ? Icons.check_circle
                            : _getIconForHabit(selectedHabit.icon),
                      ),
                      label: Text(
                        streakProvider.isTodayMarked(_selectedHabitId!)
                            ? '${selectedHabit.name} Already Marked Today'
                            : 'Mark ${selectedHabit.name}',
                      ),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 24),

                // All Habits Overview
                if (activeHabits.length > 1) ...[
                  Text(
                    'All Habits Overview',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  ...activeHabits.map((habit) {
                    final habitStreak = streakProvider.getStreakForHabit(habit.id) ??
                        Streak(habitId: habit.id);
                    final rewardPerDay = activeGoal != null
                        ? RewardCalculator.calculateRewardPerDay(activeGoal, habitStreak)
                        : 0.0;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Icon(_getIconForHabit(habit.icon)),
                        title: Text(habit.name),
                        subtitle: Text('${habitStreak.currentStreak} day streak'),
                        trailing: Text(
                          currencyFormat.format(rewardPerDay),
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 24),
                ],
              ],

              // Active Goal Progress
              if (activeGoal != null) ...[
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutCubic,
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Goal Image
                          if (activeGoal.imagePath != null)
                            Center(
                              child: Container(
                                constraints: const BoxConstraints(
                                  maxHeight: 180,
                                  maxWidth: double.infinity,
                                ),
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    File(activeGoal.imagePath!),
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Theme.of(context).colorScheme.surfaceVariant,
                                        child: const Center(
                                          child: Icon(Icons.broken_image, size: 48),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  activeGoal.name,
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/add-goal',
                                    arguments: activeGoal,
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Saved (Combined)',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              Text(
                                currencyFormat.format(combinedTotalSaved),
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: (combinedTotalSaved / activeGoal.targetAmount).clamp(0.0, 1.0),
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Target',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Text(
                                currencyFormat.format(activeGoal.targetAmount),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                          if (daysRemaining != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 16,
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Estimated $daysRemaining day${daysRemaining == 1 ? '' : 's'} remaining',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          if (activeHabits.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.trending_up,
                                    size: 16,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Combined reward: ${currencyFormat.format(combinedRewardPerDay)}/day',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: Theme.of(context).colorScheme.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ] else ...[
                // No active goal
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Icon(
                          Icons.flag_outlined,
                          size: 48,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No Active Goal',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Create a goal to start tracking your rewards!',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(context, '/add-goal');
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Create Goal'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
