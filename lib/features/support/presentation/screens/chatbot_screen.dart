import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/providers/providers.dart';
import '../../../../generated/l10n.dart';
import '../widgets/chat_message_bubble.dart';
import '../widgets/chat_input_field.dart';
import '../widgets/quick_reply_buttons.dart';
import '../widgets/typing_indicator.dart';
import '../controllers/chatbot_controller.dart';

/// Chatbot Screen with Egyptian-style UI and speech bubbles
/// 
/// Features:
/// - AI-powered chatbot with Egyptian personality
/// - Pharaonic-themed chat bubbles
/// - Quick reply buttons for common questions
/// - Voice message support
/// - Order assistance and product recommendations
/// - Multi-language support (Arabic & English)
class ChatbotScreen extends ConsumerStatefulWidget {
  const ChatbotScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends ConsumerState<ChatbotScreen>
    with TickerProviderStateMixin {
  late ScrollController _scrollController;
  late TextEditingController _messageController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  bool _isAtBottom = true;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeChat();
  }

  void _initializeControllers() {
    _scrollController = ScrollController();
    _messageController = TextEditingController();
    
    _scrollController.addListener(_onScroll);

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    _fadeController.forward();
  }

  void _initializeChat() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatbotControllerProvider.notifier).initializeChat();
    });
  }

  void _onScroll() {
    final isAtBottom = _scrollController.offset >= 
        _scrollController.position.maxScrollExtent - 100;
    
    if (isAtBottom != _isAtBottom) {
      setState(() {
        _isAtBottom = isAtBottom;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final chatState = ref.watch(chatbotControllerProvider);
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: _buildAppBar(context, l10n),
      body: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: _buildChatInterface(context, l10n, chatState),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, AppLocalizations? l10n) {
    return AppBar(
      title: Row(
        children: [
          // Chatbot Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: NeferColors.pharaohGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: NeferColors.goldShadow,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          
          // Chatbot Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nefer Assistant',
                  style: NeferTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'مساعد نفِر',
                  style: NeferTypography.bodySmall.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          
          // Online Status Indicator
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: NeferColors.success,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: const Icon(Icons.arrow_back),
      ),
      actions: [
        IconButton(
          onPressed: () => _showChatOptions(context),
          icon: const Icon(Icons.more_vert),
        ),
      ],
    );
  }

  Widget _buildChatInterface(
    BuildContext context,
    AppLocalizations? l10n,
    ChatState chatState,
  ) {
    return Column(
      children: [
        // Chat Messages
        Expanded(
          child: _buildMessagesList(chatState),
        ),
        
        // Quick Replies (if available)
        if (chatState.quickReplies.isNotEmpty)
          QuickReplyButtons(
            quickReplies: chatState.quickReplies,
            onQuickReply: _sendQuickReply,
          ),
        
        // Chat Input
        _buildChatInput(context, chatState),
      ],
    );
  }

  Widget _buildMessagesList(ChatState chatState) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/chat_background.png'),
          fit: BoxFit.cover,
          opacity: 0.05,
        ),
      ),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: chatState.messages.length + (chatState.isTyping ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == chatState.messages.length && chatState.isTyping) {
            return const TypingIndicator();
          }
          
          final message = chatState.messages[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ChatMessageBubble(
              message: message,
              onMessageTap: () => _handleMessageTap(message),
              onQuickActionTap: (action) => _handleQuickAction(action),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChatInput(BuildContext context, ChatState chatState) {
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
      child: Column(
        children: [
          // Scroll to bottom button
          if (!_isAtBottom)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Center(
                child: GestureDetector(
                  onTap: _scrollToBottom,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: NeferColors.pharaohGold,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Scroll to bottom',
                          style: NeferTypography.bodySmall.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          
          // Input field
          ChatInputField(
            controller: _messageController,
            onSendMessage: _sendMessage,
            onVoiceMessage: _sendVoiceMessage,
            onAttachment: _sendAttachment,
            isEnabled: !chatState.isLoading,
          ),
        ],
      ),
    );
  }

  // Event Handlers
  void _sendMessage(String message) {
    if (message.trim().isEmpty) return;
    
    ref.read(chatbotControllerProvider.notifier).sendMessage(message.trim());
    _messageController.clear();
    _scrollToBottom();
  }

  void _sendQuickReply(String reply) {
    ref.read(chatbotControllerProvider.notifier).sendQuickReply(reply);
    _scrollToBottom();
  }

  void _sendVoiceMessage() {
    // Implement voice message functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Voice messages coming soon!'),
        backgroundColor: NeferColors.info,
      ),
    );
  }

  void _sendAttachment() {
    // Implement attachment functionality
    _showAttachmentOptions(context);
  }

  void _handleMessageTap(ChatMessage message) {
    if (message.type == MessageType.product) {
      // Navigate to product details
      context.pushNamed(RouteNames.productDetails, 
        pathParameters: {'id': message.productId!});
    } else if (message.type == MessageType.order) {
      // Navigate to order details
      context.pushNamed(RouteNames.orderDetails, 
        pathParameters: {'orderId': message.orderId!});
    }
  }

  void _handleQuickAction(String action) {
    switch (action) {
      case 'track_order':
        context.pushNamed(RouteNames.orders);
        break;
      case 'view_cart':
        context.pushNamed(RouteNames.cart);
        break;
      case 'browse_products':
        context.pushNamed(RouteNames.products);
        break;
      case 'contact_support':
        context.pushNamed(RouteNames.contact);
        break;
      default:
        _sendQuickReply(action);
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _showChatOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            
            ListTile(
              leading: const Icon(Icons.refresh, color: NeferColors.pharaohGold),
              title: const Text('Clear Chat'),
              onTap: () {
                Navigator.pop(context);
                _clearChat();
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.language, color: NeferColors.pharaohGold),
              title: const Text('Change Language'),
              onTap: () {
                Navigator.pop(context);
                _changeLanguage();
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.help, color: NeferColors.pharaohGold),
              title: const Text('Help & FAQ'),
              onTap: () {
                Navigator.pop(context);
                context.pushNamed(RouteNames.faq);
              },
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showAttachmentOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            
            ListTile(
              leading: const Icon(Icons.photo, color: NeferColors.pharaohGold),
              title: const Text('Photo'),
              onTap: () {
                Navigator.pop(context);
                // Implement photo selection
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.receipt, color: NeferColors.pharaohGold),
              title: const Text('Order Screenshot'),
              onTap: () {
                Navigator.pop(context);
                // Implement order screenshot
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.location_on, color: NeferColors.pharaohGold),
              title: const Text('Location'),
              onTap: () {
                Navigator.pop(context);
                // Implement location sharing
              },
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _clearChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Chat'),
        content: const Text('Are you sure you want to clear the chat history?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(chatbotControllerProvider.notifier).clearChat();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: NeferColors.error,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _changeLanguage() {
    final currentLocale = ref.read(localeProvider);
    final newLocale = currentLocale.languageCode == 'en' 
        ? const Locale('ar') 
        : const Locale('en');
    
    ref.read(localeProvider.notifier).state = newLocale;
    
    // Send language change message to chatbot
    ref.read(chatbotControllerProvider.notifier)
        .changeLanguage(newLocale.languageCode);
  }
}

/// Chat message model
class ChatMessage {
  final String id;
  final String content;
  final MessageType type;
  final MessageSender sender;
  final DateTime timestamp;
  final String? productId;
  final String? orderId;
  final List<String> quickActions;
  final Map<String, dynamic>? metadata;

  const ChatMessage({
    required this.id,
    required this.content,
    required this.type,
    required this.sender,
    required this.timestamp,
    this.productId,
    this.orderId,
    this.quickActions = const [],
    this.metadata,
  });
}

/// Message types
enum MessageType {
  text,
  product,
  order,
  image,
  voice,
  location,
  quickReply,
}

/// Message sender
enum MessageSender {
  user,
  bot,
  system,
}

/// Chat state model
class ChatState {
  final List<ChatMessage> messages;
  final List<String> quickReplies;
  final bool isLoading;
  final bool isTyping;
  final String? error;

  const ChatState({
    required this.messages,
    required this.quickReplies,
    required this.isLoading,
    required this.isTyping,
    this.error,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    List<String>? quickReplies,
    bool? isLoading,
    bool? isTyping,
    String? error,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      quickReplies: quickReplies ?? this.quickReplies,
      isLoading: isLoading ?? this.isLoading,
      isTyping: isTyping ?? this.isTyping,
      error: error ?? this.error,
    );
  }
}
