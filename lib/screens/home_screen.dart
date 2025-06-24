import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../theme/responsive.dart';
import '../viewmodels/sync_viewmodel.dart';
import '../widgets/sync_status_widget.dart';
import 'dashboard_screen.dart';
import 'product_list_screen.dart';
import 'category_management_screen.dart';
import 'movement_history_screen.dart';
import 'sales_screen.dart';
import '../widgets/custom_snackbar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  final _authService = AuthService();
  String _username = '';
  bool _isDrawerOpen = false;
  bool _isHovering = false;
  late AnimationController _drawerAnimationController;
  late AnimationController _hoverAnimationController;
  late Animation<double> _drawerAnimation;
  late Animation<double> _hoverAnimation;

  // Menú items con iconos y colores personalizados
  final List<MenuItemData> _menuItems = [
    MenuItemData(
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard,
      label: 'Dashboard',
      color: Colors.yellow,
    ),
    MenuItemData(
      icon: Icons.inventory_2_outlined,
      selectedIcon: Icons.inventory_2,
      label: 'Productos',
      color: Colors.orange,
    ),
    MenuItemData(
      icon: Icons.category_outlined,
      selectedIcon: Icons.category,
      label: 'Categorías',
      color: Colors.amber,
    ),
    MenuItemData(
      icon: Icons.history_outlined,
      selectedIcon: Icons.history,
      label: 'Movimientos',
      color: Colors.yellow.shade700,
    ),
    MenuItemData(
      icon: Icons.shopping_cart_outlined,
      selectedIcon: Icons.shopping_cart,
      label: 'Ventas',
      color: Colors.orange.shade700,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    
    _drawerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _hoverAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _drawerAnimation = CurvedAnimation(
      parent: _drawerAnimationController,
      curve: Curves.easeInOut,
    );
    _hoverAnimation = CurvedAnimation(
      parent: _hoverAnimationController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _drawerAnimationController.dispose();
    _hoverAnimationController.dispose();
    super.dispose();
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
      // Error loading user profile
    }
  }

  Future<void> _signOut() async {
    try {
      await _authService.signOut();
      if (mounted) {
        CustomSnackBar.showInfo(
          context: context,
          message: 'Sesión cerrada exitosamente',
        );
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      CustomSnackBar.showError(
        context: context,
        message: 'Error al cerrar sesión: ${e.toString()}',
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (Responsive.isMobile(context)) {
        _isDrawerOpen = false;
        _drawerAnimationController.reverse();
      }
    });
  }

  void navigateToIndex(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _handleSettingsMenu(BuildContext context, String value) {
    switch (value) {
      case 'migration':
        Navigator.pushNamed(context, '/migration');
        break;
      case 'force_sync':
        _forceSync(context);
        break;
      case 'app_info':
        _showAppInfo(context);
        break;
    }
  }

  void _forceSync(BuildContext context) async {
    final syncViewModel = context.read<SyncViewModel>();
    
    try {
      await syncViewModel.forceSync();
      if (context.mounted) {
        CustomSnackBar.showInfo(
          context: context,
          message: 'Sincronización completada',
        );
      }
    } catch (e) {
      if (context.mounted) {
        CustomSnackBar.showError(
          context: context,
          message: 'Error en sincronización: $e',
        );
      }
    }
  }

  void _showAppInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Stockcito - Planeta Motos'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Versión: 1.0.0'),
            const SizedBox(height: 8),
            const Text('Sistema de Gestión de Inventario'),
            const SizedBox(height: 16),
            const Text(
              'Funcionalidades:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('• Funcionamiento offline con Hive'),
            const Text('• Sincronización automática'),
            const Text('• Múltiples dispositivos'),
            const Text('• APIs gratuitas'),
            const Text('• Gestión de productos'),
            const Text('• Control de stock'),
            const Text('• Reportes y análisis'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final theme = Theme.of(context);
    final isMobile = Responsive.isMobile(context);
    
    return AppBar(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      centerTitle: true,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/logo.png',
            height: 48,
          ),
          const SizedBox(width: 12),
          Text(
            'Planeta Motos',
            style: GoogleFonts.bebasNeue(
              fontSize: 28,
              color: Colors.yellow,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
      actions: [
        // Widget de sincronización
        Consumer<SyncViewModel>(
          builder: (context, syncViewModel, child) {
            return SyncStatusWidget(
              showDetails: false,
              onTap: () {
                // Mostrar detalles de sincronización
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Estado de Sincronización'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Estado: ${syncViewModel.getSyncStatusText()}'),
                        const SizedBox(height: 8),
                        if (syncViewModel.pendingChangesCount > 0)
                          Text('Pendientes: ${syncViewModel.pendingChangesCount} cambios'),
                        const SizedBox(height: 8),
                        Text('Recomendación: ${syncViewModel.getSyncRecommendations()}'),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cerrar'),
                      ),
                      if (syncViewModel.pendingChangesCount > 0)
                        ElevatedButton(
                          onPressed: () {
                            syncViewModel.forceSync();
                            Navigator.pop(context);
                          },
                          child: const Text('Sincronizar'),
                        ),
                    ],
                  ),
                );
              },
            );
          },
        ),
        
        // Menú de configuración
        PopupMenuButton<String>(
          icon: const Icon(Icons.settings, color: Colors.white),
          onSelected: (value) => _handleSettingsMenu(context, value),
          itemBuilder: (context) => [
            PopupMenuItem<String>(
              value: 'migration',
              child: Row(
                children: [
                  const Icon(Icons.swap_horiz),
                  const SizedBox(width: 8),
                  const Text('Migración de Datos'),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'force_sync',
              child: Row(
                children: [
                  const Icon(Icons.sync_alt),
                  const SizedBox(width: 8),
                  const Text('Sincronizar Ahora'),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'app_info',
              child: Row(
                children: [
                  const Icon(Icons.info),
                  const SizedBox(width: 8),
                  const Text('Información de la App'),
                ],
              ),
            ),
          ],
        ),
        if (isMobile)
          IconButton(
            icon: Icon(
              _isDrawerOpen ? Icons.close : Icons.menu,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _isDrawerOpen = !_isDrawerOpen;
                if (_isDrawerOpen) {
                  _drawerAnimationController.forward();
                } else {
                  _drawerAnimationController.reverse();
                }
              });
            },
          ),
      ],
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Colors.black,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header del sidebar con diseño mejorado
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border(
                bottom: BorderSide(color: Colors.yellow.withOpacity(0.3), width: 2),
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.yellow.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.yellow.withOpacity(0.3), width: 1),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.yellow.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.person,
                          color: Colors.yellow,
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _username,
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.yellow, Colors.orange],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Usuario Conectado',
                    style: GoogleFonts.inter(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Menú items con nuevo diseño
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: _menuItems.length,
              itemBuilder: (context, index) {
                final item = _menuItems[index];
                final isSelected = _selectedIndex == index;
                
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _onItemTapped(index),
                      borderRadius: BorderRadius.circular(16),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          color: isSelected ? item.color.withOpacity(0.2) : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          border: isSelected 
                            ? Border.all(color: item.color, width: 2)
                            : Border.all(color: Colors.grey.shade700, width: 1),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isSelected ? item.color : Colors.grey.shade700,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                isSelected ? item.selectedIcon : item.icon,
                                color: isSelected ? Colors.black : Colors.grey.shade300,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                item.label,
                                style: GoogleFonts.inter(
                                  color: isSelected ? item.color : Colors.grey.shade300,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            if (isSelected)
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: item.color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Footer del sidebar con botón de logout
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border(
                top: BorderSide(color: Colors.yellow.withOpacity(0.3), width: 1),
              ),
            ),
            child: Column(
              children: [
                // Información de versión
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade800.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.yellow,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Alpha v1.0.0',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Créditos del desarrollador
                Column(
                  children: [
                    Text(
                      'Desarrollado por',
                      style: GoogleFonts.inter(
                        color: Colors.grey.shade400,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Hid33nStudios',
                      style: GoogleFonts.inter(
                        color: Colors.yellow,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'para Planeta Motos',
                      style: GoogleFonts.inter(
                        color: Colors.grey.shade300,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Botón de logout
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _signOut,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.red.shade600, Colors.red.shade700],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.logout,
                            color: Colors.white,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Cerrar Sesión',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactSidebar() {
    return MouseRegion(
      onEnter: (_) {
        if (!Responsive.isMobile(context)) {
          setState(() => _isHovering = true);
          _hoverAnimationController.forward();
        }
      },
      onExit: (_) {
        if (!Responsive.isMobile(context)) {
          setState(() => _isHovering = false);
          _hoverAnimationController.reverse();
        }
      },
      child: AnimatedBuilder(
        animation: _hoverAnimation,
        builder: (context, child) {
          final width = _isHovering ? 200.0 : 70.0;
          
          return Container(
            width: width,
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border(
                right: BorderSide(color: Colors.yellow.withOpacity(0.3), width: 1),
              ),
            ),
            child: Column(
              children: [
                // Header compacto
                Container(
                  height: 70,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    border: Border(
                      bottom: BorderSide(color: Colors.yellow.withOpacity(0.3), width: 1),
                    ),
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: _isHovering
                      ? Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.yellow.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.person,
                                color: Colors.yellow,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _username,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        )
                      : Center(
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.yellow.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.person,
                              color: Colors.yellow,
                              size: 20,
                            ),
                          ),
                        ),
                  ),
                ),
                
                // Menú items compactos
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemCount: _menuItems.length,
                    itemBuilder: (context, index) {
                      final item = _menuItems[index];
                      final isSelected = _selectedIndex == index;
                      
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _onItemTapped(index),
                            borderRadius: BorderRadius.circular(8),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: EdgeInsets.symmetric(
                                horizontal: _isHovering ? 16 : 12,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected ? item.color.withOpacity(0.2) : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: isSelected 
                                  ? Border.all(color: item.color, width: 1)
                                  : null,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isSelected ? item.selectedIcon : item.icon,
                                    color: isSelected ? item.color : Colors.grey.shade400,
                                    size: 20,
                                  ),
                                  if (_isHovering) ...[
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        item.label,
                                        style: GoogleFonts.inter(
                                          color: isSelected ? item.color : Colors.grey.shade300,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                          fontSize: 14,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                // Footer compacto con botón de logout
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isHovering)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
                        child: Column(
                          children: [
                            Text(
                              'Alpha v1.0.0',
                              style: GoogleFonts.inter(
                                color: Colors.grey.shade400,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Desarrollado por',
                              style: GoogleFonts.inter(
                                color: Colors.grey.shade500,
                                fontSize: 10,
                              ),
                            ),
                            Text(
                              'Hid33nStudios',
                              style: GoogleFonts.inter(
                                color: Colors.yellow,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'para Planeta Motos',
                              style: GoogleFonts.inter(
                                color: Colors.grey.shade500,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    SizedBox(
                      height: 70,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _signOut,
                          borderRadius: BorderRadius.circular(8),
                          child: Center(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.all(12),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: _isHovering ? Colors.red.shade600 : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.red.shade600,
                                  width: 1.5,
                                ),
                              ),
                              child: _isHovering
                                  ? Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.logout,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Salir',
                                            style: GoogleFonts.inter(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    )
                                  : Icon(
                                      Icons.logout,
                                      color: Colors.red.shade600,
                                      size: 24,
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMobileDrawer() {
    return AnimatedBuilder(
      animation: _drawerAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            _isDrawerOpen ? 0 : -280,
            0,
          ),
          child: Container(
            width: 280,
            height: double.infinity,
            child: _buildSidebar(),
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    return IndexedStack(
      index: _selectedIndex,
      children: [
        const DashboardScreen(showAppBar: false),
        const ProductListScreen(),
        const CategoryManagementScreen(),
        const MovementHistoryScreen(),
        const SalesScreen(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    
    if (isMobile) {
      return Scaffold(
        appBar: _buildAppBar(),
        body: Stack(
          children: [
            _buildContent(),
            if (_isDrawerOpen)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isDrawerOpen = false;
                      _drawerAnimationController.reverse();
                    });
                  },
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                  ),
                ),
              ),
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: _buildMobileDrawer(),
            ),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black,
                Colors.grey.shade900,
              ],
            ),
            border: Border(
              top: BorderSide(color: Colors.yellow.withOpacity(0.3), width: 1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: NavigationBar(
            backgroundColor: Colors.transparent,
            indicatorColor: Colors.yellow.withOpacity(0.2),
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onItemTapped,
            labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
            height: 70,
            elevation: 0,
            destinations: _menuItems.map((item) {
              final isSelected = _selectedIndex == _menuItems.indexOf(item);
              return NavigationDestination(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected ? item.color.withOpacity(0.2) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    item.icon,
                    color: isSelected ? item.color : Colors.grey.shade400,
                    size: 24,
                  ),
                ),
                selectedIcon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: item.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: item.color, width: 1),
                  ),
                  child: Icon(
                    item.selectedIcon,
                    color: item.color,
                    size: 24,
                  ),
                ),
                label: item.label,
              );
            }).toList(),
          ),
        ),
      );
    } else {
      return Scaffold(
        appBar: _buildAppBar(),
        body: Row(
          children: [
            _buildCompactSidebar(),
            const VerticalDivider(thickness: 1, width: 1, color: Colors.grey),
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      );
    }
  }
}

class MenuItemData {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final Color color;

  MenuItemData({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.color,
  });
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