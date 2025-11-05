import '../models/goal.dart';
import '../models/streak.dart';

class RewardCalculator {
  /// Calculate the current reward per day based on streak and goal settings
  /// 
  /// Logic:
  /// - If current streak < longest streak: use reward from longest streak
  /// - If current streak >= longest streak: calculate new reward with growth
  static double calculateRewardPerDay(Goal goal, Streak streak) {
    if (streak.currentStreak == 0) {
      return goal.baseRewardPerDay;
    }

    // If we haven't surpassed the longest streak, use the reward from longest streak
    if (streak.currentStreak < streak.longestStreak) {
      return _calculateRewardForStreak(goal, streak.longestStreak);
    }

    // Calculate reward for current streak (which is >= longest streak)
    return _calculateRewardForStreak(goal, streak.currentStreak);
  }

  /// Calculate reward for a specific streak length
  /// Formula: baseReward * (1 + growthPercentage) ^ (streakDays - 1)
  /// This applies percentage growth each day
  static double _calculateRewardForStreak(Goal goal, int streakDays) {
    if (streakDays <= 0) {
      return goal.baseRewardPerDay;
    }

    // Apply compound growth: baseReward * (1 + growthPercentage/100) ^ (streakDays - 1)
    // Day 1: baseReward (no growth)
    // Day 2: baseReward * (1 + growthPercentage/100)
    // Day 3: baseReward * (1 + growthPercentage/100) ^ 2
    // etc.
    final growthFactor = 1.0 + (goal.growthPercentage / 100.0);
    final multiplier = _power(growthFactor, streakDays - 1);
    return goal.baseRewardPerDay * multiplier;
  }

  /// Simple power function for double values
  static double _power(double base, int exponent) {
    if (exponent == 0) return 1.0;
    if (exponent < 0) return 1.0 / _power(base, -exponent);
    
    double result = 1.0;
    for (int i = 0; i < exponent; i++) {
      result *= base;
    }
    return result;
  }

  /// Calculate total saved amount based on streak and goal
  static double calculateTotalSaved(Goal goal, Streak streak) {
    if (streak.currentStreak == 0) {
      return 0.0;
    }

    double total = 0.0;
    final growthFactor = 1.0 + (goal.growthPercentage / 100.0);

    // Calculate cumulative reward for each day in the streak
    for (int day = 1; day <= streak.currentStreak; day++) {
      if (day == 1) {
        total += goal.baseRewardPerDay;
      } else {
        final dayReward = goal.baseRewardPerDay * _power(growthFactor, day - 1);
        total += dayReward;
      }
    }

    return total;
  }

  /// Calculate total saved from all habits combined
  /// Each habit gets the same reward, so we sum all habit streaks
  static double calculateTotalSavedFromAllHabits(Goal goal, Map<String, Streak> streaks) {
    double total = 0.0;
    
    for (final streak in streaks.values) {
      total += calculateTotalSaved(goal, streak);
    }
    
    return total;
  }

  /// Calculate combined reward per day from all habits
  /// Each habit contributes its reward per day
  static double calculateCombinedRewardPerDay(Goal goal, Map<String, Streak> streaks) {
    double total = 0.0;
    
    for (final streak in streaks.values) {
      total += calculateRewardPerDay(goal, streak);
    }
    
    return total;
  }

  /// Estimate days remaining to reach goal
  static int? estimateDaysRemaining(Goal goal, Streak streak, double totalSaved) {
    final remaining = goal.targetAmount - totalSaved;
    if (remaining <= 0) return 0;

    final currentReward = calculateRewardPerDay(goal, streak);
    if (currentReward <= 0) return null;

    // Simple estimation: assume current reward rate continues
    // For more accuracy, we could project future growth, but this is simpler
    return (remaining / currentReward).ceil();
  }
}

