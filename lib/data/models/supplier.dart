class Supplier {
  const Supplier({
    required this.id,
    required this.name,
    required this.city,
    required this.categoryIds,
    required this.rating,
    required this.verified,
    required this.about,
  });

  final String id;
  final String name;
  final String city;
  final List<String> categoryIds;
  final double rating;
  final bool verified;
  final String about;

  String get initial => name.isEmpty ? 'م' : name.substring(0, 1);
}
