import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/providers/providers.dart';
import '../../../../generated/l10n.dart';
import '../widgets/shipping_address_section.dart';
import '../widgets/payment_method_section.dart';
import '../widgets/order_summary_section.dart';
import '../widgets/checkout_progress_indicator.dart';
import '../controllers/checkout_controller.dart';

/// Checkout Screen with multiple payment methods and invoice generation
/// 
/// Features:
/// - Multi-step checkout process
/// - Shipping address selection/editing
/// - Multiple payment methods (Card, PayPal, Apple Pay, etc.)
/// - Order summary with final pricing
/// - Invoice generation and download
/// - Order confirmation
class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  int _currentStep = 0;
  final int _totalSteps = 3;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadCheckoutData();
  }

  void _initializeControllers() {
    _pageController = PageController();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    _fadeController.forward();
  }

  void _loadCheckoutData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(checkoutControllerProvider.notifier).initializeCheckout();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final checkoutState = ref.watch(checkoutControllerProvider);
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: _buildAppBar(context, l10n),
      body: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: _buildContent(context, l10n, checkoutState),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, AppLocalizations? l10n) {
    return AppBar(
      title: Text(
        l10n?.checkout ?? 'Checkout',
        style: NeferTypography.sectionHeader,
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        onPressed: () => _handleBackPress(),
        icon: const Icon(Icons.arrow_back),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: CheckoutProgressIndicator(
          currentStep: _currentStep,
          totalSteps: _totalSteps,
          stepTitles: const [
            'Shipping',
            'Payment',
            'Review',
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    AppLocalizations? l10n,
    CheckoutState checkoutState,
  ) {
    return checkoutState.when(
      loading: () => _buildLoadingState(),
      error: (error, _) => _buildErrorState(error.toString()),
      data: (checkout) => _buildCheckoutSteps(context, l10n, checkout),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(NeferColors.pharaohGold),
          ),
          SizedBox(height: 16),
          Text(
            'Preparing checkout...',
            style: TextStyle(
              color: NeferColors.hieroglyphGray,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
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
            'Checkout Error',
            style: NeferTypography.sectionHeader.copyWith(
              color: NeferColors.error,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: NeferTypography.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.pop(),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutSteps(
    BuildContext context,
    AppLocalizations? l10n,
    CheckoutData checkout,
  ) {
    return Column(
      children: [
        // Step Content
        Expanded(
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentStep = index;
              });
            },
            children: [
              // Step 1: Shipping Address
              _buildShippingStep(context, checkout),
              
              // Step 2: Payment Method
              _buildPaymentStep(context, checkout),
              
              // Step 3: Order Review
              _buildReviewStep(context, checkout),
            ],
          ),
        ),
        
        // Navigation Buttons
        _buildNavigationButtons(context, checkout),
      ],
    );
  }

  Widget _buildShippingStep(BuildContext context, CheckoutData checkout) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Shipping Address',
            style: NeferTypography.sectionHeader.copyWith(
              color: NeferColors.hieroglyphGray,
            ),
          ),
          const SizedBox(height: 16),
          
          ShippingAddressSection(
            selectedAddress: checkout.selectedAddress,
            addresses: checkout.availableAddresses,
            onAddressSelected: (address) {
              ref.read(checkoutControllerProvider.notifier)
                  .selectShippingAddress(address);
            },
            onAddNewAddress: () => _showAddAddressDialog(context),
            onEditAddress: (address) => _showEditAddressDialog(context, address),
          ),
          
          const SizedBox(height: 24),
          
          // Shipping Options
          _buildShippingOptions(checkout),
        ],
      ),
    );
  }

  Widget _buildPaymentStep(BuildContext context, CheckoutData checkout) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Method',
            style: NeferTypography.sectionHeader.copyWith(
              color: NeferColors.hieroglyphGray,
            ),
          ),
          const SizedBox(height: 16),
          
          PaymentMethodSection(
            selectedPaymentMethod: checkout.selectedPaymentMethod,
            paymentMethods: checkout.availablePaymentMethods,
            onPaymentMethodSelected: (method) {
              ref.read(checkoutControllerProvider.notifier)
                  .selectPaymentMethod(method);
            },
            onAddNewCard: () => _showAddCardDialog(context),
          ),
          
          const SizedBox(height: 24),
          
          // Billing Address
          _buildBillingAddressSection(checkout),
        ],
      ),
    );
  }

  Widget _buildReviewStep(BuildContext context, CheckoutData checkout) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Review',
            style: NeferTypography.sectionHeader.copyWith(
              color: NeferColors.hieroglyphGray,
            ),
          ),
          const SizedBox(height: 16),
          
          OrderSummarySection(
            cart: checkout.cart,
            shippingAddress: checkout.selectedAddress,
            paymentMethod: checkout.selectedPaymentMethod,
            shippingOption: checkout.selectedShippingOption,
            onEditCart: () => context.pushNamed(RouteNames.cart),
            onEditShipping: () => _goToStep(0),
            onEditPayment: () => _goToStep(1),
          ),
          
          const SizedBox(height: 24),
          
          // Terms and Conditions
          _buildTermsAndConditions(),
        ],
      ),
    );
  }

  Widget _buildShippingOptions(CheckoutData checkout) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: NeferColors.hieroglyphGray.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Shipping Options',
            style: NeferTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          
          ...checkout.availableShippingOptions.map((option) => 
            RadioListTile<ShippingOption>(
              value: option,
              groupValue: checkout.selectedShippingOption,
              onChanged: (value) {
                if (value != null) {
                  ref.read(checkoutControllerProvider.notifier)
                      .selectShippingOption(value);
                }
              },
              title: Text(option.name),
              subtitle: Text(
                '${option.estimatedDays} days - \$${option.price.toStringAsFixed(2)}',
              ),
              activeColor: NeferColors.pharaohGold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillingAddressSection(CheckoutData checkout) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: NeferColors.hieroglyphGray.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Billing Address',
            style: NeferTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          
          CheckboxListTile(
            value: checkout.useSameAddressForBilling,
            onChanged: (value) {
              ref.read(checkoutControllerProvider.notifier)
                  .toggleSameAddressForBilling();
            },
            title: const Text('Same as shipping address'),
            activeColor: NeferColors.pharaohGold,
            contentPadding: EdgeInsets.zero,
          ),
          
          if (!checkout.useSameAddressForBilling) ...[
            const SizedBox(height: 12),
            // Billing address form would go here
            const Text('Billing address form'),
          ],
        ],
      ),
    );
  }

  Widget _buildTermsAndConditions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: NeferColors.pharaohGold.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: NeferColors.pharaohGold.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: NeferColors.pharaohGold,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Terms & Conditions',
                style: NeferTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: NeferColors.hieroglyphGray,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          Consumer(
            builder: (context, ref, child) {
              final acceptedTerms = ref.watch(acceptedTermsProvider);
              
              return CheckboxListTile(
                value: acceptedTerms,
                onChanged: (value) {
                  ref.read(acceptedTermsProvider.notifier).state = value ?? false;
                },
                title: RichText(
                  text: TextSpan(
                    style: NeferTypography.bodyMedium,
                    children: [
                      const TextSpan(text: 'I agree to the '),
                      TextSpan(
                        text: 'Terms & Conditions',
                        style: TextStyle(
                          color: NeferColors.pharaohGold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      const TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(
                          color: NeferColors.pharaohGold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
                activeColor: NeferColors.pharaohGold,
                contentPadding: EdgeInsets.zero,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(BuildContext context, CheckoutData checkout) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back Button
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _goToPreviousStep,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: NeferColors.pharaohGold),
                ),
                child: const Text('Back'),
              ),
            ),
          
          if (_currentStep > 0) const SizedBox(width: 16),
          
          // Next/Place Order Button
          Expanded(
            flex: _currentStep > 0 ? 1 : 2,
            child: ElevatedButton(
              onPressed: _getNextButtonAction(checkout),
              style: ElevatedButton.styleFrom(
                backgroundColor: NeferColors.pharaohGold,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _getNextButtonText(),
                style: NeferTypography.buttonText.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getNextButtonText() {
    switch (_currentStep) {
      case 0:
        return 'Continue to Payment';
      case 1:
        return 'Review Order';
      case 2:
        return 'Place Order';
      default:
        return 'Next';
    }
  }

  VoidCallback? _getNextButtonAction(CheckoutData checkout) {
    switch (_currentStep) {
      case 0:
        return checkout.selectedAddress != null ? _goToNextStep : null;
      case 1:
        return checkout.selectedPaymentMethod != null ? _goToNextStep : null;
      case 2:
        return ref.watch(acceptedTermsProvider) ? () => _placeOrder(checkout) : null;
      default:
        return null;
    }
  }

  // Navigation Methods
  void _goToStep(int step) {
    setState(() {
      _currentStep = step;
    });
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _goToNextStep() {
    if (_currentStep < _totalSteps - 1) {
      _goToStep(_currentStep + 1);
    }
  }

  void _goToPreviousStep() {
    if (_currentStep > 0) {
      _goToStep(_currentStep - 1);
    }
  }

  void _handleBackPress() {
    if (_currentStep > 0) {
      _goToPreviousStep();
    } else {
      context.pop();
    }
  }

  // Event Handlers
  void _showAddAddressDialog(BuildContext context) {
    // Implement add address dialog
  }

  void _showEditAddressDialog(BuildContext context, ShippingAddress address) {
    // Implement edit address dialog
  }

  void _showAddCardDialog(BuildContext context) {
    // Implement add card dialog
  }

  void _placeOrder(CheckoutData checkout) async {
    try {
      final order = await ref.read(checkoutControllerProvider.notifier)
          .placeOrder();
      
      if (mounted) {
        // Navigate to order confirmation
        context.goNamed(RouteNames.orderConfirmation, 
          pathParameters: {'orderId': order.id});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to place order: $e'),
            backgroundColor: NeferColors.error,
          ),
        );
      }
    }
  }
}

// Provider for terms acceptance
final acceptedTermsProvider = StateProvider<bool>((ref) => false);
