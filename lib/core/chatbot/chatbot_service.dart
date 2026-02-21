import '../../data/models/farmer_profile.dart';
import '../../data/schemes_data.dart';
import '../../features/finance/data/crop_finance_data.dart';
import '../services/schemes_service.dart';
import 'chatbot_intents.dart';
import 'chatbot_response.dart';

/// Chatbot Service - Intelligent rule-based chatbot for farmer queries
/// Handles message processing, intent detection, entity extraction, and
/// response generation using all app data sources
class ChatbotService {
  ChatbotService._();
  static final ChatbotService _instance = ChatbotService._();
  static ChatbotService get instance => _instance;

  /// Handle incoming user message
  ChatbotResponse handleMessage(String message, FarmerProfile profile, {String languageCode = 'en'}) {
    if (message.trim().isEmpty) return ChatbotResponse.unknown();

    final intent = IntentDetector.detectIntent(message);

    switch (intent) {
      case ChatIntent.greeting:
        return ChatbotResponse.greeting();

      case ChatIntent.schemeCheck:
        return _handleSchemeCheck(profile, languageCode);

      case ChatIntent.schemeDetail:
        return _handleSchemeDetail(message, profile, languageCode);

      case ChatIntent.schemeRecommendation:
        return _handleSchemeRecommendation(profile, languageCode);

      case ChatIntent.cropScheme:
        return _handleCropScheme(message, profile, languageCode);

      case ChatIntent.insuranceCheck:
        return ChatbotResponse.insuranceInfo();

      case ChatIntent.insuranceDetail:
        return _handleInsuranceDetail(message, profile, languageCode);

      case ChatIntent.loanGeneral:
        return _handleLoanGeneral(profile, languageCode);

      case ChatIntent.loanDetail:
        return _handleLoanDetail(message, profile, languageCode);

      case ChatIntent.subsidyGeneral:
        return _handleSubsidyGeneral(profile, languageCode);

      case ChatIntent.subsidyDetail:
        return _handleSubsidyGeneral(profile, languageCode);

      case ChatIntent.weatherCheck:
        return _handleWeatherCheck(languageCode);

      case ChatIntent.farmingTips:
        return _handleFarmingTips(profile, languageCode);

      case ChatIntent.cropInfo:
        return _handleCropInfo(message, languageCode);

      case ChatIntent.profileStatus:
        return _handleProfileStatus(profile, languageCode);

      case ChatIntent.documentHelp:
        return _handleDocumentHelp(profile, languageCode);

      case ChatIntent.applicationProcess:
        return _handleApplicationProcess(languageCode);

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

  // ==================== Scheme Handlers ====================

  /// Handle general scheme eligibility check
  ChatbotResponse _handleSchemeCheck(FarmerProfile profile, String languageCode) {
    if (!profile.hasState) return ChatbotResponse.profileIncomplete();

    // Try JSON schemes first (richer data)
    final schemesService = SchemesService.instance;
    if (schemesService.isLoaded) {
      final eligible = schemesService.getEligibleSchemes(
        state: profile.selectedState,
        crops: profile.selectedCrops,
        landSize: profile.landSizeAcres > 0 ? profile.landSizeAcres : null,
      );
      final names = eligible.map((s) => s.getLocalizedName(languageCode)).toList();
      return ChatbotResponse.schemeResult(
        count: eligible.length,
        schemeNames: names,
        languageCode: languageCode,
      );
    }

    // Fallback to static schemes data
    final allSchemes = SchemesData.allSchemes;
    final eligible = allSchemes.where((scheme) {
      final stateOk = scheme.supportedStates.contains('All') ||
          scheme.supportedStates.contains(profile.selectedState);
      final cropOk = scheme.supportedCrops.contains('All') ||
          profile.selectedCrops.any((c) => scheme.supportedCrops.contains(c)) ||
          profile.selectedCrops.isEmpty;
      final landOk = (scheme.minLandAcres == null || profile.landSizeAcres >= scheme.minLandAcres!) &&
          (scheme.maxLandAcres == null || profile.landSizeAcres <= scheme.maxLandAcres! || profile.landSizeAcres == 0);
      return stateOk && cropOk && landOk;
    }).toList();

    final names = eligible.map((s) => s.getLocalizedName(languageCode)).toList();
    return ChatbotResponse.schemeResult(
      count: eligible.length,
      schemeNames: names,
      languageCode: languageCode,
    );
  }

  /// Handle specific scheme detail request
  ChatbotResponse _handleSchemeDetail(String message, FarmerProfile profile, String languageCode) {
    final schemeId = IntentDetector.extractSchemeId(message);

    // Try JSON schemes for rich data
    final schemesService = SchemesService.instance;
    if (schemesService.isLoaded && schemeId != null) {
      final jsonScheme = schemesService.allSchemes
          .where((s) => s.id == schemeId)
          .firstOrNull;

      if (jsonScheme != null) {
        return ChatbotResponse.schemeDetailResponse(
          nameEn: jsonScheme.name,
          nameHi: jsonScheme.nameHi,
          descriptionEn: jsonScheme.description,
          descriptionHi: jsonScheme.descriptionHi,
          benefitEn: jsonScheme.benefit,
          benefitHi: jsonScheme.benefitHi,
          eligibilityEn: jsonScheme.eligibility,
          eligibilityHi: jsonScheme.eligibilityHi,
          category: jsonScheme.category,
          docsEn: jsonScheme.docs,
          docsHi: jsonScheme.docsHi,
          deadlineEn: jsonScheme.deadline,
          deadlineHi: jsonScheme.deadlineHi,
          url: jsonScheme.url,
        );
      }
    }

    // Fallback to static schemes
    if (schemeId != null) {
      final scheme = SchemesData.getSchemeById(schemeId);
      if (scheme != null) {
        return _buildStaticSchemeDetail(scheme, languageCode);
      }
    }

    // Could not find specific scheme - show general list
    return _handleSchemeCheck(profile, languageCode);
  }

  /// Build scheme detail from static data
  ChatbotResponse _buildStaticSchemeDetail(dynamic scheme, String languageCode) {
    // Static scheme data - build a comprehensive response
    final Map<String, Map<String, String>> schemeDetails = {
      'pm_kisan': {
        'descEn': 'Direct income support of ₹6,000 per year to farmer families across India in 3 installments of ₹2,000 each.',
        'descHi': 'पूरे भारत में किसान परिवारों को ₹2,000 की 3 किस्तों में प्रति वर्ष ₹6,000 की सीधी आय सहायता।',
        'benefitEn': '₹6,000/year (3 installments of ₹2,000 each)',
        'benefitHi': '₹6,000/वर्ष (₹2,000 की 3 किस्तें)',
        'eligibilityEn': 'All farmer families with cultivable landholding',
        'eligibilityHi': 'खेती योग्य भूमि वाले सभी किसान परिवार',
        'url': 'https://pmkisan.gov.in/',
      },
      'pmfby': {
        'descEn': 'Comprehensive crop insurance scheme providing financial support against crop loss due to natural calamities, pests, and diseases.',
        'descHi': 'प्राकृतिक आपदाओं, कीटों और रोगों से फसल हानि के विरुद्ध वित्तीय सहायता प्रदान करने वाली व्यापक फसल बीमा योजना।',
        'benefitEn': 'Insurance at 2% premium for Kharif, 1.5% for Rabi crops',
        'benefitHi': 'खरीफ के लिए 2%, रबी फसलों के लिए 1.5% प्रीमियम पर बीमा',
        'eligibilityEn': 'All farmers growing notified crops in notified areas',
        'eligibilityHi': 'अधिसूचित क्षेत्रों में अधिसूचित फसल उगाने वाले सभी किसान',
        'url': 'https://pmfby.gov.in/',
      },
      'kcc': {
        'descEn': 'Provides farmers with timely access to credit for agricultural needs at just 4% interest rate with up to ₹3 lakh without collateral.',
        'descHi': 'किसानों को कृषि जरूरतों के लिए 4% ब्याज दर पर बिना गारंटी ₹3 लाख तक का समय पर ऋण प्रदान करता है।',
        'benefitEn': 'Credit at 4% interest, ₹3 lakh without collateral',
        'benefitHi': '4% ब्याज पर ऋण, बिना गारंटी ₹3 लाख',
        'eligibilityEn': 'All farmers - owner cultivators, tenant farmers, sharecroppers',
        'eligibilityHi': 'सभी किसान - मालिक किसान, किरायेदार किसान, बटाईदार',
        'url': 'https://www.jansamarth.in/kisan-credit-card-scheme',
      },
      'soil_health_card': {
        'descEn': 'Provides soil health cards with crop-wise nutrient and fertilizer recommendations based on soil testing.',
        'descHi': 'मृदा परीक्षण के आधार पर फसल-वार पोषक तत्व और उर्वरक सिफारिशों वाले मृदा स्वास्थ्य कार्ड प्रदान करता है।',
        'benefitEn': 'Free comprehensive soil nutrient report every 2 years',
        'benefitHi': 'हर 2 साल में मुफ्त व्यापक मृदा पोषक तत्व रिपोर्ट',
        'eligibilityEn': 'All farmers with agricultural land',
        'eligibilityHi': 'कृषि भूमि वाले सभी किसान',
        'url': 'https://soilhealth.dac.gov.in/',
      },
      'enam': {
        'descEn': 'Online trading platform for agricultural commodities connecting farmers directly to markets across India for better price discovery.',
        'descHi': 'बेहतर मूल्य खोज के लिए किसानों को सीधे भारत भर के बाजारों से जोड़ने वाला कृषि वस्तुओं का ऑनलाइन ट्रेडिंग प्लेटफॉर्म।',
        'benefitEn': 'Direct selling to Mandis, better price discovery, reduced intermediaries',
        'benefitHi': 'मंडियों में सीधे बिक्री, बेहतर मूल्य खोज, बिचौलिये कम',
        'eligibilityEn': 'All farmers with agricultural produce',
        'eligibilityHi': 'कृषि उत्पादन वाले सभी किसान',
        'url': 'https://enam.gov.in/',
      },
      'pkvy': {
        'descEn': 'Promotes organic farming through cluster approach. Farmers in groups of 50+ hectares get financial assistance for organic certification.',
        'descHi': 'क्लस्टर दृष्टिकोण के माध्यम से जैविक खेती को बढ़ावा देता है। 50+ हेक्टेयर के समूहों में किसानों को जैविक प्रमाणन के लिए वित्तीय सहायता।',
        'benefitEn': '₹50,000/hectare over 3 years for organic farming',
        'benefitHi': 'जैविक खेती के लिए 3 वर्षों में ₹50,000/हेक्टेयर',
        'eligibilityEn': 'Farmers forming clusters of 50+ hectares for organic farming',
        'eligibilityHi': 'जैविक खेती के लिए 50+ हेक्टेयर के क्लस्टर बनाने वाले किसान',
        'url': 'https://pgsindia-ncof.gov.in/',
      },
    };

    final details = schemeDetails[scheme.id];
    if (details != null) {
      return ChatbotResponse.schemeDetailResponse(
        nameEn: scheme.nameEn,
        nameHi: scheme.nameHi,
        descriptionEn: details['descEn']!,
        descriptionHi: details['descHi']!,
        benefitEn: details['benefitEn']!,
        benefitHi: details['benefitHi']!,
        eligibilityEn: details['eligibilityEn']!,
        eligibilityHi: details['eligibilityHi']!,
        category: scheme.category,
        url: details['url'],
      );
    }

    // Generic fallback for unknown scheme detail
    return ChatbotResponse.schemeDetailResponse(
      nameEn: scheme.nameEn,
      nameHi: scheme.nameHi,
      descriptionEn: 'A government scheme available for eligible farmers.',
      descriptionHi: 'पात्र किसानों के लिए उपलब्ध सरकारी योजना।',
      benefitEn: 'Various benefits for eligible farmers',
      benefitHi: 'पात्र किसानों के लिए विभिन्न लाभ',
      eligibilityEn: 'Check eligibility based on your profile',
      eligibilityHi: 'अपनी प्रोफ़ाइल के आधार पर पात्रता जांचें',
      category: scheme.category,
    );
  }

  /// Handle personalized scheme recommendation
  ChatbotResponse _handleSchemeRecommendation(FarmerProfile profile, String languageCode) {
    if (!profile.hasState) return ChatbotResponse.profileIncomplete();

    // Get eligible schemes and prioritize
    final schemesService = SchemesService.instance;
    List<String> topSchemes = [];
    String personalNote = '';
    String personalNoteHi = '';

    if (schemesService.isLoaded) {
      final eligible = schemesService.getEligibleSchemes(
        state: profile.selectedState,
        crops: profile.selectedCrops,
        landSize: profile.landSizeAcres > 0 ? profile.landSizeAcres : null,
      );

      topSchemes = eligible.take(5).map((s) => s.getLocalizedName(languageCode)).toList();

      if (profile.landSizeAcres > 0 && profile.landSizeAcres <= 2) {
        personalNote = '\n\n💡 As a small farmer (${profile.landSizeAcres} acres), you may get priority benefits in KCC and subsidy schemes.';
        personalNoteHi = '\n\n💡 एक छोटे किसान (${profile.landSizeAcres} एकड़) के रूप में, आपको KCC और सब्सिडी योजनाओं में प्राथमिकता लाभ मिल सकते हैं।';
      }
    } else {
      return _handleSchemeCheck(profile, languageCode);
    }

    if (topSchemes.isEmpty) return ChatbotResponse.profileIncomplete();

    return ChatbotResponse(
      message: '⭐ **Recommended schemes for you:**\n\n${topSchemes.map((n) => '• $n').join('\n')}$personalNote\n\nAsk about any scheme by name for full details!',
      messageHi: '⭐ **आपके लिए अनुशंसित योजनाएं:**\n\n${topSchemes.map((n) => '• $n').join('\n')}$personalNoteHi\n\nपूर्ण विवरण के लिए किसी भी योजना का नाम पूछें!',
      type: ResponseType.schemeList,
      schemeNames: topSchemes,
      showSchemesButton: true,
    );
  }

  /// Handle crop-specific scheme query
  ChatbotResponse _handleCropScheme(String message, FarmerProfile profile, String languageCode) {
    final cropName = IntentDetector.extractCropName(message);
    if (cropName == null) return _handleSchemeCheck(profile, languageCode);

    // Filter schemes supporting this crop
    final schemesService = SchemesService.instance;
    List<String> matchingSchemes = [];

    if (schemesService.isLoaded) {
      final schemes = schemesService.allSchemes.where((s) {
        if (s.supportsAllCrops) return true;
        return s.params.crops.any((c) => c.toLowerCase() == cropName.toLowerCase());
      }).toList();

      // Also filter by state if available
      if (profile.hasState) {
        final stateFiltered = schemes.where((s) {
          if (s.supportsAllStates) return true;
          final states = s.params.states;
          return states.any((st) => st.toLowerCase() == profile.selectedState!.toLowerCase());
        }).toList();
        matchingSchemes = stateFiltered.map((s) => s.getLocalizedName(languageCode)).toList();
      } else {
        matchingSchemes = schemes.map((s) => s.getLocalizedName(languageCode)).toList();
      }
    } else {
      // Fallback to static data
      final schemes = SchemesData.allSchemes.where((s) {
        return s.supportedCrops.contains('All') ||
            s.supportedCrops.contains(cropName);
      }).toList();
      matchingSchemes = schemes.map((s) => s.getLocalizedName(languageCode)).toList();
    }

    return ChatbotResponse.cropSchemeResult(
      cropName: cropName,
      schemeNames: matchingSchemes,
      languageCode: languageCode,
    );
  }

  // ==================== Finance Handlers ====================

  /// Handle general loan query
  ChatbotResponse _handleLoanGeneral(FarmerProfile profile, String languageCode) {
    final income = CropFinanceDataGenerator.getAnnualIncomeValue(profile.annualIncome);
    final landSize = profile.landSizeAcres > 0 ? profile.landSizeAcres : 2.0;
    final loans = CropFinanceDataGenerator.generateLoanData(income, landSize);

    final loanSummaries = loans.map((l) => {
      'name': l.name,
      'nameHi': l.nameHi,
      'rate': l.interestRate.toStringAsFixed(1),
      'amount': l.eligibleAmount >= 100000
          ? '${(l.eligibleAmount / 100000).toStringAsFixed(1)} Lakh'
          : l.eligibleAmount.toStringAsFixed(0),
    }).toList();

    return ChatbotResponse.loanListResponse(
      loans: loanSummaries,
      languageCode: languageCode,
    );
  }

  /// Handle specific loan detail query
  ChatbotResponse _handleLoanDetail(String message, FarmerProfile profile, String languageCode) {
    final loanName = IntentDetector.extractLoanName(message);
    final income = CropFinanceDataGenerator.getAnnualIncomeValue(profile.annualIncome);
    final landSize = profile.landSizeAcres > 0 ? profile.landSizeAcres : 2.0;
    final loans = CropFinanceDataGenerator.generateLoanData(income, landSize);

    if (loanName != null) {
      // Find the matching loan
      final loan = loans.where((l) {
        final nameLC = l.name.toLowerCase();
        final queryLC = loanName.toLowerCase();
        return nameLC.contains(queryLC) || queryLC.contains(nameLC.split(' ').first);
      }).firstOrNull;

      if (loan != null) {
        return ChatbotResponse.loanDetailResponse(
          nameEn: loan.name,
          nameHi: loan.nameHi,
          descEn: loan.description,
          descHi: loan.descriptionHi,
          interestRate: loan.interestRate,
          eligibleAmount: loan.eligibleAmount,
          tenure: loan.tenure,
          provider: loan.provider,
          benefitsEn: loan.benefits,
          benefitsHi: loan.benefitsHi,
        );
      }
    }

    // Fallback to loan list
    return _handleLoanGeneral(profile, languageCode);
  }

  /// Handle subsidy query
  ChatbotResponse _handleSubsidyGeneral(FarmerProfile profile, String languageCode) {
    final income = CropFinanceDataGenerator.getAnnualIncomeValue(profile.annualIncome);
    final landSize = profile.landSizeAcres > 0 ? profile.landSizeAcres : 2.0;
    final subsidies = CropFinanceDataGenerator.generateSubsidyData(income, landSize);

    final subsidySummaries = subsidies.map((s) => {
      'name': s.name,
      'nameHi': s.nameHi,
      'amount': s.amount >= 1000
          ? '${(s.amount / 1000).toStringAsFixed(0)}K'
          : s.amount.toStringAsFixed(0),
      'frequency': s.frequency,
      'frequencyHi': s.frequencyHi,
    }).toList();

    return ChatbotResponse.subsidyListResponse(
      subsidies: subsidySummaries,
      languageCode: languageCode,
    );
  }

  // ==================== Insurance Handlers ====================

  /// Handle specific insurance detail
  ChatbotResponse _handleInsuranceDetail(String message, FarmerProfile profile, String languageCode) {
    final insuranceName = IntentDetector.extractInsuranceName(message);
    final income = CropFinanceDataGenerator.getAnnualIncomeValue(profile.annualIncome);
    final landSize = profile.landSizeAcres > 0 ? profile.landSizeAcres : 2.0;
    final insurances = CropFinanceDataGenerator.generateInsuranceData(income, landSize);

    if (insuranceName != null) {
      final insurance = insurances.where((i) {
        final nameLC = i.name.toLowerCase();
        final queryLC = insuranceName.toLowerCase();
        return nameLC.contains(queryLC) || queryLC.contains(nameLC.split(' ').first);
      }).firstOrNull;

      if (insurance != null) {
        return ChatbotResponse.insuranceDetailResponse(
          nameEn: insurance.name,
          nameHi: insurance.nameHi,
          descEn: insurance.description,
          descHi: insurance.descriptionHi,
          premium: insurance.premiumPercentage,
          sumInsured: insurance.sumInsured,
          coverageEn: insurance.coverage,
          coverageHi: insurance.coverageHi,
          risksEn: insurance.coveredRisks,
          risksHi: insurance.coveredRisksHi,
        );
      }
    }

    // Fallback to general insurance info
    return ChatbotResponse.insuranceInfo();
  }

  // ==================== Weather & Farming Handlers ====================

  /// Handle weather check
  ChatbotResponse _handleWeatherCheck(String languageCode) {
    return ChatbotResponse.weatherTipResponse(
      season: _getCurrentSeason(),
      tipEn: '🌤️ **Weather & Farming Advisory**\n\nFor real-time weather data, check the Weather section in the app.\n\n📍 Current Season: ${_getCurrentSeason()}\n\n🌾 Season Tips:\n${_getSeasonTipsEn()}\n\nTap below to view detailed weather forecast.',
      tipHi: '🌤️ **मौसम और कृषि सलाह**\n\nवास्तविक समय मौसम डेटा के लिए, ऐप में मौसम अनुभाग देखें।\n\n📍 वर्तमान मौसम: ${_getCurrentSeasonHi()}\n\n🌾 मौसम सुझाव:\n${_getSeasonTipsHi()}\n\nविस्तृत मौसम पूर्वानुमान देखने के लिए नीचे टैप करें।',
      tipMr: '🌤️ **हवामान आणि शेती सल्ला**\n\nरिअल-टाइम हवामान डेटासाठी अॅपमध्ये हवामान विभाग पहा.\n\n📍 सध्याचा हंगाम: ${_getCurrentSeasonMr()}\n\n🌾 हंगामी सल्ला:\n${_getSeasonTipsMr()}\n\nतपशीलवार हवामान अंदाज पाहण्यासाठी खाली टॅप करा.',
    );
  }

  /// Handle farming tips
  ChatbotResponse _handleFarmingTips(FarmerProfile profile, String languageCode) {
    final season = _getCurrentSeason();
    final crops = profile.selectedCrops;
    String cropAdviceEn = '';
    String cropAdviceHi = '';
    String cropAdviceMr = '';

    if (crops.isNotEmpty) {
      cropAdviceEn = '\n\n🌱 **Tips for your crops (${crops.join(', ')}):**\n${_getCropTipsEn(crops)}';
      cropAdviceHi = '\n\n🌱 **आपकी फसलों के लिए सुझाव (${crops.join(', ')}):**\n${_getCropTipsHi(crops)}';
      cropAdviceMr = '\n\n🌱 **तुमच्या पिकांसाठी सल्ला (${crops.join(', ')}):**\n${_getCropTipsMr(crops)}';
    }

    return ChatbotResponse.weatherTipResponse(
      season: season,
      tipEn: '🌾 **Farming Tips - ${_getCurrentSeason()} Season**\n\n${_getSeasonTipsEn()}$cropAdviceEn\n\n💡 Complete your profile for personalized crop advice!',
      tipHi: '🌾 **खेती सुझाव - ${_getCurrentSeasonHi()} मौसम**\n\n${_getSeasonTipsHi()}$cropAdviceHi\n\n💡 व्यक्तिगत फसल सलाह के लिए प्रोफ़ाइल पूरी करें!',
      tipMr: '🌾 **शेती सल्ला - ${_getCurrentSeasonMr()} हंगाम**\n\n${_getSeasonTipsMr()}$cropAdviceMr\n\n💡 वैयक्तिक पीक सल्ल्यासाठी प्रोफाइल पूर्ण करा!',
    );
  }

  /// Handle crop info request
  ChatbotResponse _handleCropInfo(String message, String languageCode) {
    final cropName = IntentDetector.extractCropName(message);
    if (cropName == null) {
      return _handleFarmingTips(const FarmerProfile(), languageCode);
    }

    final info = _getCropDetails(cropName);
    return ChatbotResponse(
      message: info['en']!,
      messageHi: info['hi'],
      messageMr: info['mr'],
      type: ResponseType.farmingTip,
    );
  }

  // ==================== Profile & Document Handlers ====================

  /// Handle profile status
  ChatbotResponse _handleProfileStatus(FarmerProfile profile, String languageCode) {
    final completion = profile.completionPercentage;
    final percent = (completion * 100).toInt();

    final stateEn = profile.hasState ? '✅ State: ${profile.selectedState}' : '❌ State: Not set';
    final cropsEn = profile.hasCrops ? '✅ Crops: ${profile.selectedCrops.join(', ')}' : '❌ Crops: Not selected';
    final landEn = profile.hasLandSize ? '✅ Land: ${profile.landSizeAcres} acres' : '❌ Land Size: Not set';
    final nameEn = profile.hasPersonalDetails ? '✅ Name: ${profile.fullName}' : '❌ Name: Not filled';
    final aadhaarEn = profile.hasAadhaar ? '✅ Aadhaar: ${profile.maskedAadhaar}' : '❌ Aadhaar: Not added';
    final bankEn = profile.hasBankDetails ? '✅ Bank: ${profile.maskedBankAccount}' : '❌ Bank: Not added';

    final stateHi = profile.hasState ? '✅ राज्य: ${profile.selectedState}' : '❌ राज्य: सेट नहीं';
    final cropsHi = profile.hasCrops ? '✅ फसलें: ${profile.selectedCrops.join(', ')}' : '❌ फसलें: चयनित नहीं';
    final landHi = profile.hasLandSize ? '✅ भूमि: ${profile.landSizeAcres} एकड़' : '❌ भूमि आकार: सेट नहीं';
    final nameHi = profile.hasPersonalDetails ? '✅ नाम: ${profile.fullName}' : '❌ नाम: नहीं भरा';
    final aadhaarHi = profile.hasAadhaar ? '✅ आधार: ${profile.maskedAadhaar}' : '❌ आधार: नहीं जोड़ा';
    final bankHi = profile.hasBankDetails ? '✅ बैंक: ${profile.maskedBankAccount}' : '❌ बैंक: नहीं जोड़ा';

    final stateMr = profile.hasState ? '✅ राज्य: ${profile.selectedState}' : '❌ राज्य: सेट नाही';
    final cropsMr = profile.hasCrops ? '✅ पिके: ${profile.selectedCrops.join(', ')}' : '❌ पिके: निवडलेली नाहीत';
    final landMr = profile.hasLandSize ? '✅ जमीन: ${profile.landSizeAcres} एकर' : '❌ जमिनीचा आकार: सेट नाही';
    final nameMr = profile.hasPersonalDetails ? '✅ नाव: ${profile.fullName}' : '❌ नाव: भरलेले नाही';
    final aadhaarMr = profile.hasAadhaar ? '✅ आधार: ${profile.maskedAadhaar}' : '❌ आधार: जोडलेला नाही';
    final bankMr = profile.hasBankDetails ? '✅ बँक: ${profile.maskedBankAccount}' : '❌ बँक: जोडलेली नाही';

    return ChatbotResponse.profileSummaryResponse(
      summaryEn: '👤 **Your Profile** ($percent% complete)\n\n$stateEn\n$cropsEn\n$landEn\n$nameEn\n$aadhaarEn\n$bankEn${percent < 100 ? '\n\n⚠️ Complete your profile for better scheme recommendations!' : '\n\n🎉 Your profile is complete! Ask me about eligible schemes.'}',
      summaryHi: '👤 **आपकी प्रोफ़ाइल** ($percent% पूर्ण)\n\n$stateHi\n$cropsHi\n$landHi\n$nameHi\n$aadhaarHi\n$bankHi${percent < 100 ? '\n\n⚠️ बेहतर योजना सिफारिशों के लिए प्रोफ़ाइल पूरी करें!' : '\n\n🎉 आपकी प्रोफ़ाइल पूरी है! पात्र योजनाओं के बारे में पूछें।'}',
      summaryMr: '👤 **तुमची प्रोफाइल** ($percent% पूर्ण)\n\n$stateMr\n$cropsMr\n$landMr\n$nameMr\n$aadhaarMr\n$bankMr${percent < 100 ? '\n\n⚠️ चांगल्या योजना शिफारसींसाठी प्रोफाइल पूर्ण करा!' : '\n\n🎉 तुमची प्रोफाइल पूर्ण आहे! पात्र योजनांबद्दल विचारा.'}',
      completionPercent: completion,
    );
  }

  /// Handle document help
  ChatbotResponse _handleDocumentHelp(FarmerProfile profile, String languageCode) {
    return ChatbotResponse.documentHelpResponse(
      messageEn: '📄 **Documents for Government Schemes:**\n\nMost schemes require these documents:\n\n1️⃣ **Aadhaar Card** - ${profile.hasAadhaar ? '✅ Added' : '❌ Not added'}\n2️⃣ **Land Records (7/12)** - ${profile.hasSevenTwelve ? '✅ Added' : '❌ Not added'}\n3️⃣ **Bank Account** - ${profile.hasBankDetails ? '✅ Added' : '❌ Not added'}\n4️⃣ **PAN Card** - ${profile.hasPan ? '✅ Added' : '❌ Not added'}\n5️⃣ **Passport Size Photos**\n6️⃣ **Income Certificate** (for some schemes)\n\n💡 You can add documents in the Profile section.\nAsk about a specific scheme (e.g. "PM-KISAN") to see its exact document requirements.',
      messageHi: '📄 **सरकारी योजनाओं के लिए दस्तावेज़:**\n\nअधिकांश योजनाओं के लिए ये दस्तावेज़ चाहिए:\n\n1️⃣ **आधार कार्ड** - ${profile.hasAadhaar ? '✅ जोड़ा गया' : '❌ नहीं जोड़ा'}\n2️⃣ **भूमि रिकॉर्ड (7/12)** - ${profile.hasSevenTwelve ? '✅ जोड़ा गया' : '❌ नहीं जोड़ा'}\n3️⃣ **बैंक खाता** - ${profile.hasBankDetails ? '✅ जोड़ा गया' : '❌ नहीं जोड़ा'}\n4️⃣ **पैन कार्ड** - ${profile.hasPan ? '✅ जोड़ा गया' : '❌ नहीं जोड़ा'}\n5️⃣ **पासपोर्ट साइज फोटो**\n6️⃣ **आय प्रमाण पत्र** (कुछ योजनाओं के लिए)\n\n💡 आप प्रोफ़ाइल में दस्तावेज़ जोड़ सकते हैं।\nकिसी योजना (जैसे "PM-KISAN") के बारे में पूछें उसके सटीक दस्तावेज़ जानने के लिए।',
      messageMr: '📄 **सरकारी योजनांसाठी कागदपत्रे:**\n\nबहुतेक योजनांसाठी ही कागदपत्रे आवश्यक आहेत:\n\n1️⃣ **आधार कार्ड** - ${profile.hasAadhaar ? '✅ जोडले' : '❌ जोडलेले नाही'}\n2️⃣ **जमीन नोंद (७/१२)** - ${profile.hasSevenTwelve ? '✅ जोडले' : '❌ जोडलेले नाही'}\n3️⃣ **बँक खाते** - ${profile.hasBankDetails ? '✅ जोडले' : '❌ जोडलेले नाही'}\n4️⃣ **पॅन कार्ड** - ${profile.hasPan ? '✅ जोडले' : '❌ जोडलेले नाही'}\n5️⃣ **पासपोर्ट आकाराचे फोटो**\n6️⃣ **उत्पन्न प्रमाणपत्र** (काही योजनांसाठी)\n\n💡 तुम्ही प्रोफाइलमध्ये कागदपत्रे जोडू शकता.\nविशिष्ट योजनेबद्दल (जसे "PM-KISAN") विचारा त्याच्या अचूक कागदपत्र आवश्यकता जाणून घ्या.',
    );
  }

  /// Handle application process
  ChatbotResponse _handleApplicationProcess(String languageCode) {
    return ChatbotResponse.applicationProcessResponse(
      messageEn: '📝 **How to Apply for Schemes:**\n\n**Step 1:** Complete your profile\n   • Add state, crops, land size\n   • Upload Aadhaar, bank details\n\n**Step 2:** Check eligible schemes\n   • Say "Show my schemes"\n   • I\'ll find matching ones\n\n**Step 3:** View scheme details\n   • Tap on any scheme for full info\n   • Check documents needed\n\n**Step 4:** Apply through official channels\n   • Visit scheme website (link provided)\n   • Or visit nearest CSC/Bank/Krishi Bhavan\n\n**Step 5:** Track status\n   • Use scheme portal for updates\n\n💡 Start by saying "Show my schemes"!',
      messageHi: '📝 **योजनाओं के लिए आवेदन कैसे करें:**\n\n**चरण 1:** प्रोफ़ाइल पूरी करें\n   • राज्य, फसलें, भूमि आकार जोड़ें\n   • आधार, बैंक विवरण अपलोड करें\n\n**चरण 2:** पात्र योजनाएं जांचें\n   • "मेरी योजनाएं दिखाओ" बोलें\n   • मैं मिलान करने वाली योजनाएं खोजूंगा\n\n**चरण 3:** योजना विवरण देखें\n   • पूर्ण जानकारी के लिए किसी भी योजना पर टैप करें\n   • आवश्यक दस्तावेज़ जांचें\n\n**चरण 4:** आधिकारिक चैनलों से आवेदन करें\n   • योजना वेबसाइट पर जाएं (लिंक दी गई है)\n   • या निकटतम CSC/बैंक/कृषि भवन जाएं\n\n**चरण 5:** स्थिति ट्रैक करें\n   • अपडेट के लिए योजना पोर्टल का उपयोग करें\n\n💡 "मेरी योजनाएं दिखाओ" बोलकर शुरू करें!',
    );
  }

  // ==================== Season & Crop Helpers ====================

  String _getCurrentSeason() {
    final month = DateTime.now().month;
    if (month >= 6 && month <= 10) return 'Kharif';
    if (month >= 11 || month <= 3) return 'Rabi';
    return 'Zaid (Summer)';
  }

  String _getCurrentSeasonHi() {
    final month = DateTime.now().month;
    if (month >= 6 && month <= 10) return 'खरीफ';
    if (month >= 11 || month <= 3) return 'रबी';
    return 'जायद (गर्मी)';
  }

  String _getCurrentSeasonMr() {
    final month = DateTime.now().month;
    if (month >= 6 && month <= 10) return 'खरीप';
    if (month >= 11 || month <= 3) return 'रब्बी';
    return 'उन्हाळी';
  }

  String _getSeasonTipsEn() {
    final month = DateTime.now().month;
    if (month >= 6 && month <= 10) {
      return '• 🌧️ Kharif season - Good for Rice, Maize, Cotton, Soybean\n• 💧 Ensure proper drainage during heavy rains\n• 🐛 Watch for pest infestations in humid weather\n• 🌱 Apply recommended fertilizers after soil test\n• 🛡️ Enroll in PMFBY before July 31 deadline';
    }
    if (month >= 11 || month <= 3) {
      return '• ❄️ Rabi season - Good for Wheat, Mustard, Chickpea, Barley\n• 💧 Schedule irrigation carefully in dry weather\n• 🌿 Protect crops from frost in cold regions\n• 📊 Get Soil Health Card for nutrient guidance\n• 🛡️ Enroll in PMFBY before December 31 deadline';
    }
    return '• ☀️ Zaid/Summer season - Good for Watermelon, Muskmelon, Cucumber, Moong\n• 💧 Increase irrigation frequency in hot weather\n• 🌡️ Use mulching to retain soil moisture\n• 🌻 Consider sunflower or summer vegetables\n• 🏗️ Prepare land for next Kharif season';
  }

  String _getSeasonTipsHi() {
    final month = DateTime.now().month;
    if (month >= 6 && month <= 10) {
      return '• 🌧️ खरीफ मौसम - चावल, मक्का, कपास, सोयाबीन के लिए अच्छा\n• 💧 भारी बारिश में उचित जल निकासी सुनिश्चित करें\n• 🐛 नम मौसम में कीट पर नज़र रखें\n• 🌱 मृदा परीक्षण के बाद उर्वरक लगाएं\n• 🛡️ 31 जुलाई से पहले PMFBY में नामांकन करें';
    }
    if (month >= 11 || month <= 3) {
      return '• ❄️ रबी मौसम - गेहूं, सरसों, चना, जौ के लिए अच्छा\n• 💧 सूखे मौसम में सिंचाई की योजना बनाएं\n• 🌿 ठंडे क्षेत्रों में फसलों को पाले से बचाएं\n• 📊 पोषक मार्गदर्शन के लिए मृदा स्वास्थ्य कार्ड बनवाएं\n• 🛡️ 31 दिसंबर से पहले PMFBY में नामांकन करें';
    }
    return '• ☀️ जायद/गर्मी मौसम - तरबूज, खरबूजा, खीरा, मूंग के लिए अच्छा\n• 💧 गर्म मौसम में सिंचाई बढ़ाएं\n• 🌡️ मिट्टी की नमी बनाए रखने के लिए मल्चिंग करें\n• 🌻 सूरजमुखी या गर्मी की सब्जियां लगाएं\n• 🏗️ अगले खरीफ मौसम के लिए खेत तैयार करें';
  }

  String _getSeasonTipsMr() {
    final month = DateTime.now().month;
    if (month >= 6 && month <= 10) {
      return '• 🌧️ खरीप हंगाम - तांदूळ, मका, कापूस, सोयाबीनसाठी चांगला\n• 💧 मुसळधार पावसात योग्य निचरा सुनिश्चित करा\n• 🐛 दमट हवामानात कीड-रोगांवर लक्ष ठेवा\n• 🌱 माती परीक्षणानंतर शिफारस केलेली खते वापरा\n• 🛡️ ३१ जुलैपूर्वी PMFBY मध्ये नोंदणी करा';
    }
    if (month >= 11 || month <= 3) {
      return '• ❄️ रब्बी हंगाम - गहू, मोहरी, हरभरा, जवसाठी चांगला\n• 💧 कोरड्या हवामानात सिंचन काळजीपूर्वक करा\n• 🌿 थंड भागात पिकांचे दवापासून संरक्षण करा\n• 📊 पोषक मार्गदर्शनासाठी मृदा आरोग्य कार्ड बनवा\n• 🛡️ ३१ डिसेंबरपूर्वी PMFBY मध्ये नोंदणी करा';
    }
    return '• ☀️ उन्हाळी हंगाम - कलिंगड, खरबूज, काकडी, मूगसाठी चांगला\n• 💧 उष्ण हवामानात सिंचन वाढवा\n• 🌡️ मातीत ओलावा टिकवण्यासाठी मल्चिंग करा\n• 🌻 सूर्यफूल किंवा उन्हाळी भाज्या लावा\n• 🏗️ पुढील खरीप हंगामासाठी जमीन तयार करा';
  }

  String _getCropTipsEn(List<String> crops) {
    final tips = <String>[];
    for (final crop in crops.take(3)) {
      switch (crop) {
        case 'Rice':
          tips.add('• 🌾 Rice: Ensure proper water management. Apply nitrogen in 3 splits.');
          break;
        case 'Wheat':
          tips.add('• 🌾 Wheat: Best sowing time Nov-Dec. Use certified seeds.');
          break;
        case 'Cotton':
          tips.add('• 🌿 Cotton: Watch for bollworm. Use integrated pest management.');
          break;
        case 'Sugarcane':
          tips.add('• 🎋 Sugarcane: Ensure adequate irrigation. De-trash at regular intervals.');
          break;
        case 'Maize':
          tips.add('• 🌽 Maize: Use hybrid varieties. Apply zinc sulfate for better yield.');
          break;
        case 'Pulses':
          tips.add('• 🫘 Pulses: Use Rhizobium culture treatment. Minimal fertilizer needed.');
          break;
        case 'Vegetables':
          tips.add('• 🥬 Vegetables: Use drip irrigation. Apply organic manure.');
          break;
        case 'Fruits':
          tips.add('• 🍎 Fruits: Regular pruning and mulching. Check for fruit fly.');
          break;
        default:
          tips.add('• 🌱 $crop: Follow recommended practices from Krishi Vigyan Kendra.');
      }
    }
    return tips.join('\n');
  }

  String _getCropTipsHi(List<String> crops) {
    final tips = <String>[];
    for (final crop in crops.take(3)) {
      switch (crop) {
        case 'Rice':
          tips.add('• 🌾 चावल: उचित जल प्रबंधन सुनिश्चित करें। नाइट्रोजन 3 भागों में दें।');
          break;
        case 'Wheat':
          tips.add('• 🌾 गेहूं: सबसे अच्छा बुवाई समय नवंबर-दिसंबर। प्रमाणित बीज उपयोग करें।');
          break;
        case 'Cotton':
          tips.add('• 🌿 कपास: बॉलवर्म पर नज़र रखें। एकीकृत कीट प्रबंधन करें।');
          break;
        case 'Sugarcane':
          tips.add('• 🎋 गन्ना: पर्याप्त सिंचाई सुनिश्चित करें। नियमित रूप से ट्रैशिंग करें।');
          break;
        default:
          tips.add('• 🌱 $crop: कृषि विज्ञान केंद्र की सिफारिशों का पालन करें।');
      }
    }
    return tips.join('\n');
  }

  String _getCropTipsMr(List<String> crops) {
    final tips = <String>[];
    for (final crop in crops.take(3)) {
      switch (crop) {
        case 'Rice':
          tips.add('• 🌾 तांदूळ: योग्य पाणी व्यवस्थापन सुनिश्चित करा.');
          break;
        case 'Wheat':
          tips.add('• 🌾 गहू: सर्वोत्तम पेरणी वेळ नोव्हें-डिसें. प्रमाणित बियाणे वापरा.');
          break;
        case 'Cotton':
          tips.add('• 🌿 कापूस: बोंडअळीवर लक्ष ठेवा. एकात्मिक कीड व्यवस्थापन करा.');
          break;
        case 'Sugarcane':
          tips.add('• 🎋 ऊस: पुरेशा सिंचनाची खात्री करा.');
          break;
        default:
          tips.add('• 🌱 $crop: कृषी विज्ञान केंद्राच्या शिफारशींचे पालन करा.');
      }
    }
    return tips.join('\n');
  }

  Map<String, String> _getCropDetails(String cropName) {
    final Map<String, Map<String, String>> cropData = {
      'Rice': {
        'en': '🌾 **Rice (चावल)**\n\nSeason: Kharif (June-November)\nWater: High water requirement\nSoil: Clayey, loamy soil with good water retention\n\n📋 Related Schemes:\n• PM-KISAN (Income support)\n• PMFBY (Crop insurance)\n• KCC (Credit)\n• Soil Health Card\n\n💡 Tips:\n• Use SRI (System of Rice Intensification) for better yield\n• Proper nursery management is key\n• Apply recommended fertilizers based on soil test',
        'hi': '🌾 **चावल (Rice)**\n\nमौसम: खरीफ (जून-नवंबर)\nपानी: अधिक पानी की आवश्यकता\nमिट्टी: चिकनी, दोमट मिट्टी\n\n📋 संबंधित योजनाएं:\n• PM-KISAN (आय सहायता)\n• PMFBY (फसल बीमा)\n• KCC (ऋण)\n• मृदा स्वास्थ्य कार्ड\n\n💡 सुझाव:\n• बेहतर उपज के लिए SRI पद्धति अपनाएं\n• उचित नर्सरी प्रबंधन करें\n• मृदा परीक्षण के आधार पर उर्वरक दें',
        'mr': '🌾 **तांदूळ (Rice)**\n\nहंगाम: खरीप (जून-नोव्हेंबर)\nपाणी: जास्त पाणी लागते\nमाती: चिकणमाती, पाणी धरून ठेवणारी\n\n📋 संबंधित योजना:\n• PM-KISAN (उत्पन्न सहाय्य)\n• PMFBY (पीक विमा)\n• KCC (कर्ज)\n• मृदा आरोग्य कार्ड',
      },
      'Wheat': {
        'en': '🌾 **Wheat (गेहूं)**\n\nSeason: Rabi (November-April)\nWater: 4-5 irrigations needed\nSoil: Well-drained loamy soil\n\n📋 Related Schemes:\n• PM-KISAN (Income support)\n• PMFBY (Crop insurance)\n• KCC (Credit)\n\n💡 Tips:\n• Sow before December 15 for best yield\n• First irrigation at Crown Root stage (21 days)\n• Watch for yellow rust in humid conditions',
        'hi': '🌾 **गेहूं (Wheat)**\n\nमौसम: रबी (नवंबर-अप्रैल)\nपानी: 4-5 सिंचाई आवश्यक\nमिट्टी: अच्छी जल निकासी वाली दोमट मिट्टी\n\n📋 संबंधित योजनाएं:\n• PM-KISAN (आय सहायता)\n• PMFBY (फसल बीमा)\n• KCC (ऋण)\n\n💡 सुझाव:\n• सर्वोत्तम उपज के लिए 15 दिसंबर से पहले बुवाई करें\n• पहली सिंचाई Crown Root अवस्था (21 दिन) पर करें\n• नम स्थितियों में पीला रतुआ देखें',
        'mr': '🌾 **गहू (Wheat)**\n\nहंगाम: रब्बी (नोव्हेंबर-एप्रिल)\nपाणी: ४-५ सिंचन आवश्यक\nमाती: निचरा होणारी माती\n\n📋 संबंधित योजना:\n• PM-KISAN\n• PMFBY\n• KCC',
      },
      'Cotton': {
        'en': '🌿 **Cotton (कपास)**\n\nSeason: Kharif (April-December)\nWater: Moderate, drought tolerant\nSoil: Black cotton soil (vertisol)\n\n📋 Related Schemes:\n• PMFBY (Crop insurance)\n• KCC (Credit)\n• Namo Drone Didi (for spraying)\n\n💡 Tips:\n• Use Bt cotton varieties for bollworm resistance\n• Integrated Pest Management reduces costs\n• Timely picking improves cotton quality',
        'hi': '🌿 **कपास (Cotton)**\n\nमौसम: खरीफ (अप्रैल-दिसंबर)\nपानी: मध्यम, सूखा सहनशील\nमिट्टी: काली कपास मिट्टी\n\n📋 संबंधित योजनाएं:\n• PMFBY (फसल बीमा)\n• KCC (ऋण)\n• नमो ड्रोन दीदी (छिड़काव के लिए)\n\n💡 सुझाव:\n• बॉलवर्म प्रतिरोधी Bt कपास किस्में उपयोग करें\n• एकीकृत कीट प्रबंधन लागत कम करता है\n• समय पर चुनाई से कपास गुणवत्ता बेहतर होती है',
        'mr': '🌿 **कापूस (Cotton)**\n\nहंगाम: खरीप (एप्रिल-डिसेंबर)\nपाणी: मध्यम, दुष्काळ सहनशील\nमाती: काळी कापूस माती\n\n📋 संबंधित योजना:\n• PMFBY\n• KCC\n• नमो ड्रोन दीदी',
      },
    };

    return cropData[cropName] ?? {
      'en': '🌱 **$cropName**\n\nFor detailed information about $cropName cultivation:\n• Visit your local Krishi Vigyan Kendra\n• Check with the Agriculture Department\n• Use Soil Health Card for soil analysis\n\n📋 Common schemes for all crops:\n• PM-KISAN\n• KCC\n• Soil Health Card',
      'hi': '🌱 **$cropName**\n\n$cropName की खेती की विस्तृत जानकारी के लिए:\n• अपने स्थानीय कृषि विज्ञान केंद्र पर जाएं\n• कृषि विभाग से जांचें\n• मृदा विश्लेषण के लिए मृदा स्वास्थ्य कार्ड बनवाएं\n\n📋 सभी फसलों के लिए सामान्य योजनाएं:\n• PM-KISAN\n• KCC\n• मृदा स्वास्थ्य कार्ड',
      'mr': '🌱 **$cropName**\n\n$cropName लागवडीच्या तपशीलवार माहितीसाठी:\n• स्थानिक कृषी विज्ञान केंद्राला भेट द्या\n• कृषी विभागाशी संपर्क साधा\n\n📋 सर्व पिकांसाठी सामान्य योजना:\n• PM-KISAN\n• KCC\n• मृदा आरोग्य कार्ड',
    };
  }

  // ==================== Welcome & Quick Replies ====================

  /// Get a welcome message for new chat sessions
  ChatbotResponse getWelcomeMessage() {
    return const ChatbotResponse(
      message: 'Namaste! 🙏 Welcome to KisanSetu Assistant.\n\nI can help you with:\n• 📋 Finding eligible government schemes\n• 🛡️ Crop insurance information\n• 💰 Loans & subsidies for farmers\n• 🌾 Farming tips & crop advice\n• 👤 Your profile & documents\n\nWhat would you like to know?',
      messageHi: 'नमस्ते! 🙏 किसान सेतु सहायक में आपका स्वागत है।\n\nमैं आपकी इनमें मदद कर सकता हूं:\n• 📋 पात्र सरकारी योजनाएं खोजना\n• 🛡️ फसल बीमा जानकारी\n• 💰 किसानों के लिए ऋण और सब्सिडी\n• 🌾 खेती सुझाव और फसल सलाह\n• 👤 आपकी प्रोफ़ाइल और दस्तावेज़\n\nआप क्या जानना चाहेंगे?',
      messageMr: 'नमस्कार! 🙏 किसान सेतु सहाय्यकामध्ये आपले स्वागत आहे.\n\nमी तुम्हाला यामध्ये मदत करू शकतो:\n• 📋 पात्र सरकारी योजना शोधणे\n• 🛡️ पीक विमा माहिती\n• 💰 शेतकऱ्यांसाठी कर्ज आणि अनुदान\n• 🌾 शेती सल्ला आणि पीक मार्गदर्शन\n• 👤 तुमची प्रोफाइल आणि कागदपत्रे\n\nतुम्हाला काय जाणून घ्यायचे आहे?',
      type: ResponseType.text,
    );
  }

  /// Get context-aware quick reply suggestions
  List<String> getQuickReplies(String languageCode) {
    if (languageCode == 'hi') {
      return [
        'मेरी योजनाएं दिखाओ',
        'बीमा बताओ',
        'लोन विकल्प',
        'सब्सिडी बताओ',
        'खेती सुझाव',
        'मेरी प्रोफ़ाइल',
        'PM-KISAN बताओ',
        'मदद',
      ];
    }
    if (languageCode == 'mr') {
      return [
        'माझ्या योजना दाखवा',
        'विम्याबद्दल सांगा',
        'कर्ज पर्याय',
        'अनुदान सांगा',
        'शेती सल्ला',
        'माझी प्रोफाइल',
        'PM-KISAN सांगा',
        'मदत',
      ];
    }
    return [
      'Show my schemes',
      'Insurance options',
      'Loan options',
      'Subsidies',
      'Farming tips',
      'My profile',
      'PM-KISAN details',
      'Help',
    ];
  }
}
