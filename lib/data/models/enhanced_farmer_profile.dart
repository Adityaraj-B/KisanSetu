import 'state_model.dart';
import 'district_model.dart';
import 'crop_model.dart';

/// Enhanced Farmer Profile Model for PMFBY Integration
/// Stores complete farmer details including state, district, crops, land information, and documents
class EnhancedFarmerProfile {
  final StateModel? selectedState;
  final DistrictModel? selectedDistrict;
  final List<CropModel> selectedCrops;
  final double landSizeAcres;
  final String? mobileNumber;
  final String seasonId;
  final DateTime? lastUpdated;

  // Personal Details
  final String? fullName;
  final String? fatherName;
  final String? gender;
  final DateTime? dateOfBirth;
  final String? address;
  final String? pinCode;
  final String? village;
  final String? taluka;

  // Document Details (storing document numbers, not files)
  final String? aadhaarNumber;
  final String? panNumber;
  final String? bankAccountNumber;
  final String? bankIfscCode;
  final String? bankName;
  final String? bankBranch;
  final String? sevenTwelveNumber; // 7/12 Extract Number
  final String? incomeCertificateNumber;
  final String? annualIncome;

  // Document Upload Paths (optional for actual file uploads)
  final String? aadhaarDocPath;
  final String? panDocPath;
  final String? sevenTwelveDocPath;
  final String? incomeCertificateDocPath;
  final String? bankPassbookDocPath;
  final String? landRecordDocPath;
  final String? photographPath;

  const EnhancedFarmerProfile({
    this.selectedState,
    this.selectedDistrict,
    this.selectedCrops = const [],
    this.landSizeAcres = 0.0,
    this.mobileNumber,
    required this.seasonId,
    this.lastUpdated,
    // Personal Details
    this.fullName,
    this.fatherName,
    this.gender,
    this.dateOfBirth,
    this.address,
    this.pinCode,
    this.village,
    this.taluka,
    // Document Details
    this.aadhaarNumber,
    this.panNumber,
    this.bankAccountNumber,
    this.bankIfscCode,
    this.bankName,
    this.bankBranch,
    this.sevenTwelveNumber,
    this.incomeCertificateNumber,
    this.annualIncome,
    // Document Paths
    this.aadhaarDocPath,
    this.panDocPath,
    this.sevenTwelveDocPath,
    this.incomeCertificateDocPath,
    this.bankPassbookDocPath,
    this.landRecordDocPath,
    this.photographPath,
  });

  /// Create an empty profile with current season
  factory EnhancedFarmerProfile.empty() {
    return EnhancedFarmerProfile(
      selectedState: null,
      selectedDistrict: null,
      selectedCrops: const [],
      landSizeAcres: 0.0,
      mobileNumber: null,
      seasonId: SeasonHelper.getCurrentSeasonId(),
      lastUpdated: null,
    );
  }

  /// Create a copy with updated values
  EnhancedFarmerProfile copyWith({
    StateModel? selectedState,
    DistrictModel? selectedDistrict,
    List<CropModel>? selectedCrops,
    double? landSizeAcres,
    String? mobileNumber,
    String? seasonId,
    DateTime? lastUpdated,
    bool clearState = false,
    bool clearDistrict = false,
    bool clearCrops = false,
    // Personal Details
    String? fullName,
    String? fatherName,
    String? gender,
    DateTime? dateOfBirth,
    String? address,
    String? pinCode,
    String? village,
    String? taluka,
    // Document Details
    String? aadhaarNumber,
    String? panNumber,
    String? bankAccountNumber,
    String? bankIfscCode,
    String? bankName,
    String? bankBranch,
    String? sevenTwelveNumber,
    String? incomeCertificateNumber,
    String? annualIncome,
    // Document Paths
    String? aadhaarDocPath,
    String? panDocPath,
    String? sevenTwelveDocPath,
    String? incomeCertificateDocPath,
    String? bankPassbookDocPath,
    String? landRecordDocPath,
    String? photographPath,
  }) {
    return EnhancedFarmerProfile(
      selectedState: clearState ? null : (selectedState ?? this.selectedState),
      selectedDistrict: clearDistrict ? null : (selectedDistrict ?? this.selectedDistrict),
      selectedCrops: clearCrops ? const [] : (selectedCrops ?? this.selectedCrops),
      landSizeAcres: landSizeAcres ?? this.landSizeAcres,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      seasonId: seasonId ?? this.seasonId,
      lastUpdated: lastUpdated ?? DateTime.now(),
      // Personal Details
      fullName: fullName ?? this.fullName,
      fatherName: fatherName ?? this.fatherName,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      address: address ?? this.address,
      pinCode: pinCode ?? this.pinCode,
      village: village ?? this.village,
      taluka: taluka ?? this.taluka,
      // Document Details
      aadhaarNumber: aadhaarNumber ?? this.aadhaarNumber,
      panNumber: panNumber ?? this.panNumber,
      bankAccountNumber: bankAccountNumber ?? this.bankAccountNumber,
      bankIfscCode: bankIfscCode ?? this.bankIfscCode,
      bankName: bankName ?? this.bankName,
      bankBranch: bankBranch ?? this.bankBranch,
      sevenTwelveNumber: sevenTwelveNumber ?? this.sevenTwelveNumber,
      incomeCertificateNumber: incomeCertificateNumber ?? this.incomeCertificateNumber,
      annualIncome: annualIncome ?? this.annualIncome,
      // Document Paths
      aadhaarDocPath: aadhaarDocPath ?? this.aadhaarDocPath,
      panDocPath: panDocPath ?? this.panDocPath,
      sevenTwelveDocPath: sevenTwelveDocPath ?? this.sevenTwelveDocPath,
      incomeCertificateDocPath: incomeCertificateDocPath ?? this.incomeCertificateDocPath,
      bankPassbookDocPath: bankPassbookDocPath ?? this.bankPassbookDocPath,
      landRecordDocPath: landRecordDocPath ?? this.landRecordDocPath,
      photographPath: photographPath ?? this.photographPath,
    );
  }

