// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:stock/main.dart';
import 'package:stock/services/auth_service.dart';
import 'package:stock/services/firestore_service.dart';
import 'package:stock/viewmodels/auth_viewmodel.dart';
import 'package:stock/viewmodels/category_viewmodel.dart';
import 'package:stock/viewmodels/product_viewmodel.dart';
import 'package:stock/viewmodels/sale_viewmodel.dart';
import 'package:stock/viewmodels/movement_viewmodel.dart';
import 'package:stock/viewmodels/dashboard_viewmodel.dart';
import 'package:stock/models/category.dart';
import 'package:stock/models/product.dart';
import 'test_helper.dart';

void main() {
  group('Widget Tests', () {
    late FakeFirebaseFirestore fakeFirestore;
    late AuthService authService;
    late MockFirestoreService firestoreService;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      authService = MockAuthService();
      firestoreService = MockFirestoreService();
    });

    testWidgets('App should start without crashing', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthViewModel(authService, firestoreService)),
            ChangeNotifierProvider(create: (_) => CategoryViewModel(firestoreService, authService)),
            ChangeNotifierProvider(create: (_) => ProductViewModel(firestoreService, authService)),
            ChangeNotifierProvider(create: (_) => SaleViewModel(firestoreService, authService)),
            ChangeNotifierProvider(create: (_) => MovementViewModel(firestoreService, authService)),
            ChangeNotifierProvider(create: (_) => DashboardViewModel(firestoreService, authService)),
          ],
          child: const MyApp(),
        ),
      );

      // Verify that the app starts without errors
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Login screen should display correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthViewModel(authService, firestoreService)),
            ChangeNotifierProvider(create: (_) => CategoryViewModel(firestoreService, authService)),
            ChangeNotifierProvider(create: (_) => ProductViewModel(firestoreService, authService)),
            ChangeNotifierProvider(create: (_) => SaleViewModel(firestoreService, authService)),
            ChangeNotifierProvider(create: (_) => MovementViewModel(firestoreService, authService)),
            ChangeNotifierProvider(create: (_) => DashboardViewModel(firestoreService, authService)),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: Center(
                child: Text('Login Screen'),
              ),
            ),
          ),
        ),
      );

      // Verify that the login screen displays
      expect(find.text('Login Screen'), findsOneWidget);
    });

    testWidgets('Category management should work', (WidgetTester tester) async {
      final categoryViewModel = CategoryViewModel(firestoreService, authService);

      await tester.pumpWidget(
        ChangeNotifierProvider<CategoryViewModel>.value(
          value: categoryViewModel,
          child: MaterialApp(
            home: Scaffold(
              body: Consumer<CategoryViewModel>(
                builder: (context, model, child) {
                  return Column(
                    children: [
                      Text('Categories: ${model.categories.length}'),
                      ElevatedButton(
                        onPressed: () {
                          final category = Category(
                            id: '',
                            name: 'Test Category',
                            description: 'Test Description',
                            createdAt: DateTime.now(),
                            updatedAt: DateTime.now(),
                          );
                          model.addCategory(category);
                        },
                        child: const Text('Add Category'),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Verify initial state
      expect(find.text('Categories: 0'), findsOneWidget);
      expect(find.text('Add Category'), findsOneWidget);
    });

    testWidgets('Product management should work', (WidgetTester tester) async {
      final productViewModel = ProductViewModel(firestoreService, authService);

      await tester.pumpWidget(
        ChangeNotifierProvider<ProductViewModel>.value(
          value: productViewModel,
          child: MaterialApp(
            home: Scaffold(
              body: Consumer<ProductViewModel>(
                builder: (context, model, child) {
                  return Column(
                    children: [
                      Text('Products: ${model.products.length}'),
                      ElevatedButton(
                        onPressed: () {
                          final product = Product(
                            id: '',
                            name: 'Test Product',
                            description: 'Test Description',
                            price: 10.0,
                            stock: 5,
                            minStock: 2,
                            maxStock: 100,
                            categoryId: 'category1',
                            createdAt: DateTime.now(),
                            updatedAt: DateTime.now(),
                          );
                          model.addProduct(product);
                        },
                        child: const Text('Add Product'),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Verify initial state
      expect(find.text('Products: 0'), findsOneWidget);
      expect(find.text('Add Product'), findsOneWidget);
    });
  });
}
