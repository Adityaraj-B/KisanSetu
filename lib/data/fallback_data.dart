// Fallback data for when PMFBY API is unavailable
// This ensures the app works even when offline

import 'dart:convert';
import 'package:flutter/services.dart';
import 'models/state_model.dart';
import 'models/district_model.dart';
import 'models/crop_model.dart';

class FallbackData {
  // Cached districts data from JSON
  static Map<String, dynamic>? _districtsJsonData;
  static bool _isDistrictsLoaded = false;

  /// Load districts JSON data
  static Future<void> _loadDistrictsJson() async {
    if (_isDistrictsLoaded) return;
    try {
      final jsonString = await rootBundle.loadString('lib/core/data/districts.json');
      _districtsJsonData = json.decode(jsonString) as Map<String, dynamic>;
      _isDistrictsLoaded = true;
    } catch (e) {
      _districtsJsonData = null;
    }
  }

  /// Indian states with their IDs (from PMFBY API structure)
  static List<StateModel> getIndianStates() {
    final statesData = [
      {'stateID': '1', 'stateName': 'Andhra Pradesh'},
      {'stateID': '2', 'stateName': 'Arunachal Pradesh'},
      {'stateID': '3', 'stateName': 'Assam'},
      {'stateID': '4', 'stateName': 'Bihar'},
      {'stateID': '5', 'stateName': 'Chhattisgarh'},
      {'stateID': '6', 'stateName': 'Goa'},
      {'stateID': '7', 'stateName': 'Gujarat'},
      {'stateID': '8', 'stateName': 'Haryana'},
      {'stateID': '9', 'stateName': 'Himachal Pradesh'},
      {'stateID': '10', 'stateName': 'Jharkhand'},
      {'stateID': '11', 'stateName': 'Karnataka'},
      {'stateID': '12', 'stateName': 'Kerala'},
      {'stateID': '13', 'stateName': 'Madhya Pradesh'},
      {'stateID': '14', 'stateName': 'Maharashtra'},
      {'stateID': '15', 'stateName': 'Manipur'},
      {'stateID': '16', 'stateName': 'Meghalaya'},
      {'stateID': '17', 'stateName': 'Mizoram'},
      {'stateID': '18', 'stateName': 'Nagaland'},
      {'stateID': '19', 'stateName': 'Odisha'},
      {'stateID': '20', 'stateName': 'Punjab'},
      {'stateID': '21', 'stateName': 'Rajasthan'},
      {'stateID': '22', 'stateName': 'Sikkim'},
      {'stateID': '23', 'stateName': 'Tamil Nadu'},
      {'stateID': '24', 'stateName': 'Telangana'},
      {'stateID': '25', 'stateName': 'Tripura'},
      {'stateID': '26', 'stateName': 'Uttar Pradesh'},
      {'stateID': '27', 'stateName': 'Uttarakhand'},
      {'stateID': '28', 'stateName': 'West Bengal'},
      {'stateID': '29', 'stateName': 'Andaman and Nicobar Islands'},
      {'stateID': '30', 'stateName': 'Chandigarh'},
      {'stateID': '31', 'stateName': 'Dadra and Nagar Haveli and Daman and Diu'},
      {'stateID': '32', 'stateName': 'Delhi'},
      {'stateID': '33', 'stateName': 'Jammu and Kashmir'},
      {'stateID': '34', 'stateName': 'Ladakh'},
      {'stateID': '35', 'stateName': 'Lakshadweep'},
      {'stateID': '36', 'stateName': 'Puducherry'},
    ];

    return statesData.map((data) => StateModel.fromJson(data)).toList();
  }