  /// Check if profile has all required fields filled
  bool get isComplete =>
      hasState &&
      hasDistrict &&
      hasCrops &&
      hasValidLandSize;

  /// Check if state is selected
  bool get hasState => selectedState != null;

  /// Check if district is selected
  bool get hasDistrict => selectedDistrict != null;

  /// Check if at least one crop is selected
  bool get hasCrops => selectedCrops.isNotEmpty;

  /// Check if land size is valid (> 0)
  bool get hasValidLandSize => landSizeAcres >= 0.01;

  /// Get completion percentage (0-100)
  int get completionPercentage {
    int completed = 0;
    if (hasState) completed += 25;
    if (hasDistrict) completed += 25;
    if (hasCrops) completed += 25;
    if (hasValidLandSize) completed += 25;
    return completed;
  }

  /// Get state name for display
  String get stateName => selectedState?.stateName ?? '';

  /// Get district name for display
  String get districtName => selectedDistrict?.districtName ?? '';

  /// Get crop names as comma-separated string
  String get cropNames => selectedCrops.map((c) => c.cropName).join(', ');

  /// Get formatted land size string
  String get formattedLandSize => '${landSizeAcres.toStringAsFixed(2)} acres';

  /// Check if personal details are filled
  bool get hasPersonalDetails =>
      fullName != null && fullName!.isNotEmpty &&
      fatherName != null && fatherName!.isNotEmpty;

  /// Check if bank details are filled
  bool get hasBankDetails =>
      bankAccountNumber != null && bankAccountNumber!.isNotEmpty &&
      bankIfscCode != null && bankIfscCode!.isNotEmpty;

  /// Check if Aadhaar is filled
  bool get hasAadhaar =>
      aadhaarNumber != null && aadhaarNumber!.length == 12;

  /// Check if 7/12 extract number is filled
  bool get hasSevenTwelve =>
      sevenTwelveNumber != null && sevenTwelveNumber!.isNotEmpty;

  /// Get masked Aadhaar number for display
  String get maskedAadhaar {
    if (aadhaarNumber == null || aadhaarNumber!.length != 12) return '';
    return 'XXXX XXXX ${aadhaarNumber!.substring(8)}';
  }

