/// Chatbot Intents - Defines all possible user intents and entity extraction
/// Enum representing all chatbot intents
enum ChatIntent {
  // Greetings & Basic
  greeting,
  thanks,
  help,

  // Scheme Related
  schemeCheck,         // General "show my schemes"
  schemeDetail,        // Ask about a specific scheme by name
  schemeRecommendation, // "Which scheme is best for me?"
  cropScheme,          // "Schemes for cotton/rice"

  // Insurance Related
  insuranceCheck,      // General insurance info
  insuranceDetail,     // Specific insurance product (PMFBY, WBCIS, Livestock)

  // Finance Related
  loanGeneral,         // "What loans can I get?"
  loanDetail,          // Specific loan (KCC, Crop Loan)
  subsidyGeneral,      // "What subsidies are available?"
  subsidyDetail,       // Specific subsidy

  // Farming & Knowledge
  weatherCheck,        // "What's the weather?" / farming weather tips
  farmingTips,         // Season-based crop advice
  cropInfo,            // Info about a specific crop

  // Profile & Documents
  profileStatus,       // "Show my profile" / completion status
  documentHelp,        // "What documents do I need?"
  applicationProcess,  // "How to apply?"

  // Language Switching
  languageSwitchHindi,
  languageSwitchEnglish,
  languageSwitchMarathi,

  // Fallback
  unknown,
}

/// Intent Detector - Maps user messages to intents using keyword matching
class IntentDetector {
  IntentDetector._();

  // ===================== Scheme name aliases =====================
  static const Map<String, String> _schemeAliases = {
    // PM-KISAN
    'pm kisan': 'pm_kisan', 'pm-kisan': 'pm_kisan', 'pmkisan': 'pm_kisan',
    'kisan samman': 'pm_kisan', 'samman nidhi': 'pm_kisan',
    'पीएम किसान': 'pm_kisan', 'किसान सम्मान': 'pm_kisan',
    'पीएम-किसान': 'pm_kisan', 'किसान सन्मान': 'pm_kisan',
    '6000': 'pm_kisan', '₹6000': 'pm_kisan', '2000 installment': 'pm_kisan',

    // PMFBY
    'pmfby': 'pmfby', 'fasal bima': 'pmfby', 'crop insurance scheme': 'pmfby',
    'फसल बीमा': 'pmfby', 'पीक विमा': 'pmfby',
    'fasal suraksha': 'pmfby',

    // KCC
    'kcc': 'kcc', 'kisan credit': 'kcc', 'credit card': 'kcc',
    'किसान क्रेडिट': 'kcc', 'क्रेडिट कार्ड': 'kcc',

    // Soil Health Card
    'soil health': 'soil_health_card', 'mruda': 'soil_health_card',
    'मृदा स्वास्थ्य': 'soil_health_card', 'soil card': 'soil_health_card',
    'मृदा कार्ड': 'soil_health_card',

    // e-NAM
    'enam': 'enam', 'e-nam': 'enam', 'mandi': 'enam',
    'ई-नाम': 'enam', 'national market': 'enam', 'agriculture market': 'enam',
    'कृषि बाजार': 'enam', 'मंडी': 'enam',

    // PKVY (Organic Farming)
    'pkvy': 'pkvy', 'organic farming': 'pkvy', 'paramparagat': 'pkvy',
    'परम्परागत': 'pkvy', 'जैविक खेती': 'pkvy', 'सेंद्रिय शेती': 'pkvy',

    // PM-KUSUM
    'kusum': 'pm_kusum', 'pm kusum': 'pm_kusum', 'pm-kusum': 'pm_kusum',
    'solar pump': 'pm_kusum', 'सोलर पंप': 'pm_kusum', 'कुसुम': 'pm_kusum',
    'सौर पंप': 'pm_kusum',

    // Namo Drone Didi
    'drone didi': 'namo_drone_didi', 'namo drone': 'namo_drone_didi',
    'ड्रोन दीदी': 'namo_drone_didi', 'नमो ड्रोन': 'namo_drone_didi',

    // Others from schemes.json
    'per drop more crop': 'pdmc', 'micro irrigation': 'pdmc',
    'drip irrigation': 'pdmc', 'सूक्ष्म सिंचाई': 'pdmc',
    'bamboo mission': 'nbm', 'बांस': 'nbm', 'बांबू': 'nbm',
    'agriculture infrastructure': 'aif', 'कृषि अवसंरचना': 'aif',
    'kisan pension': 'pm_kmy', 'मानधन': 'pm_kmy', 'pension': 'pm_kmy',
    'horticulture': 'midh', 'बागवानी': 'midh', 'फलोत्पादन': 'midh',
    'gobar dhan': 'gobar_dhan', 'गोबर धन': 'gobar_dhan',
    'mgnrega': 'mgnrega', 'मनरेगा': 'mgnrega', 'nrega': 'mgnrega',
    'beekeeping': 'nbhm', 'मधुमक्खी': 'nbhm', 'मधमाशी': 'nbhm',
  };

