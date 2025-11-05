import 'package:flutter/foundation.dart';
import '../models/streak.dart';
import '../services/local_storage_service.dart';

class StreakProvider extends ChangeNotifier {
  final LocalStorageService _storage = LocalStorageService();
  Map<String, Streak> _streaks = {};
  bool _isLoading = false;

  Map<String, Streak> get streaks => _streaks;
  bool get isLoading => _isLoading;

  Streak? getStreakForHabit(String habitId) {
    return _streaks[habitId];
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _streaks = await _storage.getStreaks();
    } catch (e) {
      debugPrint('Error loading streaks: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markTodayAsCompleted(String habitId) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    Streak currentStreak = _streaks[habitId] ?? Streak(habitId: habitId);
    
    // Check if already marked today
    if (currentStreak.lastCompletedDate != null) {
      final lastDate = DateTime(
        currentStreak.lastCompletedDate!.year,
        currentStreak.lastCompletedDate!.month,
        currentStreak.lastCompletedDate!.day,
      );
      
      if (lastDate == today) {
        // Already marked today, do nothing
        return;
      }
    }

    // Check if streak should continue or reset
    int newCurrentStreak = 1;
    
    if (currentStreak.lastCompletedDate != null) {
      final lastDate = DateTime(
        currentStreak.lastCompletedDate!.year,
        currentStreak.lastCompletedDate!.month,
        currentStreak.lastCompletedDate!.day,
      );
      
      final yesterday = today.subtract(const Duration(days: 1));
      
      if (lastDate == yesterday) {
        // Consecutive day - continue streak
        newCurrentStreak = currentStreak.currentStreak + 1;
      } else {
        // Gap detected - reset streak
        newCurrentStreak = 1;
      }
    }

    // Update longest streak if exceeded
    int newLongestStreak = currentStreak.longestStreak;
    if (newCurrentStreak > newLongestStreak) {
      newLongestStreak = newCurrentStreak;
    }

    final updatedStreak = Streak(
      habitId: habitId,
      currentStreak: newCurrentStreak,
      longestStreak: newLongestStreak,
      lastCompletedDate: today,
      lastCheckedDate: now,
    );

    _streaks[habitId] = updatedStreak;
    await _storage.saveStreakForHabit(updatedStreak);
    notifyListeners();
  }

  Future<void> checkAndResetIfNeeded(String habitId) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    Streak? streak = _streaks[habitId];
    if (streak == null || streak.lastCheckedDate == null) {
      return;
    }

    final lastChecked = DateTime(
      streak.lastCheckedDate!.year,
      streak.lastCheckedDate!.month,
      streak.lastCheckedDate!.day,
    );

    // If we haven't checked today and it's been more than 1 day since last completion
    if (lastChecked.isBefore(today) && streak.lastCompletedDate != null) {
      final lastCompleted = DateTime(
        streak.lastCompletedDate!.year,
        streak.lastCompletedDate!.month,
        streak.lastCompletedDate!.day,
      );
      
      final yesterday = today.subtract(const Duration(days: 1));
      
      // If last completion was before yesterday, reset streak
      if (lastCompleted.isBefore(yesterday)) {
        final updatedStreak = streak.copyWith(
          currentStreak: 0,
          lastCheckedDate: now,
        );
        _streaks[habitId] = updatedStreak;
        await _storage.saveStreakForHabit(updatedStreak);
        notifyListeners();
      }
    }
  }

  bool isTodayMarked(String habitId) {
    final streak = _streaks[habitId];
    if (streak == null || streak.lastCompletedDate == null) return false;
    
    final today = DateTime.now();
    final lastDate = streak.lastCompletedDate!;
    
    return today.year == lastDate.year &&
           today.month == lastDate.month &&
           today.day == lastDate.day;
  }

  Future<void> checkAllStreaks() async {
    // Check all habits for streaks that need resetting
    for (final habitId in _streaks.keys) {
      await checkAndResetIfNeeded(habitId);
    }
  }
}
