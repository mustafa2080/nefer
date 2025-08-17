import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

/// User entity representing authenticated user
@freezed
class User with _$User {
  const factory User({
    required String uid,
    required String email,
    String? displayName,
    String? photoURL,
    String? phoneNumber,
    @Default(false) bool emailVerified,
    @Default(false) bool isAnonymous,
    UserRole? role,
    UserProfile? profile,
    UserPreferences? preferences,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    DateTime? updatedAt,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

/// User role with permissions
@freezed
class UserRole with _$UserRole {
  const factory UserRole({
    required String id,
    required String name,
    required String displayName,
    @Default(0) int level,
    @Default([]) List<Permission> permissions,
    @Default(false) bool isAdmin,
    @Default(true) bool isActive,
  }) = _UserRole;

  factory UserRole.fromJson(Map<String, dynamic> json) => _$UserRoleFromJson(json);
}

/// User profile information
@freezed
class UserProfile with _$UserProfile {
  const factory UserProfile({
    String? firstName,
    String? lastName,
    String? dateOfBirth,
    String? gender,
    String? bio,
    UserAddress? defaultAddress,
    @Default([]) List<UserAddress> addresses,
    @Default([]) List<String> wishlist,
    UserStats? stats,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) => _$UserProfileFromJson(json);
}

/// User address
@freezed
class UserAddress with _$UserAddress {
  const factory UserAddress({
    required String id,
    required String label,
    required String fullName,
    required String phoneNumber,
    required String addressLine1,
    String? addressLine2,
    required String city,
    required String state,
    required String postalCode,
    required String country,
    @Default(false) bool isDefault,
    double? latitude,
    double? longitude,
  }) = _UserAddress;

  factory UserAddress.fromJson(Map<String, dynamic> json) => _$UserAddressFromJson(json);
}

/// User preferences
@freezed
class UserPreferences with _$UserPreferences {
  const factory UserPreferences({
    @Default('en') String language,
    @Default('system') String theme, // light, dark, system
    @Default('USD') String currency,
    @Default(true) bool pushNotifications,
    @Default(true) bool emailNotifications,
    @Default(true) bool smsNotifications,
    @Default(true) bool marketingEmails,
    @Default(true) bool orderUpdates,
    @Default(true) bool promotionalOffers,
  }) = _UserPreferences;

  factory UserPreferences.fromJson(Map<String, dynamic> json) => _$UserPreferencesFromJson(json);
}

/// User statistics
@freezed
class UserStats with _$UserStats {
  const factory UserStats({
    @Default(0) int totalOrders,
    @Default(0.0) double totalSpent,
    @Default(0) int totalReviews,
    @Default(0) int loyaltyPoints,
    @Default(0) int wishlistItems,
    DateTime? lastOrderDate,
    DateTime? memberSince,
  }) = _UserStats;

  factory UserStats.fromJson(Map<String, dynamic> json) => _$UserStatsFromJson(json);
}

/// Permission enum
enum Permission {
  // User permissions
  viewProfile,
  editProfile,
  deleteAccount,
  
  // Shopping permissions
  addToCart,
  placeOrder,
  viewOrders,
  cancelOrder,
  returnOrder,
  
  // Review permissions
  writeReview,
  editReview,
  deleteReview,
  
  // Admin permissions
  accessAdminDashboard,
  manageUsers,
  manageProducts,
  manageOrders,
  manageCategories,
  manageCoupons,
  manageReviews,
  viewAnalytics,
  manageSettings,
  manageRoles,
  
  // Super admin permissions
  manageAdmins,
  systemSettings,
  backupData,
  viewLogs,
}

// Extensions
extension UserExtension on User {
  String get fullName {
    if (profile?.firstName != null && profile?.lastName != null) {
      return '${profile!.firstName} ${profile!.lastName}';
    }
    return displayName ?? email.split('@').first;
  }
  
  String get initials {
    final name = fullName;
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }
  
  bool get isAdmin => role?.isAdmin ?? false;
  
  bool get canAccessAdminDashboard => hasPermission(Permission.accessAdminDashboard);
  
  bool hasPermission(Permission permission) {
    return role?.permissions.contains(permission) ?? false;
  }
  
  bool hasAnyPermission(List<Permission> permissions) {
    return permissions.any((permission) => hasPermission(permission));
  }
  
  bool hasAllPermissions(List<Permission> permissions) {
    return permissions.every((permission) => hasPermission(permission));
  }
}

extension UserRoleExtension on UserRole {
  bool get hasAdminAccess => isAdmin || permissions.contains(Permission.accessAdminDashboard);
  
  bool hasPermission(Permission permission) {
    return permissions.contains(permission);
  }
  
  bool hasAnyPermission(List<Permission> permissions) {
    return permissions.any((permission) => this.permissions.contains(permission));
  }
  
  bool hasAllPermissions(List<Permission> permissions) {
    return permissions.every((permission) => this.permissions.contains(permission));
  }
}

/// Predefined user roles
class UserRoles {
  static const UserRole customer = UserRole(
    id: 'customer',
    name: 'customer',
    displayName: 'Customer',
    level: 1,
    permissions: [
      Permission.viewProfile,
      Permission.editProfile,
      Permission.addToCart,
      Permission.placeOrder,
      Permission.viewOrders,
      Permission.cancelOrder,
      Permission.returnOrder,
      Permission.writeReview,
      Permission.editReview,
      Permission.deleteReview,
    ],
  );
  
  static const UserRole moderator = UserRole(
    id: 'moderator',
    name: 'moderator',
    displayName: 'Moderator',
    level: 50,
    permissions: [
      ...customer.permissions,
      Permission.manageReviews,
      Permission.viewAnalytics,
    ],
  );
  
  static const UserRole admin = UserRole(
    id: 'admin',
    name: 'admin',
    displayName: 'Administrator',
    level: 100,
    isAdmin: true,
    permissions: [
      ...moderator.permissions,
      Permission.accessAdminDashboard,
      Permission.manageUsers,
      Permission.manageProducts,
      Permission.manageOrders,
      Permission.manageCategories,
      Permission.manageCoupons,
      Permission.manageSettings,
      Permission.manageRoles,
    ],
  );
  
  static const UserRole superAdmin = UserRole(
    id: 'super_admin',
    name: 'super_admin',
    displayName: 'Super Administrator',
    level: 1000,
    isAdmin: true,
    permissions: [
      ...admin.permissions,
      Permission.manageAdmins,
      Permission.systemSettings,
      Permission.backupData,
      Permission.viewLogs,
    ],
  );
  
  static List<UserRole> get allRoles => [customer, moderator, admin, superAdmin];
  
  static UserRole? getRoleById(String id) {
    try {
      return allRoles.firstWhere((role) => role.id == id);
    } catch (e) {
      return null;
    }
  }
}
