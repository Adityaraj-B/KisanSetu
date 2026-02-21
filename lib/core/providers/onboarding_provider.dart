import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/state_model.dart';
import '../../data/models/district_model.dart';
import '../../data/models/crop_model.dart';
import '../../data/models/enhanced_farmer_profile.dart';
import '../../data/fallback_data.dart';
import '../services/pmfby_api_service.dart';

/// Loading state enum for API calls
enum LoadingState { initial, loading, success, error }

/// Onboarding Provider - State management for farmer onboarding flow
/// Handles API calls, form state, and profile persistence
class OnboardingProvider extends ChangeNotifier {
  // API Service
  final PMFBYApiService _apiService = PMFBYApiService();

  // Profile data
  EnhancedFarmerProfile _profile = EnhancedFarmerProfile.empty();

  // Lists from API
  List<StateModel> _states = [];
  List<DistrictModel> _districts = [];
  List<CropModel> _crops = [];

  // Loading states
  LoadingState _statesLoadingState = LoadingState.initial;
  LoadingState _districtsLoadingState = LoadingState.initial;
  LoadingState _cropsLoadingState = LoadingState.initial;

  // Error messages
  String? _statesError;
  String? _districtsError;
  String? _cropsError;

  // Current step in onboarding flow (0-4)
  int _currentStep = 0;

  // Storage key
  static const String _profileKey = 'enhanced_farmer_profile';

  // ==================== Getters ====================

  EnhancedFarmerProfile get profile => _profile;
  List<StateModel> get states => _states;
  List<DistrictModel> get districts => _districts;
  List<CropModel> get crops => _crops;

  LoadingState get statesLoadingState => _statesLoadingState;
  LoadingState get districtsLoadingState => _districtsLoadingState;
  LoadingState get cropsLoadingState => _cropsLoadingState;

  String? get statesError => _statesError;
  String? get districtsError => _districtsError;
  String? get cropsError => _cropsError;

  int get currentStep => _currentStep;
  int get totalSteps => 8; // Personal Details, State, District, Crops, Land Area, Aadhaar/PAN, Bank Details, Land Records/Income (excludes review)

  bool get isStatesLoading => _statesLoadingState == LoadingState.loading;
  bool get isDistrictsLoading => _districtsLoadingState == LoadingState.loading;
  bool get isCropsLoading => _cropsLoadingState == LoadingState.loading;

  bool get hasStates => _states.isNotEmpty;
  bool get hasDistricts => _districts.isNotEmpty;
  bool get hasCrops => _crops.isNotEmpty;

  bool get canSelectDistrict => _profile.hasState;
  bool get canSelectCrops => _profile.hasDistrict;
  bool get canEnterLandArea => _profile.hasCrops;

  bool get isProfileComplete => _profile.isComplete;
  int get completionPercentage => _profile.completionPercentage;

  String get currentSeasonDisplay => SeasonHelper.getCurrentSeasonDisplay();

  // ==================== Initialization ====================

  /// Initialize the provider - load saved profile and fetch states
  Future<void> initialize() async {
    await _loadSavedProfile();
    await loadStates();
  }

  /// Load saved profile from storage
  Future<void> _loadSavedProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileJson = prefs.getString(_profileKey);

