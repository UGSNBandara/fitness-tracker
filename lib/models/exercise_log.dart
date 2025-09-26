class ExerciseLog {
  final DateTime start;
  final DateTime end;
  final int repsDone;
  final int rpe;
  final Exercise exercise;

  ExerciseLog({
    required this.start,
    required this.end,
    required this.repsDone,
    required this.rpe,
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
