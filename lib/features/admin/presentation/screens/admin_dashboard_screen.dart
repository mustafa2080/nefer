import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/providers/providers.dart';
import '../../../../generated/l10n.dart';
import '../widgets/admin_sidebar.dart';
import '../widgets/admin_stats_cards.dart';
import '../widgets/admin_recent_orders.dart';
import '../widgets/admin_analytics_chart.dart';
import '../widgets/admin_quick_actions.dart';
import '../controllers/admin_dashboard_controller.dart';

/// Admin Dashboard Screen - Main control center for administrators
/// 
/// Features:
/// - Real-time analytics and statistics
/// - Quick actions for common tasks
/// - Recent orders and activities
/// - Navigation to different admin sections
/// - Role-based access control
class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkAdminAccess();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  void _checkAdminAccess() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = ref.read(authStateProvider);
      authState.maybeWhen(
        authenticated: (user) {
          if (!user.canAccessAdminDashboard()) {
            _showAccessDeniedDialog();
          }
        },
        orElse: () => context.go('/login'),
      );
    });
  }

  void _showAccessDeniedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Access Denied'),
        content: const Text('You do not have permission to access the admin dashboard.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/');
            },
            child: const Text('Go to Home'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dashboardState = ref.watch(adminDashboardControllerProvider);
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Row(
        children: [
          // Sidebar
          const AdminSidebar(),
          
          // Main Content
          Expanded(
            child: AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: _buildMainContent(context, l10n, dashboardState, currentUser),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(
    BuildContext context,
    AppLocalizations? l10n,
    AdminDashboardState dashboardState,
    User? currentUser,
  ) {
    return CustomScrollView(
      slivers: [
        // App Bar
        SliverAppBar(
          expandedHeight: 120,
          floating: false,
          pinned: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                gradient: NeferColors.pharaohGradient,
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Admin Dashboard',
                        style: NeferTypography.pharaohTitle.copyWith(
                          color: Colors.white,
                          fontSize: 28,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Welcome back, ${currentUser?.fullName ?? 'Administrator'}',
                        style: NeferTypography.bodyLarge.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          actions: [
            // Notifications
            IconButton(
              onPressed: () => _showNotifications(context),
              icon: Stack(
                children: [
                  const Icon(Icons.notifications_outlined, color: Colors.white),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: NeferColors.error,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                      child: const Text(
                        '3',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // User Menu
            PopupMenuButton<String>(
              onSelected: (value) => _handleUserMenuAction(context, value),
              icon: CircleAvatar(
                backgroundImage: currentUser?.photoURL != null
                    ? NetworkImage(currentUser!.photoURL!)
                    : null,
                backgroundColor: NeferColors.sandstoneBeige,
                child: currentUser?.photoURL == null
                    ? Text(
                        currentUser?.initials ?? 'A',
                        style: const TextStyle(
                          color: NeferColors.hieroglyphGray,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'profile',
                  child: ListTile(
                    leading: Icon(Icons.person),
                    title: Text('Profile'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'settings',
                  child: ListTile(
                    leading: Icon(Icons.settings),
                    title: Text('Settings'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'logout',
                  child: ListTile(
                    leading: Icon(Icons.logout, color: NeferColors.error),
                    title: Text('Logout', style: TextStyle(color: NeferColors.error)),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
          ],
        ),

        // Dashboard Content
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Stats Cards
              dashboardState.when(
                loading: () => const AdminStatsCardsLoading(),
                error: (error, _) => AdminStatsCardsError(error: error.toString()),
                data: (data) => AdminStatsCards(stats: data.stats),
              ),
              
              const SizedBox(height: 24),
              
              // Quick Actions
              const AdminQuickActions(),
              
              const SizedBox(height: 24),
              
              // Analytics and Recent Orders Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Analytics Chart
                  Expanded(
                    flex: 2,
                    child: dashboardState.when(
                      loading: () => const AdminAnalyticsChartLoading(),
                      error: (error, _) => AdminAnalyticsChartError(error: error.toString()),
                      data: (data) => AdminAnalyticsChart(analytics: data.analytics),
                    ),
                  ),
                  
                  const SizedBox(width: 24),
                  
                  // Recent Orders
                  Expanded(
                    flex: 1,
                    child: dashboardState.when(
                      loading: () => const AdminRecentOrdersLoading(),
                      error: (error, _) => AdminRecentOrdersError(error: error.toString()),
                      data: (data) => AdminRecentOrders(orders: data.recentOrders),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Recent Activities
              _buildRecentActivities(context, dashboardState),
              
              const SizedBox(height: 40),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivities(BuildContext context, AdminDashboardState dashboardState) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Activities',
                  style: NeferTypography.sectionHeader,
                ),
                TextButton(
                  onPressed: () => context.go('/admin/activities'),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            dashboardState.when(
              loading: () => const CircularProgressIndicator(),
              error: (error, _) => Text('Error: $error'),
              data: (data) => ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: data.recentActivities.length.clamp(0, 5),
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final activity = data.recentActivities[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getActivityColor(activity.type),
                      child: Icon(
                        _getActivityIcon(activity.type),
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    title: Text(activity.title),
                    subtitle: Text(activity.description),
                    trailing: Text(
                      _formatTime(activity.timestamp),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getActivityColor(String type) {
    switch (type) {
      case 'order':
        return NeferColors.success;
      case 'user':
        return NeferColors.info;
      case 'product':
        return NeferColors.pharaohGold;
      case 'system':
        return NeferColors.warning;
      default:
        return NeferColors.hieroglyphGray;
    }
  }

  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'order':
        return Icons.shopping_cart;
      case 'user':
        return Icons.person;
      case 'product':
        return Icons.inventory;
      case 'system':
        return Icons.settings;
      default:
        return Icons.info;
    }
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  void _showNotifications(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notifications'),
        content: const SizedBox(
          width: 300,
          height: 200,
          child: Center(
            child: Text('No new notifications'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _handleUserMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'profile':
        context.go('/admin/profile');
        break;
      case 'settings':
        context.go('/admin/settings');
        break;
      case 'logout':
        _showLogoutDialog(context);
        break;
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(authStateProvider.notifier).signOut();
              context.go('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: NeferColors.error,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