      if (profileJson != null) {
        final decoded = json.decode(profileJson) as Map<String, dynamic>;
        _profile = EnhancedFarmerProfile.fromJson(decoded);

        // Update season ID if profile is old
        if (_profile.seasonId != SeasonHelper.getCurrentSeasonId()) {
          _profile = _profile.copyWith(
            seasonId: SeasonHelper.getCurrentSeasonId(),
            // Clear district and crops as they depend on season
            clearDistrict: true,
            clearCrops: true,
          );
          await _saveProfile();
        }

        debugPrint('OnboardingProvider: Loaded saved profile: $_profile');
      }
    } catch (e) {
      debugPrint('OnboardingProvider: Error loading profile: $e');
      _profile = EnhancedFarmerProfile.empty();
    }
    notifyListeners();
  }

  /// Save profile to storage
  Future<void> _saveProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_profileKey, json.encode(_profile.toJson()));
      debugPrint('OnboardingProvider: Profile saved');
    } catch (e) {
      debugPrint('OnboardingProvider: Error saving profile: $e');
    }
  }

  // ==================== API Calls ====================

  /// Load states from API (with fallback to local data)
  Future<void> loadStates({bool forceRefresh = false}) async {
    _statesLoadingState = LoadingState.loading;
    _statesError = null;
    notifyListeners();

    try {
      _states = await _apiService.fetchStates(forceRefresh: forceRefresh);
      _statesLoadingState = LoadingState.success;
      debugPrint('OnboardingProvider: Loaded ${_states.length} states from API');
    } on PMFBYApiException catch (e) {
      debugPrint('OnboardingProvider: API error loading states: ${e.message}');
      // Use fallback data when API fails
      _states = FallbackData.getIndianStates();
      _statesLoadingState = LoadingState.success;
      debugPrint('OnboardingProvider: Using fallback data - ${_states.length} states');
    } catch (e) {
      debugPrint('OnboardingProvider: Unknown error loading states: $e');
      // Use fallback data when API fails
      _states = FallbackData.getIndianStates();
      _statesLoadingState = LoadingState.success;
      debugPrint('OnboardingProvider: Using fallback data - ${_states.length} states');
    }

    notifyListeners();
  }

  /// Load districts for selected state (with fallback to generic districts)
  Future<void> loadDistricts({bool forceRefresh = false}) async {
    if (!_profile.hasState) {
      _districts = [];
      notifyListeners();
      return;
    }

    _districtsLoadingState = LoadingState.loading;
    _districtsError = null;
    notifyListeners();

    try {
      _districts = await _apiService.fetchDistricts(
        stateId: _profile.selectedState!.stateId,
        seasonId: _profile.seasonId,
        forceRefresh: forceRefresh,
      );
      _districtsLoadingState = LoadingState.success;
      debugPrint('OnboardingProvider: Loaded ${_districts.length} districts from API');
    } on PMFBYApiException catch (e) {
      debugPrint('OnboardingProvider: API error loading districts: ${e.message}');
      // Use fallback data from JSON when API fails
      _districts = await FallbackData.getDistrictsFromJson(_profile.selectedState!.stateId);
      _districtsLoadingState = LoadingState.success;
      debugPrint('OnboardingProvider: Using fallback data - ${_districts.length} districts');
    } catch (e) {
      debugPrint('OnboardingProvider: Unknown error loading districts: $e');
      // Use fallback data from JSON when API fails
      _districts = await FallbackData.getDistrictsFromJson(_profile.selectedState!.stateId);
      _districtsLoadingState = LoadingState.success;
      debugPrint('OnboardingProvider: Using fallback data - ${_districts.length} districts');
    }

    notifyListeners();
  }

  /// Load crops for selected district (with fallback to common crops)
  Future<void> loadCrops({bool forceRefresh = false}) async {
    if (!_profile.hasDistrict) {
      _crops = [];
      notifyListeners();
      return;
    }

    _cropsLoadingState = LoadingState.loading;
    _cropsError = null;
    notifyListeners();

    try {
      _crops = await _apiService.fetchCrops(
        districtId: _profile.selectedDistrict!.districtId,
        seasonId: _profile.seasonId,
        forceRefresh: forceRefresh,
      );
      _cropsLoadingState = LoadingState.success;
      debugPrint('OnboardingProvider: Loaded ${_crops.length} crops from API');
    } on PMFBYApiException catch (e) {
      debugPrint('OnboardingProvider: API error loading crops: ${e.message}');
      // Use fallback data when API fails
      _crops = FallbackData.getFallbackCrops(_profile.selectedDistrict!.districtId);
      _cropsLoadingState = LoadingState.success;
      debugPrint('OnboardingProvider: Using fallback data - ${_crops.length} crops');
    } catch (e) {
      debugPrint('OnboardingProvider: Unknown error loading crops: $e');
      // Use fallback data when API fails
      _crops = FallbackData.getFallbackCrops(_profile.selectedDistrict!.districtId);
      _cropsLoadingState = LoadingState.success;
      debugPrint('OnboardingProvider: Using fallback data - ${_crops.length} crops');
    }

    notifyListeners();
  }

  // ==================== Profile Updates ====================

  /// Update selected state
  Future<void> selectState(StateModel state) async {
    _profile = _profile.copyWith(
      selectedState: state,
      clearDistrict: true, // Clear dependent selections
      clearCrops: true,
    );
    _districts = [];
    _crops = [];
    notifyListeners();

    await _saveProfile();
    await loadDistricts();
  }

  /// Update selected district
  Future<void> selectDistrict(DistrictModel district) async {
    _profile = _profile.copyWith(
      selectedDistrict: district,
      clearCrops: true, // Clear dependent selection
    );
    _crops = [];
    notifyListeners();

    await _saveProfile();
    await loadCrops();
  }

  /// Add a crop to selection
  Future<void> addCrop(CropModel crop) async {
    if (!_profile.selectedCrops.any((c) => c.cropId == crop.cropId)) {
      final updatedCrops = [..._profile.selectedCrops, crop];
      _profile = _profile.copyWith(selectedCrops: updatedCrops);
      notifyListeners();
      await _saveProfile();
    }
  }

  /// Remove a crop from selection
  Future<void> removeCrop(CropModel crop) async {
    final updatedCrops = _profile.selectedCrops
        .where((c) => c.cropId != crop.cropId)
        .toList();
    _profile = _profile.copyWith(selectedCrops: updatedCrops);
    notifyListeners();
    await _saveProfile();
  }

  /// Toggle crop selection
  Future<void> toggleCrop(CropModel crop) async {
    if (_profile.selectedCrops.any((c) => c.cropId == crop.cropId)) {
      await removeCrop(crop);
    } else {
      await addCrop(crop);
    }
  }

  /// Check if a crop is selected
  bool isCropSelected(CropModel crop) {
    return _profile.selectedCrops.any((c) => c.cropId == crop.cropId);
  }

  /// Update land size
  Future<void> updateLandSize(double landSize) async {
    _profile = _profile.copyWith(landSizeAcres: landSize);
    notifyListeners();
    await _saveProfile();
  }

  /// Update mobile number
  Future<void> updateMobileNumber(String? mobileNumber) async {
    _profile = _profile.copyWith(mobileNumber: mobileNumber);
    notifyListeners();
    await _saveProfile();
  }

  /// Update personal details
  Future<void> updatePersonalDetails({
    String? fullName,
    String? fatherName,
    String? gender,
    DateTime? dateOfBirth,
    String? address,
    String? village,
    String? taluka,
    String? pinCode,
  }) async {
    _profile = _profile.copyWith(
      fullName: fullName,
      fatherName: fatherName,
      gender: gender,
      dateOfBirth: dateOfBirth,
      address: address,
      village: village,
      taluka: taluka,
      pinCode: pinCode,
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
    String? accountNumber,
    String? ifscCode,
    String? bankName,
    String? branchName,
  }) async {
    _profile = _profile.copyWith(
      bankAccountNumber: accountNumber,
      bankIfscCode: ifscCode,
      bankName: bankName,
      bankBranch: branchName,
    );
    notifyListeners();
    await _saveProfile();
  }

  /// Update land records and income details
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

  // ==================== Step Navigation ====================

  /// Go to next step
  void nextStep() {
    if (_currentStep < totalSteps - 1) {
      _currentStep++;
      notifyListeners();
    }
  }

  /// Go to previous step
  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  /// Go to specific step
  void goToStep(int step) {
    debugPrint('OnboardingProvider: goToStep called with step=$step, totalSteps=$totalSteps');
    if (step >= 0 && step < totalSteps) {
      debugPrint('OnboardingProvider: Valid step, updating from $_currentStep to $step');
      _currentStep = step;
      notifyListeners();
    } else {
      debugPrint('OnboardingProvider: Invalid step $step (must be 0-${totalSteps - 1})');
    }
  }

  /// Check if can proceed to next step
  bool canProceedFromCurrentStep() {
    switch (_currentStep) {
      case 0: // State selection
        return _profile.hasState;
      case 1: // District selection
        return _profile.hasDistrict;
      case 2: // Crop selection
        return _profile.hasCrops;
      case 3: // Land area
        return _profile.hasValidLandSize;
      default:
        return false;
    }
  }

  // ==================== Reset ====================

  /// Reset the entire profile
  Future<void> resetProfile() async {
    _profile = EnhancedFarmerProfile.empty();
    _districts = [];
    _crops = [];
    _currentStep = 0;
    notifyListeners();
    await _saveProfile();
  }

  /// Clear API cache
  Future<void> clearCache() async {
    await _apiService.clearCache();
  }
}

