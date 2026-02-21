/// Chatbot Response Model - Structured response from chatbot
/// Contains response text and optional action suggestions

/// Response type for different chat responses
enum ResponseType {
  text,
  schemeList,
  insuranceInfo,
  navigation,
}

/// Chatbot Response - Holds response data and suggestions
class ChatbotResponse {
  final String message;
  final String? messageHi; // Hindi translation
  final String? messageMr; // Marathi translation
  final ResponseType type;
  final List<String>? schemeNames; // For scheme_check responses
  final String? navigationTarget; // For navigation suggestions
  final bool showInsuranceButton;
  final bool showSchemesButton;

  const ChatbotResponse({
    required this.message,
    this.messageHi,
    this.messageMr,
    this.type = ResponseType.text,
    this.schemeNames,
    this.navigationTarget,
    this.showInsuranceButton = false,
    this.showSchemesButton = false,
  });

  /// Get localized message based on language code
  String getLocalizedMessage(String languageCode) {
    if (languageCode == 'hi' && messageHi != null) {
      return messageHi!;
    }
    if (languageCode == 'mr' && messageMr != null) {
      return messageMr!;
    }
    if (languageCode == 'mr' && messageHi != null) {
      return messageHi!; // fallback to Hindi if no Marathi
    }
    return message;
  }

  /// Factory for greeting responses
  factory ChatbotResponse.greeting() {
    return const ChatbotResponse(
      message: 'Hello! I\'m your KisanSetu assistant. How can I help you today? You can ask me about government schemes, crop insurance, or general help.',
      messageHi: 'नमस्ते! मैं आपका किसान सेतु सहायक हूं। आज मैं आपकी कैसे मदद कर सकता हूं? आप मुझसे सरकारी योजनाओं, फसल बीमा, या सामान्य मदद के बारे में पूछ सकते हैं।',
      messageMr: 'नमस्कार! मी तुमचा किसान सेतु सहाय्यक आहे. आज मी तुमची कशी मदत करू? तुम्ही मला सरकारी योजना, पीक विमा किंवा सामान्य मदत याबद्दल विचारू शकता.',
      type: ResponseType.text,
    );
  }

  /// Factory for scheme eligibility responses
  factory ChatbotResponse.schemeResult({
    required int count,
    required List<String> schemeNames,
    required String languageCode,
  }) {
    if (count == 0) {
      return const ChatbotResponse(
        message: 'Based on your profile, I couldn\'t find matching schemes. Please update your profile with your state, crops, and land size to see eligible schemes.',
        messageHi: 'आपकी प्रोफ़ाइल के आधार पर, मुझे कोई मिलान करने वाली योजना नहीं मिली। पात्र योजनाएं देखने के लिए कृपया अपना राज्य, फसलें और भूमि का आकार अपडेट करें।',
        messageMr: 'आपल्या प्रोफाइलच्या आधारे, मला जुळणारी कोणतीही योजना सापडली नाही. पात्र योजना पाहण्यासाठी कृपया आपले राज्य, पिके आणि जमिनीचा आकार अपडेट करा.',
        type: ResponseType.schemeList,
        showSchemesButton: true,
      );
    }

    final messageEn = 'Great news! You are eligible for $count scheme${count > 1 ? 's' : ''}:\n\n• ${schemeNames.take(5).join('\n• ')}${count > 5 ? '\n\n...and ${count - 5} more!' : ''}\n\nTap below to see all details.';
    final messageHi = 'बढ़िया खबर! आप $count योजना${count > 1 ? 'ओं' : ''} के लिए पात्र हैं:\n\n• ${schemeNames.take(5).join('\n• ')}${count > 5 ? '\n\n...और ${count - 5} अन्य!' : ''}\n\nसभी विवरण देखने के लिए नीचे टैप करें।';
    final messageMr = 'छान बातमी! तुम्ही $count योजनांसाठी पात्र आहात:\n\n• ${schemeNames.take(5).join('\n• ')}${count > 5 ? '\n\n...आणि ${count - 5} अधिक!' : ''}\n\nसर्व तपशील पाहण्यासाठी खाली टॅप करा.';

    return ChatbotResponse(
      message: messageEn,
      messageHi: messageHi,
      messageMr: messageMr,
      type: ResponseType.schemeList,
      schemeNames: schemeNames,
      showSchemesButton: true,
    );
  }

  /// Factory for insurance information response
  factory ChatbotResponse.insuranceInfo() {
    return const ChatbotResponse(
      message: 'PM Fasal Bima Yojana (PMFBY) provides crop insurance protection. Key benefits:\n\n• Low premium (2% for Kharif, 1.5% for Rabi crops)\n• Protection against natural calamities\n• Quick claim settlement\n\nTap below to learn more about insurance options.',
      messageHi: 'पीएम फसल बीमा योजना (PMFBY) फसल बीमा सुरक्षा प्रदान करती है। मुख्य लाभ:\n\n• कम प्रीमियम (खरीफ के लिए 2%, रबी फसलों के लिए 1.5%)\n• प्राकृतिक आपदाओं से सुरक्षा\n• त्वरित दावा निपटान\n\nबीमा विकल्पों के बारे में अधिक जानने के लिए नीचे टैप करें।',
      messageMr: 'पीएम फसल बीमा योजना (PMFBY) पीक विमा संरक्षण प्रदान करते. मुख्य फायदे:\n\n• कमी प्रीमियम (खरीपसाठी २%, रब्बी पिकांसाठी १.५%)\n• नैसर्गिक आपत्तींपासून संरक्षण\n• जलद दावा निपटारा\n\nविमा पर्यायांबद्दल अधिक जाणून घेण्यासाठी खाली टॅप करा.',
      type: ResponseType.insuranceInfo,
      showInsuranceButton: true,
    );
  }

