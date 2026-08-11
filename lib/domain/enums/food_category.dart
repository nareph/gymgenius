enum FoodCategory {
  carbohydrate,
  protein,
  fat,
  vegetable,
  fruit,
  traditionalMeal,
}

extension FoodCategoryExtension on FoodCategory {
  String get displayName {
    switch (this) {
      case FoodCategory.carbohydrate:
        return 'Carbohydrate';
      case FoodCategory.protein:
        return 'Protein';
      case FoodCategory.fat:
        return 'Fat';
      case FoodCategory.vegetable:
        return 'Vegetable';
      case FoodCategory.fruit:
        return 'Fruit';
      case FoodCategory.traditionalMeal:
        return 'Traditional meal';
    }
  }

  String get value {
    switch (this) {
      case FoodCategory.carbohydrate:
        return 'carbohydrate';
      case FoodCategory.protein:
        return 'protein';
      case FoodCategory.fat:
        return 'fat';
      case FoodCategory.vegetable:
        return 'vegetable';
      case FoodCategory.fruit:
        return 'fruit';
      case FoodCategory.traditionalMeal:
        return 'traditional_meal';
    }
  }

  static FoodCategory fromValue(String value) {
    return FoodCategory.values.firstWhere(
      (e) => e.value == value,
      orElse: () => FoodCategory.carbohydrate,
    );
  }
}
