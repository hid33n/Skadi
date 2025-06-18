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
import 'viewmodels/theme_viewmodel.dart';
import 'viewmodels/dashboard_viewmodel.dart';
import 'viewmodels/organization_viewmodel.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/organization_setup_screen.dart';
import 'screens/add_sale_screen.dart';
import 'screens/add_product_screen.dart';
import 'widgets/page_transition.dart';
import 'theme/app_theme.dart';

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
          create: (_) => ProductViewModel(),
        ),
        ChangeNotifierProvider<CategoryViewModel>(
          create: (_) => CategoryViewModel(),
        ),
        ChangeNotifierProvider<MovementViewModel>(
          create: (context) => MovementViewModel(context.read<FirestoreService>()),
        ),
        ChangeNotifierProvider<SaleViewModel>(
          create: (context) => SaleViewModel(context.read<FirestoreService>()),
        ),
        ChangeNotifierProvider<DashboardViewModel>(
          create: (context) => DashboardViewModel(context.read<FirestoreService>()),
        ),
        ChangeNotifierProvider<ThemeViewModel>(
          create: (_) => ThemeViewModel(),
        ),
        ChangeNotifierProvider<OrganizationViewModel>(
          create: (_) => OrganizationViewModel(),
        ),
        ChangeNotifierProvider<AuthViewModel>(
          create: (context) => AuthViewModel(context.read<AuthService>()),
        ),
      ],
      child: Consumer<ThemeViewModel>(
        builder: (context, themeViewModel, _) {
          return MaterialApp(
            title: 'Skadi',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeViewModel.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            initialRoute: '/login',
            onGenerateRoute: (settings) {
              Widget page;
              switch (settings.name) {
                case '/login':
                  page = const LoginScreen();
                  break;
                case '/register':
                  page = const RegisterScreen();
                  break;
                case '/home':
                  page = HomeScreen();
                  break;
                case '/add-sale':
                  page = const AddSaleScreen();
                  break;
                case '/add-product':
                  page = const AddProductScreen();
                  break;
                case '/organization-setup':
                  page = const OrganizationSetupScreen();
                  break;
                default:
                  page = const LoginScreen();
              }
              return PageTransition(
                page: page,
                settings: settings,
              );
            },
          );
        },
      ),
    );
  }
}