  /// Get state name from state ID
  static String? _getStateNameFromId(String stateId) {
    final stateIdToName = {
      '1': 'Andhra Pradesh',
      '2': 'Arunachal Pradesh',
      '3': 'Assam',
      '4': 'Bihar',
      '5': 'Chhattisgarh',
      '6': 'Goa',
      '7': 'Gujarat',
      '8': 'Haryana',
      '9': 'Himachal Pradesh',
      '10': 'Jharkhand',
      '11': 'Karnataka',
      '12': 'Kerala',
      '13': 'Madhya Pradesh',
      '14': 'Maharashtra',
      '15': 'Manipur',
      '16': 'Meghalaya',
      '17': 'Mizoram',
      '18': 'Nagaland',
      '19': 'Odisha',
      '20': 'Punjab',
      '21': 'Rajasthan',
      '22': 'Sikkim',
      '23': 'Tamil Nadu',
      '24': 'Telangana',
      '25': 'Tripura',
      '26': 'Uttar Pradesh',
      '27': 'Uttarakhand',
      '28': 'West Bengal',
    };
    return stateIdToName[stateId];
  }

  /// Get districts from JSON data for a given state ID
  static Future<List<DistrictModel>> getDistrictsFromJson(String stateId) async {
    await _loadDistrictsJson();

    if (_districtsJsonData == null) {
      return _getDefaultDistricts(stateId);
    }

    final stateName = _getStateNameFromId(stateId);
    if (stateName == null) {
      return _getDefaultDistricts(stateId);
    }

    final states = _districtsJsonData!['states'] as Map<String, dynamic>?;
    if (states == null) {
      return _getDefaultDistricts(stateId);
    }

    final stateData = states[stateName] as Map<String, dynamic>?;
    if (stateData == null) {
      return _getDefaultDistricts(stateId);
    }

    final districtsJson = stateData['districts'] as List<dynamic>?;
    if (districtsJson == null) {
      return _getDefaultDistricts(stateId);
    }

    return districtsJson
        .map((d) => DistrictModel.fromJson({
              'districtID': d['districtId'],
              'districtName': d['districtName'],
              'stateID': stateId,
            }))
        .toList();
  }

  /// Default districts fallback (when JSON is also unavailable)
  static List<DistrictModel> _getDefaultDistricts(String stateId) {
    final districtsData = [
      {'districtID': '${stateId}_1', 'districtName': 'District 1'},
      {'districtID': '${stateId}_2', 'districtName': 'District 2'},
      {'districtID': '${stateId}_3', 'districtName': 'District 3'},
      {'districtID': '${stateId}_4', 'districtName': 'District 4'},
      {'districtID': '${stateId}_5', 'districtName': 'District 5'},
    ];
    return districtsData.map((data) => DistrictModel.fromJson(data)).toList();
  }

  /// Generic districts fallback (when API fails)
  /// Now uses JSON data for real district names
  static List<DistrictModel> getFallbackDistricts(String stateId) {
    // This is synchronous fallback, so we use default districts
    // For async version with actual data, use getDistrictsFromJson()
    return _getDefaultDistricts(stateId);
  }

  /// Common crops fallback (when API fails)
  /// Returns most common crops grown in India
  static List<CropModel> getFallbackCrops(String districtId) {
    final cropsData = [
      {'cropID': '${districtId}_1', 'cropName': 'Rice'},
      {'cropID': '${districtId}_2', 'cropName': 'Wheat'},
      {'cropID': '${districtId}_3', 'cropName': 'Cotton'},
      {'cropID': '${districtId}_4', 'cropName': 'Sugarcane'},
      {'cropID': '${districtId}_5', 'cropName': 'Maize'},
      {'cropID': '${districtId}_6', 'cropName': 'Pulses'},
      {'cropID': '${districtId}_7', 'cropName': 'Groundnut'},
      {'cropID': '${districtId}_8', 'cropName': 'Soybean'},
      {'cropID': '${districtId}_9', 'cropName': 'Millets'},
      {'cropID': '${districtId}_10', 'cropName': 'Vegetables'},
      {'cropID': '${districtId}_11', 'cropName': 'Fruits'},
      {'cropID': '${districtId}_12', 'cropName': 'Other Crops'},
    ];

    return cropsData.map((data) => CropModel.fromJson(data)).toList();
  }
}