  // ===================== Crop name aliases =====================
  static const Map<String, String> _cropAliases = {
    'rice': 'Rice', 'paddy': 'Rice', 'chawal': 'Rice', 'dhan': 'Rice',
    'चावल': 'Rice', 'धान': 'Rice', 'तांदूळ': 'Rice', 'भात': 'Rice',

    'wheat': 'Wheat', 'gehu': 'Wheat', 'gehun': 'Wheat',
    'गेहूं': 'Wheat', 'गहू': 'Wheat',

    'cotton': 'Cotton', 'kapas': 'Cotton',
    'कपास': 'Cotton', 'कापूस': 'Cotton',

    'sugarcane': 'Sugarcane', 'ganna': 'Sugarcane',
    'गन्ना': 'Sugarcane', 'ऊस': 'Sugarcane',

    'maize': 'Maize', 'corn': 'Maize', 'makka': 'Maize',
    'मक्का': 'Maize', 'मका': 'Maize',

    'pulses': 'Pulses', 'dal': 'Pulses', 'daal': 'Pulses',
    'दाल': 'Pulses', 'डाळी': 'Pulses',

    'vegetables': 'Vegetables', 'sabzi': 'Vegetables', 'sabji': 'Vegetables',
    'सब्जी': 'Vegetables', 'सब्जियां': 'Vegetables', 'भाज्या': 'Vegetables',

    'fruits': 'Fruits', 'phal': 'Fruits',
    'फल': 'Fruits', 'फळे': 'Fruits',

    'oilseeds': 'Oilseeds', 'tilhan': 'Oilseeds',
    'तिलहन': 'Oilseeds', 'तेलबिया': 'Oilseeds',

    'spices': 'Spices', 'masala': 'Spices', 'masale': 'Spices',
    'मसाले': 'Spices',

    'soybean': 'Soybean', 'soya': 'Soybean',
    'सोयाबीन': 'Soybean',

    'groundnut': 'Groundnut', 'mungfali': 'Groundnut',
    'मूंगफली': 'Groundnut', 'भुईमूग': 'Groundnut',
  };

  // ===================== Loan name aliases =====================
  static const Map<String, String> _loanAliases = {
    'kisan credit card': 'KCC', 'kcc loan': 'KCC',
    'किसान क्रेडिट कार्ड': 'KCC', 'केसीसी': 'KCC',

    'crop loan': 'Crop Loan', 'fasal rin': 'Crop Loan',
    'फसल ऋण': 'Crop Loan', 'पीक कर्ज': 'Crop Loan',

    'tractor loan': 'Tractor Loan', 'equipment loan': 'Tractor Loan',
    'ट्रैक्टर ऋण': 'Tractor Loan', 'उपकरण ऋण': 'Tractor Loan',

    'mudra loan': 'Mudra', 'mudra': 'Mudra', 'pm mudra': 'Mudra',
    'मुद्रा ऋण': 'Mudra', 'मुद्रा': 'Mudra',
  };

