/// Represents a nutrient profile (per 100g or per serving basis) for a food item.
class NutrientProfile {
  final String profileId; // UUID
  final String basis; // e.g. "per100g", "perServing"
  final double calories;
  final double carbs;
  final double protein;
  final double fat;
  final double fiber;
  final double sugar;
  final double sodium;

  const NutrientProfile({
    required this.profileId,
    required this.basis,
    required this.calories,
    required this.carbs,
    required this.protein,
    required this.fat,
    required this.fiber,
    required this.sugar,
    required this.sodium,
  });
}

/// Represents an item in the food library.
class FoodItem {
  final String foodId; // UUID
  final String name;
  final String category; // e.g. "Fruit", "Beverage"
  final NutrientProfile nutrientProfile; // 1:1 relation per diagram

  const FoodItem({
    required this.foodId,
    required this.name,
    required this.category,
    required this.nutrientProfile,
  });
}

/// Abstraction for searching foods (could wrap API, local DB, or in-memory index).
class FoodLibrary {
  final List<FoodItem> _items;
  FoodLibrary({List<FoodItem>? seed}) : _items = seed ?? [];

  /// Search by name (case-insensitive contains). Returns first match or null for now.
  FoodItem? searchByName(String query) {
    final q = query.toLowerCase();
    try {
      return _items.firstWhere((f) => f.name.toLowerCase().contains(q));
    } catch (_) {
      return null;
    }
  }

  /// Search by ID.
  FoodItem? searchById(String id) {
    try {
      return _items.firstWhere((f) => f.foodId == id);
    } catch (_) {
      return null;
    }
  }

  /// Add or replace existing food item by id.
  void upsert(FoodItem item) {
    final idx = _items.indexWhere((f) => f.foodId == item.foodId);
    if (idx >= 0) {
      _items[idx] = item;
    } else {
      _items.add(item);
    }
  }

  List<FoodItem> all() => List.unmodifiable(_items);
}
