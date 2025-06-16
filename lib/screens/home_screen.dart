import 'package:flutter/material.dart';
import '../widgets/adaptive_navigation.dart';
import '../widgets/mobile_navigation.dart';
import '../widgets/responsive_layout.dart';
import '../services/auth_service.dart';
import '../theme/responsive.dart';
import 'dashboard_screen.dart';
import 'product_list_screen.dart';
import 'category_management_screen.dart';
import 'movement_history_screen.dart';
import 'sales_screen.dart';
import 'add_sale_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final _authService = AuthService();
  String _username = '';

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final userProfile = await _authService.getUserProfile();
      if (mounted) {
        setState(() {
          _username = userProfile.get('username') ?? '';
        });
      }
    } catch (e) {
      print('Error loading user profile: $e');
    }
  }

  Future<void> _signOut() async {
    try {
      await _authService.signOut();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cerrar sesión: ${e.toString()}')),
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void navigateToIndex(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isTablet = MediaQuery.of(context).size.width >= 600 && MediaQuery.of(context).size.width < 1200;

    if (isMobile) {
      return _buildMobileLayout();
    } else if (isTablet) {
      return _buildTabletLayout();
    } else {
      return _buildDesktopLayout();
    }
  }

  Widget _buildMobileLayout() {
    return HomeScreenProvider(
      navigateToIndex: navigateToIndex,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_getTitle(_selectedIndex)),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _signOut,
            ),
          ],
        ),
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            const DashboardScreen(),
            const ProductListScreen(),
            const CategoryManagementScreen(),
            const MovementHistoryScreen(),
            const SalesScreen(),
          ],
        ),
        bottomNavigationBar: MobileNavigation(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onItemTapped,
        ),
      ),
    );
  }

  Widget _buildTabletLayout() {
    return HomeScreenProvider(
      navigateToIndex: navigateToIndex,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_getTitle(_selectedIndex)),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _signOut,
            ),
          ],
        ),
        body: Row(
          children: [
            NavigationRail(
              extended: true,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.dashboard),
                  label: Text('Dashboard'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.inventory),
                  label: Text('Productos'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.category),
                  label: Text('Categorías'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.history),
                  label: Text('Movimientos'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.shopping_cart),
                  label: Text('Ventas'),
                ),
              ],
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onItemTapped,
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: [
                  const DashboardScreen(),
                  const ProductListScreen(),
                  const CategoryManagementScreen(),
                  const MovementHistoryScreen(),
                  const SalesScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return HomeScreenProvider(
      navigateToIndex: navigateToIndex,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_getTitle(_selectedIndex)),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _signOut,
            ),
          ],
        ),
        body: Row(
          children: [
            NavigationRail(
              extended: true,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.dashboard),
                  label: Text('Dashboard'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.inventory),
                  label: Text('Productos'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.category),
                  label: Text('Categorías'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.history),
                  label: Text('Movimientos'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.shopping_cart),
                  label: Text('Ventas'),
                ),
              ],
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onItemTapped,
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: [
                  const DashboardScreen(),
                  const ProductListScreen(),
                  const CategoryManagementScreen(),
                  const MovementHistoryScreen(),
                  const SalesScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTitle(int index) {
    switch (index) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Productos';
      case 2:
        return 'Categorías';
      case 3:
        return 'Movimientos';
      case 4:
        return 'Ventas';
      default:
        return 'Dashboard';
    }
  }
}

class HomeScreenProvider extends InheritedWidget {
  final Function(int) navigateToIndex;

  const HomeScreenProvider({
    Key? key,
    required this.navigateToIndex,
    required Widget child,
  }) : super(key: key, child: child);

  static HomeScreenProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<HomeScreenProvider>();
  }

  @override
  bool updateShouldNotify(HomeScreenProvider oldWidget) {
    return navigateToIndex != oldWidget.navigateToIndex;
  }
} 