  /// Get masked bank account number for display
  String get maskedBankAccount {
    if (bankAccountNumber == null || bankAccountNumber!.length < 4) return '';
    return 'XXXX${bankAccountNumber!.substring(bankAccountNumber!.length - 4)}';
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() => {
    'selectedState': selectedState?.toJson(),
    'selectedDistrict': selectedDistrict?.toJson(),
    'selectedCrops': selectedCrops.map((c) => c.toJson()).toList(),
    'landSizeAcres': landSizeAcres,
    'mobileNumber': mobileNumber,
    'seasonId': seasonId,
    'lastUpdated': lastUpdated?.toIso8601String(),
    // Personal Details
    'fullName': fullName,
    'fatherName': fatherName,
    'gender': gender,
    'dateOfBirth': dateOfBirth?.toIso8601String(),
    'address': address,
    'pinCode': pinCode,
    'village': village,
    'taluka': taluka,
    // Document Details
    'aadhaarNumber': aadhaarNumber,
    'panNumber': panNumber,
    'bankAccountNumber': bankAccountNumber,
    'bankIfscCode': bankIfscCode,
    'bankName': bankName,
    'bankBranch': bankBranch,
    'sevenTwelveNumber': sevenTwelveNumber,
    'incomeCertificateNumber': incomeCertificateNumber,
    'annualIncome': annualIncome,
    // Document Paths
    'aadhaarDocPath': aadhaarDocPath,
    'panDocPath': panDocPath,
    'sevenTwelveDocPath': sevenTwelveDocPath,
    'incomeCertificateDocPath': incomeCertificateDocPath,
    'bankPassbookDocPath': bankPassbookDocPath,
    'landRecordDocPath': landRecordDocPath,
    'photographPath': photographPath,
  };

  /// Create from JSON
  factory EnhancedFarmerProfile.fromJson(Map<String, dynamic> json) {
    return EnhancedFarmerProfile(
      selectedState: json['selectedState'] != null
          ? StateModel.fromJson(json['selectedState'] as Map<String, dynamic>)
          : null,
      selectedDistrict: json['selectedDistrict'] != null
          ? DistrictModel.fromJson(json['selectedDistrict'] as Map<String, dynamic>)
          : null,
      selectedCrops: (json['selectedCrops'] as List<dynamic>?)
          ?.map((e) => CropModel.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      landSizeAcres: (json['landSizeAcres'] as num?)?.toDouble() ?? 0.0,
      mobileNumber: json['mobileNumber'] as String?,
      seasonId: json['seasonId'] as String? ?? SeasonHelper.getCurrentSeasonId(),
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.tryParse(json['lastUpdated'] as String)
          : null,
      // Personal Details
      fullName: json['fullName'] as String?,
      fatherName: json['fatherName'] as String?,
      gender: json['gender'] as String?,
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.tryParse(json['dateOfBirth'] as String)
          : null,
      address: json['address'] as String?,
      pinCode: json['pinCode'] as String?,
      village: json['village'] as String?,
      taluka: json['taluka'] as String?,
      // Document Details
      aadhaarNumber: json['aadhaarNumber'] as String?,
      panNumber: json['panNumber'] as String?,
      bankAccountNumber: json['bankAccountNumber'] as String?,
      bankIfscCode: json['bankIfscCode'] as String?,
      bankName: json['bankName'] as String?,
      bankBranch: json['bankBranch'] as String?,
      sevenTwelveNumber: json['sevenTwelveNumber'] as String?,
      incomeCertificateNumber: json['incomeCertificateNumber'] as String?,
      annualIncome: json['annualIncome'] as String?,
      // Document Paths
      aadhaarDocPath: json['aadhaarDocPath'] as String?,
      panDocPath: json['panDocPath'] as String?,
      sevenTwelveDocPath: json['sevenTwelveDocPath'] as String?,
      incomeCertificateDocPath: json['incomeCertificateDocPath'] as String?,
      bankPassbookDocPath: json['bankPassbookDocPath'] as String?,
      landRecordDocPath: json['landRecordDocPath'] as String?,
      photographPath: json['photographPath'] as String?,
    );
  }

  @override
  String toString() {
    return 'EnhancedFarmerProfile(state: $stateName, district: $districtName, '
        'crops: ${selectedCrops.length}, land: $landSizeAcres acres, season: $seasonId)';
  }
}

/// Helper class for agricultural season calculation
class SeasonHelper {
  SeasonHelper._();

  /// Get current agricultural season ID in PMFBY format
  /// Kharif (monsoon): April-September
  /// Rabi (winter): October-March
  static String getCurrentSeasonId() {
    final now = DateTime.now();
    final month = now.month;
    final year = now.year;

    if (month >= 4 && month <= 9) {
      // Kharif season (monsoon crops)
      // Format: 0401YYYY (April 1st of current year)
      return '0401$year';
    } else {
      // Rabi season (winter crops)
      // Format: 0110YYYY (October 1st)
      // If we're in Jan-March, use previous year's October
      final seasonYear = month >= 10 ? year : year - 1;
      return '0110$seasonYear';
    }
  }

  /// Get human-readable season name
  static String getCurrentSeasonName() {
    final month = DateTime.now().month;
    if (month >= 4 && month <= 9) {
      return 'Kharif';
    } else {
      return 'Rabi';
    }
  }

  /// Get season year for display
  static String getCurrentSeasonYear() {
    final now = DateTime.now();
    final month = now.month;
    final year = now.year;

    if (month >= 4 && month <= 9) {
      return '$year';
    } else {
      // Rabi season spans two years
      final startYear = month >= 10 ? year : year - 1;
      final endYear = startYear + 1;
      return '$startYear-${endYear.toString().substring(2)}';
    }
  }

  /// Get full season display string
  static String getCurrentSeasonDisplay() {
    return '${getCurrentSeasonName()} ${getCurrentSeasonYear()}';
  }

  /// Get localized season name
  static String getLocalizedSeasonName(String languageCode) {
    final month = DateTime.now().month;
    if (month >= 4 && month <= 9) {
      if (languageCode == 'mr') return 'खरीप';
      if (languageCode == 'hi') return 'खरीफ';
      return 'Kharif';
    } else {
      if (languageCode == 'mr') return 'रब्बी';
      if (languageCode == 'hi') return 'रबी';
      return 'Rabi';
    }
  }

  /// Get localized full season display string
  static String getLocalizedSeasonDisplay(String languageCode) {
    return '${getLocalizedSeasonName(languageCode)} ${getCurrentSeasonYear()}';
  }
}
