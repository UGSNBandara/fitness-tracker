class FoodEntry {
	final String name;
	final String quantity;
	final int calories;
	final int protein; // grams
	final int carbs; // grams
	final int fat; // grams
	final DateTime time;

	FoodEntry({
		required this.name,
		required this.quantity,
		required this.calories,
		required this.protein,
		required this.carbs,
		required this.fat,
		DateTime? time,
	}) : time = time ?? DateTime.now();

	FoodEntry copyWith({
		String? name,
		String? quantity,
		int? calories,
		int? protein,
		int? carbs,
		int? fat,
		DateTime? time,
	}) {
		return FoodEntry(
			name: name ?? this.name,
			quantity: quantity ?? this.quantity,
			calories: calories ?? this.calories,
			protein: protein ?? this.protein,
			carbs: carbs ?? this.carbs,
			fat: fat ?? this.fat,
			time: time ?? this.time,
		);
	}
}
