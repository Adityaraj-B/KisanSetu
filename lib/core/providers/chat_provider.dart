import 'package:flutter/foundation.dart';
import '../chatbot/chatbot_service.dart';
import '../chatbot/chatbot_response.dart';
import '../../data/models/farmer_profile.dart';

/// Chat Message Model
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final ChatbotResponse? response;

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
    this.response,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// Chat Provider - State management for the chatbot screen
/// Uses the local intelligent chatbot service directly
class ChatProvider extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  // ==================== Getters ====================
  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  bool get isWakingUp => false; // No API, never waking up
  String? get sessionId => null;
  String? get error => null;
  bool get hasMessages => _messages.isNotEmpty;

  // ==================== Session ====================

  /// Initialize — no-op since we use local chatbot
  Future<void> initSession() async {
    // Nothing to initialize for local chatbot
  }

  // ==================== Messages ====================

  /// Send a message and get a response from the local chatbot
  Future<void> sendMessage(
    String text, {
    required FarmerProfile profile,
    required String languageCode,
  }) async {
    if (text.trim().isEmpty) return;

    // Add user message
    _messages.add(ChatMessage(text: text, isUser: true));
    _isLoading = true;
    notifyListeners();

    // Small delay to feel natural
    await Future.delayed(const Duration(milliseconds: 250));

    // Get response from local chatbot
    final response = ChatbotService.instance.handleMessage(
      text,
      profile,
      languageCode: languageCode,
    );

    final responseText = response.getLocalizedMessage(languageCode);

    // Add bot response with full ChatbotResponse object
    _messages.add(ChatMessage(
      text: responseText,
      isUser: false,
      response: response,
    ));
    _isLoading = false;
    notifyListeners();
  }

  /// Get the last bot response (for action buttons, etc.)
  ChatbotResponse? get lastBotResponse {
    for (int i = _messages.length - 1; i >= 0; i--) {
      if (!_messages[i].isUser && _messages[i].response != null) {
        return _messages[i].response;
      }
    }
    return null;
  }

  /// Clear all messages and reset state
  void clearChat() {
    _messages.clear();
    _isLoading = false;
    notifyListeners();
  }
}

