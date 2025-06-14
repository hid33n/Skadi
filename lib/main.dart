import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'viewmodels/product_viewmodel.dart';
import 'viewmodels/category_viewmodel.dart';
import 'viewmodels/movement_viewmodel.dart';
import 'viewmodels/sale_viewmodel.dart';
import 'screens/dashboard_screen.dart';
import 'screens/product_list_screen.dart';
import 'screens/category_management_screen.dart';
import 'screens/movement_history_screen.dart';
import 'screens/sales_screen.dart';
import 'widgets/adaptive_navigation.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Servicios
        Provider<AuthService>(
          create: (_) => AuthService(),
        ),
        Provider<FirestoreService>(
          create: (context) => FirestoreService(context.read<AuthService>()),
        ),
        // ViewModels
        ChangeNotifierProvider<ProductViewModel>(
          create: (context) => ProductViewModel(context.read<FirestoreService>()),
        ),
        ChangeNotifierProvider<CategoryViewModel>(
          create: (context) => CategoryViewModel(context.read<FirestoreService>()),
        ),
        ChangeNotifierProvider<MovementViewModel>(
          create: (context) => MovementViewModel(context.read<FirestoreService>()),
        ),
        ChangeNotifierProvider<SaleViewModel>(
          create: (context) => SaleViewModel(context.read<FirestoreService>()),
        ),
      ],
      child: MaterialApp(
        title: 'Skadi',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => HomeScreen(),
        },
      ),
    );
  }
}
