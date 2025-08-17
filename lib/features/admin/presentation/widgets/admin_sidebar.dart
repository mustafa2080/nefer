import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/providers/providers.dart';
import '../../../../features/auth/data/models/user_role.dart';

/// Admin Sidebar Navigation
/// 
/// Provides navigation for different admin sections with role-based access control.
/// Features pharaonic design elements and smooth animations.
class AdminSidebar extends ConsumerStatefulWidget {
  const AdminSidebar({Key? key}) : super(key: key);

  @override
  ConsumerState<AdminSidebar> createState() => _AdminSidebarState();
}

class _AdminSidebarState extends ConsumerState<AdminSidebar>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  
  String _selectedRoute = '/admin';

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _updateSelectedRoute();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );

    _animationController.forward();
  }

  void _updateSelectedRoute() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentRoute = GoRouterState.of(context).location;
      if (mounted) {
        setState(() {
          _selectedRoute = currentRoute;
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(-250 * (1 - _slideAnimation.value), 0),
          child: Container(
            width: 250,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  NeferColors.lapisBlue,
                  Color(0xFF1E293B),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: NeferColors.blueShadow,
                  blurRadius: 10,
                  offset: const Offset(2, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header
                _buildHeader(context, currentUser),
                
                // Navigation Items
                Expanded(
                  child: _buildNavigationItems(context, currentUser),
                ),
                
                // Footer
                _buildFooter(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, User? currentUser) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: NeferColors.pharaohGradient,
      ),
      child: Column(
        children: [
          // Logo
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.admin_panel_settings,
              color: Colors.white,
              size: 30,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // App Name
          Text(
            'نفِر Admin',
            style: NeferTypography.sectionHeader.copyWith(
              color: Colors.white,
              fontSize: 20,
            ),
          ),
          
          const SizedBox(height: 4),
          
          // User Info
          if (currentUser != null) ...[
            Text(
              currentUser.fullName,
              style: NeferTypography.bodyMedium.copyWith(
                color: Colors.white.withOpacity(0.9),
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              currentUser.role.displayName,
              style: NeferTypography.bodySmall.copyWith(
                color: Colors.white.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNavigationItems(BuildContext context, User? currentUser) {
    final navigationItems = _getNavigationItems(currentUser);
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: navigationItems.length,
      itemBuilder: (context, index) {
        final item = navigationItems[index];
        
        if (item.isDivider) {
          return const Divider(
            color: Colors.white24,
            height: 24,
            indent: 16,
            endIndent: 16,
          );
        }
        
        return _buildNavigationItem(context, item);
      },
    );
  }

  Widget _buildNavigationItem(BuildContext context, AdminNavigationItem item) {
    final isSelected = _selectedRoute.startsWith(item.route);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: isSelected ? Colors.white.withOpacity(0.1) : null,
      ),
      child: ListTile(
        leading: Icon(
          item.icon,
          color: isSelected ? NeferColors.pharaohGold : Colors.white70,
          size: 22,
        ),
        title: Text(
          item.title,
          style: NeferTypography.bodyMedium.copyWith(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        trailing: item.badge != null
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: NeferColors.error,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  item.badge!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : null,
        onTap: () {
          setState(() {
            _selectedRoute = item.route;
          });
          context.go(item.route);
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // App Version
          Text(
            'Version 1.0.0',
            style: NeferTypography.caption.copyWith(
              color: Colors.white54,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Logout Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _handleLogout(context),
              icon: const Icon(Icons.logout, size: 18),
              label: const Text('Logout'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white70,
                side: BorderSide(color: Colors.white.withOpacity(0.3)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<AdminNavigationItem> _getNavigationItems(User? currentUser) {
    final items = <AdminNavigationItem>[
      AdminNavigationItem(
        icon: Icons.dashboard,
        title: 'Dashboard',
        route: '/admin',
      ),
      
      AdminNavigationItem(isDivider: true),
      
      // Products Section
      AdminNavigationItem(
        icon: Icons.inventory_2,
        title: 'Products',
        route: '/admin/products',
      ),
      AdminNavigationItem(
        icon: Icons.category,
        title: 'Categories',
        route: '/admin/categories',
      ),
      AdminNavigationItem(
        icon: Icons.warehouse,
        title: 'Inventory',
        route: '/admin/inventory',
      ),
      
      AdminNavigationItem(isDivider: true),
      
      // Orders Section
      AdminNavigationItem(
        icon: Icons.receipt_long,
        title: 'Orders',
        route: '/admin/orders',
        badge: '12', // Example badge
      ),
      AdminNavigationItem(
        icon: Icons.local_shipping,
        title: 'Shipping',
        route: '/admin/shipping',
      ),
      AdminNavigationItem(
        icon: Icons.assignment_return,
        title: 'Returns',
        route: '/admin/returns',
      ),
      
      AdminNavigationItem(isDivider: true),
      
      // Users Section
      AdminNavigationItem(
        icon: Icons.people,
        title: 'Users',
        route: '/admin/users',
      ),
      AdminNavigationItem(
        icon: Icons.star,
        title: 'Reviews',
        route: '/admin/reviews',
      ),
      
      AdminNavigationItem(isDivider: true),
      
      // Marketing Section
      AdminNavigationItem(
        icon: Icons.local_offer,
        title: 'Coupons',
        route: '/admin/coupons',
      ),
      AdminNavigationItem(
        icon: Icons.flash_on,
        title: 'Flash Sales',
        route: '/admin/flash-sales',
      ),
      AdminNavigationItem(
        icon: Icons.campaign,
        title: 'Promotions',
        route: '/admin/promotions',
      ),
      
      AdminNavigationItem(isDivider: true),
      
      // Analytics Section
      AdminNavigationItem(
        icon: Icons.analytics,
        title: 'Analytics',
        route: '/admin/analytics',
      ),
      AdminNavigationItem(
        icon: Icons.assessment,
        title: 'Reports',
        route: '/admin/reports',
      ),
      
      AdminNavigationItem(isDivider: true),
      
      // System Section
      AdminNavigationItem(
        icon: Icons.settings,
        title: 'Settings',
        route: '/admin/settings',
      ),
      AdminNavigationItem(
        icon: Icons.support_agent,
        title: 'Support',
        route: '/admin/support',
      ),
    ];

    // Filter items based on user permissions
    if (currentUser != null) {
      return items.where((item) {
        if (item.isDivider) return true;
        return _hasPermissionForRoute(currentUser, item.route);
      }).toList();
    }

    return items;
  }

  bool _hasPermissionForRoute(User user, String route) {
    // Map routes to required permissions
    final routePermissions = <String, Permission>{
      '/admin': Permission.accessAdminDashboard,
      '/admin/products': Permission.manageProducts,
      '/admin/categories': Permission.manageCategories,
      '/admin/inventory': Permission.manageInventory,
      '/admin/orders': Permission.manageOrders,
      '/admin/shipping': Permission.manageShipping,
      '/admin/returns': Permission.processRefunds,
      '/admin/users': Permission.manageUsers,
      '/admin/reviews': Permission.manageReviews,
      '/admin/coupons': Permission.manageCoupons,
      '/admin/flash-sales': Permission.manageFlashSales,
      '/admin/promotions': Permission.managePromotions,
      '/admin/analytics': Permission.viewAnalytics,
      '/admin/reports': Permission.viewReports,
      '/admin/settings': Permission.manageSettings,
      '/admin/support': Permission.moderateContent,
    };

    final requiredPermission = routePermissions[route];
    if (requiredPermission == null) return true;
    
    return user.hasPermission(requiredPermission);
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout from admin panel?'),
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

/// Navigation item model
class AdminNavigationItem {
  final IconData icon;
  final String title;
  final String route;
  final String? badge;
  final bool isDivider;

  AdminNavigationItem({
    this.icon = Icons.circle,
    this.title = '',
    this.route = '',
    this.badge,
    this.isDivider = false,
  });
}
