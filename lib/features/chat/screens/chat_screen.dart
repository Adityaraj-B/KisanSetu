import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/localization/language_provider.dart';
import '../../../core/providers/farmer_provider.dart';
import '../../../core/providers/chat_provider.dart';
import '../../../core/chatbot/chatbot_response.dart';
import '../../../core/chatbot/chatbot_intents.dart';
import '../../schemes/screens/schemes_screen.dart';
import '../../insurance/screens/insurance_screen.dart';
import '../../finance/screens/crop_finance_screen.dart';
import '../../weather/screens/weather_screen.dart';

/// Premium AI Chat Screen - Matches KisanSetu glass/gradient aesthetic
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  late AnimationController _dotController;

  @override
  void initState() {
    super.initState();
    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    // Initialize session after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().initSession();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _dotController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    _controller.clear();

    final farmer = context.read<FarmerProvider>();
    final langProvider = context.read<LanguageProvider>();
    final chatProvider = context.read<ChatProvider>();

    // Detect language switch intent before sending
    final intent = IntentDetector.detectIntent(text);
    if (intent == ChatIntent.languageSwitchHindi) {
      langProvider.setLocale('hi');
    } else if (intent == ChatIntent.languageSwitchEnglish) {
      langProvider.setLocale('en');
    } else if (intent == ChatIntent.languageSwitchMarathi) {
      langProvider.setLocale('mr');
    }

    // Use the (possibly updated) language code
    final effectiveLang = langProvider.locale.languageCode;

    chatProvider
        .sendMessage(text, profile: farmer.profile, languageCode: effectiveLang)
        .then((_) => _scrollToBottom());

    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final langCode = context.watch<LanguageProvider>().locale.languageCode;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D3B12), Color(0xFF1A5C22), Color(0xFFF2FCF3)],
            stops: [0.0, 0.35, 1.0],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // ── App Bar ──
              _buildAppBar(langCode, l10n),
              // ── Messages ──
              Expanded(
                child: Consumer<ChatProvider>(
                  builder: (context, chat, _) {
                    if (chat.messages.isEmpty && !chat.isLoading) {
                      return _buildEmptyState(langCode);
                    }
                    return _buildMessageList(chat, langCode);
                  },
                ),
              ),
              // ── Input Bar ──
              _buildInputBar(langCode),
            ],
          ),
        ),
      ),
    );
  }

  // ─── App Bar ──────────────────────────────────────────────────────────────────

  Widget _buildAppBar(String langCode, AppLocalizations? l10n) {
    final title = langCode == 'hi'
        ? 'किसान मित्र AI'
        : langCode == 'mr'
            ? 'किसान मित्र AI'
            : 'Kisan Mitra AI';
    final subtitle = langCode == 'hi'
        ? 'आपका कृषि सहायक'
        : langCode == 'mr'
            ? 'आपला कृषी सहाय्यक'
            : 'Your farming assistant';

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withValues(alpha: 0.15),
              ),
            ),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF43A047), Color(0xFF66BB6A)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF43A047).withValues(alpha: 0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.smart_toy_rounded,
                    color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: const Color(0xFF76FF03),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF76FF03)
                                    .withValues(alpha: 0.5),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Clear chat button
              Consumer<ChatProvider>(
                builder: (context, chat, _) {
                  if (!chat.hasMessages) return const SizedBox.shrink();
                  return IconButton(
                    icon: Icon(Icons.refresh_rounded,
                        color: Colors.white.withValues(alpha: 0.7)),
                    tooltip: langCode == 'hi' ? 'नई चैट' : 'New chat',
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      chat.clearChat();
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Empty State ──────────────────────────────────────────────────────────────

  Widget _buildEmptyState(String langCode) {
    final greeting = langCode == 'hi'
        ? 'नमस्ते! 🙏\nमैं आपका कृषि सहायक हूं'
        : langCode == 'mr'
            ? 'नमस्कार! 🙏\nमी आपला कृषी सहाय्यक आहे'
            : 'Namaste! 🙏\nI\'m your farming assistant';

    final helpText = langCode == 'hi'
        ? 'मुझसे सरकारी योजनाओं, बीमा, ऋण या खेती से जुड़ा कुछ भी पूछें।'
        : langCode == 'mr'
            ? 'मला सरकारी योजना, विमा, कर्ज किंवा शेतीबद्दल काहीही विचारा.'
            : 'Ask me about government schemes, insurance, loans, or anything farming-related.';

    final suggestions = _getSuggestionChips(langCode);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          // Bot avatar
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF43A047), Color(0xFF2E7D32)],
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2E7D32).withValues(alpha: 0.35),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(Icons.smart_toy_rounded,
                color: Colors.white, size: 44),
          ),
          const SizedBox(height: 24),
          Text(
            greeting,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              helpText,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.7),
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 36),
          // Suggestion chips
          Text(
            langCode == 'hi'
                ? 'सुझाव:'
                : langCode == 'mr'
                    ? 'सूचना:'
                    : 'Suggestions:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 14),
          ...suggestions.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _SuggestionChip(
                  text: s,
                  onTap: () => _sendMessage(s),
                ),
              )),
        ],
      ),
    );
  }

  List<String> _getSuggestionChips(String langCode) {
    if (langCode == 'hi') {
      return [
        'मेरी योजनाएं दिखाओ',
        'PM-KISAN के बारे में बताओ',
        'लोन विकल्प बताओ',
        'बीमा बताओ',
        'खेती सुझाव',
        'मेरी प्रोफ़ाइल',
      ];
    }
    if (langCode == 'mr') {
      return [
        'माझ्या योजना दाखवा',
        'PM-KISAN बद्दल सांगा',
        'कर्ज पर्याय सांगा',
        'विम्याबद्दल सांगा',
        'शेती सल्ला',
        'माझी प्रोफाइल',
      ];
    }
    return [
      'Show my schemes',
      'Tell me about PM-KISAN',
      'Loan options',
      'Insurance options',
      'Farming tips',
      'My profile',
    ];
  }

  // ─── Message List ─────────────────────────────────────────────────────────────

  Widget _buildMessageList(ChatProvider chat, String langCode) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      itemCount: chat.messages.length + (chat.isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        // Typing indicator at the end
        if (index == chat.messages.length) {
          return _buildTypingIndicator(chat.isWakingUp, langCode);
        }
        final msg = chat.messages[index];
        return _MessageBubble(
          message: msg,
          dotController: _dotController,
        );
      },
    );
  }

  // ─── Typing Indicator ─────────────────────────────────────────────────────────

  Widget _buildTypingIndicator(bool isWakingUp, String langCode) {
    final wakingText = langCode == 'hi'
        ? 'सर्वर जाग रहा है...'
        : langCode == 'mr'
            ? 'सर्व्हर जागे होत आहे...'
            : 'Waking up server...';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16, right: 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomRight: Radius.circular(20),
              bottomLeft: Radius.circular(6),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.85),
                      Colors.white.withValues(alpha: 0.65),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                    bottomLeft: Radius.circular(6),
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
                child: _AnimatedDots(controller: _dotController),
              ),
            ),
          ),
          if (isWakingUp) ...[
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                wakingText,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.6),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─── Input Bar ────────────────────────────────────────────────────────────────

  Widget _buildInputBar(String langCode) {
    final hint = langCode == 'hi'
        ? 'अपना संदेश लिखें...'
        : langCode == 'mr'
            ? 'तुमचा संदेश लिहा...'
            : 'Type your message...';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F7F6),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFF2E7D32).withValues(alpha: 0.15),
                    ),
                  ),
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: 4,
                    minLines: 1,
                    style: const TextStyle(fontSize: 15),
                    decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                    ),
                    onSubmitted: _sendMessage,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Consumer<ChatProvider>(
                builder: (context, chat, _) {
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _sendMessage(_controller.text);
                    },
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: chat.isLoading
                              ? [Colors.grey[400]!, Colors.grey[500]!]
                              : const [Color(0xFF2E7D32), Color(0xFF43A047)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: chat.isLoading
                            ? []
                            : [
                                BoxShadow(
                                  color: const Color(0xFF2E7D32)
                                      .withValues(alpha: 0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                      ),
                      child: Icon(
                        chat.isLoading
                            ? Icons.hourglass_top_rounded
                            : Icons.send_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Message Bubble ───────────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final AnimationController dotController;

  const _MessageBubble({
    required this.message,
    required this.dotController,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Padding(
      padding: EdgeInsets.only(
        bottom: 14,
        left: isUser ? 50 : 0,
        right: isUser ? 0 : 50,
      ),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Sender label
          Padding(
            padding: const EdgeInsets.only(bottom: 4, left: 4, right: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isUser) ...[
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF43A047), Color(0xFF2E7D32)],
                      ),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: const Icon(Icons.smart_toy_rounded,
                        color: Colors.white, size: 13),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Kisan Mitra',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ],
                if (isUser)
                  Text(
                    'You',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
              ],
            ),
          ),

          // Bubble
          isUser ? _buildUserBubble() : _buildBotBubble(),

          // Action buttons for bot messages
          if (!isUser && message.response != null)
            _buildActionButtons(context, message.response!),

          // Timestamp
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
            child: Text(
              _formatTime(message.timestamp),
              style: TextStyle(
                fontSize: 10,
                color: Colors.white.withValues(alpha: 0.4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, ChatbotResponse response) {
    final langCode = context.read<LanguageProvider>().locale.languageCode;
    final buttons = <Widget>[];

    if (response.showSchemesButton) {
      buttons.add(_ActionChipButton(
        icon: Icons.list_alt_rounded,
        label: langCode == 'hi' ? 'योजनाएं देखें' : langCode == 'mr' ? 'योजना पहा' : 'View Schemes',
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SchemesScreen())),
      ));
    }
    if (response.showInsuranceButton) {
      buttons.add(_ActionChipButton(
        icon: Icons.shield_rounded,
        label: langCode == 'hi' ? 'बीमा देखें' : langCode == 'mr' ? 'विमा पहा' : 'View Insurance',
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InsuranceScreen())),
      ));
    }
    if (response.showFinanceButton) {
      buttons.add(_ActionChipButton(
        icon: Icons.account_balance_rounded,
        label: langCode == 'hi' ? 'वित्त देखें' : langCode == 'mr' ? 'वित्त पहा' : 'View Finance',
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CropFinanceScreen())),
      ));
    }
    if (response.showWeatherButton) {
      buttons.add(_ActionChipButton(
        icon: Icons.wb_sunny_rounded,
        label: langCode == 'hi' ? 'मौसम देखें' : langCode == 'mr' ? 'हवामान पहा' : 'View Weather',
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WeatherScreen())),
      ));
    }
    if (response.showProfileButton) {
      buttons.add(_ActionChipButton(
        icon: Icons.person_rounded,
        label: langCode == 'hi' ? 'प्रोफ़ाइल' : langCode == 'mr' ? 'प्रोफाइल' : 'Edit Profile',
        onTap: () => Navigator.pop(context),
      ));
    }

    if (buttons.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 6,
        children: buttons,
      ),
    );
  }

  Widget _buildUserBubble() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2E7D32), Color(0xFF43A047)],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(6),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D32).withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        message.text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          height: 1.45,
        ),
      ),
    );
  }

  Widget _buildBotBubble() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
        bottomRight: Radius.circular(20),
        bottomLeft: Radius.circular(6),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.88),
                Colors.white.withValues(alpha: 0.68),
              ],
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomRight: Radius.circular(20),
              bottomLeft: Radius.circular(6),
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.6),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SelectableText(
            message.text,
            style: const TextStyle(
              color: Color(0xFF1C1B1F),
              fontSize: 15,
              height: 1.45,
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

// ─── Action Chip Button ───────────────────────────────────────────────────────

class _ActionChipButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionChipButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF2E7D32).withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: const Color(0xFF2E7D32)),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2E7D32),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Suggestion Chip ──────────────────────────────────────────────────────────

class _SuggestionChip extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _SuggestionChip({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.18),
                  Colors.white.withValues(alpha: 0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.chat_bubble_outline_rounded,
                    size: 16,
                    color: Colors.white.withValues(alpha: 0.7)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: Colors.white.withValues(alpha: 0.4)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Animated Dots ────────────────────────────────────────────────────────────

class _AnimatedDots extends StatelessWidget {
  final AnimationController controller;

  const _AnimatedDots({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final delay = i * 0.25;
            final value = ((controller.value - delay) % 1.0).clamp(0.0, 1.0);
            final scale = 0.5 + 0.5 * _bounceCurve(value);
            final opacity = 0.3 + 0.7 * _bounceCurve(value);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32).withValues(alpha: opacity),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  double _bounceCurve(double t) {
    if (t < 0.5) return 4 * t * t * t;
    return 1 - ((-2 * t + 2) * (-2 * t + 2) * (-2 * t + 2)) / 2;
  }
}