  /// Factory for help response
  factory ChatbotResponse.help() {
    return const ChatbotResponse(
      message: 'I can help you with:\n\n📋 **Schemes** - Ask "Show my schemes" or "योजनाएं दिखाओ"\n\n🛡️ **Insurance** - Ask "Tell me about insurance" or "बीमा के बारे में बताओ"\n\n💡 **Tip**: Complete your profile with state, crops, and land size to get personalized scheme recommendations!',
      messageHi: 'मैं आपकी इनमें मदद कर सकता हूं:\n\n📋 **योजनाएं** - पूछें "मेरी योजनाएं दिखाओ" या "Show my schemes"\n\n🛡️ **बीमा** - पूछें "बीमा के बारे में बताओ" या "Tell me about insurance"\n\n💡 **सुझाव**: व्यक्तिगत योजना सिफारिशें पाने के लिए अपनी प्रोफ़ाइल में राज्य, फसलें और भूमि का आकार भरें!',
      messageMr: 'मी तुम्हाला यामध्ये मदत करू शकतो:\n\n📋 **योजना** - विचारा "माझ्या योजना दाखवा" किंवा "Show my schemes"\n\n🛡️ **विमा** - विचारा "विम्याबद्दल सांगा" किंवा "Tell me about insurance"\n\n💡 **सूचना**: वैयक्तिक योजना शिफारसी मिळवण्यासाठी तुमच्या प्रोफाइलमध्ये राज्य, पिके आणि जमिनीचा आकार भरा!',
      type: ResponseType.text,
    );
  }

  /// Factory for thanks response
  factory ChatbotResponse.thanks() {
    return const ChatbotResponse(
      message: 'You\'re welcome! Feel free to ask if you have more questions. I\'m here to help! 🌾',
      messageHi: 'आपका स्वागत है! अगर आपके और प्रश्न हैं तो पूछें। मैं मदद के लिए यहां हूं! 🌾',
      messageMr: 'तुमचे स्वागत आहे! अधिक प्रश्न असल्यास विचारा. मी मदतीसाठी येथे आहे! 🌾',
      type: ResponseType.text,
    );
  }

  /// Factory for unknown/fallback response
  factory ChatbotResponse.unknown() {
    return const ChatbotResponse(
      message: 'I\'m not sure I understood that. You can ask me about:\n\n• Government schemes for farmers\n• Crop insurance (PMFBY)\n• How to use this app\n\nTry asking "What schemes am I eligible for?" or "Tell me about insurance".',
      messageHi: 'मुझे यह समझ नहीं आया। आप मुझसे इनके बारे में पूछ सकते हैं:\n\n• किसानों के लिए सरकारी योजनाएं\n• फसल बीमा (PMFBY)\n• इस ऐप का उपयोग कैसे करें\n\n"मैं कौन सी योजनाओं के लिए पात्र हूं?" या "बीमा के बारे में बताओ" पूछने का प्रयास करें।',
      messageMr: 'मला हे समजले नाही. तुम्ही मला याबद्दल विचारू शकता:\n\n• शेतकऱ्यांसाठी सरकारी योजना\n• पीक विमा (PMFBY)\n• हे अॅप कसे वापरावे\n\n"मी कोणत्या योजनांसाठी पात्र आहे?" किंवा "विम्याबद्दल सांगा" विचारून पहा.',
      type: ResponseType.text,
    );
  }

  /// Factory for profile incomplete response
  factory ChatbotResponse.profileIncomplete() {
    return const ChatbotResponse(
      message: 'To check your eligible schemes, I need your profile information. Please go to the Home screen and fill in your:\n\n• State\n• Crops you grow\n• Land size\n\nOnce complete, come back and ask me again!',
      messageHi: 'आपकी पात्र योजनाओं की जांच करने के लिए, मुझे आपकी प्रोफ़ाइल जानकारी चाहिए। कृपया होम स्क्रीन पर जाएं और भरें:\n\n• राज्य\n• आपकी फसलें\n• भूमि का आकार\n\nपूरा होने पर, वापस आएं और मुझसे फिर पूछें!',
      messageMr: 'आपल्या पात्र योजना तपासण्यासाठी मला आपली प्रोफाइल माहिती हवी आहे. कृपया मुख्यपृष्ठावर जा आणि भरा:\n\n• राज्य\n• तुम्ही घेत असलेली पिके\n• जमिनीचा आकार\n\nपूर्ण झाल्यावर, परत या आणि पुन्हा विचारा!',
      type: ResponseType.text,
    );
  }

  factory ChatbotResponse.languageSwitchHindi() {
    return const ChatbotResponse(
      message: 'Switching to Hindi. अब मैं हिंदी में बात करूंगा।',
      messageHi: 'हिंदी में बदल रहा हूं। अब मैं हिंदी में बात करूंगा।',
      messageMr: 'हिंदी मध्ये बदलत आहे. अब मैं हिंदी में बात करूंगा।',
      type: ResponseType.text,
    );
  }

  factory ChatbotResponse.languageSwitchEnglish() {
    return const ChatbotResponse(
      message: 'Switching to English. I will now speak in English.',
      messageHi: 'अंग्रेजी में बदल रहा हूं। I will now speak in English.',
      messageMr: 'इंग्रजीत बदलत आहे. I will now speak in English.',
      type: ResponseType.text,
    );
  }

  factory ChatbotResponse.languageSwitchMarathi() {
    return const ChatbotResponse(
      message: 'Switching to Marathi. आता मी मराठीत बोलेन.',
      messageHi: 'मराठी में बदल रहा हूं। आता मी मराठीत बोलेन.',
      messageMr: 'मराठीत बदलत आहे. आता मी मराठीत बोलेन.',
      type: ResponseType.text,
    );
  }
}
