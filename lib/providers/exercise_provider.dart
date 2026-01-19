import 'package:flutter/foundation.dart';
import '../models/exercise_log.dart';
import '../models/user_level.dart';
import '../services/firebase_exercise_service.dart';
import '../services/local_storage_service.dart';

class ExerciseProvider extends ChangeNotifier {
  // Predefined exercises with YouTube demo links
  late List<Exercise> _exercises = [
    // WEEK 1 - Beginner
    Exercise(
      exerciseId: '1',
      name: 'Push-ups',
      muscleGroup: 'Chest',
      steps: ['https://www.youtube.com/watch?v=IODxDxX7oi4'],
      targetReps: 8,
      targetSets: 3,
      caloriesPerSet: 8,
    ),
    Exercise(
      exerciseId: '2',
      name: 'Squats',
      muscleGroup: 'Legs',
      steps: ['https://www.youtube.com/watch?v=xQvguRHXlKQ'],
      targetReps: 12,
      targetSets: 3,
      caloriesPerSet: 10,
    ),
    Exercise(
      exerciseId: '3',
      name: 'Plank Hold',
      muscleGroup: 'Core',
      steps: ['https://www.youtube.com/watch?v=p4VhdAMqnfE'],
      targetReps: 20,
      targetSets: 3,
      caloriesPerSet: 6,
    ),
    Exercise(
      exerciseId: '4',
      name: 'Jumping Jacks',
      muscleGroup: 'Full Body',
      steps: ['https://www.youtube.com/watch?v=c6bSwJe4pIE'],
      targetReps: 15,
      targetSets: 3,
      caloriesPerSet: 12,
    ),
    // WEEK 2 - Intermediate
    Exercise(
      exerciseId: '5',
      name: 'Incline Push-ups',
      muscleGroup: 'Chest',
      steps: ['https://www.youtube.com/watch?v=S-VsxQLhH4g'],
      targetReps: 10,
      targetSets: 3,
      caloriesPerSet: 10,
    ),
    Exercise(
      exerciseId: '6',
      name: 'Bulgarian Split Squats',
      muscleGroup: 'Legs',
      steps: ['https://www.youtube.com/watch?v=wvrnowAf_oA'],
      targetReps: 10,
      targetSets: 3,
      caloriesPerSet: 12,
    ),
    Exercise(
      exerciseId: '7',
      name: 'Side Plank',
      muscleGroup: 'Core',
      steps: ['https://www.youtube.com/watch?v=Hrmob1V_tWI'],
      targetReps: 15,
      targetSets: 3,
      caloriesPerSet: 8,
    ),
    Exercise(
      exerciseId: '8',
      name: 'Mountain Climbers',
      muscleGroup: 'Full Body',
      steps: ['https://www.youtube.com/watch?v=nmwgirgXLYM'],
      targetReps: 20,
      targetSets: 3,
      caloriesPerSet: 14,
    ),
    // WEEK 3 - Advanced
    Exercise(
      exerciseId: '9',
      name: 'Diamond Push-ups',
      muscleGroup: 'Chest',
      steps: ['https://www.youtube.com/watch?v=hGnAPONkFJs'],
      targetReps: 12,
      targetSets: 3,
      caloriesPerSet: 11,
    ),
    Exercise(
      exerciseId: '10',
      name: 'Pistol Squats (Assisted)',
      muscleGroup: 'Legs',
      steps: ['https://www.youtube.com/watch?v=2xLhVJwePEg'],
      targetReps: 8,
      targetSets: 3,
      caloriesPerSet: 14,
    ),
    Exercise(
      exerciseId: '11',
      name: 'Hollow Body Hold',
      muscleGroup: 'Core',
      steps: ['https://www.youtube.com/watch?v=m6O0YFfhvEw'],
      targetReps: 20,
      targetSets: 3,
      caloriesPerSet: 9,
    ),
    Exercise(
      exerciseId: '12',
      name: 'Burpees',
      muscleGroup: 'Full Body',
      steps: ['https://www.youtube.com/watch?v=JZQA84N6MSU'],
      targetReps: 10,
      targetSets: 3,
      caloriesPerSet: 16,
    ),
    // WEEK 4 - Expert
    Exercise(
      exerciseId: '13',
      name: 'Archer Push-ups',
      muscleGroup: 'Chest',
      steps: ['https://www.youtube.com/watch?v=Fk08jzC9bnU'],
      targetReps: 8,
      targetSets: 4,
      caloriesPerSet: 13,
    ),
    Exercise(
      exerciseId: '14',
      name: 'Jump Squats',
      muscleGroup: 'Legs',
      steps: ['https://www.youtube.com/watch?v=0X-0Vj_ZqSY'],
      targetReps: 12,
      targetSets: 4,
      caloriesPerSet: 15,
    ),
    Exercise(
      exerciseId: '15',
      name: 'L-Sit Hold',
      muscleGroup: 'Core',
      steps: ['https://www.youtube.com/watch?v=tTfx0bZBjsA'],
      targetReps: 15,
      targetSets: 3,
      caloriesPerSet: 12,
    ),
    Exercise(
      exerciseId: '16',
      name: 'Jump Lunges',
      muscleGroup: 'Full Body',
      steps: ['https://www.youtube.com/watch?v=2j55dDfXB0g'],
      targetReps: 10,
      targetSets: 3,
      caloriesPerSet: 14,
    ),
  ];

