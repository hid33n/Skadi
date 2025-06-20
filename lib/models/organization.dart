import 'package:flutter/foundation.dart';

/// Modelo para representar una organización
class Organization {
  final String id;
  final String name;
  final String description;
  final String ownerId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> settings;
  final List<String> members;
  final String plan;
  final bool isActive;

  Organization({
    required this.id,
    required this.name,
    required this.description,
    required this.ownerId,
    required this.createdAt,
    required this.updatedAt,
    this.settings = const {},
    this.members = const [],
    this.plan = 'free',
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    // Crear una copia segura del settings para evitar referencias circulares
    final safeSettings = <String, dynamic>{};
    for (final entry in settings.entries) {
      final key = entry.key;
      final value = entry.value;
      
      // Solo incluir valores que se pueden serializar a JSON
      if (value is String || value is int || value is double || value is bool || value == null) {
        safeSettings[key] = value;
      } else if (value is List) {
        // Filtrar listas para solo incluir valores serializables
        safeSettings[key] = value.where((item) => 
          item is String || item is int || item is double || item is bool || item == null
        ).toList();
      } else if (value is Map) {
        // Filtrar maps para solo incluir valores serializables
        final safeMap = <String, dynamic>{};
        for (final mapEntry in value.entries) {
          final mapValue = mapEntry.value;
          if (mapValue is String || mapValue is int || mapValue is double || mapValue is bool || mapValue == null) {
            safeMap[mapEntry.key.toString()] = mapValue;
          }
        }
        safeSettings[key] = safeMap;
      }
    }
    
    return {
      'id': id,
      'name': name,
      'description': description,
      'ownerId': ownerId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'settings': safeSettings,
      'members': members,
      'plan': plan,
      'isActive': isActive,
    };
  }

  factory Organization.fromMap(Map<String, dynamic> map, String id) {
    return Organization(
      id: id,
      name: map['name'] as String,
      description: map['description'] as String,
      ownerId: map['ownerId'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      settings: Map<String, dynamic>.from(map['settings'] ?? {}),
      members: List<String>.from(map['members'] ?? []),
      plan: map['plan'] as String? ?? 'free',
      isActive: map['isActive'] as bool? ?? true,
    );
  }

  Organization copyWith({
    String? id,
    String? name,
    String? description,
    String? ownerId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? settings,
    List<String>? members,
    String? plan,
    bool? isActive,
  }) {
    return Organization(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      settings: settings ?? this.settings,
      members: members ?? this.members,
      plan: plan ?? this.plan,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() {
    return 'Organization(id: $id, name: $name, description: $description, ownerId: $ownerId, createdAt: $createdAt, updatedAt: $updatedAt, settings: $settings, members: $members, plan: $plan, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Organization &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.ownerId == ownerId &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        mapEquals(other.settings, settings) &&
        listEquals(other.members, members) &&
        other.plan == plan &&
        other.isActive == isActive;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        description.hashCode ^
        ownerId.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        settings.hashCode ^
        members.hashCode ^
        plan.hashCode ^
        isActive.hashCode;
  }
} 