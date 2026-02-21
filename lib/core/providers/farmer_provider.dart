import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../data/models/farmer_profile.dart';
import '../../data/models/scheme_model.dart';
import '../services/eligibility_service.dart';

/// Farmer Provider - State management for farmer profile
/// Provides reactive updates when farmer data changes with persistence
class FarmerProvider extends ChangeNotifier {
  FarmerProfile _profile = FarmerProfile.empty();
  bool _isLoading = true;
  String? _aadharCardPath;

  static const String _keyProfile = 'farmer_profile';
  static const String _keyAadharCard = 'aadhar_card_path';

  /// Get current farmer profile
  FarmerProfile get profile => _profile;

  /// Get loading state
  bool get isLoading => _isLoading;

  /// Get Aadhar card path
  String? get aadharCardPath => _aadharCardPath;

  // ==================== Farm Details ====================

  /// Get selected state
  String? get selectedState => _profile.selectedState;

  /// Get selected district
  String? get selectedDistrict => _profile.selectedDistrict;

  /// Get selected crops
  List<String> get selectedCrops => _profile.selectedCrops;

  /// Get land size in acres
  double get landSizeAcres => _profile.landSizeAcres;

  // ==================== Personal Details ====================

  /// Get full name
  String? get fullName => _profile.fullName;

  /// Get father's name
  String? get fatherName => _profile.fatherName;

  /// Get gender
  String? get gender => _profile.gender;

  /// Get date of birth
  DateTime? get dateOfBirth => _profile.dateOfBirth;

  /// Get village
  String? get village => _profile.village;

  /// Get taluka
  String? get taluka => _profile.taluka;

  /// Get address
  String? get address => _profile.address;

  /// Get PIN code
  String? get pinCode => _profile.pinCode;

  /// Get mobile number
  String? get mobileNumber => _profile.mobileNumber;

  // ==================== Identity Documents ====================

  /// Get Aadhaar number
  String? get aadhaarNumber => _profile.aadhaarNumber;

  /// Get masked Aadhaar
  String get maskedAadhaar => _profile.maskedAadhaar;

  /// Get PAN number
  String? get panNumber => _profile.panNumber;

  // ==================== Bank Details ====================

  /// Get bank account number
  String? get bankAccountNumber => _profile.bankAccountNumber;

  /// Get masked bank account
  String get maskedBankAccount => _profile.maskedBankAccount;

  /// Get IFSC code
  String? get bankIfscCode => _profile.bankIfscCode;

  /// Get bank name
  String? get bankName => _profile.bankName;

  /// Get bank branch
  String? get bankBranch => _profile.bankBranch;

  // ==================== Land Records & Income ====================

  /// Get 7/12 extract number
  String? get sevenTwelveNumber => _profile.sevenTwelveNumber;

  /// Get income certificate number
  String? get incomeCertificateNumber => _profile.incomeCertificateNumber;

  /// Get annual income
  String? get annualIncome => _profile.annualIncome;

  // ==================== Status Checks ====================

  /// Check if profile is complete (all required fields filled)
  bool get isProfileComplete => _profile.isComplete;

  /// Check if state is selected
  bool get hasState => _profile.hasState;

  /// Check if crops are selected
  bool get hasCrops => _profile.hasCrops;

  /// Check if land size is valid
  bool get hasLandSize => _profile.hasLandSize;

  /// Check if personal details are filled
  bool get hasPersonalDetails => _profile.hasPersonalDetails;

  /// Check if Aadhaar is filled
  bool get hasAadhaar => _profile.hasAadhaar;

  /// Check if PAN is filled
  bool get hasPan => _profile.hasPan;

  /// Check if bank details are filled
  bool get hasBankDetails => _profile.hasBankDetails;

  /// Check if 7/12 is filled
  bool get hasSevenTwelve => _profile.hasSevenTwelve;

  /// Get profile completion percentage (0.0 - 1.0)
  double get completionPercentage => _profile.completionPercentage;

  /// Get eligible schemes based on current profile
  List<Scheme> get eligibleSchemes {
    return EligibilityService.instance.getEligibleSchemes(_profile);
  }

  /// Get count of eligible schemes
  int get eligibleSchemeCount => eligibleSchemes.length;

  /// Check if farmer is eligible for any scheme
  bool get hasEligibleSchemes => eligibleSchemes.isNotEmpty;

  /// Initialize farmer profile from storage
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileJson = prefs.getString(_keyProfile);
      final aadharPath = prefs.getString(_keyAadharCard);

      if (profileJson != null) {
        final Map<String, dynamic> profileMap = json.decode(profileJson);
        _profile = FarmerProfile.fromJson(profileMap);
      }

