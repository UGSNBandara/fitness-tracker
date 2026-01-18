import 'package:flutter/foundation.dart';
import '../models/exercise_log.dart';

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
    ),
    Exercise(
      exerciseId: '2',
      name: 'Squats',
      muscleGroup: 'Legs',
      steps: ['https://www.youtube.com/watch?v=xQvguRHXlKQ'],
      targetReps: 12,
      targetSets: 3,
    ),
    Exercise(
      exerciseId: '3',
      name: 'Plank Hold',
      muscleGroup: 'Core',
      steps: ['https://www.youtube.com/watch?v=p4VhdAMqnfE'],
      targetReps: 20,
      targetSets: 3,
    ),
    Exercise(
      exerciseId: '4',
      name: 'Jumping Jacks',
      muscleGroup: 'Full Body',
      steps: ['https://www.youtube.com/watch?v=c6bSwJe4pIE'],
      targetReps: 15,
      targetSets: 3,
    ),
    // WEEK 2 - Intermediate
    Exercise(
      exerciseId: '5',
      name: 'Incline Push-ups',
      muscleGroup: 'Chest',
      steps: ['https://www.youtube.com/watch?v=S-VsxQLhH4g'],
      targetReps: 10,
      targetSets: 3,
    ),
    Exercise(
      exerciseId: '6',
      name: 'Bulgarian Split Squats',
      muscleGroup: 'Legs',
      steps: ['https://www.youtube.com/watch?v=wvrnowAf_oA'],
      targetReps: 10,
      targetSets: 3,
    ),
    Exercise(
      exerciseId: '7',
      name: 'Side Plank',
      muscleGroup: 'Core',
      steps: ['https://www.youtube.com/watch?v=Hrmob1V_tWI'],
      targetReps: 15,
      targetSets: 3,
    ),
    Exercise(
      exerciseId: '8',
      name: 'Mountain Climbers',
      muscleGroup: 'Full Body',
      steps: ['https://www.youtube.com/watch?v=nmwgirgXLYM'],
      targetReps: 20,
      targetSets: 3,
    ),
    // WEEK 3 - Advanced
    Exercise(
      exerciseId: '9',
      name: 'Diamond Push-ups',
      muscleGroup: 'Chest',
      steps: ['https://www.youtube.com/watch?v=hGnAPONkFJs'],
      targetReps: 12,
      targetSets: 3,
    ),
    Exercise(
      exerciseId: '10',
      name: 'Pistol Squats (Assisted)',
      muscleGroup: 'Legs',
      steps: ['https://www.youtube.com/watch?v=2xLhVJwePEg'],
      targetReps: 8,
      targetSets: 3,
    ),
    Exercise(
      exerciseId: '11',
      name: 'Hollow Body Hold',
      muscleGroup: 'Core',
      steps: ['https://www.youtube.com/watch?v=m6O0YFfhvEw'],
      targetReps: 20,
      targetSets: 3,
    ),
    Exercise(
      exerciseId: '12',
      name: 'Burpees',
      muscleGroup: 'Full Body',
      steps: ['https://www.youtube.com/watch?v=JZQA84N6MSU'],
      targetReps: 10,
      targetSets: 3,
    ),
    // WEEK 4 - Expert
    Exercise(
      exerciseId: '13',
      name: 'Archer Push-ups',
      muscleGroup: 'Chest',
      steps: ['https://www.youtube.com/watch?v=Fk08jzC9bnU'],
      targetReps: 8,
      targetSets: 4,
    ),
    Exercise(
      exerciseId: '14',
      name: 'Jump Squats',
      muscleGroup: 'Legs',
      steps: ['https://www.youtube.com/watch?v=0X-0Vj_ZqSY'],
      targetReps: 12,
      targetSets: 4,
    ),
    Exercise(
      exerciseId: '15',
      name: 'L-Sit Hold',
      muscleGroup: 'Core',
      steps: ['https://www.youtube.com/watch?v=tTfx0bZBjsA'],
      targetReps: 15,
      targetSets: 3,
    ),
    Exercise(
      exerciseId: '16',
      name: 'Jump Lunges',
      muscleGroup: 'Full Body',
      steps: ['https://www.youtube.com/watch?v=2j55dDfXB0g'],
      targetReps: 10,
      targetSets: 3,
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
  Map<String, bool> _completionStatus =
      {}; // "${week}_${dayIndex}_${exerciseId}" -> completed
  List<ExerciseLog> _logs = [];

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

  // Get exercises for current week (same 4 for all days)
  List<Exercise> get currentWeekExercises =>
      _weekPlans[_currentWeek][0].map((i) => _exercises[i]).toList();

  List<ExerciseLog> get logs => _logs;

  // Calculate progress for current week
  double get weekProgress {
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
  }) {
    final key = "${_currentWeek}_${dayIndex}_${exerciseId}";
    _completionStatus[key] = true;

    final ex = _exercises.firstWhere((e) => e.exerciseId == exerciseId);
    final log = ExerciseLog(
      start: DateTime.now().subtract(const Duration(minutes: 5)),
      end: DateTime.now(),
      repsDone: repsDone,
      rpe: rpe,
      exercise: ex,
    );
    _logs.add(log);

    // Check if week is complete
    _checkWeekCompletion();
    notifyListeners();
  }

  // Check if current week is fully completed (all 4 exercises for all 7 days)
  void _checkWeekCompletion() {
    final total = currentWeekExercises.length * 7; // 4 exercises * 7 days

    int completed = 0;
    for (int day = 0; day < 7; day++) {
      for (int exIdx in _weekPlans[_currentWeek][day]) {
        final key = "${_currentWeek}_${day}_${_exercises[exIdx].exerciseId}";
        if (_completionStatus[key] == true) {
          completed++;
        }
      }
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
}
