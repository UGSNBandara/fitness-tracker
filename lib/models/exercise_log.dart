class ExerciseLog {
  final DateTime start;
  final DateTime end;
  final int repsDone;
  final int rpe;
  final Exercise exercise;
  final int caloriesBurned; // Total calories for this exercise log

  ExerciseLog({
    required this.start,
    required this.end,
    required this.repsDone,
    required this.rpe,
    required this.exercise,
    required this.caloriesBurned,
  });

  /// Convert to Firebase-compatible map
  Map<String, dynamic> toFirestore() {
    return {
      'exerciseId': exercise.exerciseId,
      'exerciseName': exercise.name,
      'muscleGroup': exercise.muscleGroup,
      'repsDone': repsDone,
      'rpe': rpe,
      'caloriesBurned': caloriesBurned,
      'start': start,
      'end': end,
      'duration': end.difference(start).inMinutes,
    };
  }

  /// Create from Firebase map
  static ExerciseLog fromFirestore(
    Map<String, dynamic> data,
    Exercise exercise,
  ) {
    // Handle Firestore Timestamps - they have a .toDate() method
    DateTime startDate;
    DateTime endDate;

    final startValue = data['start'];
    final endValue = data['end'];

    // Convert Firestore Timestamp to DateTime
    if (startValue is DateTime) {
      startDate = startValue;
    } else if (startValue != null &&
        startValue.runtimeType.toString().contains('Timestamp')) {
      // Handle Firestore Timestamp
      startDate = (startValue as dynamic).toDate() as DateTime;
    } else {
      startDate = DateTime.now();
    }

    if (endValue is DateTime) {
      endDate = endValue;
    } else if (endValue != null &&
        endValue.runtimeType.toString().contains('Timestamp')) {
      // Handle Firestore Timestamp
      endDate = (endValue as dynamic).toDate() as DateTime;
    } else {
      endDate = DateTime.now();
    }

    return ExerciseLog(
      start: startDate,
      end: endDate,
      repsDone: data['repsDone'] as int? ?? 0,
      rpe: data['rpe'] as int? ?? 0,
      exercise: exercise,
      caloriesBurned: data['caloriesBurned'] as int? ?? 0,
    );
  }
}

class Exercise {
  final String exerciseId;
  final String name;
  final String muscleGroup;
  final List<String> steps; // YouTube URLs
  final int targetReps;
  final int targetSets;
  final Map<String, int>
  setsByLevel; // 'beginner': 2, 'intermediate': 3, 'advanced': 4
  final int caloriesPerSet; // Calories burned per set
  bool completed;
  DateTime? completedAt;

  Exercise({
    required this.exerciseId,
    required this.name,
    required this.muscleGroup,
    required this.steps,
    this.targetReps = 10,
    this.targetSets = 3,
    this.setsByLevel = const {'beginner': 2, 'intermediate': 3, 'advanced': 4},
    this.caloriesPerSet = 10, // Default calories per set
    this.completed = false,
    this.completedAt,
  });

  /// Get sets for a specific fitness level
  int getSetsForLevel(String level) {
    return setsByLevel[level] ?? targetSets;
  }

  /// Calculate total calories for a given number of sets
  int calculateTotalCalories(int setsCompleted) {
    return caloriesPerSet * setsCompleted;
  }
}
