/// Farmer Profile Model - Stores farmer input data for eligibility matching
/// This class holds the farmer's personal, farm, identity, and financial information
class FarmerProfile {
  // Farm Details
  final String? selectedState;
  final String? selectedDistrict;
  final List<String> selectedCrops;
  final double landSizeAcres;

  // Personal Details
  final String? fullName;
  final String? fatherName;
  final String? gender;
  final DateTime? dateOfBirth;
  final String? village;
  final String? taluka;
  final String? address;
  final String? pinCode;
  final String? mobileNumber;

  // Identity Documents
  final String? aadhaarNumber;
  final String? panNumber;

  // Bank Details
  final String? bankAccountNumber;
  final String? bankIfscCode;
  final String? bankName;
  final String? bankBranch;

  // Land Records & Income
  final String? sevenTwelveNumber;
  final String? incomeCertificateNumber;
  final String? annualIncome;

  const FarmerProfile({
    this.selectedState,
    this.selectedDistrict,
    this.selectedCrops = const [],
    this.landSizeAcres = 0.0,
    // Personal Details
    this.fullName,
    this.fatherName,
    this.gender,
    this.dateOfBirth,
    this.village,
    this.taluka,
    this.address,
    this.pinCode,
    this.mobileNumber,
    // Identity Documents
    this.aadhaarNumber,
    this.panNumber,
    // Bank Details
    this.bankAccountNumber,
    this.bankIfscCode,
    this.bankName,
    this.bankBranch,
    // Land Records & Income
    this.sevenTwelveNumber,
    this.incomeCertificateNumber,
    this.annualIncome,
  });

  /// Create a copy with updated values
  FarmerProfile copyWith({
    String? selectedState,
    String? selectedDistrict,
    List<String>? selectedCrops,
    double? landSizeAcres,
    // Personal Details
    String? fullName,
    String? fatherName,
    String? gender,
    DateTime? dateOfBirth,
    String? village,
    String? taluka,
    String? address,
    String? pinCode,
    String? mobileNumber,
    // Identity Documents
    String? aadhaarNumber,
    String? panNumber,
    // Bank Details
    String? bankAccountNumber,
    String? bankIfscCode,
    String? bankName,
    String? bankBranch,
    // Land Records & Income
    String? sevenTwelveNumber,
    String? incomeCertificateNumber,
    String? annualIncome,
  }) {
    return FarmerProfile(
      selectedState: selectedState ?? this.selectedState,
      selectedDistrict: selectedDistrict ?? this.selectedDistrict,
      selectedCrops: selectedCrops ?? this.selectedCrops,
      landSizeAcres: landSizeAcres ?? this.landSizeAcres,
      // Personal Details
      fullName: fullName ?? this.fullName,
      fatherName: fatherName ?? this.fatherName,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      village: village ?? this.village,
      taluka: taluka ?? this.taluka,
      address: address ?? this.address,
      pinCode: pinCode ?? this.pinCode,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      // Identity Documents
      aadhaarNumber: aadhaarNumber ?? this.aadhaarNumber,
      panNumber: panNumber ?? this.panNumber,
      // Bank Details
      bankAccountNumber: bankAccountNumber ?? this.bankAccountNumber,
      bankIfscCode: bankIfscCode ?? this.bankIfscCode,
      bankName: bankName ?? this.bankName,
      bankBranch: bankBranch ?? this.bankBranch,
      // Land Records & Income
      sevenTwelveNumber: sevenTwelveNumber ?? this.sevenTwelveNumber,
      incomeCertificateNumber: incomeCertificateNumber ?? this.incomeCertificateNumber,
      annualIncome: annualIncome ?? this.annualIncome,
    );
  }

  /// Check if profile has all required fields filled
  bool get isComplete =>
      selectedState != null &&
      selectedState!.isNotEmpty &&
      selectedCrops.isNotEmpty &&
      landSizeAcres > 0;

  /// Check if profile is fully complete with all optional details
  bool get isFullyComplete =>
      isComplete && hasPersonalDetails && hasAadhaar && hasBankDetails;

  /// Get profile completion percentage (0.0 - 1.0)
  double get completionPercentage {
    int total = 6; // Total sections
    int completed = 0;

    if (hasState) completed++;
    if (hasCrops) completed++;
    if (hasLandSize) completed++;
    if (hasPersonalDetails) completed++;
    if (hasAadhaar) completed++;
    if (hasBankDetails) completed++;

    return completed / total;
  }

