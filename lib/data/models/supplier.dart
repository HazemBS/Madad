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

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'city': city,
    'categoryIds': categoryIds,
    'rating': rating,
    'verified': verified,
    'about': about,
  };

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      id: json['id'] as String,
      name: json['name'] as String,
      city: json['city'] as String,
      categoryIds: [
        for (final id in json['categoryIds'] as List<dynamic>) id as String,
      ],
      rating: (json['rating'] as num).toDouble(),
      verified: json['verified'] as bool? ?? false,
      about: json['about'] as String? ?? '',
    );
  }
}