  // Daily plans structure: weeks -> days -> exercise indices
  // Each day has the same 4 exercises that repeat for the whole week
  late List<List<List<int>>> _weekPlans = [
    // Week 1: Days 1-7 (Exercises 0, 1, 2, 3)
    List.filled(7, [0, 1, 2, 3]),
    // Week 2: Days 8-14 (Exercises 4, 5, 6, 7)
    List.filled(7, [4, 5, 6, 7]),
    // Week 3: Days 15-21 (Exercises 8, 9, 10, 11)
    List.filled(7, [8, 9, 10, 11]),
    // Week 4: Days 22-28 (Exercises 12, 13, 14, 15)
    List.filled(7, [12, 13, 14, 15]),
  ];

  int _currentWeek = 0;
  UserLevel _userLevel = UserLevel.beginner;
  int _weekCount = 0; // Track weeks at current level
  Map<String, bool> _completionStatus =
      {}; // "${week}_${dayIndex}_${exerciseId}" -> completed
  List<ExerciseLog> _logs = [];
  static const double COMPLETION_THRESHOLD = 0.90; // 90% completion required

  ExerciseProvider() {
    _initializePlans();
  }

  void _initializePlans() {
    // Initialize completion status for all exercises
    for (int week = 0; week < _weekPlans.length; week++) {
      for (int day = 0; day < 7; day++) {
        for (int exIdx in _weekPlans[week][day]) {
          final key = "${week}_${day}_${_exercises[exIdx].exerciseId}";
          _completionStatus[key] = false;
        }
      }
    }
  }

  // Getters
  List<Exercise> get exercises => _exercises;
  List<List<List<int>>> get weekPlans => _weekPlans;
  int get currentWeek => _currentWeek;
  UserLevel get userLevel => _userLevel;
  int get weekCount => _weekCount;

  /// Set user level from profile
  void setUserLevel(UserLevel level) {
    _userLevel = level;
    notifyListeners();
  }

  // Get exercises for current week (same 4 for all days)
  List<Exercise> get currentWeekExercises =>
      _weekPlans[_currentWeek][0].map((i) => _exercises[i]).toList();

  List<ExerciseLog> get logs => _logs;

  // Check if current week is fully completed (all 4 exercises for all 7 days)
  void _checkWeekCompletion() {
    // This can be used to trigger notifications or UI updates when threshold is met
  }

  /// Calculate progress for current week (using 90% threshold)
  double get weekProgress {
    return getWeekCompletionPercentage();
  }

  /// Check completion percentage for current week
  double getWeekCompletionPercentage() {
    final total = currentWeekExercises.length * 7; // 4 exercises * 7 days
    if (total == 0) return 0;

    int completed = 0;
    for (int day = 0; day < 7; day++) {
      for (int exIdx in _weekPlans[_currentWeek][day]) {
        final key = "${_currentWeek}_${day}_${_exercises[exIdx].exerciseId}";
        if (_completionStatus[key] == true) {
          completed++;
        }
      }
    }
    return completed / total;
  }

  /// Check if current week meets 90% completion threshold
  bool isWeekThresholdMet() {
    return getWeekCompletionPercentage() >= COMPLETION_THRESHOLD;
  }

  /// Check if user can advance to next level
  bool canAdvanceLevel() {
    // Advanced level is the max, no progression beyond that
    if (_userLevel == UserLevel.advanced) return false;
    return isWeekThresholdMet();
  }

  /// Advance user to next fitness level
  void advanceLevel() {
    if (_userLevel == UserLevel.beginner) {
      _userLevel = UserLevel.intermediate;
    } else if (_userLevel == UserLevel.intermediate) {
      _userLevel = UserLevel.advanced;
    }
    // Reset week counter and clear completion for new level
    _weekCount++;
    _clearWeekCompletion();
    notifyListeners();
  }

  /// Clear completion status for current week
  void _clearWeekCompletion() {
    final keysToRemove = <String>[];
    for (int day = 0; day < 7; day++) {
      for (int exIdx in _weekPlans[_currentWeek][day]) {
        final key = "${_currentWeek}_${day}_${_exercises[exIdx].exerciseId}";
        keysToRemove.add(key);
      }
    }
    for (var key in keysToRemove) {
      _completionStatus[key] = false;
    }
  }

  // Add exercise (manual entry)
  void addExercise(Exercise ex) {
    _exercises.add(ex);
    notifyListeners();
  }

