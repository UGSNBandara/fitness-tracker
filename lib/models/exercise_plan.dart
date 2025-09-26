import 'workout.dart';
import 'user_level.dart';

class ExercisePlan {
  final String planId;
  final UserLevel level;
  final String name;
  final String desc;
  final List<Workout> workouts;

  ExercisePlan({
    required this.planId,
    required this.level,
    required this.name,
    required this.desc,
    required this.workouts,
  });
}
