import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../../data/models/scheme_model.dart';

/// JSON Scheme Model - Extended model for schemes loaded from JSON
class JsonScheme {
  final String id;
  final String name;
  final String nameHi;
  final String nameMr;
  final String description;
  final String descriptionHi;
  final String descriptionMr;
  final String benefit;
  final String benefitHi;
  final String benefitMr;
  final List<String> docs;
  final List<String> docsHi;
  final List<String> docsMr;
  final String category;
  final String categoryHi;
  final String categoryMr;
  final String url;
  final String eligibility;
  final String eligibilityHi;
  final String eligibilityMr;
  final String deadline;
  final String deadlineHi;
  final String deadlineMr;
  final String status;
  final SchemeParams params;

  const JsonScheme({
    required this.id,
    required this.name,
    required this.nameHi,
    required this.nameMr,
    required this.description,
    required this.descriptionHi,
    required this.descriptionMr,
    required this.benefit,
    required this.benefitHi,
    required this.benefitMr,
    required this.docs,
    required this.docsHi,
    required this.docsMr,
    required this.category,
    required this.categoryHi,
    required this.categoryMr,
    required this.url,
    required this.eligibility,
    required this.eligibilityHi,
    required this.eligibilityMr,
    required this.deadline,
    required this.deadlineHi,
    required this.deadlineMr,
    required this.status,
    required this.params,
  });

  factory JsonScheme.fromJson(Map<String, dynamic> json) {
    return JsonScheme(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      nameHi: json['nameHi']?.toString() ?? json['name']?.toString() ?? '',
      nameMr: json['nameMr']?.toString() ?? json['nameHi']?.toString() ?? json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      descriptionHi: json['descriptionHi']?.toString() ?? json['description']?.toString() ?? '',
      descriptionMr: json['descriptionMr']?.toString() ?? json['descriptionHi']?.toString() ?? json['description']?.toString() ?? '',
      benefit: json['benefit']?.toString() ?? '',
      benefitHi: json['benefitHi']?.toString() ?? json['benefit']?.toString() ?? '',
      benefitMr: json['benefitMr']?.toString() ?? json['benefitHi']?.toString() ?? json['benefit']?.toString() ?? '',
      docs: _parseStringList(json['docs']),
      docsHi: _parseStringList(json['docsHi'] ?? json['docs']),
      docsMr: _parseStringList(json['docsMr'] ?? json['docsHi'] ?? json['docs']),
      category: json['category']?.toString() ?? '',
      categoryHi: json['categoryHi']?.toString() ?? json['category']?.toString() ?? '',
      categoryMr: json['categoryMr']?.toString() ?? json['categoryHi']?.toString() ?? json['category']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      eligibility: json['eligibility']?.toString() ?? '',
      eligibilityHi: json['eligibilityHi']?.toString() ?? json['eligibility']?.toString() ?? '',
      eligibilityMr: json['eligibilityMr']?.toString() ?? json['eligibilityHi']?.toString() ?? json['eligibility']?.toString() ?? '',
      deadline: json['deadline']?.toString() ?? '',
      deadlineHi: json['deadlineHi']?.toString() ?? json['deadline']?.toString() ?? '',
      deadlineMr: json['deadlineMr']?.toString() ?? json['deadlineHi']?.toString() ?? json['deadline']?.toString() ?? '',
      status: json['status']?.toString() ?? 'active',
      params: SchemeParams.fromJson(json['params'] ?? {}),
    );
  }

  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return [];
  }

  /// Get localized name
  String getLocalizedName(String languageCode) {
    if (languageCode == 'mr') return nameMr;
    if (languageCode == 'hi') return nameHi;
    return name;
  }

  /// Get localized description
  String getLocalizedDescription(String languageCode) {
    if (languageCode == 'mr') return descriptionMr;
    if (languageCode == 'hi') return descriptionHi;
    return description;
  }

  /// Get localized benefit
  String getLocalizedBenefit(String languageCode) {
    if (languageCode == 'mr') return benefitMr;
    if (languageCode == 'hi') return benefitHi;
    return benefit;
  }

  /// Get localized documents
  List<String> getLocalizedDocs(String languageCode) {
    if (languageCode == 'mr') return docsMr;
    if (languageCode == 'hi') return docsHi;
    return docs;
  }

  /// Get localized category
  String getLocalizedCategory(String languageCode) {
    if (languageCode == 'mr') return categoryMr;
    if (languageCode == 'hi') return categoryHi;
    return category;
  }

  /// Get localized eligibility
  String getLocalizedEligibility(String languageCode) {
    if (languageCode == 'mr') return eligibilityMr;
    if (languageCode == 'hi') return eligibilityHi;
    return eligibility;
  }

  /// Get localized deadline
  String getLocalizedDeadline(String languageCode) {
    if (languageCode == 'mr') return deadlineMr;
    if (languageCode == 'hi') return deadlineHi;
    return deadline;
  }

  /// Check if scheme supports all states
  bool get supportsAllStates => params.supportsAllStates;

  /// Check if scheme supports all crops
  bool get supportsAllCrops => params.supportsAllCrops;

  /// Check if scheme has land requirements
  bool get hasLandRequirements => params.maxAcres != null || params.minAcres != null;

  /// Get icon name based on category
  String get icon {
    switch (category.toLowerCase()) {
      case 'income support':
        return 'payments';
      case 'insurance':
        return 'security';
      case 'credit':
        return 'credit_card';
      case 'energy':
        return 'solar_power';
      case 'soil health':
        return 'eco';
      case 'organic':
        return 'spa';
      case 'market access':
        return 'storefront';
      case 'irrigation':
        return 'water_drop';
      case 'machinery':
        return 'agriculture';
      case 'horticulture':
        return 'local_florist';
      case 'technology':
        return 'smart_toy';
      case 'pension':
        return 'elderly';
      case 'infrastructure':
        return 'business';
      case 'plantation':
        return 'park';
      case 'allied activities':
        return 'hive';
      case 'development':
        return 'trending_up';
      case 'sustainability':
        return 'recycling';
      case 'organization':
        return 'groups';
      case 'waste management':
        return 'delete_sweep';
      case 'food security':
        return 'restaurant';
      case 'food processing':
        return 'factory';
      case 'employment':
        return 'work';
      case 'price support':
        return 'price_check';
      default:
        return 'account_balance';
    }
  }

  /// Convert to legacy Scheme model for compatibility
  Scheme toScheme() {
    return Scheme(
      id: id,
      name: name,
      nameEn: name,
      nameHi: nameHi,
      supportedStates: params.states,
      supportedCrops: params.crops,
      minLandAcres: params.minAcres,
      maxLandAcres: params.maxAcres,
      benefits: benefit,
      description: description,
      category: category,
      icon: icon,
    );
  }
}

