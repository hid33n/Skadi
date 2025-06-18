import 'package:cloud_firestore/cloud_firestore.dart';

class Organization {
  final String id;
  final String name;
  final String? description;
  final String? logoUrl;
  final String? website;
  final String? phone;
  final String? email;
  final String? address;
  final String? city;
  final String? state;
  final String? country;
  final String? postalCode;
  final String? taxId;
  final String? currency;
  final String? timezone;
  final Map<String, dynamic>? settings;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;

  Organization({
    required this.id,
    required this.name,
    this.description,
    this.logoUrl,
    this.website,
    this.phone,
    this.email,
    this.address,
    this.city,
    this.state,
    this.country,
    this.postalCode,
    this.taxId,
    this.currency = 'USD',
    this.timezone = 'UTC',
    this.settings,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'logoUrl': logoUrl,
      'website': website,
      'phone': phone,
      'email': email,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'postalCode': postalCode,
      'taxId': taxId,
      'currency': currency,
      'timezone': timezone,
      'settings': settings,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
    };
  }

  factory Organization.fromMap(Map<String, dynamic> map, String id) {
    return Organization(
      id: id,
      name: map['name'] as String,
      description: map['description'] as String?,
      logoUrl: map['logoUrl'] as String?,
      website: map['website'] as String?,
      phone: map['phone'] as String?,
      email: map['email'] as String?,
      address: map['address'] as String?,
      city: map['city'] as String?,
      state: map['state'] as String?,
      country: map['country'] as String?,
      postalCode: map['postalCode'] as String?,
      taxId: map['taxId'] as String?,
      currency: map['currency'] as String? ?? 'USD',
      timezone: map['timezone'] as String? ?? 'UTC',
      settings: map['settings'] as Map<String, dynamic>?,
      isActive: map['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      createdBy: map['createdBy'] as String,
    );
  }

  Organization copyWith({
    String? id,
    String? name,
    String? description,
    String? logoUrl,
    String? website,
    String? phone,
    String? email,
    String? address,
    String? city,
    String? state,
    String? country,
    String? postalCode,
    String? taxId,
    String? currency,
    String? timezone,
    Map<String, dynamic>? settings,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
  }) {
    return Organization(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      logoUrl: logoUrl ?? this.logoUrl,
      website: website ?? this.website,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
      taxId: taxId ?? this.taxId,
      currency: currency ?? this.currency,
      timezone: timezone ?? this.timezone,
      settings: settings ?? this.settings,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }
} 