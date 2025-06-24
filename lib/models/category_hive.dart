import 'package:hive/hive.dart';

part 'category_hive.g.dart';

@HiveType(typeId: 1)
class CategoryHive extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String? description;

  @HiveField(3)
  String? color;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  DateTime updatedAt;

  CategoryHive({
    required this.id,
    required this.name,
    this.description,
    this.color,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convertir desde el modelo Category original
  factory CategoryHive.fromCategory(dynamic category) {
    return CategoryHive(
      id: category.id,
      name: category.name,
      description: category.description,
      color: category.color,
      createdAt: category.createdAt,
      updatedAt: category.updatedAt,
    );
  }

  // Convertir al modelo Category original
  Map<String, dynamic> toCategoryMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'color': color,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Crear una copia con cambios
  CategoryHive copyWith({
    String? id,
    String? name,
    String? description,
    String? color,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CategoryHive(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'CategoryHive(id: $id, name: $name)';
  }
} 