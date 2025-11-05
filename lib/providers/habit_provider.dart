import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/habit.dart';
import '../services/local_storage_service.dart';

class HabitProvider extends ChangeNotifier {
  final LocalStorageService _storage = LocalStorageService();
  final _uuid = const Uuid();
  List<Habit> _habits = [];
  bool _isLoading = false;

  List<Habit> get habits => _habits;
  List<Habit> get activeHabits => _habits.where((h) => h.isActive).toList();
  bool get isLoading => _isLoading;

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _habits = await _storage.getHabits();
      // If no habits exist, create default ones
      if (_habits.isEmpty) {
        await _initializeDefaultHabits();
      }
    } catch (e) {
      debugPrint('Error loading habits: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _initializeDefaultHabits() async {
    _habits = [
      Habit(
        id: _uuid.v4(),
        name: 'Fasting',
        icon: 'fasting',
        isActive: true,
      ),
      Habit(
        id: _uuid.v4(),
        name: 'YouTube Video',
        icon: 'youtube',
        isActive: true,
      ),
    ];
    await _storage.saveHabits(_habits);
  }

  Future<void> addHabit(Habit habit) async {
    _habits.add(habit);
    await _storage.saveHabits(_habits);
    notifyListeners();
  }

  Future<void> updateHabit(Habit updatedHabit) async {
    final index = _habits.indexWhere((h) => h.id == updatedHabit.id);
    if (index != -1) {
      _habits[index] = updatedHabit;
      await _storage.saveHabits(_habits);
      notifyListeners();
    }
  }

  Future<void> deleteHabit(String habitId) async {
    _habits.removeWhere((h) => h.id == habitId);
    await _storage.saveHabits(_habits);
    notifyListeners();
  }

  Future<void> toggleHabitActive(String habitId) async {
    final index = _habits.indexWhere((h) => h.id == habitId);
    if (index != -1) {
      _habits[index] = _habits[index].copyWith(isActive: !_habits[index].isActive);
      await _storage.saveHabits(_habits);
      notifyListeners();
    }
  }

  String generateId() {
    return _uuid.v4();
  }
}

