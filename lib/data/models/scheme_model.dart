/// Scheme Model - Data model for government schemes
/// Contains all scheme information including eligibility criteria
class Scheme {
  final String id;
  final String name; // Localization key
  final String nameEn;
  final String nameHi;
  final List<String> supportedStates; // Empty or ['All'] means all states
  final List<String> supportedCrops; // Empty or ['All'] means all crops
  final double? minLandAcres; // null means no minimum
  final double? maxLandAcres; // null means no maximum
  final String benefits; // Localization key
  final String description; // Localization key
  final String category;
  final String icon;

  const Scheme({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.nameHi,
    required this.supportedStates,
    required this.supportedCrops,
    this.minLandAcres,
    this.maxLandAcres,
    required this.benefits,
    required this.description,
    required this.category,
    this.icon = 'account_balance',
  });

  /// Check if scheme supports all states
  bool get supportsAllStates =>
      supportedStates.isEmpty ||
      supportedStates.any((s) => s.toLowerCase() == 'all');

  /// Check if scheme supports all crops
  bool get supportsAllCrops =>
      supportedCrops.isEmpty ||
      supportedCrops.any((c) => c.toLowerCase() == 'all');

  /// Check if scheme has land size requirements
  bool get hasLandRequirements => minLandAcres != null || maxLandAcres != null;

  /// Get localized name based on language code
  String getLocalizedName(String languageCode) {
    return languageCode == 'hi' ? nameHi : nameEn;
  }

  @override
  String toString() {
    return 'Scheme(id: $id, nameEn: $nameEn, states: $supportedStates, crops: $supportedCrops)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Scheme && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
