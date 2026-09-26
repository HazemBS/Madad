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
}
