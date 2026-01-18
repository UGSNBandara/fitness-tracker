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
}
