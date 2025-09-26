import 'goal.dart';
import 'exercise_log.dart';
import 'meal_log.dart';
import 'exercise_plan.dart';
import 'user_level.dart';

class User {
	final String userId;
	String name;
	String email;
	UserLevel level;
	double height;
	double weight;
	DateTime dob;
	String gender;
	List<MealLog> mealLogs = [];
	List<ExerciseLog> exerciseLogs = [];
	List<Goal> goals = [];
	ExercisePlan? exercisePlan;

	User({
		required this.userId,
		required this.name,
		required this.email,
		required this.level,
		required this.height,
		required this.weight,
		required this.dob,
		required this.gender,
	});

	void createAccount() {
		// TODO: Implement account creation logic
	}

	void updateProfile() {
		// TODO: Implement profile update logic
	}
}