/// Scheme Parameters - Eligibility criteria
class SchemeParams {
  final dynamic state; // Can be "ALL" or List<String>
  final dynamic district; // Can be "ALL" or List<String>
  final List<String> crops;
  final double? maxAcres;
  final double? minAcres;

  const SchemeParams({
    required this.state,
    required this.district,
    required this.crops,
    this.maxAcres,
    this.minAcres,
  });

  factory SchemeParams.fromJson(Map<String, dynamic> json) {
    return SchemeParams(
      state: json['state'] ?? 'ALL',
      district: json['district'] ?? 'ALL',
      crops: _parseCrops(json['crops']),
      maxAcres: _parseDouble(json['max_acres']),
      minAcres: _parseDouble(json['min_acres']),
    );
  }

  static List<String> _parseCrops(dynamic value) {
    if (value == null) return ['ALL'];
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return ['ALL'];
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  /// Check if supports all states
  bool get supportsAllStates {
    if (state is String && state.toString().toUpperCase() == 'ALL') return true;
    if (state is List && (state as List).isEmpty) return true;
    return false;
  }

  /// Check if supports all crops
  bool get supportsAllCrops {
    if (crops.isEmpty) return true;
    if (crops.length == 1 && crops[0].toUpperCase() == 'ALL') return true;
    return false;
  }

  /// Get list of supported states
  List<String> get states {
    if (supportsAllStates) return ['All'];
    if (state is List) {
      return (state as List).map((e) => e.toString()).toList();
    }
    return ['All'];
  }
}

/// Scheme Category Model
class SchemeCategory {
  final String id;
  final String name;
  final String nameHi;
  final String nameMr;
  final String icon;

  const SchemeCategory({
    required this.id,
    required this.name,
    required this.nameHi,
    required this.nameMr,
    required this.icon,
  });

  factory SchemeCategory.fromJson(Map<String, dynamic> json) {
    return SchemeCategory(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      nameHi: json['nameHi']?.toString() ?? json['name']?.toString() ?? '',
      nameMr: json['nameMr']?.toString() ?? json['nameHi']?.toString() ?? json['name']?.toString() ?? '',
      icon: json['icon']?.toString() ?? 'category',
    );
  }

