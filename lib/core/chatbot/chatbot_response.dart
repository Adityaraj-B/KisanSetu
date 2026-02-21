// Chatbot Response Model - Structured response from chatbot
// Contains response text and optional action suggestions

/// Response type for different chat responses
enum ResponseType {
  text,
  schemeList,
  schemeDetail,
  insuranceInfo,
  insuranceDetail,
  loanList,
  loanDetail,
  subsidyList,
  subsidyDetail,
  weatherInfo,
  farmingTip,
  profileSummary,
  documentInfo,
  navigation,
}

/// Chatbot Response - Holds response data and suggestions
class ChatbotResponse {
  final String message;
  final String? messageHi;
  final String? messageMr;
  final ResponseType type;
  final List<String>? schemeNames;
  final String? navigationTarget;
  final bool showInsuranceButton;
  final bool showSchemesButton;
  final bool showFinanceButton;
  final bool showWeatherButton;
  final bool showProfileButton;

  const ChatbotResponse({
    required this.message,
    this.messageHi,
    this.messageMr,
    this.type = ResponseType.text,
    this.schemeNames,
    this.navigationTarget,
    this.showInsuranceButton = false,
    this.showSchemesButton = false,
    this.showFinanceButton = false,
    this.showWeatherButton = false,
    this.showProfileButton = false,
  });

  /// Get localized message based on language code
  String getLocalizedMessage(String languageCode) {
    if (languageCode == 'hi' && messageHi != null) return messageHi!;
    if (languageCode == 'mr' && messageMr != null) return messageMr!;
    if (languageCode == 'mr' && messageHi != null) return messageHi!;
    return message;
  }

  /// Factory for greeting responses
  factory ChatbotResponse.greeting() {
    return const ChatbotResponse(
      message: 'Hello! 🙏 I\'m your KisanSetu assistant. How can I help you today?\n\nYou can ask me about:\n📋 Government schemes\n🛡️ Crop insurance\n💰 Loans & subsidies\n🌾 Farming tips\n👤 Your profile',
      messageHi: 'नमस्ते! 🙏 मैं आपका किसान सेतु सहायक हूं। आज मैं आपकी कैसे मदद कर सकता हूं?\n\nआप मुझसे पूछ सकते हैं:\n📋 सरकारी योजनाएं\n🛡️ फसल बीमा\n💰 ऋण और सब्सिडी\n🌾 खेती सुझाव\n👤 आपकी प्रोफ़ाइल',
      messageMr: 'नमस्कार! 🙏 मी तुमचा किसान सेतु सहाय्यक आहे. आज मी तुमची कशी मदत करू?\n\nतुम्ही मला विचारू शकता:\n📋 सरकारी योजना\n🛡️ पीक विमा\n💰 कर्ज आणि अनुदान\n🌾 शेती सल्ला\n👤 तुमची प्रोफाइल',
      type: ResponseType.text,
    );
  }

  /// Factory for scheme eligibility results
  factory ChatbotResponse.schemeResult({
    required int count,
    required List<String> schemeNames,
    required String languageCode,
  }) {
    if (count == 0) {
      return const ChatbotResponse(
        message: 'Based on your profile, I couldn\'t find matching schemes right now. Please update your profile with your state, crops, and land size to see eligible schemes.',
        messageHi: 'आपकी प्रोफ़ाइल के आधार पर, मुझे कोई मिलान करने वाली योजना नहीं मिली। कृपया अपना राज्य, फसलें और भूमि का आकार अपडेट करें।',
        messageMr: 'आपल्या प्रोफाइलच्या आधारे, मला जुळणारी कोणतीही योजना सापडली नाही. कृपया आपले राज्य, पिके आणि जमिनीचा आकार अपडेट करा.',
        type: ResponseType.schemeList,
        showSchemesButton: true,
        showProfileButton: true,
      );
    }

    final msgEn = '✅ Great news! You are eligible for $count scheme${count > 1 ? 's' : ''}:\n\n${schemeNames.take(6).map((n) => '• $n').join('\n')}${count > 6 ? '\n\n...and ${count - 6} more!' : ''}\n\nTap below to see full details and apply.';
    final msgHi = '✅ बढ़िया खबर! आप $count योजना${count > 1 ? 'ओं' : ''} के लिए पात्र हैं:\n\n${schemeNames.take(6).map((n) => '• $n').join('\n')}${count > 6 ? '\n\n...और ${count - 6} अन्य!' : ''}\n\nपूरा विवरण देखने और आवेदन करने के लिए नीचे टैप करें।';
    final msgMr = '✅ छान बातमी! तुम्ही $count योजनांसाठी पात्र आहात:\n\n${schemeNames.take(6).map((n) => '• $n').join('\n')}${count > 6 ? '\n\n...आणि ${count - 6} अधिक!' : ''}\n\nसर्व तपशील पाहण्यासाठी खाली टॅप करा.';

    return ChatbotResponse(
      message: msgEn,
      messageHi: msgHi,
      messageMr: msgMr,
      type: ResponseType.schemeList,
      schemeNames: schemeNames,
      showSchemesButton: true,
    );
  }

