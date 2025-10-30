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

enum GoalType { weight, calories, protein, steps, workoutsPerWeek }

enum GoalMetricDetail {
  netIntake,
  burned,
  grams,
  percentageOfCalories,
  durationMinutes,
  sessionsCompleted,
}

class Period {
  // Define period details here
}