  String getLocalizedName(String languageCode) {
    if (languageCode == 'mr') return nameMr;
    if (languageCode == 'hi') return nameHi;
    return name;
  }
}

/// Schemes Service - Loads and manages schemes from JSON
class SchemesService {
  // Private constructor for singleton
  SchemesService._();

  // Singleton instance
  static final SchemesService _instance = SchemesService._();

  /// Get singleton instance
  static SchemesService get instance => _instance;

  // Cached data
  List<JsonScheme> _schemes = [];
  List<SchemeCategory> _categories = [];
  bool _isLoaded = false;

  /// Get all schemes
  List<JsonScheme> get allSchemes => _schemes;

  /// Get all categories
  List<SchemeCategory> get categories => _categories;

  /// Check if data is loaded
  bool get isLoaded => _isLoaded;

  /// Load schemes data from JSON file
  Future<void> loadSchemesData() async {
    if (_isLoaded) return;

    try {
      final jsonString = await rootBundle.loadString('lib/core/services/schemes.json');
      final data = json.decode(jsonString) as Map<String, dynamic>;

      // Parse schemes
      final schemesMap = data['schemes'] as Map<String, dynamic>? ?? {};
      _schemes = schemesMap.entries
          .map((e) => JsonScheme.fromJson(e.value as Map<String, dynamic>))
          .where((s) => s.status == 'active')
          .toList();

      // Parse categories
      final categoriesList = data['categories'] as List<dynamic>? ?? [];
      _categories = categoriesList
          .map((c) => SchemeCategory.fromJson(c as Map<String, dynamic>))
          .toList();

      _isLoaded = true;
      debugPrint('SchemesService: Loaded ${_schemes.length} schemes and ${_categories.length} categories');
    } catch (e) {
      debugPrint('SchemesService: Error loading schemes data: $e');
      _schemes = [];
      _categories = [];
    }
  }

  /// Get eligible schemes based on farmer profile
  List<JsonScheme> getEligibleSchemes({
    String? state,
    String? district,
    List<String>? crops,
    double? landSize,
  }) {
    if (!_isLoaded || _schemes.isEmpty) return [];

    return _schemes.where((scheme) {
      // Check state eligibility
      if (!_isStateEligible(scheme, state)) return false;

      // Check crop eligibility
      if (crops != null && crops.isNotEmpty && !_isCropEligible(scheme, crops)) return false;

      // Check land size eligibility
      if (landSize != null && !_isLandSizeEligible(scheme, landSize)) return false;

      return true;
    }).toList();
  }

  /// Check if farmer's state matches scheme requirements
  bool _isStateEligible(JsonScheme scheme, String? state) {
    if (state == null || state.isEmpty) return false;
    if (scheme.supportsAllStates) return true;

    final params = scheme.params;
    if (params.state is List) {
      final states = (params.state as List).map((e) => e.toString().toLowerCase()).toList();
      return states.contains(state.toLowerCase());
    }
    return true;
  }

  /// Check if any of farmer's crops match scheme requirements
  bool _isCropEligible(JsonScheme scheme, List<String> crops) {
    if (scheme.supportsAllCrops) return true;
    if (crops.isEmpty) return true;

    final schemeCrops = scheme.params.crops.map((c) => c.toLowerCase()).toList();
    for (final crop in crops) {
      if (schemeCrops.contains(crop.toLowerCase())) return true;
    }
    return false;
  }

  /// Check if farmer's land size meets scheme requirements
  bool _isLandSizeEligible(JsonScheme scheme, double landSize) {
    final params = scheme.params;

    // Check minimum land requirement
    if (params.minAcres != null && landSize < params.minAcres!) return false;

    // Check maximum land requirement (0 means no land required, e.g., livestock schemes)
    if (params.maxAcres != null && params.maxAcres! > 0 && landSize > params.maxAcres!) return false;

    return true;
  }

  /// Get schemes by category
  List<JsonScheme> getSchemesByCategory(String category) {
    if (category.toLowerCase() == 'all') return _schemes;
    return _schemes.where((s) => s.category.toLowerCase() == category.toLowerCase()).toList();
  }

  /// Get unique categories from schemes
  List<String> getUniqueCategories() {
    final categories = _schemes.map((s) => s.category).toSet().toList();
    categories.sort();
    return ['All', ...categories];
  }

  /// Clear cached data
  void clearCache() {
    _schemes = [];
    _categories = [];
    _isLoaded = false;
  }
}

