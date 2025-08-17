import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/rtl_theme.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/providers/providers.dart';
import '../../../../generated/l10n.dart';
import '../widgets/pharaoh_app_bar.dart';
import '../widgets/pharaoh_bottom_nav_bar.dart';
import '../widgets/pharaoh_floating_action_button.dart';

/// Main Navigation Screen with Bottom Navigation Bar
/// 
/// This screen provides the main navigation structure for the app,
/// including the bottom navigation bar, floating action button for wishlist,
/// and the animated Pharaoh-themed app bar.
class MainNavigationScreen extends ConsumerStatefulWidget {
  final Widget child;

  const MainNavigationScreen({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  ConsumerState<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen>
    with TickerProviderStateMixin {
  late AnimationController _appBarAnimationController;
  late AnimationController _fabAnimationController;
  late Animation<double> _appBarAnimation;
  late Animation<double> _fabAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    // App bar animation controller
    _appBarAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // FAB animation controller
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // App bar animation
    _appBarAnimation = CurvedAnimation(
      parent: _appBarAnimationController,
      curve: Curves.easeOutCubic,
    );

    // FAB animation
    _fabAnimation = CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.elasticOut,
    );

    // Start animations
    _appBarAnimationController.forward();
    _fabAnimationController.forward();
  }

  @override
  void dispose() {
    _appBarAnimationController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentRoute = GoRouterState.of(context).location;
    final currentIndex = RouteNames.getTabIndex(currentRoute);
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    final l10n = AppLocalizations.of(context);
    
    // Watch providers
    final cartItemCount = ref.watch(cartItemCountProvider);
    final wishlistItemCount = ref.watch(wishlistItemCountProvider);
    final unreadNotificationCount = ref.watch(unreadNotificationCountProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      
      // Animated App Bar
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AnimatedBuilder(
          animation: _appBarAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, -50 * (1 - _appBarAnimation.value)),
              child: Opacity(
                opacity: _appBarAnimation.value,
                child: PharaohAppBar(
                  title: _getAppBarTitle(currentRoute, l10n, isRTL),
                  showBackButton: _shouldShowBackButton(currentRoute),
                  showSearchButton: _shouldShowSearchButton(currentRoute),
                  showNotificationButton: _shouldShowNotificationButton(currentRoute),
                  notificationCount: unreadNotificationCount,
                  onSearchTap: () => _handleSearchTap(context),
                  onNotificationTap: () => _handleNotificationTap(context),
                  backgroundColor: _getAppBarBackgroundColor(currentRoute),
                  foregroundColor: _getAppBarForegroundColor(currentRoute),
                ),
              ),
            );
          },
        ),
      ),

      // Main Content
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        child: widget.child,
      ),

      // Floating Action Button (Wishlist)
      floatingActionButton: _shouldShowFAB(currentRoute)
          ? AnimatedBuilder(
              animation: _fabAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _fabAnimation.value,
                  child: PharaohFloatingActionButton(
                    onPressed: () => _handleWishlistTap(context),
                    icon: Icons.favorite,
                    badgeCount: wishlistItemCount,
                    tooltip: l10n?.wishlist ?? 'Wishlist',
                  ),
                );
              },
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      // Bottom Navigation Bar
      bottomNavigationBar: AnimatedBuilder(
        animation: _appBarAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, 100 * (1 - _appBarAnimation.value)),
            child: Opacity(
              opacity: _appBarAnimation.value,
              child: PharaohBottomNavBar(
                currentIndex: currentIndex,
                onTap: (index) => _handleBottomNavTap(context, index),
                cartItemCount: cartItemCount,
                items: _buildBottomNavItems(l10n, isRTL),
              ),
            ),
          );
        },
      ),

      // Drawer (if needed)
      drawer: _shouldShowDrawer(currentRoute) ? _buildDrawer(context) : null,
    );
  }

  // =============================================================================
  // HELPER METHODS
  // =============================================================================

  String _getAppBarTitle(String route, AppLocalizations? l10n, bool isRTL) {
    if (isRTL) {
      return RouteNames.getRouteTitleAr(route);
    }
    return RouteNames.getRouteTitle(route);
  }

  bool _shouldShowBackButton(String route) {
    return !RouteNames.isMainNavigationRoute(route);
  }

  bool _shouldShowSearchButton(String route) {
    return route == RouteNames.home || 
           route == RouteNames.categories ||
           route.startsWith('/categories/products/');
  }

  bool _shouldShowNotificationButton(String route) {
    return RouteNames.isMainNavigationRoute(route);
  }

  bool _shouldShowFAB(String route) {
    return route == RouteNames.home || 
           route == RouteNames.categories ||
           route.startsWith('/product/');
  }

  bool _shouldShowDrawer(String route) {
    return route == RouteNames.home;
  }

  Color _getAppBarBackgroundColor(String route) {
    switch (route) {
      case RouteNames.home:
        return Colors.transparent;
      case RouteNames.cart:
        return NeferColors.pharaohGold.withOpacity(0.1);
      default:
        return Theme.of(context).colorScheme.surface;
    }
  }

  Color _getAppBarForegroundColor(String route) {
    switch (route) {
      case RouteNames.home:
        return NeferColors.hieroglyphGray;
      default:
        return Theme.of(context).colorScheme.onSurface;
    }
  }

  List<BottomNavItem> _buildBottomNavItems(AppLocalizations? l10n, bool isRTL) {
    return [
      BottomNavItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        label: isRTL ? 'الرئيسية' : (l10n?.home ?? 'Home'),
        route: RouteNames.home,
      ),
      BottomNavItem(
        icon: Icons.category_outlined,
        activeIcon: Icons.category,
        label: isRTL ? 'الفئات' : (l10n?.categories ?? 'Categories'),
        route: RouteNames.categories,
      ),
      BottomNavItem(
        icon: Icons.shopping_cart_outlined,
        activeIcon: Icons.shopping_cart,
        label: isRTL ? 'السلة' : (l10n?.cart ?? 'Cart'),
        route: RouteNames.cart,
      ),
      BottomNavItem(
        icon: Icons.receipt_long_outlined,
        activeIcon: Icons.receipt_long,
        label: isRTL ? 'الطلبات' : (l10n?.orders ?? 'Orders'),
        route: RouteNames.orders,
      ),
      BottomNavItem(
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        label: isRTL ? 'الملف الشخصي' : (l10n?.profile ?? 'Profile'),
        route: RouteNames.profile,
      ),
    ];
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Drawer header with pharaonic design
          Container(
            height: 200,
            decoration: const BoxDecoration(
              gradient: NeferColors.pharaohGradient,
            ),
            child: const Center(
              child: Text(
                'نفِر\nNefer',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          
          // Drawer items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: const Icon(Icons.flash_on),
                  title: const Text('Flash Sales'),
                  onTap: () => context.pushNamed(RouteNames.flashSales),
                ),
                ListTile(
                  leading: const Icon(Icons.local_offer),
                  title: const Text('Coupons'),
                  onTap: () => context.pushNamed(RouteNames.coupons),
                ),
                ListTile(
                  leading: const Icon(Icons.chat),
                  title: const Text('Support Chat'),
                  onTap: () => context.pushNamed(RouteNames.chat),
                ),
                ListTile(
                  leading: const Icon(Icons.report_problem),
                  title: const Text('Complaints'),
                  onTap: () => context.pushNamed(RouteNames.complaints),
                ),
                ListTile(
                  leading: const Icon(Icons.contact_support),
                  title: const Text('Contact Us'),
                  onTap: () => context.pushNamed(RouteNames.contact),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Settings'),
                  onTap: () => context.pushNamed(RouteNames.settings),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =============================================================================
  // EVENT HANDLERS
  // =============================================================================

  void _handleBottomNavTap(BuildContext context, int index) {
    // Animate tab change
    _fabAnimationController.reset();
    _fabAnimationController.forward();
    
    // Navigate to selected tab
    switch (index) {
      case 0:
        context.goNamed(RouteNames.home);
        break;
      case 1:
        context.goNamed(RouteNames.categories);
        break;
      case 2:
        context.goNamed(RouteNames.cart);
        break;
      case 3:
        context.goNamed(RouteNames.orders);
        break;
      case 4:
        context.goNamed(RouteNames.profile);
        break;
    }
  }

  void _handleSearchTap(BuildContext context) {
    context.pushNamed(RouteNames.search);
  }

  void _handleNotificationTap(BuildContext context) {
    // Show notifications bottom sheet or navigate to notifications screen
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const NotificationsBottomSheet(),
    );
  }

  void _handleWishlistTap(BuildContext context) {
    context.pushNamed(RouteNames.wishlist);
  }
}

// =============================================================================
// SUPPORTING CLASSES
// =============================================================================

class BottomNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;

  const BottomNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
  });
}

// Placeholder for notifications bottom sheet
class NotificationsBottomSheet extends StatelessWidget {
  const NotificationsBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: const Center(
        child: Text('Notifications'),
      ),
    );
  }
}
