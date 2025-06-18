import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Sale {
  final String id;
  final String userId;
  final String productId;
  final String productName;
  final double amount;
  final int quantity;
  final DateTime date;
  final String organizationId;
  final String? notes;

  Sale({
    required this.id,
    required this.userId,
    required this.productId,
    required this.productName,
    required this.amount,
    required this.quantity,
    required this.date,
    required this.organizationId,
    this.notes,
  });

  factory Sale.fromMap(Map<String, dynamic> map, String id) {
    return Sale(
      id: id,
      userId: map['userId'] as String,
      productId: map['productId'] as String,
      productName: map['productName'] as String,
      amount: (map['amount'] as num).toDouble(),
      quantity: map['quantity'] as int,
      date: (map['date'] as Timestamp).toDate(),
      organizationId: map['organizationId'] as String,
      notes: map['notes'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'productId': productId,
      'productName': productName,
      'amount': amount,
      'quantity': quantity,
      'date': Timestamp.fromDate(date),
      'organizationId': organizationId,
      'notes': notes,
    };
  }

  String get formattedDate => DateFormat('dd/MM/yyyy HH:mm').format(date);
  String get formattedTotal => '\$${amount.toStringAsFixed(2)}';
}

class SaleItem {
  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double subtotal;

  SaleItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'subtotal': subtotal,
    };
  }

  factory SaleItem.fromJson(Map<String, dynamic> json) {
    return SaleItem(
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      quantity: json['quantity'] as int,
      unitPrice: json['unitPrice'] as double,
      subtotal: json['subtotal'] as double,
    );
  }
} 