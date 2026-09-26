enum CategoryIcon { food, store, care, home, electronics, stationery }

class Category {
  const Category({required this.id, required this.name, required this.icon});

  final String id;
  final String name;
  final CategoryIcon icon;

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'icon': icon.name};

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: CategoryIcon.values.byName(json['icon'] as String),
    );
  }
}
