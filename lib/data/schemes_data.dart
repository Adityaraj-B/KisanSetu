import 'models/scheme_model.dart';

/// Schemes Data - Static repository of government schemes
/// Contains all scheme data with eligibility criteria
class SchemesData {
  SchemesData._();

  /// All available schemes
  static const List<Scheme> allSchemes = [
    // 1. PM-KISAN - Universal for all farmers
    Scheme(
      id: 'pm_kisan',
      name: 'scheme_pm_kisan',
      nameEn: 'PM-KISAN',
      nameHi: 'पीएम-किसान',
      supportedStates: ['All'],
      supportedCrops: ['All'],
      minLandAcres: null,
      maxLandAcres: null,
      benefits: 'scheme_pm_kisan_benefits',
      description: 'scheme_pm_kisan_description',
      category: 'Income Support',
      icon: 'agriculture',
    ),

    // 2. PM Fasal Bima Yojana - Crop Insurance
    Scheme(
      id: 'pmfby',
      name: 'scheme_pmfby',
      nameEn: 'PM Fasal Bima Yojana',
      nameHi: 'पीएम फसल बीमा योजना',
      supportedStates: [
        'Maharashtra',
        'Madhya Pradesh',
        'Rajasthan',
        'Uttar Pradesh',
        'Karnataka',
        'Andhra Pradesh',
        'Telangana',
        'Gujarat',
        'Tamil Nadu',
        'Haryana',
        'Punjab',
        'Bihar',
        'West Bengal',
        'Odisha',
        'Chhattisgarh',
      ],
      supportedCrops: [
        'Rice',
        'Wheat',
        'Cotton',
        'Sugarcane',
        'Maize',
        'Pulses',
        'Oilseeds',
      ],
      minLandAcres: 0.5,
      maxLandAcres: null,
      benefits: 'scheme_pmfby_benefits',
      description: 'scheme_pmfby_description',
      category: 'Insurance',
      icon: 'security',
    ),

    // 3. Soil Health Card Scheme
    Scheme(
      id: 'soil_health_card',
      name: 'scheme_soil_health',
      nameEn: 'Soil Health Card Scheme',
      nameHi: 'मृदा स्वास्थ्य कार्ड योजना',
      supportedStates: ['All'],
      supportedCrops: [
        'Rice',
        'Wheat',
        'Cotton',
        'Maize',
        'Pulses',
        'Vegetables',
        'Fruits',
        'Oilseeds',
      ],
      minLandAcres: 1.0,
      maxLandAcres: null,
      benefits: 'scheme_soil_health_benefits',
      description: 'scheme_soil_health_description',
      category: 'Soil Health',
      icon: 'eco',
    ),

    // 4. National Agriculture Market (e-NAM)
    Scheme(
      id: 'enam',
      name: 'scheme_enam',
      nameEn: 'National Agriculture Market (e-NAM)',
      nameHi: 'राष्ट्रीय कृषि बाजार (ई-नाम)',
      supportedStates: [
        'Andhra Pradesh',
        'Gujarat',
        'Haryana',
        'Himachal Pradesh',
        'Jharkhand',
        'Madhya Pradesh',
        'Maharashtra',
        'Odisha',
        'Rajasthan',
        'Tamil Nadu',
        'Telangana',
        'Uttar Pradesh',
        'Uttarakhand',
        'West Bengal',
        'Chhattisgarh',
        'Karnataka',
        'Kerala',
        'Punjab',
      ],
      supportedCrops: ['All'],
      minLandAcres: null,
      maxLandAcres: null,
      benefits: 'scheme_enam_benefits',
      description: 'scheme_enam_description',
      category: 'Market Access',
      icon: 'storefront',
    ),

    // 5. Kisan Credit Card
    Scheme(
      id: 'kcc',
      name: 'scheme_kcc',
      nameEn: 'Kisan Credit Card',
      nameHi: 'किसान क्रेडिट कार्ड',
      supportedStates: ['All'],
      supportedCrops: ['All'],
      minLandAcres: null,
      maxLandAcres: 12.5, // Small and marginal farmers priority
      benefits: 'scheme_kcc_benefits',
      description: 'scheme_kcc_description',
      category: 'Credit',
      icon: 'credit_card',
    ),

    // 6. Paramparagat Krishi Vikas Yojana (Organic Farming)
    Scheme(
      id: 'pkvy',
      name: 'scheme_pkvy',
      nameEn: 'Paramparagat Krishi Vikas Yojana',
      nameHi: 'परम्परागत कृषि विकास योजना',
      supportedStates: [
        'Sikkim',
        'Uttarakhand',
        'Himachal Pradesh',
        'Rajasthan',
        'Madhya Pradesh',
        'Maharashtra',
        'Karnataka',
        'Kerala',
        'Tamil Nadu',
        'Andhra Pradesh',
        'Telangana',
        'Gujarat',
        'Punjab',
        'Haryana',
        'Uttar Pradesh',
      ],
      supportedCrops: [
        'Vegetables',
        'Fruits',
        'Spices',
        'Pulses',
        'Oilseeds',
      ],
      minLandAcres: 0.5,
      maxLandAcres: 5.0,
      benefits: 'scheme_pkvy_benefits',
      description: 'scheme_pkvy_description',
      category: 'Organic',
      icon: 'spa',
    ),
  ];

  /// Get schemes by category
  static List<Scheme> getSchemesByCategory(String category) {
    if (category.toLowerCase() == 'all') {
      return allSchemes;
    }
    return allSchemes
        .where((s) => s.category.toLowerCase() == category.toLowerCase())
        .toList();
  }

  /// Get scheme by ID
  static Scheme? getSchemeById(String id) {
    try {
      return allSchemes.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get all unique categories
  static List<String> get allCategories {
    final categories = allSchemes.map((s) => s.category).toSet().toList();
    categories.sort();
    return ['All', ...categories];
  }
}
