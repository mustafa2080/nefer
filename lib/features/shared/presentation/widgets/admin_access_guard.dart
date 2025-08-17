import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/providers/providers.dart';
import '../../../../features/auth/data/models/user_role.dart';

/// Admin Access Guard Widget
/// 
/// Protects admin routes and features by checking user permissions.
/// Shows appropriate UI based on user's access level.
class AdminAccessGuard extends ConsumerWidget {
  final Widget child;
  final Permission? requiredPermission;
  final List<Permission>? requiredPermissions;
  final bool requireAllPermissions;
  final Widget? fallbackWidget;
  final String? redirectRoute;
  final bool showAccessDenied;

  const AdminAccessGuard({
    Key? key,
    required this.child,
    this.requiredPermission,
    this.requiredPermissions,
    this.requireAllPermissions = false,
    this.fallbackWidget,
    this.redirectRoute,
    this.showAccessDenied = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    
    return authState.when(
      loading: () => const AdminAccessLoading(),
      error: (error, _) => AdminAccessError(error: error.toString()),
      unauthenticated: () => _handleUnauthenticated(context),
      authenticated: (user) => _buildWithUser(context, user),
    );
  }

  Widget _buildWithUser(BuildContext context, User user) {
    final hasAccess = _checkUserAccess(user);
    
    if (hasAccess) {
      return child;
    }
    
    if (redirectRoute != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go(redirectRoute!);
      });
      return const AdminAccessLoading();
    }
    
    if (fallbackWidget != null) {
      return fallbackWidget!;
    }
    
    if (showAccessDenied) {
      return AdminAccessDenied(
        user: user,
        requiredPermission: requiredPermission,
        requiredPermissions: requiredPermissions,
      );
    }
    
    return const SizedBox.shrink();
  }

  Widget _handleUnauthenticated(BuildContext context) {
    if (redirectRoute != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go(redirectRoute!);
      });
      return const AdminAccessLoading();
    }
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.go('/login');
    });
    
    return const AdminAccessLoading();
  }

  bool _checkUserAccess(User user) {
    // Check single permission
    if (requiredPermission != null) {
      return user.hasPermission(requiredPermission!);
    }
    
    // Check multiple permissions
    if (requiredPermissions != null && requiredPermissions!.isNotEmpty) {
      if (requireAllPermissions) {
        return user.role.hasAllPermissions(requiredPermissions!);
      } else {
        return user.role.hasAnyPermission(requiredPermissions!);
      }
    }
    
    // Default: check admin dashboard access
    return user.canAccessAdminDashboard();
  }
}

/// Loading widget for admin access checks
class AdminAccessLoading extends StatelessWidget {
  const AdminAccessLoading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: NeferColors.pharaohGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: NeferColors.goldShadow,
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.admin_panel_settings,
                color: Colors.white,
                size: 40,
              ),
            ),
            
            const SizedBox(height: 24),
            
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(NeferColors.pharaohGold),
            ),
            
            const SizedBox(height: 16),
            
            Text(
              'Verifying Access...',
              style: NeferTypography.bodyLarge.copyWith(
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Error widget for admin access checks
class AdminAccessError extends StatelessWidget {
  final String error;

  const AdminAccessError({
    Key? key,
    required this.error,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 80,
                color: NeferColors.error,
              ),
              
              const SizedBox(height: 24),
              
              Text(
                'Access Error',
                style: NeferTypography.sectionHeader.copyWith(
                  color: NeferColors.error,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              Text(
                error,
                style: NeferTypography.bodyMedium,
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 24),
              
              ElevatedButton(
                onPressed: () => context.go('/'),
                child: const Text('Go to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Access denied widget
class AdminAccessDenied extends StatelessWidget {
  final User user;
  final Permission? requiredPermission;
  final List<Permission>? requiredPermissions;

  const AdminAccessDenied({
    Key? key,
    required this.user,
    this.requiredPermission,
    this.requiredPermissions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Access Denied Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: NeferColors.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: NeferColors.error.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.block,
                  size: 60,
                  color: NeferColors.error,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Title
              Text(
                'Access Denied',
                style: NeferTypography.pharaohTitle.copyWith(
                  color: NeferColors.error,
                  fontSize: 32,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // Message
              Text(
                'You do not have permission to access this area.',
                style: NeferTypography.bodyLarge,
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 24),
              
              // User Info Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: user.photoURL != null
                                ? NetworkImage(user.photoURL!)
                                : null,
                            backgroundColor: NeferColors.sandstoneBeige,
                            child: user.photoURL == null
                                ? Text(
                                    user.initials,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                          ),
                          
                          const SizedBox(width: 12),
                          
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.fullName,
                                  style: NeferTypography.bodyLarge.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  user.email,
                                  style: NeferTypography.bodyMedium.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 12),
                      
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: user.isAdmin ? NeferColors.pharaohGold : NeferColors.info,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Role: ${user.role.displayName}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Required Permissions
              if (requiredPermission != null || requiredPermissions != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Required Permissions:',
                          style: NeferTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (requiredPermission != null)
                          _buildPermissionChip(requiredPermission!),
                        if (requiredPermissions != null)
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: requiredPermissions!
                                .map((permission) => _buildPermissionChip(permission))
                                .toList(),
                          ),
                      ],
                    ),
                  ),
                ),
              
              const SizedBox(height: 32),
              
              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: () => context.go('/'),
                    child: const Text('Go to Home'),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  ElevatedButton(
                    onPressed: () => context.go('/profile'),
                    child: const Text('View Profile'),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Contact Admin
              TextButton(
                onPressed: () => _showContactAdminDialog(context),
                child: const Text('Contact Administrator'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionChip(Permission permission) {
    return Chip(
      label: Text(
        permission.displayName,
        style: const TextStyle(fontSize: 12),
      ),
      backgroundColor: NeferColors.warning.withOpacity(0.1),
      side: BorderSide(
        color: NeferColors.warning.withOpacity(0.3),
      ),
    );
  }

  void _showContactAdminDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Administrator'),
        content: const Text(
          'If you believe you should have access to this area, please contact your system administrator.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/contact');
            },
            child: const Text('Contact Support'),
          ),
        ],
      ),
    );
  }
}

/// Convenience widgets for common admin access patterns

/// Admin-only widget wrapper
class AdminOnly extends StatelessWidget {
  final Widget child;
  final Widget? fallback;

  const AdminOnly({
    Key? key,
    required this.child,
    this.fallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AdminAccessGuard(
      requiredPermission: Permission.accessAdminDashboard,
      fallbackWidget: fallback ?? const SizedBox.shrink(),
      showAccessDenied: false,
      child: child,
    );
  }
}

/// Permission-based widget wrapper
class PermissionGuard extends StatelessWidget {
  final Widget child;
  final Permission permission;
  final Widget? fallback;

  const PermissionGuard({
    Key? key,
    required this.child,
    required this.permission,
    this.fallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AdminAccessGuard(
      requiredPermission: permission,
      fallbackWidget: fallback ?? const SizedBox.shrink(),
      showAccessDenied: false,
      child: child,
    );
  }
}
