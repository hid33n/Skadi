// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:stock/main.dart';
import 'package:stock/services/auth_service.dart';
import 'package:stock/services/firestore_service.dart';
import 'package:stock/viewmodels/auth_viewmodel.dart';
import 'package:stock/viewmodels/category_viewmodel.dart';
import 'package:stock/viewmodels/product_viewmodel.dart';
import 'package:stock/viewmodels/sale_viewmodel.dart';
import 'package:stock/viewmodels/movement_viewmodel.dart';
import 'package:stock/viewmodels/dashboard_viewmodel.dart';
import 'package:stock/screens/category_management_screen.dart';
import 'package:stock/screens/product_list_screen.dart';
import 'test_helper.dart';

void main() {
  late AuthService authService;
  late MockFirestoreService firestoreService;

  setUpAll(() async {
    await setupFirebaseForTesting();
    authService = AuthService();
    firestoreService = MockFirestoreService();
    firestoreService.addTestData();
  });

  testWidgets('Login screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthViewModel(authService)),
          ChangeNotifierProvider(create: (_) => CategoryViewModel(firestoreService)),
          ChangeNotifierProvider(create: (_) => ProductViewModel(firestoreService)),
          ChangeNotifierProvider(create: (_) => SaleViewModel(firestoreService)),
          ChangeNotifierProvider(create: (_) => MovementViewModel(firestoreService)),
          ChangeNotifierProvider(create: (_) => DashboardViewModel(firestoreService)),
        ],
        child: const MyApp(),
      ),
    );

    // Verify that the login screen is displayed
    expect(find.text('Iniciar Sesión'), findsOneWidget);
    expect(find.text('Registrarse'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2)); // Email y contraseña
  });

  testWidgets('Dashboard shows correct data', (WidgetTester tester) async {
    // Simular login exitoso
    final authViewModel = AuthViewModel(authService);
    await authViewModel.signIn('test@test.com', 'password');

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: authViewModel),
          ChangeNotifierProvider(create: (_) => CategoryViewModel(firestoreService)),
          ChangeNotifierProvider(create: (_) => ProductViewModel(firestoreService)),
          ChangeNotifierProvider(create: (_) => SaleViewModel(firestoreService)),
          ChangeNotifierProvider(create: (_) => MovementViewModel(firestoreService)),
          ChangeNotifierProvider(create: (_) => DashboardViewModel(firestoreService)),
        ],
        child: const MyApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Verificar que el dashboard muestra los datos correctamente
    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Smartphone'), findsOneWidget);
    expect(find.text('Camiseta'), findsOneWidget);
    expect(find.text('Electrónicos'), findsOneWidget);
    expect(find.text('Ropa'), findsOneWidget);
  });

  testWidgets('Category management works correctly', (WidgetTester tester) async {
    final categoryViewModel = CategoryViewModel(firestoreService);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChangeNotifierProvider.value(
            value: categoryViewModel,
            child: const CategoryManagementScreen(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verificar que las categorías existentes se muestran
    expect(find.text('Electrónicos'), findsOneWidget);
    expect(find.text('Ropa'), findsOneWidget);

    // Agregar una nueva categoría
    await tester.tap(find.text('Nueva Categoría'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'Nueva Categoría');
    await tester.enterText(find.byType(TextFormField).last, 'Descripción de prueba');
    await tester.tap(find.text('Agregar Categoría'));
    await tester.pumpAndSettle();

    // Verificar que la nueva categoría se agregó
    expect(find.text('Nueva Categoría'), findsOneWidget);
  });

  testWidgets('Product management works correctly', (WidgetTester tester) async {
    final productViewModel = ProductViewModel(firestoreService);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChangeNotifierProvider.value(
            value: productViewModel,
            child: const ProductListScreen(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verificar que los productos existentes se muestran
    expect(find.text('Smartphone'), findsOneWidget);
    expect(find.text('Camiseta'), findsOneWidget);

    // Verificar que los productos con bajo stock se muestran correctamente
    expect(find.text('Stock: 5 (Mín: 10)'), findsOneWidget);
  });
}
