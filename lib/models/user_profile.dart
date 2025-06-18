import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole {
  owner,
  admin,
  manager,
  employee,
  viewer,
}

enum UserStatus {
  active,
  inactive,
  suspended,
  pending,
}

class UserProfile {
  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? avatarUrl;
  final String organizationId;
  final UserRole role;
  final UserStatus status;
  final List<String> permissions;
  final Map<String, dynamic>? preferences;
  final DateTime? lastLoginAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? invitedBy;

  UserProfile({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.phone,
    this.avatarUrl,
    required this.organizationId,
    this.role = UserRole.employee,
    this.status = UserStatus.pending,
    this.permissions = const [],
    this.preferences,
    this.lastLoginAt,
    required this.createdAt,
    required this.updatedAt,
    this.invitedBy,
  });

  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    } else if (firstName != null) {
      return firstName!;
    } else if (lastName != null) {
      return lastName!;
    } else {
      return email;
    }
  }

  String get displayName {
    return fullName;
  }

  bool get isOwner => role == UserRole.owner;
  bool get isAdmin => role == UserRole.admin || role == UserRole.owner;
  bool get isManager => role == UserRole.manager || isAdmin;
  bool get isActive => status == UserStatus.active;

  bool hasPermission(String permission) {
    return permissions.contains(permission) || isAdmin;
  }

  bool canManageUsers() {
    return isAdmin || hasPermission('manage_users');
  }

  bool canManageProducts() {
    return isManager || hasPermission('manage_products');
  }

  bool canViewReports() {
    return isManager || hasPermission('view_reports');
  }

  bool canManageSales() {
    return isManager || hasPermission('manage_sales');
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'avatarUrl': avatarUrl,
      'organizationId': organizationId,
      'role': role.name,
      'status': status.name,
      'permissions': permissions,
      'preferences': preferences,
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'invitedBy': invitedBy,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map, String id) {
    return UserProfile(
      id: id,
      email: map['email'] as String,
      firstName: map['firstName'] as String?,
      lastName: map['lastName'] as String?,
      phone: map['phone'] as String?,
      avatarUrl: map['avatarUrl'] as String?,
      organizationId: map['organizationId'] as String,
      role: UserRole.values.firstWhere(
        (e) => e.name == map['role'],
        orElse: () => UserRole.employee,
      ),
      status: UserStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => UserStatus.pending,
      ),
      permissions: List<String>.from(map['permissions'] ?? []),
      preferences: map['preferences'] as Map<String, dynamic>?,
      lastLoginAt: map['lastLoginAt'] != null 
        ? DateTime.parse(map['lastLoginAt'] as String)
        : null,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      invitedBy: map['invitedBy'] as String?,
    );
  }

  UserProfile copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? phone,
    String? avatarUrl,
    String? organizationId,
    UserRole? role,
    UserStatus? status,
    List<String>? permissions,
    Map<String, dynamic>? preferences,
    DateTime? lastLoginAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? invitedBy,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      organizationId: organizationId ?? this.organizationId,
      role: role ?? this.role,
      status: status ?? this.status,
      permissions: permissions ?? this.permissions,
      preferences: preferences ?? this.preferences,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      invitedBy: invitedBy ?? this.invitedBy,
    );
  }
} 