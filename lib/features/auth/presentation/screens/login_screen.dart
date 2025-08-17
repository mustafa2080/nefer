import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/providers/providers.dart';
import '../../../../generated/l10n.dart';
import '../widgets/pharaoh_text_field.dart';
import '../widgets/pharaoh_button.dart';
import '../widgets/auth_background.dart';
import '../controllers/auth_controller.dart';

/// Login Screen with Pharaonic design
/// 
/// Features:
/// - Animated background with Egyptian motifs
/// - Custom form fields with golden accents
/// - Social login options
/// - Smooth transitions and validations
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
  }

  void _startAnimations() {
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final authState = ref.watch(authControllerProvider);
    
    return Scaffold(
      body: AuthBackground(
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: _buildLoginForm(context, l10n, authState),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context, AppLocalizations? l10n, AuthState authState) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo and title
            _buildHeader(l10n),
            
            const SizedBox(height: 40),
            
            // Login form
            _buildForm(l10n, authState),
            
            const SizedBox(height: 24),
            
            // Social login options
            _buildSocialLogin(l10n),
            
            const SizedBox(height: 24),
            
            // Register link
            _buildRegisterLink(l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations? l10n) {
    return Column(
      children: [
        // Logo
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
            Icons.auto_awesome,
            color: Colors.white,
            size: 40,
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Welcome text
        Text(
          l10n?.welcome ?? 'Welcome to Nefer',
          style: NeferTypography.sectionHeader.copyWith(
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 8),
        
        Text(
          'سوق الفراعنة',
          style: NeferTypography.arabicSectionHeader.copyWith(
            color: Colors.white.withOpacity(0.8),
            fontSize: 18,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildForm(AppLocalizations? l10n, AuthState authState) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title
            Text(
              l10n?.signIn ?? 'Sign In',
              style: NeferTypography.sectionHeader.copyWith(
                color: NeferColors.hieroglyphGray,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 24),
            
            // Email field
            PharaohTextField(
              controller: _emailController,
              labelText: l10n?.email ?? 'Email',
              hintText: 'Enter your email',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: _validateEmail,
            ),
            
            const SizedBox(height: 16),
            
            // Password field
            PharaohTextField(
              controller: _passwordController,
              labelText: l10n?.password ?? 'Password',
              hintText: 'Enter your password',
              prefixIcon: Icons.lock_outlined,
              obscureText: _obscurePassword,
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
                icon: Icon(
                  _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                ),
              ),
              validator: _validatePassword,
            ),
            
            const SizedBox(height: 16),
            
            // Remember me and forgot password
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      onChanged: (value) {
                        setState(() {
                          _rememberMe = value ?? false;
                        });
                      },
                      activeColor: NeferColors.pharaohGold,
                    ),
                    Text(
                      'Remember me',
                      style: NeferTypography.bodySmall,
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () => context.pushNamed(RouteNames.forgotPassword),
                  child: Text(
                    l10n?.forgotPassword ?? 'Forgot Password?',
                    style: NeferTypography.bodySmall.copyWith(
                      color: NeferColors.pharaohGold,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Login button
            PharaohButton(
              onPressed: authState.isLoading ? null : _handleLogin,
              text: l10n?.signIn ?? 'Sign In',
              isLoading: authState.isLoading,
              gradient: NeferColors.pharaohGradient,
            ),
            
            // Error message
            if (authState.hasError) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: NeferColors.errorLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: NeferColors.error),
                ),
                child: Text(
                  authState.error ?? 'An error occurred',
                  style: NeferTypography.bodySmall.copyWith(
                    color: NeferColors.error,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSocialLogin(AppLocalizations? l10n) {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(child: Divider(color: Colors.white54)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Or continue with',
                style: NeferTypography.bodySmall.copyWith(
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ),
            const Expanded(child: Divider(color: Colors.white54)),
          ],
        ),
        
        const SizedBox(height: 16),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildSocialButton(
              icon: Icons.g_mobiledata,
              label: 'Google',
              onPressed: _handleGoogleLogin,
            ),
            _buildSocialButton(
              icon: Icons.facebook,
              label: 'Facebook',
              onPressed: _handleFacebookLogin,
            ),
            _buildSocialButton(
              icon: Icons.apple,
              label: 'Apple',
              onPressed: _handleAppleLogin,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 80,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: NeferColors.hieroglyphGray,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildRegisterLink(AppLocalizations? l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: NeferTypography.bodyMedium.copyWith(
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        TextButton(
          onPressed: () => context.pushNamed(RouteNames.register),
          child: Text(
            l10n?.signUp ?? 'Sign Up',
            style: NeferTypography.bodyMedium.copyWith(
              color: NeferColors.pharaohGold,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  void _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      final result = await ref.read(authControllerProvider.notifier).signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );
      
      if (result && mounted) {
        final user = ref.read(currentUserProvider);
        if (user?.canAccessAdminDashboard() ?? false) {
          context.go(RouteNames.admin);
        } else {
          context.go(RouteNames.home);
        }
      }
    }
  }

  void _handleGoogleLogin() async {
    await ref.read(authControllerProvider.notifier).signInWithGoogle();
  }

  void _handleFacebookLogin() async {
    // Implement Facebook login
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Facebook login coming soon')),
    );
  }

  void _handleAppleLogin() async {
    // Implement Apple login
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Apple login coming soon')),
    );
  }
}
