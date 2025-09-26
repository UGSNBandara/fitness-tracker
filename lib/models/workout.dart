enum WorkoutStatus {
  PLANNED,
  IN_PROGRESS,
  DONE,
}

class Workout {
  final String workoutId;
  final DateTime date;
  final WorkoutStatus status;
  final List<WorkoutExercise> exercises;

  Workout({
    required this.workoutId,
    required this.date,
    required this.status,
    required this.exercises,
  });
}

class WorkoutExercise {
  final int sets;
  final int reps;
  final int restSec;
  final Exercise exercise;

  WorkoutExercise({
    required this.sets,
    required this.reps,
    required this.restSec,
    required this.exercise,
  });
}

class Exercise {
  final String exerciseId;
  final String name;
  final String muscleGroup;

  Exercise({
    required this.exerciseId,
    required this.name,
    required this.muscleGroup,
  });
}
