class Goal {
  final String goalId;
  final GoalType type;
  final double target;
  final Period period;

  Goal({
    required this.goalId,
    required this.type,
    required this.target,
    required this.period,
  });
}

enum GoalType { WEIGHT, CALORIES, PROTEIN, STEPS, WORKOUTS_PER_WEEK }

enum GoalMetricDetail {
  NET_INTAKE,
  BURNED,
  GRAMS,
  PERCENTAGE_OF_CALORIES,
  DURATION_MINUTES,
  SESSIONS_COMPLETED,
}

class Period {
  // Define period details here
}
