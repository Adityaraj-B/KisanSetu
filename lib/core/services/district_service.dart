import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../../data/models/district_model.dart';

/// District Service - Loads districts from JSON data based on state
/// Provides state-wise district data for profile and onboarding
class DistrictService {
  // Private constructor for singleton
  DistrictService._();

  // Singleton instance
  static final DistrictService _instance = DistrictService._();

  /// Get singleton instance
  static DistrictService get instance => _instance;

  // Cached districts data
  Map<String, dynamic>? _districtsData;
  bool _isLoaded = false;

  /// Load districts data from JSON file
  Future<void> loadDistrictsData() async {
    if (_isLoaded) return;

    try {
      final jsonString = await rootBundle.loadString('lib/core/data/districts.json');
      _districtsData = json.decode(jsonString) as Map<String, dynamic>;
      _isLoaded = true;
    } catch (e) {
      debugPrint('Error loading districts data: $e');
      _districtsData = null;
    }
  }

  /// Get districts for a given state name
  /// Returns empty list if state not found or data not loaded
  Future<List<DistrictModel>> getDistrictsForState(String stateName) async {
    await loadDistrictsData();

    if (_districtsData == null) return [];

    final states = _districtsData!['states'] as Map<String, dynamic>?;
    if (states == null) return [];

    final stateData = states[stateName] as Map<String, dynamic>?;
    if (stateData == null) return [];

    final districtsJson = stateData['districts'] as List<dynamic>?;
    if (districtsJson == null) return [];

    return districtsJson
        .map((d) => DistrictModel.fromJson({
              'districtID': d['districtId'],
              'districtName': d['districtName'],
              'stateID': stateData['stateId'],
            }))
        .toList();
  }

  /// Get all state names that have districts data
  Future<List<String>> getAvailableStates() async {
    await loadDistrictsData();

    if (_districtsData == null) return [];

    final states = _districtsData!['states'] as Map<String, dynamic>?;
    if (states == null) return [];

    return states.keys.toList()..sort();
  }

  /// Get state ID for a given state name
  Future<String?> getStateId(String stateName) async {
    await loadDistrictsData();

    if (_districtsData == null) return null;

    final states = _districtsData!['states'] as Map<String, dynamic>?;
    if (states == null) return null;

    final stateData = states[stateName] as Map<String, dynamic>?;
    return stateData?['stateId'] as String?;
  }

  /// Clear cached data (useful for testing)
  void clearCache() {
    _districtsData = null;
    _isLoaded = false;
  }
}


