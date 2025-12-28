import 'package:flutter/foundation.dart';

import '../models/habit.dart';
import '../services/habits_service.dart';

class HabitsProvider extends ChangeNotifier {
  final HabitsService _habitsService;

  List<Habit> _habits = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Track which habits are marked as done for a given date (local state only)
  final Map<String, Set<String>> _completedHabits = {};

  HabitsProvider({HabitsService? habitsService})
      : _habitsService = habitsService ?? HabitsService();

  List<Habit> get habits => _habits;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadHabits(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _habits = await _habitsService.getHabits(userId);
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createHabit({
    required String userId,
    required String name,
    String? description,
    HabitType? type,
    required int points,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final habit = await _habitsService.createHabit(
        userId: userId,
        name: name,
        description: description,
        type: type?.name,
        points: points,
      );
      _habits.add(habit);
      _habits.sort((a, b) => a.name.compareTo(b.name));
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateHabit({
    required String id,
    required String name,
    String? description,
    HabitType? type,
    required int points,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final habit = await _habitsService.updateHabit(
        id: id,
        name: name,
        description: description,
        type: type?.name,
        points: points,
      );
      final index = _habits.indexWhere((h) => h.id == id);
      if (index != -1) {
        _habits[index] = habit;
        _habits.sort((a, b) => a.name.compareTo(b.name));
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteHabit(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _habitsService.deleteHabit(id);
      _habits.removeWhere((h) => h.id == id);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Local state for tracking completed habits (not persisted)
  String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  bool isHabitCompleted(String habitId, DateTime date) {
    final key = _dateKey(date);
    return _completedHabits[key]?.contains(habitId) ?? false;
  }

  void toggleHabitCompletion(String habitId, DateTime date) {
    final key = _dateKey(date);
    _completedHabits[key] ??= {};

    if (_completedHabits[key]!.contains(habitId)) {
      _completedHabits[key]!.remove(habitId);
    } else {
      _completedHabits[key]!.add(habitId);
    }
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
