import 'food_item.dart';

/// Represents a logged meal composed of multiple entries.
class MealLog {
  final String logId; // UUID
  final DateTime dateTime;
  final MealSource source; // Dominant source (e.g. CAMERA if majority auto)
  final List<MealEntry> entries;

  MealLog({
    required this.logId,
    required this.dateTime,
    required this.source,
    List<MealEntry>? entries,
  }) : entries = entries ?? [];

  /// Computes total calories by summing subTotals of each entry.
  double totalCalories(Map<String, FoodItem> foodLookup) {
    return entries.fold(0.0, (sum, e) => sum + e.subTotalCalories(foodLookup));
  }

  void addEntry(MealEntry entry) => entries.add(entry);
  void removeEntry(String foodId) =>
      entries.removeWhere((e) => e.foodId == foodId);
}

/// A single food component within a meal.
class MealEntry {
  final String foodId; // Links to FoodItem
  final String name; // Snapshotted name at logging time (in case lib changes)
  final double
  qty; // Quantity in the same basis as FoodItem profile (e.g. grams)
  final MealSource source;

  MealEntry({
    required this.foodId,
    required this.name,
    required this.qty,
    required this.source,
  });

  /// Computes calories for this entry using the referenced food's nutrient profile.
  double subTotalCalories(Map<String, FoodItem> foodLookup) {
    final item = foodLookup[foodId];
    if (item == null) return 0.0;
    final profile = item.nutrientProfile;
    // Assume profile.basis == per100g; adjust accordingly.
    if (profile.basis.toLowerCase() == 'per100g') {
      return (qty / 100.0) * profile.calories;
    }
    // If perServing, qty = number of servings.
    if (profile.basis.toLowerCase() == 'perserving') {
      return qty * profile.calories;
    }
    // Fallback treat as per unit.
    return qty * profile.calories;
  }
}

enum MealSource { MANUAL, CAMERA, BARCODE }
