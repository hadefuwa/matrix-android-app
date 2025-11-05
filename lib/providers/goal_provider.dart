import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/goal.dart';
import '../services/local_storage_service.dart';

class GoalProvider extends ChangeNotifier {
  final LocalStorageService _storage = LocalStorageService();
  final _uuid = const Uuid();
  List<Goal> _goals = [];
  bool _isLoading = false;

  List<Goal> get goals => _goals;
  List<Goal> get activeGoals => _goals.where((g) => g.isActive).toList();
  bool get isLoading => _isLoading;

  Goal? getActiveGoal() {
    final active = activeGoals;
    if (active.isEmpty) return null;
    // Return the first active goal, or you could implement logic to select one
    return active.first;
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _goals = await _storage.getGoals();
    } catch (e) {
      debugPrint('Error loading goals: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addGoal(Goal goal) async {
    _goals.add(goal);
    await _storage.saveGoals(_goals);
    notifyListeners();
  }

  Future<void> updateGoal(Goal updatedGoal) async {
    final index = _goals.indexWhere((g) => g.id == updatedGoal.id);
    if (index != -1) {
      _goals[index] = updatedGoal;
      await _storage.saveGoals(_goals);
      notifyListeners();
    }
  }

  Future<void> deleteGoal(String goalId) async {
    _goals.removeWhere((g) => g.id == goalId);
    await _storage.saveGoals(_goals);
    notifyListeners();
  }

  Future<void> toggleGoalActive(String goalId) async {
    final index = _goals.indexWhere((g) => g.id == goalId);
    if (index != -1) {
      _goals[index] = _goals[index].copyWith(isActive: !_goals[index].isActive);
      await _storage.saveGoals(_goals);
      notifyListeners();
    }
  }

  String generateId() {
    return _uuid.v4();
  }
}

