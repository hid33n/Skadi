import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'services/user_data_service.dart';
import 'services/sync_service.dart';
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
import 'package:sentry_flutter/sentry_flutter.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Inicializar servicios de sincronización
  try {
    final syncService = SyncService();
    await syncService.initialize();
  } catch (e) {
    debugPrint('Error al inicializar sincronización: $e');
  }
  
  await SentryFlutter.init(
    (options) {
      options.dsn = 'https://7809e26486e6ab2d891da853864a2047@o4509520741335040.ingest.us.sentry.io/4509520742776832';
      // Set tracesSampleRate to 1.0 to capture 100% of transactions for tracing.
      // We recommend adjusting this value in production.
      options.tracesSampleRate = 1.0;
      // The sampling rate for profiling is relative to tracesSampleRate
      // Setting to 1.0 will profile 100% of sampled transactions:
      options.profilesSampleRate = 1.0;
    },
    appRunner: () => runApp(SentryWidget(child: const MyApp())),
  );
  // TODO: Remove this line after sending the first sample event to sentry.
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
        Provider<UserDataService>(
          create: (_) => UserDataService(),
        ),
        Provider<SyncService>(
          create: (_) => SyncService(),
        ),
        // ViewModels
        ChangeNotifierProvider<ProductViewModel>(
          create: (_) => ProductViewModel(),
        ),
        ChangeNotifierProvider<CategoryViewModel>(
          create: (_) => CategoryViewModel(),
        ),
        ChangeNotifierProvider<MovementViewModel>(
          create: (_) => MovementViewModel(),
        ),
        ChangeNotifierProvider<SaleViewModel>(
          create: (_) => SaleViewModel(),
        ),
        ChangeNotifierProvider<DashboardViewModel>(
          create: (_) => DashboardViewModel(),
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
