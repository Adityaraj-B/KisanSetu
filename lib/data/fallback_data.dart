// Fallback data for when PMFBY API is unavailable
// This ensures the app works even when offline

import 'models/state_model.dart';
import 'models/district_model.dart';
import 'models/crop_model.dart';

class FallbackData {
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

  /// Generic districts fallback (when API fails)
  /// Returns common district names that work for most states
  static List<DistrictModel> getFallbackDistricts(String stateId) {
    final districtsData = [
      {'districtID': '${stateId}_1', 'districtName': 'District 1'},
      {'districtID': '${stateId}_2', 'districtName': 'District 2'},
      {'districtID': '${stateId}_3', 'districtName': 'District 3'},
      {'districtID': '${stateId}_4', 'districtName': 'District 4'},
      {'districtID': '${stateId}_5', 'districtName': 'District 5'},
    ];

    return districtsData.map((data) => DistrictModel.fromJson(data)).toList();
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

