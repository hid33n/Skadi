import 'package:cloud_firestore/cloud_firestore.dart';

enum MovementType {
  entry,
  exit,
}

class Movement {
  final String id;
  final String productId;
  final String productName;
  final int quantity;
  final MovementType type;
  final DateTime date;
  final String? note;

  Movement({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.type,
    required this.date,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'type': type.toString().split('.').last,
      'date': Timestamp.fromDate(date),
      'note': note,
    };
  }

  factory Movement.fromMap(Map<String, dynamic> map, String id) {
    return Movement(
      id: id,
      productId: map['productId'] as String,
      productName: map['productName'] as String,
      quantity: map['quantity'] as int,
      type: MovementType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
      ),
      date: (map['date'] as Timestamp).toDate(),
      note: map['note'] as String?,
    );
  }

  Movement copyWith({
    String? id,
    String? productId,
    String? productName,
    int? quantity,
    MovementType? type,
    DateTime? date,
    String? note,
  }) {
    return Movement(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      type: type ?? this.type,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }
} 