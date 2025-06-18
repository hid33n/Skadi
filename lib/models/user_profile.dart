import 'package:flutter/foundation.dart';

/// Roles de usuario en la aplicación
enum UserRole {
  owner,
  admin,
  manager,
  employee,
  viewer,
}

/// Modelo para representar el perfil de un usuario
class UserProfile {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? phone;
  final String? avatarUrl;
  final UserRole role;
  final String organizationId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final Map<String, dynamic>? preferences;
  final List<String> permissions;

  UserProfile({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phone,
    this.avatarUrl,
    required this.role,
    required this.organizationId,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.preferences,
    this.permissions = const [],
  });

  String get fullName => '$firstName $lastName';
  String get displayName => fullName.isNotEmpty ? fullName : email;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'avatarUrl': avatarUrl,
      'role': role.name,
      'organizationId': organizationId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive,
      'preferences': preferences,
      'permissions': permissions,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map, String id) {
    return UserProfile(
      id: id,
      email: map['email'] as String,
      firstName: map['firstName'] as String,
      lastName: map['lastName'] as String,
      phone: map['phone'] as String?,
      avatarUrl: map['avatarUrl'] as String?,
      role: UserRole.values.firstWhere(
        (role) => role.name == map['role'],
        orElse: () => UserRole.viewer,
      ),
      organizationId: map['organizationId'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      isActive: map['isActive'] as bool? ?? true,
      preferences: map['preferences'] as Map<String, dynamic>?,
      permissions: List<String>.from(map['permissions'] ?? []),
    );
  }

  UserProfile copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? phone,
    String? avatarUrl,
    UserRole? role,
    String? organizationId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    Map<String, dynamic>? preferences,
    List<String>? permissions,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      organizationId: organizationId ?? this.organizationId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      preferences: preferences ?? this.preferences,
      permissions: permissions ?? this.permissions,
    );
  }

  @override
  String toString() {
    return 'UserProfile(id: $id, email: $email, firstName: $firstName, lastName: $lastName, phone: $phone, avatarUrl: $avatarUrl, role: $role, organizationId: $organizationId, createdAt: $createdAt, updatedAt: $updatedAt, isActive: $isActive, preferences: $preferences, permissions: $permissions)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfile &&
        other.id == id &&
        other.email == email &&
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.phone == phone &&
        other.avatarUrl == avatarUrl &&
        other.role == role &&
        other.organizationId == organizationId &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.isActive == isActive &&
        mapEquals(other.preferences, preferences) &&
        listEquals(other.permissions, permissions);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        email.hashCode ^
        firstName.hashCode ^
        lastName.hashCode ^
        phone.hashCode ^
        avatarUrl.hashCode ^
        role.hashCode ^
        organizationId.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        isActive.hashCode ^
        preferences.hashCode ^
        permissions.hashCode;
  }
} 