  /// Check if profile has state selected
  bool get hasState => selectedState != null && selectedState!.isNotEmpty;

  /// Check if profile has crops selected
  bool get hasCrops => selectedCrops.isNotEmpty;

  /// Check if profile has valid land size
  bool get hasLandSize => landSizeAcres > 0;

  /// Check if personal details are filled
  bool get hasPersonalDetails => fullName != null && fullName!.isNotEmpty;

  /// Check if identity documents are filled
  bool get hasAadhaar => aadhaarNumber != null && aadhaarNumber!.length == 12;
  bool get hasPan => panNumber != null && panNumber!.length == 10;

  /// Check if bank details are filled
  bool get hasBankDetails =>
      bankAccountNumber != null && bankAccountNumber!.isNotEmpty &&
      bankIfscCode != null && bankIfscCode!.isNotEmpty;

  /// Check if 7/12 details are filled
  bool get hasSevenTwelve => sevenTwelveNumber != null && sevenTwelveNumber!.isNotEmpty;

  /// Get masked Aadhaar for display
  String get maskedAadhaar {
    if (aadhaarNumber == null || aadhaarNumber!.length != 12) return '';
    return 'XXXX XXXX ${aadhaarNumber!.substring(8)}';
  }

  /// Get masked bank account for display
  String get maskedBankAccount {
    if (bankAccountNumber == null || bankAccountNumber!.length < 4) return '';
    return 'XXXX${bankAccountNumber!.substring(bankAccountNumber!.length - 4)}';
  }

  /// Clear all profile data
  static FarmerProfile empty() {
    return const FarmerProfile(
      selectedState: null,
      selectedCrops: [],
      landSizeAcres: 0.0,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'selectedState': selectedState,
      'selectedDistrict': selectedDistrict,
      'selectedCrops': selectedCrops,
      'landSizeAcres': landSizeAcres,
      // Personal Details
      'fullName': fullName,
      'fatherName': fatherName,
      'gender': gender,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'village': village,
      'taluka': taluka,
      'address': address,
      'pinCode': pinCode,
      'mobileNumber': mobileNumber,
      // Identity Documents
      'aadhaarNumber': aadhaarNumber,
      'panNumber': panNumber,
      // Bank Details
      'bankAccountNumber': bankAccountNumber,
      'bankIfscCode': bankIfscCode,
      'bankName': bankName,
      'bankBranch': bankBranch,
      // Land Records & Income
      'sevenTwelveNumber': sevenTwelveNumber,
      'incomeCertificateNumber': incomeCertificateNumber,
      'annualIncome': annualIncome,
    };
  }

  /// Create from JSON
  factory FarmerProfile.fromJson(Map<String, dynamic> json) {
    return FarmerProfile(
      selectedState: json['selectedState'] as String?,
      selectedDistrict: json['selectedDistrict'] as String?,
      selectedCrops: (json['selectedCrops'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      landSizeAcres: (json['landSizeAcres'] as num?)?.toDouble() ?? 0.0,
      // Personal Details
      fullName: json['fullName'] as String?,
      fatherName: json['fatherName'] as String?,
      gender: json['gender'] as String?,
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.tryParse(json['dateOfBirth'] as String)
          : null,
      village: json['village'] as String?,
      taluka: json['taluka'] as String?,
      address: json['address'] as String?,
      pinCode: json['pinCode'] as String?,
      mobileNumber: json['mobileNumber'] as String?,
      // Identity Documents
      aadhaarNumber: json['aadhaarNumber'] as String?,
      panNumber: json['panNumber'] as String?,
      // Bank Details
      bankAccountNumber: json['bankAccountNumber'] as String?,
      bankIfscCode: json['bankIfscCode'] as String?,
      bankName: json['bankName'] as String?,
      bankBranch: json['bankBranch'] as String?,
      // Land Records & Income
      sevenTwelveNumber: json['sevenTwelveNumber'] as String?,
      incomeCertificateNumber: json['incomeCertificateNumber'] as String?,
      annualIncome: json['annualIncome'] as String?,
    );
  }

  @override
  String toString() {
    return 'FarmerProfile(name: $fullName, state: $selectedState, crops: $selectedCrops, land: $landSizeAcres acres)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FarmerProfile &&
        other.selectedState == selectedState &&
        _listEquals(other.selectedCrops, selectedCrops) &&
        other.landSizeAcres == landSizeAcres;
  }

  @override
  int get hashCode =>
      selectedState.hashCode ^ selectedCrops.hashCode ^ landSizeAcres.hashCode;

  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