  // ===================== Insurance aliases =====================
  static const Map<String, String> _insuranceAliases = {
    'pmfby insurance': 'PMFBY', 'fasal bima yojana': 'PMFBY',
    'फसल बीमा योजना': 'PMFBY', 'पीक विमा योजना': 'PMFBY',

    'weather insurance': 'WBCIS', 'wbcis': 'WBCIS',
    'weather based': 'WBCIS', 'मौसम बीमा': 'WBCIS', 'मौसम आधारित': 'WBCIS',

    'livestock insurance': 'Livestock', 'cattle insurance': 'Livestock',
    'pashu bima': 'Livestock', 'पशुधन बीमा': 'Livestock', 'पशु बीमा': 'Livestock',

    'life insurance': 'PMJJBY', 'jeevan jyoti': 'PMJJBY',
    'pmjjby': 'PMJJBY', 'जीवन ज्योति': 'PMJJBY',
  };

  /// Keyword mappings for each intent (English, Hindi, Marathi)
  static const Map<ChatIntent, List<String>> _intentKeywords = {
    ChatIntent.greeting: [
      'hello', 'hi', 'hey', 'good morning', 'good afternoon', 'good evening',
      'namaste', 'namaskar',
      'नमस्ते', 'नमस्कार', 'हेलो', 'हाय', 'सुप्रभात', 'शुभ संध्या',
      'शुभ संध्याकाळ',
    ],
    ChatIntent.schemeDetail: [
      'tell me about', 'details of', 'explain scheme', 'what is',
      'information about', 'info about', 'describe',
      'बताओ', 'बारे में बताओ', 'विवरण', 'जानकारी दो', 'क्या है',
      'सांगा', 'बद्दल सांगा', 'माहिती द्या', 'काय आहे',
    ],
    ChatIntent.schemeCheck: [
      'scheme', 'schemes', 'yojna', 'yojana', 'eligible', 'eligibility',
      'government', 'sarkari', 'show schemes', 'my schemes', 'available schemes',
      'which scheme', 'what schemes',
      'योजना', 'योजनाएं', 'योजनाओं', 'सरकारी', 'पात्र', 'पात्रता',
      'मेरी योजना', 'उपलब्ध योजना', 'कौन सी योजना',
      'माझ्या योजना', 'उपलब्ध योजना', 'कोणती योजना',
    ],
    ChatIntent.schemeRecommendation: [
      'best scheme', 'recommend', 'suggestion', 'suitable', 'which is best',
      'best for me', 'right scheme', 'suggest scheme',
      'सबसे अच्छी योजना', 'सुझाव', 'उपयुक्त', 'मेरे लिए सबसे अच्छा',
      'सर्वोत्तम योजना', 'सूचना', 'माझ्यासाठी सर्वोत्तम',
    ],
    ChatIntent.cropScheme: [
      'scheme for rice', 'scheme for wheat', 'scheme for cotton',
      'scheme for sugarcane', 'scheme for maize', 'scheme for pulses',
      'scheme for vegetables', 'scheme for fruits', 'scheme for oilseeds',
      'crop specific scheme', 'schemes for my crop',
      'फसल के लिए योजना', 'मेरी फसल के लिए', 'पिकासाठी योजना',
    ],
    ChatIntent.insuranceCheck: [
      'insurance', 'bima', 'insure', 'crop protection',
      'protect crop', 'premium', 'claim', 'coverage',
      'बीमा', 'विमा', 'फसल सुरक्षा', 'पीक संरक्षण',
      'प्रीमियम', 'दावा', 'कवरेज',
    ],
    ChatIntent.insuranceDetail: [
      'pmfby details', 'fasal bima details', 'weather insurance',
      'livestock insurance', 'cattle insurance', 'life insurance',
      'jeevan jyoti', 'wbcis details',
      'बीमा विवरण', 'बीमा तपशील',
    ],
    ChatIntent.loanGeneral: [
      'loan', 'loans', 'rin', 'credit', 'borrow', 'finance',
      'bank loan', 'karz', 'interest rate', 'emi',
      'ऋण', 'कर्ज', 'लोन', 'उधार', 'ब्याज दर',
      'कर्ज मिळवा', 'व्याजदर',
    ],
    ChatIntent.loanDetail: [
      'kcc details', 'kisan credit card details', 'crop loan details',
      'tractor loan details', 'equipment loan details', 'mudra loan details',
      'केसीसी विवरण', 'फसल ऋण विवरण', 'ट्रैक्टर ऋण',
    ],
    ChatIntent.subsidyGeneral: [
      'subsidy', 'subsidies', 'grant', 'sahayata',
      'anudaan', 'financial help', 'support money',
      'सब्सिडी', 'अनुदान', 'सहायता', 'आर्थिक मदद',
      'अनुदान', 'सहाय्य', 'आर्थिक मदत',
    ],
    ChatIntent.subsidyDetail: [
      'fertilizer subsidy', 'seed subsidy', 'equipment subsidy',
      'pm kisan subsidy', 'kusum subsidy', 'solar subsidy',
      'उर्वरक सब्सिडी', 'बीज सब्सिडी', 'उपकरण सब्सिडी',
      'खत अनुदान', 'बियाणे अनुदान',
    ],
    ChatIntent.weatherCheck: [
      'weather', 'mausam', 'temperature', 'rain', 'rainfall',
      'forecast', 'humidity', 'wind',
      'मौसम', 'तापमान', 'बारिश', 'वर्षा', 'आर्द्रता', 'हवा',
      'हवामान', 'पाऊस', 'वारा',
    ],
    ChatIntent.farmingTips: [
      'farming tip', 'farming advice', 'crop advice', 'agriculture tip',
      'what to grow', 'what to plant', 'season', 'sowing', 'harvesting',
      'kharif', 'rabi', 'zaid', 'best time to sow', 'when to plant',
      'pest control', 'fertilizer advice', 'irrigation advice',
      'खेती सुझाव', 'फसल सलाह', 'कृषि सुझाव', 'क्या उगाएं', 'बुवाई',
      'कटाई', 'खरीफ', 'रबी', 'कीट नियंत्रण',
      'शेती सल्ला', 'पीक सल्ला', 'काय पेरावे', 'पेरणी', 'काढणी',
    ],
    ChatIntent.cropInfo: [
      'about rice', 'about wheat', 'about cotton', 'about sugarcane',
      'how to grow', 'crop information', 'crop details',
      'चावल के बारे में', 'गेहूं के बारे में', 'कपास के बारे में',
      'कसे पिकवावे', 'पीक माहिती',
    ],
    ChatIntent.profileStatus: [
      'my profile', 'profile status', 'profile complete', 'profile summary',
      'show profile', 'account info', 'my details', 'my information',
      'मेरी प्रोफ़ाइल', 'प्रोफ़ाइल स्थिति', 'मेरा विवरण',
      'माझी प्रोफाइल', 'प्रोफाइल स्थिती', 'माझा तपशील',
    ],
    ChatIntent.documentHelp: [
      'document', 'documents needed', 'papers required', 'what papers',
      'aadhaar', 'aadhar', 'pan card', '7/12', 'seven twelve',
      'saat bara', 'land record', 'bank passbook', 'how to upload',
      'दस्तावेज़', 'कागजात', 'आधार', 'पैन कार्ड', 'सात बारा',
      'भूमि रिकॉर्ड', 'बैंक पासबुक',
      'कागदपत्रे', 'पॅन कार्ड', 'जमीन नोंद',
    ],
    ChatIntent.applicationProcess: [
      'how to apply', 'apply', 'application', 'registration', 'register',
      'apply online', 'application process', 'steps to apply', 'kaise apply',
      'आवेदन कैसे करें', 'कैसे करें अप्लाई', 'पंजीकरण',
      'अर्ज कसा करावा', 'नोंदणी कशी करावी',
    ],
    ChatIntent.help: [
      'help', 'how to use', 'guide', 'what can you do', 'use app',
      'assist', 'support', 'features',
      'मदद', 'सहायता', 'कैसे', 'गाइड', 'ऐप', 'उपयोग',
      'मदत', 'सहाय्य', 'कसे', 'मार्गदर्शन', 'अॅप', 'वापर',
    ],
    ChatIntent.thanks: [
      'thank', 'thanks', 'thank you', 'great', 'awesome',
      'helpful', 'nice', 'shukriya', 'perfect', 'wonderful',
      'धन्यवाद', 'शुक्रिया', 'बहुत अच्छा', 'बढ़िया',
      'आभारी', 'छान', 'खूप चांगले',
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
  static ChatIntent detectIntent(String message) {
    final lowerMessage = message.toLowerCase().trim();
    if (lowerMessage.isEmpty) return ChatIntent.unknown;

    // Check if a specific scheme name is mentioned
    final schemeEntity = extractSchemeId(message);
    // Check if specific loan name mentioned
    final loanEntity = extractLoanName(message);
    // Check if specific insurance name mentioned
    final insuranceEntity = extractInsuranceName(message);
    // Check for crop name
    final cropEntity = extractCropName(message);

    if (loanEntity != null) return ChatIntent.loanDetail;
    if (insuranceEntity != null) return ChatIntent.insuranceDetail;
    if (schemeEntity != null) return ChatIntent.schemeDetail;
    if (cropEntity != null && _hasSchemeContext(lowerMessage)) return ChatIntent.cropScheme;

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

  /// Check if message has scheme context words
  static bool _hasSchemeContext(String msg) {
    const words = [
      'scheme', 'yojana', 'yojna', 'government', 'sarkari',
      'eligible', 'benefit', 'subsidy', 'insurance', 'for',
      'योजना', 'सरकारी', 'पात्र', 'लाभ', 'के लिए',
      'योजना', 'साठी', 'पात्र', 'फायदे',
    ];
    return words.any((w) => msg.contains(w));
  }

  /// Extract scheme ID from message
  static String? extractSchemeId(String message) {
    final lowerMessage = message.toLowerCase().trim();
    final sortedKeys = _schemeAliases.keys.toList()
      ..sort((a, b) => b.length.compareTo(a.length));
    for (final alias in sortedKeys) {
      if (lowerMessage.contains(alias.toLowerCase())) {
        return _schemeAliases[alias];
      }
    }
    return null;
  }

  /// Extract crop name from message
  static String? extractCropName(String message) {
    final lowerMessage = message.toLowerCase().trim();
    final sortedKeys = _cropAliases.keys.toList()
      ..sort((a, b) => b.length.compareTo(a.length));
    for (final alias in sortedKeys) {
      if (lowerMessage.contains(alias.toLowerCase())) {
        return _cropAliases[alias];
      }
    }
    return null;
  }

  /// Extract loan name from message
  static String? extractLoanName(String message) {
    final lowerMessage = message.toLowerCase().trim();
    final sortedKeys = _loanAliases.keys.toList()
      ..sort((a, b) => b.length.compareTo(a.length));
    for (final alias in sortedKeys) {
      if (lowerMessage.contains(alias.toLowerCase())) {
        return _loanAliases[alias];
      }
    }
    return null;
  }

  /// Extract insurance product name from message
  static String? extractInsuranceName(String message) {
    final lowerMessage = message.toLowerCase().trim();
    final sortedKeys = _insuranceAliases.keys.toList()
      ..sort((a, b) => b.length.compareTo(a.length));
    for (final alias in sortedKeys) {
      if (lowerMessage.contains(alias.toLowerCase())) {
        return _insuranceAliases[alias];
      }
    }
    return null;
  }

  /// Calculate match score based on keyword presence
  static int _calculateMatchScore(String message, List<String> keywords) {
    int score = 0;
    for (final keyword in keywords) {
      if (message.contains(keyword.toLowerCase())) {
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
