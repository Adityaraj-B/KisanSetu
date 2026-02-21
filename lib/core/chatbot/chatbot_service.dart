import '../../data/models/farmer_profile.dart';
import '../services/eligibility_service.dart';
import 'chatbot_intents.dart';
import 'chatbot_response.dart';

/// Chatbot Service - Rule-based chatbot for farmer queries
/// Handles message processing, intent detection, and response generation
class ChatbotService {
  // Private constructor for singleton
  ChatbotService._();

  // Singleton instance
  static final ChatbotService _instance = ChatbotService._();

  /// Get singleton instance
  static ChatbotService get instance => _instance;

  /// Handle incoming user message
  /// Returns structured chatbot response based on intent detection
  ChatbotResponse handleMessage(String message, FarmerProfile profile, {String languageCode = 'en'}) {
    // Guard against empty messages
    if (message.trim().isEmpty) {
      return ChatbotResponse.unknown();
    }

    // Detect user intent
    final intent = IntentDetector.detectIntent(message);

    // Process based on intent
    switch (intent) {
      case ChatIntent.greeting:
        return ChatbotResponse.greeting();

      case ChatIntent.schemeCheck:
        return _handleSchemeCheck(profile, languageCode);

      case ChatIntent.insuranceCheck:
        return ChatbotResponse.insuranceInfo();

      case ChatIntent.help:
        return ChatbotResponse.help();

      case ChatIntent.thanks:
        return ChatbotResponse.thanks();

      case ChatIntent.languageSwitchHindi:
        return ChatbotResponse.languageSwitchHindi();

      case ChatIntent.languageSwitchEnglish:
        return ChatbotResponse.languageSwitchEnglish();

      case ChatIntent.languageSwitchMarathi:
        return ChatbotResponse.languageSwitchMarathi();

      case ChatIntent.unknown:
        return ChatbotResponse.unknown();
    }
  }

  /// Handle scheme eligibility check
  ChatbotResponse _handleSchemeCheck(FarmerProfile profile, String languageCode) {
    // Check if profile has minimum required data
    if (!profile.hasState) {
      return ChatbotResponse.profileIncomplete();
    }

    // Get eligible schemes from eligibility service
    final eligibleSchemes = EligibilityService.instance.getEligibleSchemes(profile);

    // Extract scheme names based on language
    final schemeNames = eligibleSchemes
        .map((scheme) => scheme.getLocalizedName(languageCode))
        .toList();

    return ChatbotResponse.schemeResult(
      count: eligibleSchemes.length,
      schemeNames: schemeNames,
      languageCode: languageCode,
    );
  }

  /// Get a welcome message for new chat sessions
  ChatbotResponse getWelcomeMessage() {
    return const ChatbotResponse(
      message: 'Namaste! 🙏 Welcome to KisanSetu Assistant.\n\nI can help you with:\n• Finding eligible government schemes\n• Information about crop insurance\n• General guidance\n\nHow can I assist you today?',
      messageHi: 'नमस्ते! 🙏 किसान सेतु सहायक में आपका स्वागत है।\n\nमैं आपकी इनमें मदद कर सकता हूं:\n• पात्र सरकारी योजनाएं खोजना\n• फसल बीमा की जानकारी\n• सामान्य मार्गदर्शन\n\nआज मैं आपकी कैसे सहायता कर सकता हूं?',
      messageMr: 'नमस्कार! 🙏 किसान सेतु सहाय्यकामध्ये आपले स्वागत आहे.\n\nमी तुम्हाला यामध्ये मदत करू शकतो:\n• पात्र सरकारी योजना शोधणे\n• पीक विम्याची माहिती\n• सामान्य मार्गदर्शन\n\nआज मी तुमची कशी मदत करू?',
      type: ResponseType.text,
    );
  }

  /// Get quick reply suggestions based on current context
  List<String> getQuickReplies(String languageCode) {
    if (languageCode == 'hi') {
      return [
        'मेरी योजनाएं दिखाओ',
        'बीमा के बारे में बताओ',
        'मदद',
      ];
    }
    if (languageCode == 'mr') {
      return [
        'माझ्या योजना दाखवा',
        'विम्याबद्दल सांगा',
        'मदत',
      ];
    }
    return [
      'Show my schemes',
      'Tell me about insurance',
      'Help',
    ];
  }
}
