import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/exercise_log.dart';

class LocalStorageService {
  static const String _logsKey = 'workout_logs';
  static const String _progressKey = 'week_progress';
  static const String _completionStatusKey = 'completion_status';

  static final LocalStorageService _instance = LocalStorageService._internal();

  factory LocalStorageService() {
    return _instance;
  }

  LocalStorageService._internal();

  static LocalStorageService get instance => _instance;

  /// Save workout logs locally
  Future<void> saveWorkoutLogs(List<ExerciseLog> logs) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Convert logs to JSON
      final logsJson = logs
          .map((log) => jsonEncode(log.toFirestore()))
          .toList();

      await prefs.setStringList(_logsKey, logsJson);
      print('✅ Workout logs saved locally: ${logs.length} logs');
    } catch (e) {
      print('❌ Error saving logs locally: $e');
    }
  }

  /// Load workout logs from local storage
  Future<List<Map<String, dynamic>>> loadWorkoutLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final logsJson = prefs.getStringList(_logsKey) ?? [];

      final logs = logsJson
          .map((json) => jsonDecode(json) as Map<String, dynamic>)
          .toList();

      print('✅ Loaded ${logs.length} workout logs from local storage');
      return logs;
    } catch (e) {
      print('❌ Error loading logs from local storage: $e');
      return [];
    }
  }

  /// Save completion status
  Future<void> saveCompletionStatus(Map<String, bool> status) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Convert to JSON string
      final statusJson = jsonEncode(status);
      await prefs.setString(_completionStatusKey, statusJson);

      print('✅ Completion status saved locally');
    } catch (e) {
      print('❌ Error saving completion status: $e');
    }
  }

  /// Load completion status
  Future<Map<String, bool>> loadCompletionStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statusJson = prefs.getString(_completionStatusKey);

      if (statusJson == null) return {};

      final statusMap = jsonDecode(statusJson) as Map<String, dynamic>;
      return statusMap.map((key, value) => MapEntry(key, value as bool));
    } catch (e) {
      print('❌ Error loading completion status: $e');
      return {};
    }
  }

  /// Save week progress
  Future<void> saveWeekProgress(double progress) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_progressKey, progress);
      print(
        '✅ Week progress saved locally: ${(progress * 100).toStringAsFixed(1)}%',
      );
    } catch (e) {
      print('❌ Error saving progress: $e');
    }
  }

  /// Load week progress
  Future<double> loadWeekProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getDouble(_progressKey) ?? 0.0;
    } catch (e) {
      print('❌ Error loading progress: $e');
      return 0.0;
    }
  }

  /// Clear all local data
  Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_logsKey);
      await prefs.remove(_progressKey);
      await prefs.remove(_completionStatusKey);
      print('✅ Local storage cleared');
    } catch (e) {
      print('❌ Error clearing local storage: $e');
    }
  }
}
