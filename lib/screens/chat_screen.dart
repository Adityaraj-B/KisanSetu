import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/localization/app_localizations.dart';
import '../core/localization/language_provider.dart';
import '../core/providers/farmer_provider.dart';
import '../core/theme/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../core/chatbot/chatbot_service.dart';
import '../core/chatbot/chatbot_response.dart';
import '../core/chatbot/chatbot_intents.dart';
import '../core/voice/speech_service.dart';
import '../core/voice/tts_service.dart';
import '../features/schemes/screens/schemes_screen.dart';
import '../features/insurance/screens/insurance_screen.dart';
import '../features/finance/screens/crop_finance_screen.dart';
import '../features/weather/screens/weather_screen.dart';

/// Chat Message Model - Represents a single message in chat
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final ChatbotResponse? response; // For bot messages with actions

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
    this.response,
  }) : timestamp = timestamp ?? DateTime.now();
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  final FocusNode _focusNode = FocusNode();

  bool _isListening = false;
  bool _isSpeechAvailable = false;
  bool _ttsEnabled = true;

  @override
  void initState() {
    super.initState();
    _initVoiceServices();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _addWelcomeMessage();
    });
  }

  Future<void> _initVoiceServices() async {
    final speechAvailable = await SpeechService.instance.initialize();
    await TtsService.instance.initialize();

    if (mounted) {
      setState(() {
        _isSpeechAvailable = speechAvailable;
      });
    }
  }

  void _updateVoiceLanguage(String languageCode) {
    SpeechService.instance.setLanguage(languageCode);
    TtsService.instance.setLanguage(languageCode);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    SpeechService.instance.dispose();
    TtsService.instance.dispose();
    super.dispose();
  }

  void _addWelcomeMessage() {
    final welcomeResponse = ChatbotService.instance.getWelcomeMessage();
    final languageCode = context.read<LanguageProvider>().locale.languageCode;

    setState(() {
      _messages.add(ChatMessage(
        text: welcomeResponse.getLocalizedMessage(languageCode),
        isUser: false,
        response: welcomeResponse,
      ));
    });
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    final farmerProvider = context.read<FarmerProvider>();
    final languageProvider = context.read<LanguageProvider>();
    final languageCode = languageProvider.locale.languageCode;

    _updateVoiceLanguage(languageCode);

    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
      ));
    });

    _messageController.clear();

    final response = ChatbotService.instance.handleMessage(
      text,
      farmerProvider.profile,
      languageCode: languageCode,
    );

    final intent = IntentDetector.detectIntent(text);
    if (intent == ChatIntent.languageSwitchHindi) {
      languageProvider.setLocale('hi');
      _updateVoiceLanguage('hi');
    } else if (intent == ChatIntent.languageSwitchEnglish) {
      languageProvider.setLocale('en');
      _updateVoiceLanguage('en');
    } else if (intent == ChatIntent.languageSwitchMarathi) {
      languageProvider.setLocale('mr');
      _updateVoiceLanguage('mr');
    }

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        final currentLang = languageProvider.locale.languageCode;
        final responseText = response.getLocalizedMessage(currentLang);

        setState(() {
          _messages.add(ChatMessage(
            text: responseText,
            isUser: false,
            response: response,
          ));
        });
        _scrollToBottom();

        if (_ttsEnabled) {
          _speakResponse(responseText);
        }
      }
    });

    _scrollToBottom();
  }

  Future<void> _speakResponse(String text) async {
    final cleanText = text
        .replaceAll(RegExp(r'[•📋🛡️💡🌾]'), '')
        .replaceAll(RegExp(r'\*\*'), '')
        .replaceAll('\n\n', '. ')
        .replaceAll('\n', '. ');
    await TtsService.instance.speak(cleanText);
  }

  void _toggleTts() {
    setState(() {
      _ttsEnabled = !_ttsEnabled;
    });
    if (!_ttsEnabled) {
      TtsService.instance.stop();
    }
  }

  Future<void> _startListening() async {
    if (_isListening) {
      await _stopListening();
      return;
    }

    final languageCode = context.read<LanguageProvider>().locale.languageCode;
    _updateVoiceLanguage(languageCode);

    setState(() {
      _isListening = true;
    });

    await SpeechService.instance.startListening(
      onResult: (recognizedText) {
        if (recognizedText.isNotEmpty) {
          _sendMessage(recognizedText);
        }
      },
      onDone: () {
        if (mounted) {
          setState(() {
            _isListening = false;
          });
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            _isListening = false;
          });
          _showVoiceError(error);
        }
      },
    );
  }

  Future<void> _stopListening() async {
    await SpeechService.instance.stopListening();
    setState(() {
      _isListening = false;
    });
  }

  Future<void> _handleMicPress() async {
    if (_isListening) {
      await _stopListening();
      return;
    }

    if (!_isSpeechAvailable) {
      final initialized = await SpeechService.instance.initialize();
      if (mounted) {
        setState(() {
          _isSpeechAvailable = initialized;
        });
      }
      if (!initialized) {
        _showVoiceNotSupported();
        return;
      }
    }

    await _startListening();
  }

  void _showVoiceNotSupported() {
    final languageCode = context.read<LanguageProvider>().locale.languageCode;
    final message = languageCode == 'hi'
        ? 'वॉयस इनपुट इस डिवाइस पर उपलब्ध नहीं है। कृपया टाइप करें।'
        : (languageCode == 'mr' ? 'व्हॉइस इनपुट या डिव्हाइसवर उपलब्ध नाही. कृपया टाइप करा.' : 'Voice input not available on this device. Please type instead.');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        backgroundColor: AppColors.warning,
      ),
    );
  }

  void _showVoiceError(String error) {
    final languageCode = context.read<LanguageProvider>().locale.languageCode;
    final message = languageCode == 'hi'
        ? 'वॉयस पहचान विफल। कृपया टाइप करें।'
        : (languageCode == 'mr' ? 'व्हॉइस ओळख अयशस्वी. कृपया टाइप करा.' : 'Voice recognition failed. Please type instead.');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.warning,
      ),
    );
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

  void _navigateToSchemes() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SchemesScreen()),
    );
  }

  void _navigateToInsurance() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const InsuranceScreen()),
    );
  }

  void _navigateToFinance() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CropFinanceScreen()),
    );
  }

  void _navigateToWeather() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const WeatherScreen()),
    );
  }

  void _navigateToProfile() {
    // Pop back and navigate to profile - use index 4 in bottom nav
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageCode = context.watch<LanguageProvider>().locale.languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.chatAssistant),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_ttsEnabled ? Icons.volume_up : Icons.volume_off),
            onPressed: _toggleTts,
            tooltip: _ttsEnabled
                ? (languageCode == 'hi' ? 'आवाज़ बंद करें' : (languageCode == 'mr' ? 'आवाज बंद करा' : 'Mute voice'))
                : (languageCode == 'hi' ? 'आवाज़ चालू करें' : (languageCode == 'mr' ? 'आवाज चालू करा' : 'Enable voice')),
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat messages list
          Expanded(
            child: Container(
              color: AppColors.backgroundPrimary,
              child: _messages.isEmpty
                  ? _buildEmptyState(l10n)
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(AppConstants.spacingM),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        return _buildMessageBubble(
                          _messages[index],
                          l10n,
                          languageCode,
                        );
                      },
                    ),
            ),
          ),

          // Quick replies section
          _buildQuickReplies(languageCode),

          // Message input area
          _buildInputArea(l10n),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppConstants.spacingM),
          Text(
            l10n.askQuestions,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(
    ChatMessage message,
    AppLocalizations l10n,
    String languageCode,
  ) {
    final isUser = message.isUser;

    return Padding(
      padding: EdgeInsets.only(
        bottom: AppConstants.spacingM,
        left: isUser ? 48 : 0,
        right: isUser ? 0 : 48,
      ),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Avatar and name row
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isUser) ...[
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: AppColors.primaryGreen,
                    child: const Icon(
                      Icons.smart_toy,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'KisanSetu',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                if (isUser) ...[
                  Text(
                    languageCode == 'hi' ? 'आप' : (languageCode == 'mr' ? 'तुम्ही' : 'You'),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 6),
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: AppColors.earthBrown,
                    child: const Icon(
                      Icons.person,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Message bubble
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingM,
              vertical: AppConstants.spacingS,
            ),
            decoration: BoxDecoration(
              color: isUser ? AppColors.primaryGreen : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(AppConstants.radiusL),
                topRight: const Radius.circular(AppConstants.radiusL),
                bottomLeft: Radius.circular(isUser ? AppConstants.radiusL : 4),
                bottomRight: Radius.circular(isUser ? 4 : AppConstants.radiusL),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              message.text,
              style: TextStyle(
                color: isUser ? Colors.white : AppColors.textPrimary,
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ),

          // Action buttons for bot messages
          if (!isUser && message.response != null)
            _buildActionButtons(message.response!, l10n),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ChatbotResponse response, AppLocalizations l10n) {
    final buttons = <Widget>[];
    final languageCode = context.read<LanguageProvider>().locale.languageCode;

    if (response.showSchemesButton) {
      buttons.add(
        _buildActionButton(
          icon: Icons.list_alt,
          label: l10n.chatbotViewSchemes,
          onPressed: _navigateToSchemes,
        ),
      );
    }

    if (response.showInsuranceButton) {
      buttons.add(
        _buildActionButton(
          icon: Icons.security,
          label: l10n.chatbotViewInsurance,
          onPressed: _navigateToInsurance,
        ),
      );
    }

    if (response.showFinanceButton) {
      buttons.add(
        _buildActionButton(
          icon: Icons.account_balance,
          label: languageCode == 'hi' ? 'वित्त देखें' : (languageCode == 'mr' ? 'वित्त पहा' : 'View Finance'),
          onPressed: _navigateToFinance,
        ),
      );
    }

    if (response.showWeatherButton) {
      buttons.add(
        _buildActionButton(
          icon: Icons.wb_sunny,
          label: languageCode == 'hi' ? 'मौसम देखें' : (languageCode == 'mr' ? 'हवामान पहा' : 'View Weather'),
          onPressed: _navigateToWeather,
        ),
      );
    }

    if (response.showProfileButton) {
      buttons.add(
        _buildActionButton(
          icon: Icons.person,
          label: languageCode == 'hi' ? 'प्रोफ़ाइल संपादित करें' : (languageCode == 'mr' ? 'प्रोफाइल संपादित करा' : 'Edit Profile'),
          onPressed: _navigateToProfile,
        ),
      );
    }

    if (buttons.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: AppConstants.spacingS),
      child: Wrap(
        spacing: AppConstants.spacingS,
        runSpacing: AppConstants.spacingXS,
        children: buttons,
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryGreen,
        side: BorderSide(color: AppColors.primaryGreen.withValues(alpha: 0.5)),
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingS,
          vertical: AppConstants.spacingXS,
        ),
        textStyle: const TextStyle(fontSize: 13),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
        ),
      ),
    );
  }

  Widget _buildQuickReplies(String languageCode) {
    final quickReplies = ChatbotService.instance.getQuickReplies(languageCode);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingM,
        vertical: AppConstants.spacingS,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: AppColors.borderLight,
            width: 1,
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: quickReplies.map((reply) {
            return Padding(
              padding: const EdgeInsets.only(right: AppConstants.spacingS),
              child: ActionChip(
                label: Text(reply),
                onPressed: () => _sendMessage(reply),
                backgroundColor: AppColors.primaryGreenOverlay10,
                labelStyle: TextStyle(
                  color: AppColors.primaryGreen,
                  fontSize: 13,
                ),
                side: BorderSide.none,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacingS,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildInputArea(AppLocalizations l10n) {
    final languageCode = context.watch<LanguageProvider>().locale.languageCode;

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Container(
              margin: const EdgeInsets.only(right: AppConstants.spacingS),
              decoration: BoxDecoration(
                color: _isListening
                    ? AppColors.warmOrange
                    : AppColors.backgroundSecondary,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: _handleMicPress,
                icon: Icon(
                  _isListening ? Icons.mic : Icons.mic_none,
                  color: _isListening
                      ? Colors.white
                      : AppColors.primaryGreen,
                ),
                tooltip: _isListening
                    ? (languageCode == 'hi' ? 'सुन रहा है...' : (languageCode == 'mr' ? 'ऐकत आहे...' : 'Listening...'))
                    : (languageCode == 'hi' ? 'बोलें' : (languageCode == 'mr' ? 'बोला' : 'Speak')),
              ),
            ),
            Expanded(
              child: TextField(
                controller: _messageController,
                focusNode: _focusNode,
                textInputAction: TextInputAction.send,
                onSubmitted: _sendMessage,
                decoration: InputDecoration(
                  hintText: _isListening
                      ? (languageCode == 'hi' ? 'सुन रहा है...' : (languageCode == 'mr' ? 'ऐकत आहे...' : 'Listening...'))
                      : l10n.chatbotTypeMessage,
                  hintStyle: TextStyle(color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.backgroundSecondary,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spacingM,
                    vertical: AppConstants.spacingS,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusL),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusL),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusL),
                    borderSide: BorderSide(
                      color: AppColors.primaryGreen,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppConstants.spacingS),
            Container(
              decoration: BoxDecoration(
                color: AppColors.primaryGreen,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () => _sendMessage(_messageController.text),
                icon: const Icon(Icons.send_rounded),
                color: Colors.white,
                tooltip: l10n.chatbotSend,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
