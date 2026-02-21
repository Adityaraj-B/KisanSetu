import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  final Locale locale;
  late Map<String, String> _localizedStrings;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  Future<bool> load() async {
    String jsonString =
        await rootBundle.loadString('assets/lang/${locale.languageCode}.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);

    _localizedStrings = jsonMap.map((key, value) {
      return MapEntry(key, value.toString());
    });

    return true;
  }

  String text(String key) {
    return _localizedStrings[key] ?? key;
  }

  String get appTitle => text('app_title');
  String get selectLanguage => text('select_language');
  String get selectYourLanguage => text('select_your_language');
  String get chooseYourLanguage => text('choose_your_language');
  String get continueButton => text('continue');
  String get english => text('english');
  String get hindi => text('hindi');
  String get marathi => text('marathi');
  String get goBack => text('go_back');

  String get welcome => text('welcome');
  String get welcomeTo => text('welcome_to');
  String get welcomeSubtitle => text('welcome_subtitle');
  String get goodMorning => text('good_morning');
  String get goodAfternoon => text('good_afternoon');
  String get goodEvening => text('good_evening');

  String get tellUsAboutYou => text('tell_us_about_you');
  String get infoMessage => text('info_message');
  String get yourState => text('your_state');
  String get selectYourState => text('select_your_state');
  String get cropsYouGrow => text('crops_you_grow');
  String get landSize => text('land_size');
  String get acres => text('acres');
  String get readyToContinue => text('ready_to_continue');
  String get state => text('state');
  String get crops => text('crops');
  String get land => text('land');
  String get pleaseFillRequiredFields => text('please_fill_required_fields');

  String get quickAccess => text('quick_access');
  String get governmentSchemes => text('government_schemes');
  String get discoverSchemes => text('discover_schemes');
  String get exploreSchemes => text('explore_schemes');
  String get cropInsurance => text('crop_insurance');
  String get protectCrops => text('protect_crops');
  String get protectCropsPmfby => text('protect_crops_pmfby');
  String get financialSupport => text('financial_support');
  String get findLoans => text('find_loans');
  String get askQuestions => text('ask_questions');
  String get getHelp => text('get_help');
  String get needHelp => text('need_help');
  String get languageSelectionComingSoon => text('language_selection_coming_soon');
  String get changeLanguage => text('change_language');

  String get home => text('home');
  String get explore => text('explore');
  String get saved => text('saved');
  String get savedItems => text('saved_items');
  String get viewSavedSchemes => text('view_saved_schemes');
  String get profile => text('profile');
  String get manageProfile => text('manage_profile');
  String get searchExplore => text('search_explore');

  String get schemesFound => text('schemes_found');
  String get noSchemesFound => text('no_schemes_found');
  String get tryDifferentCategory => text('try_different_category');
  String get schemeDetailsComingSoon => text('scheme_details_coming_soon');
  String get schemesEligibilityMessage => text('schemes_eligibility_message');

  String get all => text('all');
  String get subsidy => text('subsidy');
  String get insurance => text('insurance');
  String get loans => text('loans');
  String get energy => text('energy');
  String get organic => text('organic');

  String get keyBenefits => text('key_benefits');
  String get lowPremium => text('low_premium');
  String get lowPremiumDesc => text('low_premium_desc');
  String get wideCoverage => text('wide_coverage');
  String get wideCoverageDesc => text('wide_coverage_desc');
  String get quickSettlement => text('quick_settlement');
  String get quickSettlementDesc => text('quick_settlement_desc');
  String get noUpperLimit => text('no_upper_limit');
  String get noUpperLimitDesc => text('no_upper_limit_desc');

  String get howToApply => text('how_to_apply');
  String get visitNearestBank => text('visit_nearest_bank');
  String get visitBankDesc => text('visit_bank_desc');
  String get fillApplication => text('fill_application');
  String get fillApplicationDesc => text('fill_application_desc');
  String get submitDocuments => text('submit_documents');
  String get submitDocumentsDesc => text('submit_documents_desc');
  String get payPremium => text('pay_premium');
  String get payPremiumDesc => text('pay_premium_desc');
  String get learnMore => text('learn_more');
  String get externalLinkComingSoon => text('external_link_coming_soon');

  String get pmFasalBimaYojana => text('pm_fasal_bima_yojana');
  String get comprehensiveCropInsurance => text('comprehensive_crop_insurance');
  String get insuranceHelpMessage => text('insurance_help_message');

  String get helpSupport => text('help_support');
  String get getAppHelp => text('get_app_help');

  String get chatAssistant => text('chat_assistant');
  String get chatbotMessage => text('chatbot_message');

  String get financialHelpMessage => text('financial_help_message');

  String get didYouKnow => text('did_you_know');
  String get pmKisanInfo => text('pm_kisan_info');

  // Chatbot strings
  String get chatbotWelcome => text('chatbot_welcome');
  String get chatbotTypeMessage => text('chatbot_type_message');
  String get chatbotSend => text('chatbot_send');
  String get chatbotQuickSchemes => text('chatbot_quick_schemes');
  String get chatbotQuickInsurance => text('chatbot_quick_insurance');
  String get chatbotQuickHelp => text('chatbot_quick_help');
  String get chatbotViewSchemes => text('chatbot_view_schemes');
  String get chatbotViewInsurance => text('chatbot_view_insurance');

  // Profile screen strings
  String get editProfile => text('editProfile');
  String get personalInfo => text('personalInfo');
  String get farmDetails => text('farmDetails');
  String get appSettings => text('appSettings');
  String get aboutApp => text('aboutApp');
  String get profileUpdated => text('profileUpdated');
  String get selectCrops => text('selectCrops');
  String get selectLandSize => text('selectLandSize');
  String get noSchemesYet => text('noSchemesYet');

  // Document upload strings
  String get uploadAadhar => text('uploadAadhar');
  String get uploadAadharOptional => text('uploadAadharOptional');
  String get tapToUpload => text('tapToUpload');
  String get skipForNow => text('skipForNow');
  String get documentUploadInfo => text('documentUploadInfo');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'hi', 'mr'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