  // Toggle exercise as completed for a specific day
  void toggleComplete(String exerciseId, int dayIndex) {
    final key = "${_currentWeek}_${dayIndex}_${exerciseId}";
    _completionStatus[key] = !(_completionStatus[key] ?? false);
    notifyListeners();
  }

  // Mark exercise done with manual log entry (reps, RPE) for a specific day
  void completeExerciseWithLog({
    required String exerciseId,
    required int dayIndex,
    required int repsDone,
    required int rpe,
    required int setsDone,
  }) {
    final key = "${_currentWeek}_${dayIndex}_${exerciseId}";
    _completionStatus[key] = true;

    final ex = _exercises.firstWhere((e) => e.exerciseId == exerciseId);

    // Calculate calories based on sets completed
    final caloriesBurned = ex.calculateTotalCalories(setsDone);

    final log = ExerciseLog(
      start: DateTime.now().subtract(const Duration(minutes: 5)),
      end: DateTime.now(),
      repsDone: repsDone,
      rpe: rpe,
      exercise: ex,
      caloriesBurned: caloriesBurned,
    );
    _logs.add(log);

    // Save to local storage
    _saveWorkoutLocally();

    // Save to Firebase
    _saveWorkoutToFirebase(log);

    // Check if week is complete
    _checkWeekCompletion();
    notifyListeners();
  }

  /// Save workout logs to local storage
  Future<void> _saveWorkoutLocally() async {
    await LocalStorageService.instance.saveWorkoutLogs(_logs);
    await LocalStorageService.instance.saveCompletionStatus(_completionStatus);
  }

  /// Save workout log to Firebase
  Future<void> _saveWorkoutToFirebase(ExerciseLog log) async {
    try {
      print('🏋️ Saving workout to Firebase: ${log.exercise.name}');
      await FirebaseExerciseService.instance.saveWorkoutLog(log);
      print('✅ Workout saved successfully! Calories: ${log.caloriesBurned}');
    } catch (e) {
      print('❌ Error saving to Firebase: $e');
    }
  }

  // Unlock next week if current week is complete
  void unlockNextWeek() {
    final total = currentWeekExercises.length * 7;

    int completed = 0;
    for (int day = 0; day < 7; day++) {
      for (int exIdx in _weekPlans[_currentWeek][day]) {
        final key = "${_currentWeek}_${day}_${_exercises[exIdx].exerciseId}";
        if (_completionStatus[key] == true) {
          completed++;
        }
      }
    }

    if (completed == total && _currentWeek < _weekPlans.length - 1) {
      _currentWeek++;
      notifyListeners();
    }
  }

  // Reset all progress (for testing)
  void resetProgress() {
    _completionStatus.clear();
    _currentWeek = 0;
    _logs.clear();
    _initializePlans();
    notifyListeners();
  }

  /// Add a log from Firebase (used on app startup to load previous workouts)
  void addLogFromFirebase(ExerciseLog log) {
    if (!_logs.any(
      (existingLog) =>
          existingLog.exercise.exerciseId == log.exercise.exerciseId &&
          existingLog.start.day == log.start.day,
    )) {
      _logs.add(log);

      // Mark exercise as completed in the completion status
      final dayIndex = log.start.weekday - 1; // Convert to 0-6 format
      final key = "${_currentWeek}_${dayIndex}_${log.exercise.exerciseId}";
      _completionStatus[key] = true;
    }
  }

  /// Call this after adding all Firebase logs to notify listeners once
  void notifyFirebaseLogsLoaded() {
    notifyListeners();
  }

  /// Load workout logs from local storage
  Future<void> loadLogsFromLocalStorage() async {
    try {
      final logsData = await LocalStorageService.instance.loadWorkoutLogs();
      final statusData = await LocalStorageService.instance
          .loadCompletionStatus();

      for (final logData in logsData) {
        try {
          // Find the exercise by exerciseId
          final exerciseId = logData['exerciseId'] as String?;
          final exerciseName = logData['exerciseName'] as String?;

          Exercise? exercise;
          if (exerciseId != null) {
            exercise = _exercises.firstWhere(
              (ex) => ex.exerciseId == exerciseId,
              orElse: () => Exercise(
                exerciseId: exerciseId,
                name: exerciseName ?? 'Unknown',
                muscleGroup: 'Unknown',
                steps: [],
                targetReps: 0,
                targetSets: 0,
                caloriesPerSet: 0,
              ),
            );
          }

          if (exercise != null) {
            final log = ExerciseLog.fromFirestore(logData, exercise);
            if (!_logs.any(
              (existingLog) =>
                  existingLog.exercise.exerciseId == log.exercise.exerciseId &&
                  existingLog.start.day == log.start.day,
            )) {
              _logs.add(log);
            }
          }
        } catch (e) {
          debugPrint('Error loading log from local storage: $e');
        }
      }

      // Restore completion status
      _completionStatus.addAll(statusData);

      notifyListeners();
      debugPrint('✅ Loaded ${_logs.length} logs from local storage');
    } catch (e) {
      debugPrint('Error loading from local storage: $e');
    }
  }
}
