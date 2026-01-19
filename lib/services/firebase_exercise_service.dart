import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import '../models/exercise_log.dart';
import '../models/exercise.dart';

class FirebaseExerciseService {
  FirebaseExerciseService._();
  static final instance = FirebaseExerciseService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Save a workout log to Firebase
  Future<void> saveWorkoutLog(ExerciseLog log) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    try {
      await _db
          .collection('users')
          .doc(user.uid)
          .collection('workoutLogs')
          .doc()
          .set({
            ...log.toFirestore(),
            'createdAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      throw Exception('Failed to save workout log: $e');
    }
  }

  /// Get all workout logs for a user
  Future<List<Map<String, dynamic>>> getWorkoutLogs() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    try {
      final snapshot = await _db
          .collection('users')
          .doc(user.uid)
          .collection('workoutLogs')
          .orderBy('start', descending: true)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw Exception('Failed to fetch workout logs: $e');
    }
  }

  /// Get workout logs for a specific date range
  Future<List<Map<String, dynamic>>> getWorkoutLogsInRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    try {
      final snapshot = await _db
          .collection('users')
          .doc(user.uid)
          .collection('workoutLogs')
          .where('start', isGreaterThanOrEqualTo: startDate)
          .where('start', isLessThanOrEqualTo: endDate)
          .orderBy('start', descending: true)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw Exception('Failed to fetch workout logs: $e');
    }
  }

  /// Get total calories burned in last N days
  Future<int> getTotalCaloriesLastDays(int days) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    try {
      final startDate = DateTime.now().subtract(Duration(days: days));
      final snapshot = await _db
          .collection('users')
          .doc(user.uid)
          .collection('workoutLogs')
          .where('start', isGreaterThanOrEqualTo: startDate)
          .get();

      int totalCalories = 0;
      for (var doc in snapshot.docs) {
        totalCalories += (doc.data()['caloriesBurned'] as int? ?? 0);
      }
      return totalCalories;
    } catch (e) {
      return 0;
    }
  }

  /// Get workout statistics
  Future<Map<String, dynamic>> getWorkoutStats() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    try {
      final snapshot = await _db
          .collection('users')
          .doc(user.uid)
          .collection('workoutLogs')
          .get();

      int totalWorkouts = snapshot.docs.length;
      int totalCalories = 0;
      int totalMinutes = 0;
      Map<String, int> exerciseCounts = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        totalCalories += (data['caloriesBurned'] as int? ?? 0);
        totalMinutes += (data['duration'] as int? ?? 0);

        final exerciseName = data['exerciseName'] as String? ?? 'Unknown';
        exerciseCounts[exerciseName] = (exerciseCounts[exerciseName] ?? 0) + 1;
      }

      return {
        'totalWorkouts': totalWorkouts,
        'totalCalories': totalCalories,
        'totalMinutes': totalMinutes,
        'averageCaloriesPerWorkout': totalWorkouts > 0
            ? (totalCalories ~/ totalWorkouts)
            : 0,
        'favoriteExercises': exerciseCounts,
      };
    } catch (e) {
      return {
        'totalWorkouts': 0,
        'totalCalories': 0,
        'totalMinutes': 0,
        'averageCaloriesPerWorkout': 0,
        'favoriteExercises': {},
      };
    }
  }

  /// Delete a workout log
  Future<void> deleteWorkoutLog(String logId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    try {
      await _db
          .collection('users')
          .doc(user.uid)
          .collection('workoutLogs')
          .doc(logId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete workout log: $e');
    }
  }
}
