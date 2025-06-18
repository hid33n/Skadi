import 'package:cloud_firestore/cloud_firestore.dart';
import 'product.dart';
import 'sale.dart';
import 'category.dart' as app_category;
import 'movement.dart';

class DashboardData {
  final int totalProducts;
  final int totalSales;
  final double totalRevenue;
  final int totalCategories;
  final List<Movement> recentMovements;
  final List<Product> products;
  final List<Sale> sales;
  final List<app_category.Category> categories;

  DashboardData({
    required this.totalProducts,
    required this.totalSales,
    required this.totalRevenue,
    required this.totalCategories,
    required this.recentMovements,
    required this.products,
    required this.sales,
    required this.categories,
  });

  factory DashboardData.fromFirestore(Map<String, dynamic> data) {
    return DashboardData(
      totalProducts: data['totalProducts'] ?? 0,
      totalSales: data['totalSales'] ?? 0,
      totalRevenue: (data['totalRevenue'] ?? 0.0).toDouble(),
      totalCategories: data['totalCategories'] ?? 0,
      recentMovements: (data['recentMovements'] as List?)
          ?.map((e) => Movement.fromMap(e, ''))
          .toList() ?? [],
      products: (data['products'] as List?)
          ?.map((e) => Product.fromMap(e, ''))
          .toList() ?? [],
      sales: (data['sales'] as List?)
          ?.map((e) => Sale.fromMap(e, ''))
          .toList() ?? [],
      categories: (data['categories'] as List?)
          ?.map((e) => app_category.Category.fromMap(e, ''))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalProducts': totalProducts,
      'totalSales': totalSales,
      'totalRevenue': totalRevenue,
      'totalCategories': totalCategories,
      'recentMovements': recentMovements.map((e) => e.toMap()).toList(),
      'products': products.map((e) => e.toMap()).toList(),
      'sales': sales.map((e) => e.toMap()).toList(),
      'categories': categories.map((e) => e.toMap()).toList(),
    };
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