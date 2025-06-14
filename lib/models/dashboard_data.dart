import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardData {
  final List<SalesData> salesData;
  final List<LowStockProduct> lowStockProducts;
  final List<RecentMovement> recentMovements;
  final Map<String, dynamic> summary;

  DashboardData({
    required this.salesData,
    required this.lowStockProducts,
    required this.recentMovements,
    required this.summary,
  });

  factory DashboardData.fromFirestore(Map<String, dynamic> data) {
    return DashboardData(
      salesData: (data['salesData'] as List)
          .map((e) => SalesData.fromMap(e))
          .toList(),
      lowStockProducts: (data['lowStockProducts'] as List)
          .map((e) => LowStockProduct.fromMap(e))
          .toList(),
      recentMovements: (data['recentMovements'] as List)
          .map((e) => RecentMovement.fromMap(e))
          .toList(),
      summary: data['summary'] ?? {},
    );
  }
}

class SalesData {
  final DateTime date;
  final double amount;
  final int quantity;

  SalesData({
    required this.date,
    required this.amount,
    required this.quantity,
  });

  factory SalesData.fromMap(Map<String, dynamic> map) {
    return SalesData(
      date: (map['date'] as Timestamp).toDate(),
      amount: (map['amount'] as num).toDouble(),
      quantity: map['quantity'] as int,
    );
  }
}

class LowStockProduct {
  final String id;
  final String name;
  final int currentStock;
  final int minimumStock;
  final String category;

  LowStockProduct({
    required this.id,
    required this.name,
    required this.currentStock,
    required this.minimumStock,
    required this.category,
  });

  factory LowStockProduct.fromMap(Map<String, dynamic> map) {
    return LowStockProduct(
      id: map['id'] as String,
      name: map['name'] as String,
      currentStock: map['currentStock'] as int,
      minimumStock: map['minimumStock'] as int,
      category: map['category'] as String,
    );
  }
}

class RecentMovement {
  final String id;
  final String type;
  final String productName;
  final int quantity;
  final DateTime date;
  final String description;

  RecentMovement({
    required this.id,
    required this.type,
    required this.productName,
    required this.quantity,
    required this.date,
    required this.description,
  });

  factory RecentMovement.fromMap(Map<String, dynamic> map) {
    return RecentMovement(
      id: map['id'] as String,
      type: map['type'] as String,
      productName: map['productName'] as String,
      quantity: map['quantity'] as int,
      date: (map['date'] as Timestamp).toDate(),
      description: map['description'] as String,
    );
  }
} 