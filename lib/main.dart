import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'services/hive_database_service.dart';
import 'services/hybrid_data_service.dart';
import 'services/sync_service.dart';
import 'services/migration_service.dart';
import 'services/barcode_scanner_service.dart';
import 'viewmodels/product_viewmodel.dart';
import 'viewmodels/category_viewmodel.dart';
import 'viewmodels/movement_viewmodel.dart';
import 'viewmodels/sale_viewmodel.dart';
import 'viewmodels/theme_viewmodel.dart';
import 'viewmodels/dashboard_viewmodel.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/sync_viewmodel.dart';
import 'viewmodels/migration_viewmodel.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/add_sale_screen.dart';
import 'screens/add_product_screen.dart';
import 'screens/migration_screen.dart';
import 'screens/barcode_scanner_screen.dart';
import 'theme/app_theme.dart';
import 'theme/theme_provider.dart';
import 'widgets/app_initializer.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

void main() async {
  // Asegurar que las inicializaciones estén en la misma zona
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Inicializar Hive
  await Hive.initFlutter();
  
  // Inicializar Sentry en la misma zona
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
  );
  
  // Ejecutar la aplicación
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Servicios base
        Provider<AuthService>(
          create: (_) => AuthService(),
        ),
        Provider<FirestoreService>(
          create: (context) => FirestoreService(context.read<AuthService>()),
        ),
        
        // Servicio de base de datos local con Hive
        Provider<HiveDatabaseService>(
          create: (_) => HiveDatabaseService(),
        ),
        
        // Servicios híbridos
        Provider<HybridDataService>(
          create: (context) => HybridDataService(
            firestoreService: context.read<FirestoreService>(),
            localDatabase: context.read<HiveDatabaseService>(),
            auth: FirebaseAuth.instance,
          ),
        ),
        Provider<SyncService>(
          create: (context) => SyncService(
            FirebaseFirestore.instance,
            FirebaseAuth.instance,
            context.read<HybridDataService>(),
          ),
        ),
        Provider<MigrationService>(
          create: (context) => MigrationService(
            FirebaseFirestore.instance,
            FirebaseAuth.instance,
            context.read<HybridDataService>(),
          ),
        ),
        
        // Servicio de escaneo de códigos de barras
        Provider<BarcodeScannerService>(
          create: (_) => BarcodeScannerService(),
        ),
        
        // Theme Provider
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(),
        ),
        
        // ViewModels con servicios híbridos
        ChangeNotifierProxyProvider<HybridDataService, ProductViewModel>(
          create: (context) => ProductViewModel(
            context.read<HybridDataService>(),
            context.read<AuthService>(),
          ),
          update: (context, hybridService, previous) => ProductViewModel(
            hybridService,
            context.read<AuthService>(),
          ),
        ),
        ChangeNotifierProxyProvider<HybridDataService, CategoryViewModel>(
          create: (context) => CategoryViewModel(
            context.read<HybridDataService>(),
            context.read<AuthService>(),
          ),
          update: (context, hybridService, previous) => CategoryViewModel(
            hybridService,
            context.read<AuthService>(),
          ),
        ),
        ChangeNotifierProxyProvider<HybridDataService, MovementViewModel>(
          create: (context) => MovementViewModel(
            context.read<HybridDataService>(),
            context.read<AuthService>(),
          ),
          update: (context, hybridService, previous) => MovementViewModel(
            hybridService,
            context.read<AuthService>(),
          ),
        ),
        ChangeNotifierProxyProvider<HybridDataService, SaleViewModel>(
          create: (context) => SaleViewModel(
            context.read<HybridDataService>(),
            context.read<AuthService>(),
          ),
          update: (context, hybridService, previous) => SaleViewModel(
            hybridService,
            context.read<AuthService>(),
          ),
        ),
        ChangeNotifierProxyProvider<HybridDataService, DashboardViewModel>(
          create: (context) => DashboardViewModel(
            context.read<HybridDataService>(),
            context.read<AuthService>(),
          ),
          update: (context, hybridService, previous) => DashboardViewModel(
            hybridService,
            context.read<AuthService>(),
          ),
        ),
        
        // ViewModels de sincronización
        ChangeNotifierProxyProvider2<SyncService, HybridDataService, SyncViewModel>(
          create: (context) => SyncViewModel(
            context.read<SyncService>(),
            context.read<HybridDataService>(),
          ),
          update: (context, syncService, hybridService, previous) => SyncViewModel(
            syncService,
            hybridService,
          ),
        ),
        ChangeNotifierProxyProvider<MigrationService, MigrationViewModel>(
          create: (context) => MigrationViewModel(
            context.read<MigrationService>(),
            context.read<HybridDataService>(),
          ),
          update: (context, migrationService, previous) => MigrationViewModel(
            migrationService,
            context.read<HybridDataService>(),
          ),
        ),
        
        // ViewModels de tema y autenticación
        ChangeNotifierProxyProvider<ThemeProvider, ThemeViewModel>(
          create: (context) => ThemeViewModel(
            context.read<ThemeProvider>(),
          ),
          update: (context, themeProvider, previous) => ThemeViewModel(
            themeProvider,
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
      child: AppInitializer(
        child: Consumer<ThemeViewModel>(
          builder: (context, themeViewModel, _) {
            return MaterialApp(
              title: 'Stockcito - Planeta Motos',
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
                  case '/migration':
                    page = const MigrationScreen();
                    break;
                  case '/barcode-scanner':
                    page = const BarcodeScannerScreen();
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
      ),
    );
  }
}