  /// Factory for specific scheme detail
  factory ChatbotResponse.schemeDetailResponse({
    required String nameEn,
    required String nameHi,
    required String descriptionEn,
    required String descriptionHi,
    required String benefitEn,
    required String benefitHi,
    required String eligibilityEn,
    required String eligibilityHi,
    required String category,
    List<String>? docsEn,
    List<String>? docsHi,
    String? deadlineEn,
    String? deadlineHi,
    String? url,
  }) {
    final docsTextEn = docsEn != null && docsEn.isNotEmpty
        ? '\n\n📄 Documents: ${docsEn.join(', ')}'
        : '';
    final docsTextHi = docsHi != null && docsHi.isNotEmpty
        ? '\n\n📄 दस्तावेज़: ${docsHi.join(', ')}'
        : '';
    final deadlineTextEn = deadlineEn != null ? '\n⏰ Deadline: $deadlineEn' : '';
    final deadlineTextHi = deadlineHi != null ? '\n⏰ अंतिम तिथि: $deadlineHi' : '';

    return ChatbotResponse(
      message: '📋 **$nameEn**\n\n$descriptionEn\n\n💰 Benefits: $benefitEn\n\n👥 Eligibility: $eligibilityEn$docsTextEn$deadlineTextEn${url != null ? '\n\n🔗 More info: $url' : ''}',
      messageHi: '📋 **$nameHi**\n\n$descriptionHi\n\n💰 लाभ: $benefitHi\n\n👥 पात्रता: $eligibilityHi$docsTextHi$deadlineTextHi',
      type: ResponseType.schemeDetail,
      showSchemesButton: true,
    );
  }

  /// Factory for crop-specific scheme results
  factory ChatbotResponse.cropSchemeResult({
    required String cropName,
    required List<String> schemeNames,
    required String languageCode,
  }) {
    final count = schemeNames.length;
    if (count == 0) {
      return ChatbotResponse(
        message: 'I couldn\'t find specific schemes for $cropName with your current profile. Try updating your state and land size for better results.',
        messageHi: '$cropName के लिए आपकी प्रोफ़ाइल से कोई विशेष योजना नहीं मिली। बेहतर परिणामों के लिए अपना राज्य और भूमि आकार अपडेट करें।',
        type: ResponseType.schemeList,
        showSchemesButton: true,
        showProfileButton: true,
      );
    }

    return ChatbotResponse(
      message: '🌾 Schemes available for **$cropName** farmers:\n\n${schemeNames.map((n) => '• $n').join('\n')}\n\nTap below to see all scheme details.',
      messageHi: '🌾 **$cropName** किसानों के लिए उपलब्ध योजनाएं:\n\n${schemeNames.map((n) => '• $n').join('\n')}\n\nसभी योजना विवरण देखने के लिए नीचे टैप करें।',
      type: ResponseType.schemeList,
      schemeNames: schemeNames,
      showSchemesButton: true,
    );
  }

