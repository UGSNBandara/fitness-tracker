class FoodRecognitionModel {
  Future<List<FoodItemProb>> detectFood(dynamic image) async {
    // TODO: Implement food detection
    return [];
  }
}

class FoodItemProb {
  final String foodId;
  final double probability;

  FoodItemProb({required this.foodId, required this.probability});
}
