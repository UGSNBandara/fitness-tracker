class FoodItem {
  final String foodId;
  final String name;
  final String brand;
  final String servingSize;
  final String barcode;
  final Nutrient nutrient;

  FoodItem({
    required this.foodId,
    required this.name,
    required this.brand,
    required this.servingSize,
    required this.barcode,
    required this.nutrient,
  });
}

class Nutrient {
  final double calories;
  final double carbs;
  final double protein;
  final double fat;
  final double fiber;
  final double sugar;
  final double sodium;

  Nutrient({
    required this.calories,
    required this.carbs,
    required this.protein,
    required this.fat,
    required this.fiber,
    required this.sugar,
    required this.sodium,
  });
}
