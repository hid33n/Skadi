import 'package:flutter/material.dart';
import '../widgets/adaptive_navigation.dart';
import '../widgets/responsive_layout.dart';
import '../services/auth_service.dart';
import '../theme/responsive.dart';
import 'dashboard_screen.dart';
import 'product_list_screen.dart';
import 'category_management_screen.dart';
import 'movement_history_screen.dart';
import 'sales_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
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

  final List<Widget> _screens = [
    DashboardScreen(),
    ProductListScreen(),
    CategoryManagementScreen(),
    MovementHistoryScreen(),
    SalesScreen(),
  ];

  Widget _buildMobileLayout() {
    return Scaffold(
      appBar: AppBar(
        title: Text('Skadi'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory),
            label: 'Productos',
          ),
          NavigationDestination(
            icon: Icon(Icons.category),
            label: 'Categorías',
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            label: 'Movimientos',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart),
            label: 'Ventas',
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Scaffold(
      body: Row(
        children: [
          AdaptiveNavigation(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
          Expanded(
            child: _screens[_selectedIndex],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _buildMobileLayout(),
      desktop: _buildDesktopLayout(),
    );
  }
} 