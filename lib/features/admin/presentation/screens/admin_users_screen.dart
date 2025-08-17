import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:data_table_2/data_table_2.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/providers/providers.dart';
import '../../../../features/auth/data/models/user.dart';
import '../../../../features/auth/data/models/user_role.dart';
import '../widgets/admin_sidebar.dart';
import '../widgets/user_details_dialog.dart';
import '../widgets/edit_user_dialog.dart';
import '../controllers/admin_users_controller.dart';

/// Admin Users Management Screen
/// 
/// Allows administrators to:
/// - View all users in a data table
/// - Search and filter users
/// - Edit user details and roles
/// - Suspend/activate users
/// - View user statistics
class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  UserRole? _selectedRoleFilter;
  AccountStatus? _selectedStatusFilter;
  int _sortColumnIndex = 0;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final usersState = ref.watch(adminUsersControllerProvider);
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Row(
        children: [
          // Sidebar
          const AdminSidebar(),
          
          // Main Content
          Expanded(
            child: Column(
              children: [
                // Header
                _buildHeader(context),
                
                // Filters and Search
                _buildFiltersSection(context),
                
                // Users Table
                Expanded(
                  child: _buildUsersTable(context, usersState),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: NeferColors.pharaohGradient,
        boxShadow: [
          BoxShadow(
            color: NeferColors.goldShadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'User Management',
                  style: NeferTypography.pharaohTitle.copyWith(
                    color: Colors.white,
                    fontSize: 28,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage users, roles, and permissions',
                  style: NeferTypography.bodyLarge.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          
          // Add User Button
          ElevatedButton.icon(
            onPressed: () => _showAddUserDialog(context),
            icon: const Icon(Icons.person_add),
            label: const Text('Add User'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: NeferColors.pharaohGold,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Search Field
          Expanded(
            flex: 2,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search users by name, email, or ID...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Role Filter
          SizedBox(
            width: 150,
            child: DropdownButtonFormField<UserRole?>(
              value: _selectedRoleFilter,
              decoration: InputDecoration(
                labelText: 'Role',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              items: [
                const DropdownMenuItem<UserRole?>(
                  value: null,
                  child: Text('All Roles'),
                ),
                ...UserRoles.allRoles.map((role) => DropdownMenuItem(
                  value: role,
                  child: Text(role.displayName),
                )),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedRoleFilter = value;
                });
              },
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Status Filter
          SizedBox(
            width: 150,
            child: DropdownButtonFormField<AccountStatus?>(
              value: _selectedStatusFilter,
              decoration: InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              items: [
                const DropdownMenuItem<AccountStatus?>(
                  value: null,
                  child: Text('All Status'),
                ),
                ...AccountStatus.values.map((status) => DropdownMenuItem(
                  value: status,
                  child: Text(_getStatusDisplayName(status)),
                )),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedStatusFilter = value;
                });
              },
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Refresh Button
          IconButton(
            onPressed: () {
              ref.refresh(adminUsersControllerProvider);
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
    );
  }

  Widget _buildUsersTable(BuildContext context, AsyncValue<List<User>> usersState) {
    return usersState.when(
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stackTrace) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: NeferColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading users',
              style: NeferTypography.sectionHeader,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: NeferTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.refresh(adminUsersControllerProvider);
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (users) {
        final filteredUsers = _filterUsers(users);
        
        if (filteredUsers.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people_outline,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'No users found',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Try adjusting your search or filters',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }
        
        return Card(
          margin: const EdgeInsets.all(20),
          child: DataTable2(
            columnSpacing: 12,
            horizontalMargin: 12,
            minWidth: 800,
            sortColumnIndex: _sortColumnIndex,
            sortAscending: _sortAscending,
            columns: [
              DataColumn2(
                label: const Text('User'),
                size: ColumnSize.L,
                onSort: (columnIndex, ascending) {
                  _sortUsers(filteredUsers, columnIndex, ascending);
                },
              ),
              DataColumn2(
                label: const Text('Email'),
                size: ColumnSize.L,
                onSort: (columnIndex, ascending) {
                  _sortUsers(filteredUsers, columnIndex, ascending);
                },
              ),
              DataColumn2(
                label: const Text('Role'),
                size: ColumnSize.S,
                onSort: (columnIndex, ascending) {
                  _sortUsers(filteredUsers, columnIndex, ascending);
                },
              ),
              DataColumn2(
                label: const Text('Status'),
                size: ColumnSize.S,
                onSort: (columnIndex, ascending) {
                  _sortUsers(filteredUsers, columnIndex, ascending);
                },
              ),
              DataColumn2(
                label: const Text('Created'),
                size: ColumnSize.M,
                onSort: (columnIndex, ascending) {
                  _sortUsers(filteredUsers, columnIndex, ascending);
                },
              ),
              DataColumn2(
                label: const Text('Last Login'),
                size: ColumnSize.M,
                onSort: (columnIndex, ascending) {
                  _sortUsers(filteredUsers, columnIndex, ascending);
                },
              ),
              const DataColumn2(
                label: Text('Actions'),
                size: ColumnSize.M,
              ),
            ],
            rows: filteredUsers.map((user) => DataRow2(
              cells: [
                DataCell(
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundImage: user.photoURL != null
                            ? NetworkImage(user.photoURL!)
                            : null,
                        backgroundColor: NeferColors.sandstoneBeige,
                        child: user.photoURL == null
                            ? Text(
                                user.initials,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              user.fullName,
                              style: const TextStyle(fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (user.phoneNumber != null)
                              Text(
                                user.phoneNumber!,
                                style: Theme.of(context).textTheme.bodySmall,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                DataCell(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(user.email),
                      if (!user.emailVerified)
                        Text(
                          'Not verified',
                          style: TextStyle(
                            color: NeferColors.warning,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: user.isAdmin ? NeferColors.pharaohGold : NeferColors.info,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      user.role.displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(user.status?.status ?? AccountStatus.active),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusDisplayName(user.status?.status ?? AccountStatus.active),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    user.createdAt != null
                        ? _formatDate(user.createdAt!)
                        : 'Unknown',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                DataCell(
                  Text(
                    user.lastLoginAt != null
                        ? _formatDate(user.lastLoginAt!)
                        : 'Never',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => _showUserDetails(context, user),
                        icon: const Icon(Icons.visibility, size: 18),
                        tooltip: 'View Details',
                      ),
                      IconButton(
                        onPressed: () => _showEditUserDialog(context, user),
                        icon: const Icon(Icons.edit, size: 18),
                        tooltip: 'Edit User',
                      ),
                      PopupMenuButton<String>(
                        onSelected: (action) => _handleUserAction(context, user, action),
                        itemBuilder: (context) => [
                          if (user.isActive)
                            const PopupMenuItem(
                              value: 'suspend',
                              child: ListTile(
                                leading: Icon(Icons.block, color: NeferColors.warning),
                                title: Text('Suspend'),
                                contentPadding: EdgeInsets.zero,
                              ),
                            )
                          else
                            const PopupMenuItem(
                              value: 'activate',
                              child: ListTile(
                                leading: Icon(Icons.check_circle, color: NeferColors.success),
                                title: Text('Activate'),
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          const PopupMenuItem(
                            value: 'reset_password',
                            child: ListTile(
                              leading: Icon(Icons.lock_reset),
                              title: Text('Reset Password'),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          const PopupMenuDivider(),
                          const PopupMenuItem(
                            value: 'delete',
                            child: ListTile(
                              leading: Icon(Icons.delete, color: NeferColors.error),
                              title: Text('Delete', style: TextStyle(color: NeferColors.error)),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                        child: const Icon(Icons.more_vert, size: 18),
                      ),
                    ],
                  ),
                ),
              ],
            )).toList(),
          ),
        );
      },
    );
  }

  List<User> _filterUsers(List<User> users) {
    return users.where((user) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!user.fullName.toLowerCase().contains(query) &&
            !user.email.toLowerCase().contains(query) &&
            !user.uid.toLowerCase().contains(query)) {
          return false;
        }
      }
      
      // Role filter
      if (_selectedRoleFilter != null && user.role.id != _selectedRoleFilter!.id) {
        return false;
      }
      
      // Status filter
      if (_selectedStatusFilter != null && 
          (user.status?.status ?? AccountStatus.active) != _selectedStatusFilter) {
        return false;
      }
      
      return true;
    }).toList();
  }

  void _sortUsers(List<User> users, int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
    
    users.sort((a, b) {
      int result = 0;
      
      switch (columnIndex) {
        case 0: // Name
          result = a.fullName.compareTo(b.fullName);
          break;
        case 1: // Email
          result = a.email.compareTo(b.email);
          break;
        case 2: // Role
          result = a.role.displayName.compareTo(b.role.displayName);
          break;
        case 3: // Status
          result = (a.status?.status.index ?? 0).compareTo(b.status?.status.index ?? 0);
          break;
        case 4: // Created
          result = (a.createdAt ?? DateTime(1970)).compareTo(b.createdAt ?? DateTime(1970));
          break;
        case 5: // Last Login
          result = (a.lastLoginAt ?? DateTime(1970)).compareTo(b.lastLoginAt ?? DateTime(1970));
          break;
      }
      
      return ascending ? result : -result;
    });
  }

  String _getStatusDisplayName(AccountStatus status) {
    switch (status) {
      case AccountStatus.active:
        return 'Active';
      case AccountStatus.suspended:
        return 'Suspended';
      case AccountStatus.banned:
        return 'Banned';
      case AccountStatus.pending:
        return 'Pending';
      case AccountStatus.inactive:
        return 'Inactive';
      case AccountStatus.deleted:
        return 'Deleted';
    }
  }

  Color _getStatusColor(AccountStatus status) {
    switch (status) {
      case AccountStatus.active:
        return NeferColors.success;
      case AccountStatus.suspended:
        return NeferColors.warning;
      case AccountStatus.banned:
        return NeferColors.error;
      case AccountStatus.pending:
        return NeferColors.info;
      case AccountStatus.inactive:
        return Colors.grey;
      case AccountStatus.deleted:
        return Colors.black54;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showAddUserDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const EditUserDialog(),
    );
  }

  void _showUserDetails(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (context) => UserDetailsDialog(user: user),
    );
  }

  void _showEditUserDialog(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (context) => EditUserDialog(user: user),
    );
  }

  void _handleUserAction(BuildContext context, User user, String action) {
    switch (action) {
      case 'suspend':
        _suspendUser(context, user);
        break;
      case 'activate':
        _activateUser(context, user);
        break;
      case 'reset_password':
        _resetUserPassword(context, user);
        break;
      case 'delete':
        _deleteUser(context, user);
        break;
    }
  }

  void _suspendUser(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Suspend User'),
        content: Text('Are you sure you want to suspend ${user.fullName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(adminUsersControllerProvider.notifier).suspendUser(
                user.uid,
                'Suspended by admin',
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: NeferColors.warning),
            child: const Text('Suspend'),
          ),
        ],
      ),
    );
  }

  void _activateUser(BuildContext context, User user) {
    ref.read(adminUsersControllerProvider.notifier).activateUser(user.uid);
  }

  void _resetUserPassword(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: Text('Send password reset email to ${user.email}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(adminUsersControllerProvider.notifier).resetUserPassword(user.email);
            },
            child: const Text('Send Reset Email'),
          ),
        ],
      ),
    );
  }

  void _deleteUser(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete ${user.fullName}?'),
            const SizedBox(height: 8),
            const Text(
              'This action cannot be undone.',
              style: TextStyle(
                color: NeferColors.error,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(adminUsersControllerProvider.notifier).deleteUser(user.uid);
            },
            style: ElevatedButton.styleFrom(backgroundColor: NeferColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