      _aadharCardPath = aadharPath;
    } catch (e) {
      debugPrint('Error loading farmer profile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Save profile to storage
  Future<void> _saveProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileJson = json.encode(_profile.toJson());
      await prefs.setString(_keyProfile, profileJson);
    } catch (e) {
      debugPrint('Error saving farmer profile: $e');
    }
  }

  /// Update selected state
  Future<void> updateState(String? state) async {
    _profile = _profile.copyWith(selectedState: state);
    notifyListeners();
    await _saveProfile();
  }

  /// Update selected district
  Future<void> updateDistrict(String? district) async {
    _profile = _profile.copyWith(selectedDistrict: district);
    notifyListeners();
    await _saveProfile();
  }

  /// Update selected crops
  Future<void> updateCrops(List<String> crops) async {
    _profile = _profile.copyWith(selectedCrops: crops);
    notifyListeners();
    await _saveProfile();
  }

  /// Add a crop to selection
  Future<void> addCrop(String crop) async {
    if (!_profile.selectedCrops.contains(crop)) {
      final updatedCrops = [..._profile.selectedCrops, crop];
      _profile = _profile.copyWith(selectedCrops: updatedCrops);
      notifyListeners();
      await _saveProfile();
    }
  }

  /// Remove a crop from selection
  Future<void> removeCrop(String crop) async {
    if (_profile.selectedCrops.contains(crop)) {
      final updatedCrops = _profile.selectedCrops.where((c) => c != crop).toList();
      _profile = _profile.copyWith(selectedCrops: updatedCrops);
      notifyListeners();
      await _saveProfile();
    }
  }

  /// Toggle a crop in selection
  void toggleCrop(String crop) {
    if (_profile.selectedCrops.contains(crop)) {
      removeCrop(crop);
    } else {
      addCrop(crop);
    }
  }

  /// Update land size in acres
  Future<void> updateLandSize(double acres) async {
    _profile = _profile.copyWith(landSizeAcres: acres);
    notifyListeners();
    await _saveProfile();
  }

  /// Update personal details
  Future<void> updatePersonalDetails({
    String? fullName,
    String? fatherName,
    String? gender,
    DateTime? dateOfBirth,
    String? village,
    String? taluka,
    String? address,
    String? pinCode,
    String? mobileNumber,
  }) async {
    _profile = _profile.copyWith(
      fullName: fullName,
      fatherName: fatherName,
      gender: gender,
      dateOfBirth: dateOfBirth,
      village: village,
      taluka: taluka,
      address: address,
      pinCode: pinCode,
      mobileNumber: mobileNumber,
    );
    notifyListeners();
    await _saveProfile();
  }

  /// Update identity details (Aadhaar, PAN)
  Future<void> updateIdentityDetails({
    String? aadhaarNumber,
    String? panNumber,
  }) async {
    _profile = _profile.copyWith(
      aadhaarNumber: aadhaarNumber,
      panNumber: panNumber,
    );
    notifyListeners();
    await _saveProfile();
  }

  /// Update bank details
  Future<void> updateBankDetails({
    String? bankAccountNumber,
    String? bankIfscCode,
    String? bankName,
    String? bankBranch,
  }) async {
    _profile = _profile.copyWith(
      bankAccountNumber: bankAccountNumber,
      bankIfscCode: bankIfscCode,
      bankName: bankName,
      bankBranch: bankBranch,
    );
    notifyListeners();
    await _saveProfile();
  }

  /// Update land records and income
  Future<void> updateLandRecordsIncome({
    String? sevenTwelveNumber,
    String? incomeCertificateNumber,
    String? annualIncome,
  }) async {
    _profile = _profile.copyWith(
      sevenTwelveNumber: sevenTwelveNumber,
      incomeCertificateNumber: incomeCertificateNumber,
      annualIncome: annualIncome,
    );
    notifyListeners();
    await _saveProfile();
  }

  /// Update Aadhar card path
  Future<void> updateAadharCard(String? path) async {
    _aadharCardPath = path;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      if (path != null) {
        await prefs.setString(_keyAadharCard, path);
      } else {
        await prefs.remove(_keyAadharCard);
      }
    } catch (e) {
      debugPrint('Error saving Aadhar card path: $e');
    }
  }

  /// Clear all profile data
  Future<void> clearProfile() async {
    _profile = FarmerProfile.empty();
    _aadharCardPath = null;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyProfile);
      await prefs.remove(_keyAadharCard);
    } catch (e) {
      debugPrint('Error clearing profile: $e');
    }
  }

  /// Set entire profile at once
  Future<void> setProfile(FarmerProfile profile) async {
    _profile = profile;
    notifyListeners();
    await _saveProfile();
  }
}
