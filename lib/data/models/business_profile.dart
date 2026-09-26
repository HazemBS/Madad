class BusinessProfile {
  const BusinessProfile({
    required this.businessName,
    required this.ownerName,
    required this.phone,
    required this.city,
    required this.addresses,
  });

  final String businessName;
  final String ownerName;
  final String phone;
  final String city;
  final List<String> addresses;

  Map<String, dynamic> toJson() => {
    'businessName': businessName,
    'ownerName': ownerName,
    'phone': phone,
    'city': city,
    'addresses': addresses,
  };

  factory BusinessProfile.fromJson(Map<String, dynamic> json) {
    return BusinessProfile(
      businessName: json['businessName'] as String,
      ownerName: json['ownerName'] as String,
      phone: json['phone'] as String,
      city: json['city'] as String,
      addresses: [
        for (final address in json['addresses'] as List<dynamic>)
          address as String,
      ],
    );
  }
}
