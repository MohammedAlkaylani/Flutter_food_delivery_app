class MenuCategory {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final List<MenuItem> items;

  MenuCategory({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    required this.items,
  });
}

class MenuItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String? imageUrl;
  final String category;
  final bool isAvailable;
  final int preparationTime;
  final List<CustomizationOption> customizationOptions;
  final List<String> tags;
  final NutritionalInfo? nutritionalInfo;

  MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
    required this.category,
    required this.isAvailable,
    required this.preparationTime,
    required this.customizationOptions,
    required this.tags,
    this.nutritionalInfo,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['menu_id'],
      name: json['item_name'],
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      imageUrl: json['image_url'],
      category: json['category'] ?? 'Main',
      isAvailable: json['availability_status'] ?? true,
      preparationTime: json['preparation_time'] ?? 15,
      customizationOptions: (json['customization_options'] as List<dynamic>?)
          ?.map((option) => CustomizationOption.fromJson(option))
          .toList() ?? [],
      tags: List<String>.from(json['tags'] ?? []),
      nutritionalInfo: json['nutritional_info'] != null
          ? NutritionalInfo.fromJson(json['nutritional_info'])
          : null,
    );
  }

  String get formattedPrice => '\$${price.toStringAsFixed(2)}';
}

class CustomizationOption {
  final String id;
  final String name;
  final List<CustomizationChoice> choices;
  final bool isRequired;
  final int maxChoices;

  CustomizationOption({
    required this.id,
    required this.name,
    required this.choices,
    required this.isRequired,
    required this.maxChoices,
  });

  factory CustomizationOption.fromJson(Map<String, dynamic> json) {
    return CustomizationOption(
      id: json['id'],
      name: json['name'],
      choices: (json['choices'] as List<dynamic>)
          .map((choice) => CustomizationChoice.fromJson(choice))
          .toList(),
      isRequired: json['is_required'] ?? false,
      maxChoices: json['max_choices'] ?? 1,
    );
  }
}

class CustomizationChoice {
  final String id;
  final String name;
  final double? additionalPrice;
  final bool isDefault;

  CustomizationChoice({
    required this.id,
    required this.name,
    this.additionalPrice,
    required this.isDefault,
  });

  factory CustomizationChoice.fromJson(Map<String, dynamic> json) {
    return CustomizationChoice(
      id: json['id'],
      name: json['name'],
      additionalPrice: json['additional_price']?.toDouble(),
      isDefault: json['is_default'] ?? false,
    );
  }

  String get formattedAdditionalPrice =>
      additionalPrice != null && additionalPrice! > 0
          ? '+\$${additionalPrice!.toStringAsFixed(2)}'
          : '';
}

class NutritionalInfo {
  final int calories;
  final double protein;
  final double carbs;
  final double fat;
  final List<String> allergens;

  NutritionalInfo({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.allergens,
  });

  factory NutritionalInfo.fromJson(Map<String, dynamic> json) {
    return NutritionalInfo(
      calories: json['calories'] ?? 0,
      protein: (json['protein'] ?? 0).toDouble(),
      carbs: (json['carbs'] ?? 0).toDouble(),
      fat: (json['fat'] ?? 0).toDouble(),
      allergens: List<String>.from(json['allergens'] ?? []),
    );
  }
}