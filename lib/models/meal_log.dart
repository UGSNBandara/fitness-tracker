class MealLog {
  final String logId;
  final DateTime dateTime;
  final double portion;
  final MealSource source;
  final List<MealEntry> entries;

  MealLog({
    required this.logId,
    required this.dateTime,
    required this.portion,
    required this.source,
    required this.entries,
  });

  double totalCalories() {
    // TODO: Implement calorie calculation
    return 0.0;
  }
}

class MealEntry {
  final String foodId;
  final String name;
  final double qty;
  final MealSource source;

  MealEntry({
    required this.foodId,
    required this.name,
    required this.qty,
    required this.source,
  });
}

enum MealSource {
  MANUAL,
  CAMERA,
  BARCODE,
}