  /// Factory for insurance information response (general)
  factory ChatbotResponse.insuranceInfo() {
    return const ChatbotResponse(
      message: '🛡️ **Crop Insurance Options:**\n\n1️⃣ **PMFBY** - Comprehensive crop insurance\n   • Premium: 2% (Kharif), 1.5% (Rabi)\n   • Covers natural calamities, pests, post-harvest losses\n\n2️⃣ **WBCIS** - Weather-based insurance\n   • Automatic claim settlement based on weather data\n\n3️⃣ **Livestock Insurance** - For cattle & animals\n   • Premium: ~3% of animal value\n\n4️⃣ **PM Jeevan Jyoti** - Life insurance\n   • Only ₹436/year for ₹2 lakh cover\n\nAsk about any specific insurance for more details!',
      messageHi: '🛡️ **फसल बीमा विकल्प:**\n\n1️⃣ **PMFBY** - व्यापक फसल बीमा\n   • प्रीमियम: 2% (खरीफ), 1.5% (रबी)\n   • प्राकृतिक आपदाओं, कीटों, कटाई बाद नुकसान कवर\n\n2️⃣ **WBCIS** - मौसम आधारित बीमा\n   • मौसम डेटा पर स्वचालित दावा निपटान\n\n3️⃣ **पशुधन बीमा** - पशुओं के लिए\n   • प्रीमियम: पशु मूल्य का ~3%\n\n4️⃣ **PM जीवन ज्योति** - जीवन बीमा\n   • केवल ₹436/वर्ष में ₹2 लाख कवर\n\nकिसी भी बीमा के बारे में विस्तार से पूछें!',
      messageMr: '🛡️ **पीक विमा पर्याय:**\n\n1️⃣ **PMFBY** - सर्वसमावेशक पीक विमा\n   • प्रीमियम: २% (खरीप), १.५% (रब्बी)\n   • नैसर्गिक आपत्ती, कीड, काढणी नंतरचे नुकसान कव्हर\n\n2️⃣ **WBCIS** - हवामान आधारित विमा\n   • हवामान डेटावर स्वयंचलित दावा निपटारा\n\n3️⃣ **पशुधन विमा** - जनावरांसाठी\n   • प्रीमियम: जनावराच्या मूल्याच्या ~३%\n\n4️⃣ **PM जीवन ज्योती** - जीवन विमा\n   • फक्त ₹४३६/वर्ष मध्ये ₹२ लाख कव्हर\n\nकोणत्याही विम्याबद्दल तपशीलवार विचारा!',
      type: ResponseType.insuranceInfo,
      showInsuranceButton: true,
    );
  }

  /// Factory for specific insurance detail
  factory ChatbotResponse.insuranceDetailResponse({
    required String nameEn,
    required String nameHi,
    required String descEn,
    required String descHi,
    required double premium,
    required double sumInsured,
    required String coverageEn,
    required String coverageHi,
    required List<String> risksEn,
    required List<String> risksHi,
  }) {
    final premiumText = premium > 0 ? '${premium.toStringAsFixed(1)}%' : 'Minimal';
    final sumText = '₹${(sumInsured / 1000).toStringAsFixed(0)}K';

    return ChatbotResponse(
      message: '🛡️ **$nameEn**\n\n$descEn\n\n💰 Premium: $premiumText\n📊 Sum Insured: Up to $sumText\n📋 Coverage: $coverageEn\n\n✅ Covered Risks:\n${risksEn.map((r) => '• $r').join('\n')}',
      messageHi: '🛡️ **$nameHi**\n\n$descHi\n\n💰 प्रीमियम: $premiumText\n📊 बीमित राशि: $sumText तक\n📋 कवरेज: $coverageHi\n\n✅ कवर किए गए जोखिम:\n${risksHi.map((r) => '• $r').join('\n')}',
      type: ResponseType.insuranceDetail,
      showInsuranceButton: true,
    );
  }

  /// Factory for loan list response
  factory ChatbotResponse.loanListResponse({
    required List<Map<String, String>> loans,
    required String languageCode,
  }) {
    final loanLines = loans.map((l) {
      return '• **${l['name']}** - ${l['rate']}% interest, up to ₹${l['amount']}';
    }).join('\n');
    final loanLinesHi = loans.map((l) {
      return '• **${l['nameHi']}** - ${l['rate']}% ब्याज, ₹${l['amount']} तक';
    }).join('\n');

    return ChatbotResponse(
      message: '💰 **Available Loans for Farmers:**\n\n$loanLines\n\nAsk about any specific loan for full details!',
      messageHi: '💰 **किसानों के लिए उपलब्ध ऋण:**\n\n$loanLinesHi\n\nपूर्ण विवरण के लिए किसी भी ऋण के बारे में पूछें!',
      type: ResponseType.loanList,
      showFinanceButton: true,
    );
  }

