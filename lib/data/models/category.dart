enum CategoryIcon { food, store, care, home, electronics, stationery }

class Category {
  const Category({required this.id, required this.name, required this.icon});

  final String id;
  final String name;
  final CategoryIcon icon;
}
