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
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/sync_viewmodel.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/add_sale_screen.dart';
import 'screens/add_product_screen.dart';
import 'theme/app_theme.dart';
import 'theme/theme_provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
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
        Provider<FirestoreService>(
          create: (context) => FirestoreService(context.read<AuthService>()),
        ),
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(),
        ),
        // ViewModels
        ChangeNotifierProxyProvider<FirestoreService, ProductViewModel>(
          create: (context) => ProductViewModel(
            context.read<FirestoreService>(),
            context.read<AuthService>(),
          ),
          update: (context, firestoreService, previous) => ProductViewModel(
            firestoreService,
            context.read<AuthService>(),
          ),
        ),
        ChangeNotifierProxyProvider<FirestoreService, CategoryViewModel>(
          create: (context) => CategoryViewModel(
            context.read<FirestoreService>(),
            context.read<AuthService>(),
          ),
          update: (context, firestoreService, previous) => CategoryViewModel(
            firestoreService,
            context.read<AuthService>(),
          ),
        ),
        ChangeNotifierProxyProvider<FirestoreService, MovementViewModel>(
          create: (context) => MovementViewModel(
            context.read<FirestoreService>(),
            context.read<AuthService>(),
          ),
          update: (context, firestoreService, previous) => MovementViewModel(
            firestoreService,
            context.read<AuthService>(),
          ),
        ),
        ChangeNotifierProxyProvider<FirestoreService, SaleViewModel>(
          create: (context) => SaleViewModel(
            context.read<FirestoreService>(),
            context.read<AuthService>(),
          ),
          update: (context, firestoreService, previous) => SaleViewModel(
            firestoreService,
            context.read<AuthService>(),
          ),
        ),
        ChangeNotifierProxyProvider<FirestoreService, DashboardViewModel>(
          create: (context) => DashboardViewModel(
            context.read<FirestoreService>(),
            context.read<AuthService>(),
          ),
          update: (context, firestoreService, previous) => DashboardViewModel(
            firestoreService,
            context.read<AuthService>(),
          ),
        ),
        ChangeNotifierProxyProvider<ThemeProvider, ThemeViewModel>(
          create: (context) => ThemeViewModel(
            context.read<ThemeProvider>(),
          ),
          update: (context, themeProvider, previous) => ThemeViewModel(
            themeProvider,
          ),
        ),
        ChangeNotifierProxyProvider<FirestoreService, SyncViewModel>(
          create: (context) => SyncViewModel(
            context.read<FirestoreService>(),
            context.read<AuthService>(),
          ),
          update: (context, firestoreService, previous) => SyncViewModel(
            firestoreService,
            context.read<AuthService>(),
          ),
        ),
        ChangeNotifierProxyProvider<AuthService, AuthViewModel>(
          create: (context) => AuthViewModel(
            context.read<AuthService>(),
            context.read<FirestoreService>(),
          ),
          update: (context, authService, previous) => AuthViewModel(
            authService,
            context.read<FirestoreService>(),
          ),
        ),
      ],
      child: Consumer<ThemeViewModel>(
        builder: (context, themeViewModel, _) {
          return MaterialApp(
            title: 'PM-Skadi',
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
                default:
                  page = const LoginScreen();
              }
              return MaterialPageRoute(
                builder: (context) => page,
                settings: settings,
              );
            },
          );
        },
      ),
    );
  }
}