  /// Factory for specific loan detail
  factory ChatbotResponse.loanDetailResponse({
    required String nameEn,
    required String nameHi,
    required String descEn,
    required String descHi,
    required double interestRate,
    required double eligibleAmount,
    required String tenure,
    required String provider,
    required List<String> benefitsEn,
    required List<String> benefitsHi,
  }) {
    final amountText = eligibleAmount >= 100000
        ? '₹${(eligibleAmount / 100000).toStringAsFixed(1)} Lakh'
        : '₹${eligibleAmount.toStringAsFixed(0)}';

    return ChatbotResponse(
      message: '🏦 **$nameEn**\n\n$descEn\n\n📊 Interest Rate: ${interestRate.toStringAsFixed(1)}%\n💰 Eligible Amount: Up to $amountText\n⏳ Tenure: $tenure\n🏛️ Provider: $provider\n\n✅ Benefits:\n${benefitsEn.map((b) => '• $b').join('\n')}',
      messageHi: '🏦 **$nameHi**\n\n$descHi\n\n📊 ब्याज दर: ${interestRate.toStringAsFixed(1)}%\n💰 पात्र राशि: $amountText तक\n⏳ अवधि: $tenure\n🏛️ प्रदाता: $provider\n\n✅ लाभ:\n${benefitsHi.map((b) => '• $b').join('\n')}',
      type: ResponseType.loanDetail,
      showFinanceButton: true,
    );
  }

  /// Factory for subsidy list response
  factory ChatbotResponse.subsidyListResponse({
    required List<Map<String, String>> subsidies,
    required String languageCode,
  }) {
    final lines = subsidies.map((s) {
      return '• **${s['name']}** - ₹${s['amount']} (${s['frequency']})';
    }).join('\n');
    final linesHi = subsidies.map((s) {
      return '• **${s['nameHi']}** - ₹${s['amount']} (${s['frequencyHi']})';
    }).join('\n');

    return ChatbotResponse(
      message: '🎁 **Available Subsidies:**\n\n$lines\n\nAsk about any specific subsidy for details!',
      messageHi: '🎁 **उपलब्ध सब्सिडी:**\n\n$linesHi\n\nकिसी भी सब्सिडी के बारे में विस्तार से पूछें!',
      type: ResponseType.subsidyList,
      showFinanceButton: true,
    );
  }

  /// Factory for weather / farming tips
  factory ChatbotResponse.weatherTipResponse({
    required String season,
    required String tipEn,
    required String tipHi,
    required String tipMr,
  }) {
    return ChatbotResponse(
      message: tipEn,
      messageHi: tipHi,
      messageMr: tipMr,
      type: ResponseType.farmingTip,
      showWeatherButton: true,
    );
  }

  /// Factory for profile summary
  factory ChatbotResponse.profileSummaryResponse({
    required String summaryEn,
    required String summaryHi,
    required String summaryMr,
    required double completionPercent,
  }) {
    return ChatbotResponse(
      message: summaryEn,
      messageHi: summaryHi,
      messageMr: summaryMr,
      type: ResponseType.profileSummary,
      showProfileButton: completionPercent < 1.0,
    );
  }

  /// Factory for document help
  factory ChatbotResponse.documentHelpResponse({
    required String messageEn,
    required String messageHi,
    required String messageMr,
  }) {
    return ChatbotResponse(
      message: messageEn,
      messageHi: messageHi,
      messageMr: messageMr,
      type: ResponseType.documentInfo,
      showProfileButton: true,
    );
  }

  /// Factory for application process
  factory ChatbotResponse.applicationProcessResponse({
    required String messageEn,
    required String messageHi,
  }) {
    return ChatbotResponse(
      message: messageEn,
      messageHi: messageHi,
      type: ResponseType.text,
      showSchemesButton: true,
    );
  }

