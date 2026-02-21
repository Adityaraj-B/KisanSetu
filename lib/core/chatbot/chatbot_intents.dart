/// Chatbot Intents - Defines all possible user intents
/// Enum representing all chatbot intents
enum ChatIntent {
  schemeCheck,
  insuranceCheck,
  help,
  greeting,
  thanks,
  languageSwitchHindi,
  languageSwitchEnglish,
  languageSwitchMarathi,
  unknown,
}

/// Intent Detector - Maps user messages to intents using keyword matching
class IntentDetector {
  IntentDetector._();

  /// Keyword mappings for each intent (English and Hindi)
  static const Map<ChatIntent, List<String>> _intentKeywords = {
    ChatIntent.greeting: [
      // English
      'hello', 'hi', 'hey', 'good morning', 'good afternoon', 'good evening',
      'namaste', 'namaskar',
      // Hindi
      'नमस्ते', 'नमस्कार', 'हेलो', 'हाय', 'सुप्रभात', 'शुभ संध्या',
      // Marathi
      'नमस्कार', 'सुप्रभात', 'शुभ संध्याकाळ',
    ],
    ChatIntent.schemeCheck: [
      // English
      'scheme', 'schemes', 'yojna', 'yojana', 'support', 'eligible', 'eligibility',
      'government', 'sarkari', 'pm kisan', 'pm-kisan', 'credit card', 'kcc',
      'benefit', 'benefits', 'subsidy', 'help me find', 'what schemes',
      'which scheme', 'show schemes', 'my schemes', 'available schemes',
      // Hindi
      'योजना', 'योजनाएं', 'योजनाओं', 'सरकारी', 'पात्र', 'पात्रता', 'लाभ',
      'सब्सिडी', 'किसान', 'पीएम किसान', 'क्रेडिट कार्ड', 'कौन सी योजना',
      'मेरी योजना', 'उपलब्ध योजना', 'सहायता',
      // Marathi
      'योजना', 'सरकारी', 'पात्र', 'पात्रता', 'फायदे', 'अनुदान',
      'माझ्या योजना', 'उपलब्ध योजना',
    ],
    ChatIntent.insuranceCheck: [
      // English
      'insurance', 'bima', 'fasal bima', 'crop insurance', 'pmfby',
      'fasal suraksha', 'protect crop', 'crop protection', 'insure',
      'premium', 'claim', 'coverage',
      // Hindi
      'बीमा', 'फसल बीमा', 'फसल सुरक्षा', 'प्रीमियम', 'दावा', 'कवरेज',
      'पीएमएफबीवाई', 'फसल रक्षा',
      // Marathi
      'विमा', 'पीक विमा', 'पीक संरक्षण', 'प्रीमियम', 'दावा',
    ],
    ChatIntent.help: [
      // English
      'help', 'how to', 'how do', 'guide', 'explain', 'what is', 'tell me',
      'use app', 'using app', 'how does', 'assist', 'support',
      // Hindi
      'मदद', 'सहायता', 'कैसे', 'बताओ', 'बताइए', 'समझाओ', 'गाइड',
      'क्या है', 'कैसे करें', 'ऐप', 'उपयोग',
      // Marathi
      'मदत', 'सहाय्य', 'कसे', 'सांगा', 'समजावून सांगा', 'मार्गदर्शन',
      'काय आहे', 'कसे करावे', 'अॅप', 'वापर',
    ],
    ChatIntent.thanks: [
      // English
      'thank', 'thanks', 'thank you', 'धन्यवाद', 'shukriya', 'great', 'awesome',
      'helpful', 'nice', 'good',
      // Hindi
      'धन्यवाद', 'शुक्रिया', 'बहुत अच्छा', 'बढ़िया',
      // Marathi
      'धन्यवाद', 'आभारी', 'छान', 'खूप चांगले',
    ],
    ChatIntent.languageSwitchHindi: [
      'speak hindi', 'hindi mein', 'hindi me', 'hindi bolo', 'hindi में',
      'हिंदी में बोलो', 'हिंदी बोलो', 'switch to hindi', 'change to hindi',
    ],
    ChatIntent.languageSwitchEnglish: [
      'speak english', 'english mein', 'english me', 'english bolo', 'english में',
      'अंग्रेजी में बोलो', 'इंग्लिश बोलो', 'switch to english', 'change to english',
    ],
    ChatIntent.languageSwitchMarathi: [
      'speak marathi', 'marathi mein', 'marathi me', 'marathi bolo', 'marathi में',
      'मराठी मध्ये बोला', 'मराठी बोला', 'switch to marathi', 'change to marathi',
      'मराठीत बोला', 'मराठीत सांगा',
    ],
  };

  /// Detect intent from user message
  /// Returns the most relevant intent based on keyword matching
  static ChatIntent detectIntent(String message) {
    final lowerMessage = message.toLowerCase().trim();

    // Empty message check
    if (lowerMessage.isEmpty) {
      return ChatIntent.unknown;
    }

    // Score each intent based on keyword matches
    int bestScore = 0;
    ChatIntent bestIntent = ChatIntent.unknown;

    for (final entry in _intentKeywords.entries) {
      int score = _calculateMatchScore(lowerMessage, entry.value);
      if (score > bestScore) {
        bestScore = score;
        bestIntent = entry.key;
      }
    }

    return bestIntent;
  }

  /// Calculate match score based on keyword presence
  static int _calculateMatchScore(String message, List<String> keywords) {
    int score = 0;

    for (final keyword in keywords) {
      if (message.contains(keyword.toLowerCase())) {
        // Longer keywords get higher score (more specific)
        score += keyword.length;
      }
    }

    return score;
  }

  /// Check if message contains any question indicators
  static bool isQuestion(String message) {
    final questionIndicators = [
      '?', 'what', 'how', 'which', 'when', 'where', 'why', 'can i', 'can you',
      'क्या', 'कैसे', 'कौन', 'कब', 'कहां', 'क्यों',
      'काय', 'कसे', 'कोण', 'केव्हा', 'कुठे', 'का',
    ];

    final lowerMessage = message.toLowerCase();
    return questionIndicators.any((q) => lowerMessage.contains(q));
  }
}
