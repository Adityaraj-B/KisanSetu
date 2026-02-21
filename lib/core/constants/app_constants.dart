/// App Constants - Global constants for the app
/// Contains static data used across the application
class AppConstants {
  // Prevent instantiation
  AppConstants._();

  // App Information
  static const String appName = 'KisanSetu';
  static const String appNameHindi = 'किसान सेतु';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Your gateway to government schemes';
  static const String appTaglineHindi = 'सरकारी योजनाओं का द्वार';

  // Supported Languages
  static const List<Map<String, String>> supportedLanguages = [
    {
      'code': 'en',
      'name': 'English',
      'nativeName': 'English',
      'icon': '🇺🇸',
    },
    {
      'code': 'hi',
      'name': 'Hindi',
      'nativeName': 'हिंदी',
      'icon': '🇮🇳',
    },
  ];

  // Indian States (for dropdown)
  static const List<String> indianStates = [
    'Andhra Pradesh',
    'Arunachal Pradesh',
    'Assam',
    'Bihar',
    'Chhattisgarh',
    'Goa',
    'Gujarat',
    'Haryana',
    'Himachal Pradesh',
    'Jharkhand',
    'Karnataka',
    'Kerala',
    'Madhya Pradesh',
    'Maharashtra',
    'Manipur',
    'Meghalaya',
    'Mizoram',
    'Nagaland',
    'Odisha',
    'Punjab',
    'Rajasthan',
    'Sikkim',
    'Tamil Nadu',
    'Telangana',
    'Tripura',
    'Uttar Pradesh',
    'Uttarakhand',
    'West Bengal',
  ];

  // Common Crops
  static const List<Map<String, dynamic>> commonCrops = [
    {'name': 'Rice', 'icon': '🌾', 'nameHindi': 'चावल'},
    {'name': 'Wheat', 'icon': '🌾', 'nameHindi': 'गेहूं'},
    {'name': 'Cotton', 'icon': '🌿', 'nameHindi': 'कपास'},
    {'name': 'Sugarcane', 'icon': '🎋', 'nameHindi': 'गन्ना'},
    {'name': 'Maize', 'icon': '🌽', 'nameHindi': 'मक्का'},
    {'name': 'Pulses', 'icon': '🫘', 'nameHindi': 'दाल'},
    {'name': 'Vegetables', 'icon': '🥬', 'nameHindi': 'सब्जियां'},
    {'name': 'Fruits', 'icon': '🍎', 'nameHindi': 'फल'},
    {'name': 'Oilseeds', 'icon': '🌻', 'nameHindi': 'तिलहन'},
    {'name': 'Spices', 'icon': '🌶️', 'nameHindi': 'मसाले'},
  ];

  // Land Size Configuration
  static const double minLandSize = 0;
  static const double maxLandSize = 50;
  static const int landSizeDivisions = 50;
  static const String landSizeUnit = 'acres';

  // Dummy Schemes Data (for UI display only)
  static const List<Map<String, dynamic>> dummySchemes = [
    {
      'id': '1',
      'name': 'PM-KISAN',
      'fullName': 'Pradhan Mantri Kisan Samman Nidhi',
      'description': 'Direct income support of ₹6,000 per year to farmer families',
      'benefits': '₹6,000/year in 3 installments',
      'category': 'Income Support',
      'icon': 'agriculture',
    },
    {
      'id': '2',
      'name': 'PM Fasal Bima Yojana',
      'fullName': 'Pradhan Mantri Fasal Bima Yojana',
      'description': 'Crop insurance scheme to protect against crop loss',
      'benefits': 'Insurance coverage at minimal premium',
      'category': 'Insurance',
      'icon': 'security',
    },
    {
      'id': '3',
      'name': 'Kisan Credit Card',
      'fullName': 'Kisan Credit Card Scheme',
      'description': 'Easy access to credit for agricultural needs',
      'benefits': 'Low interest rate loans',
      'category': 'Credit',
      'icon': 'credit_card',
    },
    {
      'id': '4',
      'name': 'PM-KUSUM',
      'fullName': 'Pradhan Mantri Kisan Urja Suraksha',
      'description': 'Solar energy support for farmers',
      'benefits': 'Subsidized solar pumps and panels',
      'category': 'Energy',
      'icon': 'solar_power',
    },
    {
      'id': '5',
      'name': 'Soil Health Card',
      'fullName': 'Soil Health Card Scheme',
      'description': 'Soil testing and recommendations for farmers',
      'benefits': 'Free soil analysis and crop guidance',
      'category': 'Soil Health',
      'icon': 'eco',
    },
  ];

  // Scheme Categories
  static const List<String> schemeCategories = [
    'All',
    'Income Support',
    'Insurance',
    'Credit',
    'Energy',
    'Soil Health',
  ];

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Spacing Constants
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  // Border Radius
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusFull = 100.0;

  // Touch Target Sizes (for accessibility)
  static const double minTouchTarget = 48.0;
  static const double buttonHeight = 56.0;
  static const double iconButtonSize = 48.0;
}