  /// Factory for help response
  factory ChatbotResponse.help() {
    return const ChatbotResponse(
      message: 'I can help you with many things! Try asking:\n\n📋 **Schemes** - "Show my schemes" or "Tell me about PM-KISAN"\n🛡️ **Insurance** - "Tell me about crop insurance" or "PMFBY details"\n💰 **Loans** - "What loans can I get?" or "KCC details"\n🎁 **Subsidies** - "What subsidies are available?"\n🌾 **Farming** - "Farming tips" or "What to grow this season?"\n👤 **Profile** - "My profile status"\n📄 **Documents** - "What documents do I need?"\n🌍 **Language** - "Switch to Hindi/Marathi"\n\n💡 Tip: Complete your profile for personalized recommendations!',
      messageHi: 'मैं आपकी बहुत चीज़ों में मदद कर सकता हूं! पूछने का प्रयास करें:\n\n📋 **योजनाएं** - "मेरी योजनाएं दिखाओ" या "PM-KISAN के बारे में बताओ"\n🛡️ **बीमा** - "फसल बीमा बताओ" या "PMFBY विवरण"\n💰 **ऋण** - "कौन से लोन मिल सकते हैं?" या "KCC विवरण"\n🎁 **सब्सिडी** - "कौन सी सब्सिडी उपलब्ध है?"\n🌾 **खेती** - "खेती सुझाव" या "इस मौसम में क्या उगाएं?"\n👤 **प्रोफ़ाइल** - "मेरी प्रोफ़ाइल स्थिति"\n📄 **दस्तावेज़** - "कौन से दस्तावेज़ चाहिए?"\n🌍 **भाषा** - "हिंदी/मराठी में बदलो"\n\n💡 सुझाव: व्यक्तिगत सिफारिशों के लिए प्रोफ़ाइल पूरी करें!',
      messageMr: 'मी तुम्हाला अनेक गोष्टींमध्ये मदत करू शकतो! विचारून पहा:\n\n📋 **योजना** - "माझ्या योजना दाखवा" किंवा "PM-KISAN बद्दल सांगा"\n🛡️ **विमा** - "पीक विम्याबद्दल सांगा" किंवा "PMFBY तपशील"\n💰 **कर्ज** - "कोणते कर्ज मिळू शकते?" किंवा "KCC तपशील"\n🎁 **अनुदान** - "कोणते अनुदान उपलब्ध आहे?"\n🌾 **शेती** - "शेती सल्ला" किंवा "या हंगामात काय पेरावे?"\n👤 **प्रोफाइल** - "माझी प्रोफाइल स्थिती"\n📄 **कागदपत्रे** - "कोणती कागदपत्रे हवीत?"\n🌍 **भाषा** - "हिंदी/मराठीत बदला"\n\n💡 सूचना: वैयक्तिक शिफारसींसाठी प्रोफाइल पूर्ण करा!',
      type: ResponseType.text,
    );
  }

  /// Factory for thanks response
  factory ChatbotResponse.thanks() {
    return const ChatbotResponse(
      message: 'You\'re welcome! 🌾 Feel free to ask anything else. I\'m here to help you find the best schemes, loans, and advice for your farm!',
      messageHi: 'आपका स्वागत है! 🌾 कुछ भी पूछने में संकोच न करें। मैं आपकी खेती के लिए सबसे अच्छी योजनाएं, ऋण और सलाह खोजने में मदद के लिए यहां हूं!',
      messageMr: 'तुमचे स्वागत आहे! 🌾 काहीही विचारायला मोकळे वाटा. तुमच्या शेतीसाठी सर्वोत्तम योजना, कर्ज आणि सल्ला शोधण्यासाठी मी येथे आहे!',
      type: ResponseType.text,
    );
  }

