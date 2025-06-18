import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/dashboard_viewmodel.dart';
import '../widgets/dashboard/dashboard_grid.dart';
import '../widgets/sync_status_widget.dart';
import '../theme/responsive.dart';
import '../services/auth_service.dart';
import '../services/sync_service.dart';
import '../utils/error_handler.dart';
import '../viewmodels/organization_viewmodel.dart';

class DashboardScreen extends StatefulWidget {
  final bool showAppBar;
  
  const DashboardScreen({
    super.key,
    this.showAppBar = true,
  });

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _authService = AuthService();
  final _syncService = SyncService();

  @override
  void initState() {
    super.initState();
    _initializeSyncService();
    _loadDashboardData();
  }

  Future<void> _initializeSyncService() async {
    try {
      await _syncService.initialize();
    } catch (e) {
      if (mounted) {
        context.showError('Error al inicializar sincronización: $e');
      }
    }
  }

  Future<void> _loadDashboardData() async {
    final dashboardViewModel = context.read<DashboardViewModel>();
    await dashboardViewModel.loadDashboardData();
  }

  Future<void> _signOut() async {
    try {
      await _authService.signOut();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      if (mounted) {
        context.showError(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final organizationVM = context.watch<OrganizationViewModel>();
    if (organizationVM.currentUser == null || organizationVM.currentOrganization == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final body = RefreshIndicator(
      onRefresh: () => context.read<DashboardViewModel>().loadDashboardData(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: widget.showAppBar ? Responsive.getResponsivePadding(context) : EdgeInsets.zero,
        child: Column(
          children: [
            // Widget de estado offline
            SyncOfflineIndicator(syncService: _syncService),
            
            // Widget de progreso de sincronización
            SyncProgressWidget(syncService: _syncService),
            
            Consumer<DashboardViewModel>(
              builder: (context, viewModel, _) {
                if (viewModel.isLoading) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (viewModel.error != null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            viewModel.error!,
                            style: const TextStyle(fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => viewModel.loadDashboardData(),
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return const DashboardGrid();
              },
            ),
          ],
        ),
      ),
    );

    return widget.showAppBar
        ? Scaffold(
            appBar: AppBar(
              title: const Text('Dashboard'),
              actions: [
                // Widget de estado de sincronización en el AppBar
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: SyncStatusWidget(syncService: _syncService),
                ),
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: _signOut,
                  tooltip: 'Cerrar sesión',
                ),
              ],
            ),
            body: body,
          )
        : body;
  }
} 