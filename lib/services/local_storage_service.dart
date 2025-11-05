import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/goal.dart';
import '../models/streak.dart';
import '../models/habit.dart';

class LocalStorageService {
  static const String _goalsKey = 'goals';
  static const String _habitsKey = 'habits';
  static const String _streaksKey = 'streaks';
  static const String _totalSavedKey = 'total_saved';

  // Goals
  Future<List<Goal>> getGoals() async {
    final prefs = await SharedPreferences.getInstance();
    final goalsJson = prefs.getString(_goalsKey);
    if (goalsJson == null) return [];
    
    try {
      final List<dynamic> decoded = json.decode(goalsJson);
      return decoded.map((json) => Goal.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveGoals(List<Goal> goals) async {
    final prefs = await SharedPreferences.getInstance();
    final goalsJson = json.encode(goals.map((goal) => goal.toJson()).toList());
    await prefs.setString(_goalsKey, goalsJson);
  }

  // Habits
  Future<List<Habit>> getHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final habitsJson = prefs.getString(_habitsKey);
    if (habitsJson == null) return [];
    
    try {
      final List<dynamic> decoded = json.decode(habitsJson);
      return decoded.map((json) => Habit.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveHabits(List<Habit> habits) async {
    final prefs = await SharedPreferences.getInstance();
    final habitsJson = json.encode(habits.map((habit) => habit.toJson()).toList());
    await prefs.setString(_habitsKey, habitsJson);
  }

  // Streaks (multiple streaks, one per habit)
  Future<Map<String, Streak>> getStreaks() async {
    final prefs = await SharedPreferences.getInstance();
    final streaksJson = prefs.getString(_streaksKey);
    if (streaksJson == null) return {};
    
    try {
      final Map<String, dynamic> decoded = json.decode(streaksJson);
      final Map<String, Streak> streaks = {};
      decoded.forEach((key, value) {
        streaks[key] = Streak.fromJson(value as Map<String, dynamic>);
      });
      return streaks;
    } catch (e) {
      return {};
    }
  }

  Future<void> saveStreaks(Map<String, Streak> streaks) async {
    final prefs = await SharedPreferences.getInstance();
    final streaksMap = <String, dynamic>{};
    streaks.forEach((key, streak) {
      streaksMap[key] = streak.toJson();
    });
    final streaksJson = json.encode(streaksMap);
    await prefs.setString(_streaksKey, streaksJson);
  }

  // Legacy method for backward compatibility (returns first streak if exists)
  Future<Streak?> getStreakForHabit(String habitId) async {
    final streaks = await getStreaks();
    return streaks[habitId];
  }

  Future<void> saveStreakForHabit(Streak streak) async {
    final streaks = await getStreaks();
    streaks[streak.habitId] = streak;
    await saveStreaks(streaks);
  }

  // Total Saved
  Future<double> getTotalSaved() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_totalSavedKey) ?? 0.0;
  }

  Future<void> saveTotalSaved(double total) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_totalSavedKey, total);
  }
}

