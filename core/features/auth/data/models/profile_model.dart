import 'package:equatable/equatable.dart';

enum UserRole {
  customer,
  wholesaler;

  String get databaseValue {
    return switch (this) {
      UserRole.customer => 'customer',
      UserRole.wholesaler => 'wholesaler',
    };
  }

  String get arabicName {
    return switch (this) {
      UserRole.customer => 'عميل',
      UserRole.wholesaler => 'تاجر جملة',
    };
  }

  static UserRole fromDatabase(String value) {
    return switch (value) {
      'customer' => UserRole.customer,
      'wholesaler' => UserRole.wholesaler,
      _ => throw FormatException('Unknown user role: $value'),
    };
  }
}

class ProfileModel extends Equatable {
  const ProfileModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
    this.businessName,
    this.createdAt,
  });

  final String id;
  final String fullName;
  final String email;
  final String phone;
  final UserRole role;
  final String? businessName;
  final DateTime? createdAt;

  bool get isCustomer {
    return role == UserRole.customer;
  }

  bool get isWholesaler {
    return role == UserRole.wholesaler;
  }

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      id: map['id'] as String,
      fullName: map['full_name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      role: UserRole.fromDatabase(map['role'] as String),
      businessName: map['business_name'] as String?,
      createdAt: _parseDateTime(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'role': role.databaseValue,
      'business_name': businessName,
    };
  }

  ProfileModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phone,
    UserRole? role,
    String? businessName,
    DateTime? createdAt,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      businessName: businessName ?? this.businessName,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props {
    return [id, fullName, email, phone, role, businessName, createdAt];
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) {
      return null;
    }

    return DateTime.tryParse(value.toString());
  }
}