  /// Factory for unknown/fallback response
  factory ChatbotResponse.unknown() {
    return const ChatbotResponse(
      message: 'I\'m not sure I understood that. Here\'s what I can help with:\n\n• "Show my schemes" - See eligible schemes\n• "Tell me about PM-KISAN" - Scheme details\n• "What loans can I get?" - Available loans\n• "Insurance options" - Crop insurance info\n• "Farming tips" - Season-based advice\n• "My profile" - Your profile summary\n\nTry one of these or say "help" for more options!',
      messageHi: 'मुझे यह समझ नहीं आया। मैं इनमें मदद कर सकता हूं:\n\n• "मेरी योजनाएं दिखाओ" - पात्र योजनाएं देखें\n• "PM-KISAN के बारे में बताओ" - योजना विवरण\n• "कौन से लोन मिल सकते हैं?" - उपलब्ध ऋण\n• "बीमा विकल्प" - फसल बीमा जानकारी\n• "खेती सुझाव" - मौसम आधारित सलाह\n• "मेरी प्रोफ़ाइल" - प्रोफ़ाइल सारांश\n\nइनमें से कोई पूछें या "मदद" बोलें!',
      messageMr: 'मला हे समजले नाही. मी यामध्ये मदत करू शकतो:\n\n• "माझ्या योजना दाखवा" - पात्र योजना पहा\n• "PM-KISAN बद्दल सांगा" - योजना तपशील\n• "कोणते कर्ज मिळू शकते?" - उपलब्ध कर्ज\n• "विमा पर्याय" - पीक विमा माहिती\n• "शेती सल्ला" - हंगाम आधारित सल्ला\n• "माझी प्रोफाइल" - प्रोफाइल सारांश\n\nयापैकी एक विचारा किंवा "मदत" म्हणा!',
      type: ResponseType.text,
    );
  }

  /// Factory for profile incomplete response
  factory ChatbotResponse.profileIncomplete() {
    return const ChatbotResponse(
      message: 'To give you personalized scheme recommendations, I need your profile information. Please fill in:\n\n• 📍 State\n• 🌾 Crops you grow\n• 📐 Land size (acres)\n\nOnce complete, I can find the best schemes for you!',
      messageHi: 'आपको व्यक्तिगत योजना सिफारिशें देने के लिए, मुझे आपकी प्रोफ़ाइल जानकारी चाहिए। कृपया भरें:\n\n• 📍 राज्य\n• 🌾 आपकी फसलें\n• 📐 भूमि का आकार (एकड़)\n\nपूरा होने पर, मैं आपके लिए सबसे अच्छी योजनाएं खोज सकता हूं!',
      messageMr: 'तुम्हाला वैयक्तिक योजना शिफारसी देण्यासाठी मला तुमची प्रोफाइल माहिती हवी आहे. कृपया भरा:\n\n• 📍 राज्य\n• 🌾 तुम्ही घेत असलेली पिके\n• 📐 जमिनीचा आकार (एकर)\n\nपूर्ण झाल्यावर, मी तुमच्यासाठी सर्वोत्तम योजना शोधू शकतो!',
      type: ResponseType.text,
      showProfileButton: true,
    );
  }

  factory ChatbotResponse.languageSwitchHindi() {
    return const ChatbotResponse(
      message: 'Switching to Hindi. अब मैं हिंदी में बात करूंगा। 🙏',
      messageHi: 'हिंदी में बदल रहा हूं। अब मैं हिंदी में बात करूंगा। 🙏',
      messageMr: 'हिंदी मध्ये बदलत आहे. अब मैं हिंदी में बात करूंगा। 🙏',
      type: ResponseType.text,
    );
  }

  factory ChatbotResponse.languageSwitchEnglish() {
    return const ChatbotResponse(
      message: 'Switching to English. I will now speak in English. 🙏',
      messageHi: 'अंग्रेजी में बदल रहा हूं। I will now speak in English. 🙏',
      messageMr: 'इंग्रजीत बदलत आहे. I will now speak in English. 🙏',
      type: ResponseType.text,
    );
  }

  factory ChatbotResponse.languageSwitchMarathi() {
    return const ChatbotResponse(
      message: 'Switching to Marathi. आता मी मराठीत बोलेन. 🙏',
      messageHi: 'मराठी में बदल रहा हूं। आता मी मराठीत बोलेन. 🙏',
      messageMr: 'मराठीत बदलत आहे. आता मी मराठीत बोलेन. 🙏',
      type: ResponseType.text,
    );
  }
}
