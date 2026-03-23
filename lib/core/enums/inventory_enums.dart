enum ItemCategory {
  coffeeBeans,
  milk,
  syrup,
  pastry,
  food,
  cleaning,
  packaging,
  other
}

enum ItemUnit {
  kg,
  g,
  l,
  ml,
  piece,
  pack,
  box
}

extension ItemCategoryExtension on ItemCategory {
  String get displayName {
    switch (this) {
      case ItemCategory.coffeeBeans: return 'Coffee Beans';
      case ItemCategory.milk: return 'Milk';
      case ItemCategory.syrup: return 'Syrup/Flavoring';
      case ItemCategory.pastry: return 'Pastry';
      case ItemCategory.food: return 'Food';
      case ItemCategory.cleaning: return 'Cleaning Supplies';
      case ItemCategory.packaging: return 'Packaging/Containers';
      case ItemCategory.other: return 'Other';
    }
  }
}

extension ItemUnitExtension on ItemUnit {
  String get displayName {
    switch (this) {
      case ItemUnit.kg: return 'kg';
      case ItemUnit.g: return 'g';
      case ItemUnit.l: return 'L';
      case ItemUnit.ml: return 'mL';
      case ItemUnit.piece: return 'Piece';
      case ItemUnit.pack: return 'Pack';
      case ItemUnit.box: return 'Box';
    }
  }
}
