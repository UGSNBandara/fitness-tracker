import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/food.dart';

class NutritionService {
  NutritionService._();
  static final instance = NutritionService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current user ID
  String? get _userId => _auth.currentUser?.uid;

  /// Save daily nutrition data for a specific date
  Future<void> saveDailyNutrition(DateTime date, Map<String, List<FoodEntry>> meals) async {
    if (_userId == null) throw Exception('Not authenticated');

    final dateKey = _getDateKey(date);
    final mealsData = <String, dynamic>{};

    for (final entry in meals.entries) {
      mealsData[entry.key] = entry.value.map((food) => _foodEntryToMap(food)).toList();
    }

    await _db
        .collection('users')
        .doc(_userId)
        .collection('nutrition')
        .doc(dateKey)
        .set({
      'date': Timestamp.fromDate(date),
      'meals': mealsData,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Load daily nutrition data for a specific date
  Future<Map<String, List<FoodEntry>>> loadDailyNutrition(DateTime date) async {
    if (_userId == null) throw Exception('Not authenticated');

    final dateKey = _getDateKey(date);
    final doc = await _db
        .collection('users')
        .doc(_userId)
        .collection('nutrition')
        .doc(dateKey)
        .get();

    if (!doc.exists || doc.data() == null) {
      return {
        'Breakfast': [],
        'Lunch': [],
        'Dinner': [],
        'Snacks': [],
      };
    }

    final data = doc.data()!;
    final mealsData = data['meals'] as Map<String, dynamic>? ?? {};

    final result = <String, List<FoodEntry>>{
      'Breakfast': [],
      'Lunch': [],
      'Dinner': [],
      'Snacks': [],
    };

    for (final entry in mealsData.entries) {
      final mealName = entry.key;
      final foods = entry.value as List<dynamic>? ?? [];
      result[mealName] = foods.map((f) => _foodEntryFromMap(f)).toList();
    }

    return result;
  }

  /// Get nutrition summary for a date range (default: last 7 days)
  Future<Map<String, dynamic>> getNutritionSummary({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (_userId == null) throw Exception('Not authenticated');

    final start = startDate ?? DateTime.now().subtract(const Duration(days: 7));
    final end = endDate ?? DateTime.now();

    final query = await _db
        .collection('users')
        .doc(_userId)
        .collection('nutrition')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .get();

    int totalCalories = 0;
    int totalProtein = 0;
    int totalCarbs = 0;
    int totalFat = 0;
    int daysWithData = 0;

    for (final doc in query.docs) {
      final data = doc.data();
      final mealsData = data['meals'] as Map<String, dynamic>? ?? {};

      bool hasData = false;
      for (final mealList in mealsData.values) {
        final foods = mealList as List<dynamic>? ?? [];
        for (final foodMap in foods) {
          final food = _foodEntryFromMap(foodMap);
          totalCalories += food.calories;
          totalProtein += food.protein;
          totalCarbs += food.carbs;
          totalFat += food.fat;
          hasData = true;
        }
      }
      if (hasData) daysWithData++;
    }

    final daysDiff = end.difference(start).inDays + 1;
    final avgCalories = daysWithData > 0 ? (totalCalories / daysWithData).round() : 0;
    final avgProtein = daysWithData > 0 ? (totalProtein / daysWithData).round() : 0;
    final avgCarbs = daysWithData > 0 ? (totalCarbs / daysWithData).round() : 0;
    final avgFat = daysWithData > 0 ? (totalFat / daysWithData).round() : 0;

    return {
      'totalCalories': totalCalories,
      'totalProtein': totalProtein,
      'totalCarbs': totalCarbs,
      'totalFat': totalFat,
      'avgCalories': avgCalories,
      'avgProtein': avgProtein,
      'avgCarbs': avgCarbs,
      'avgFat': avgFat,
      'daysWithData': daysWithData,
      'totalDays': daysDiff,
    };
  }

  /// Get today's nutrition summary
  Future<Map<String, int>> getTodayNutrition() async {
    if (_userId == null) throw Exception('Not authenticated');

    final today = DateTime.now();
    final meals = await loadDailyNutrition(today);

    int calories = 0;
    int protein = 0;
    int carbs = 0;
    int fat = 0;

    for (final mealList in meals.values) {
      for (final food in mealList) {
        calories += food.calories;
        protein += food.protein;
        carbs += food.carbs;
        fat += food.fat;
      }
    }

    return {
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
    };
  }

  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> _foodEntryToMap(FoodEntry entry) {
    return {
      'name': entry.name,
      'quantity': entry.quantity,
      'calories': entry.calories,
      'protein': entry.protein,
      'carbs': entry.carbs,
      'fat': entry.fat,
      'time': Timestamp.fromDate(entry.time),
    };
  }

  FoodEntry _foodEntryFromMap(Map<String, dynamic> map) {
    return FoodEntry(
      name: map['name'] ?? '',
      quantity: map['quantity'] ?? '',
      calories: (map['calories'] ?? 0) as int,
      protein: (map['protein'] ?? 0) as int,
      carbs: (map['carbs'] ?? 0) as int,
      fat: (map['fat'] ?? 0) as int,
      time: (map['time'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
