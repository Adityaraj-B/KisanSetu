import '../../data/models/scheme_model.dart';
import '../../data/models/farmer_profile.dart';
import '../../data/schemes_data.dart';

/// Eligibility Service - Rule-based scheme matching engine
/// Filters schemes based on farmer profile criteria
class EligibilityService {
  // Private constructor for singleton
  EligibilityService._();

  // Singleton instance
  static final EligibilityService _instance = EligibilityService._();

  /// Get singleton instance
  static EligibilityService get instance => _instance;

  /// Get eligible schemes based on farmer profile
  /// Returns empty list if profile is incomplete or no matches found
  List<Scheme> getEligibleSchemes(FarmerProfile profile) {
    // Return empty list if no state selected
    if (!profile.hasState) {
      return [];
    }

    final eligibleSchemes = <Scheme>[];

    for (final scheme in SchemesData.allSchemes) {
      if (_isSchemeEligible(scheme, profile)) {
        eligibleSchemes.add(scheme);
      }
    }

    return eligibleSchemes;
  }

  /// Check if a single scheme matches farmer profile
  bool _isSchemeEligible(Scheme scheme, FarmerProfile profile) {
    // 1. Check state eligibility
    if (!_isStateEligible(scheme, profile.selectedState)) {
      return false;
    }

    // 2. Check crop eligibility (only if farmer has selected crops)
    if (profile.hasCrops && !_isCropEligible(scheme, profile.selectedCrops)) {
      return false;
    }

    // 3. Check land size eligibility
    if (!_isLandSizeEligible(scheme, profile.landSizeAcres)) {
      return false;
    }

    return true;
  }

  /// Check if farmer's state matches scheme requirements
  bool _isStateEligible(Scheme scheme, String? state) {
    if (state == null || state.isEmpty) {
      return false;
    }

    // Scheme supports all states
    if (scheme.supportsAllStates) {
      return true;
    }

    // Case-insensitive state matching
    final stateLower = state.toLowerCase().trim();
    return scheme.supportedStates.any(
      (s) => s.toLowerCase().trim() == stateLower,
    );
  }

  /// Check if any of farmer's crops match scheme requirements
  bool _isCropEligible(Scheme scheme, List<String> crops) {
    // Scheme supports all crops
    if (scheme.supportsAllCrops) {
      return true;
    }

    // No crops selected - allow schemes that don't require specific crops
    if (crops.isEmpty) {
      return scheme.supportsAllCrops;
    }

    // Case-insensitive crop matching - at least one crop must match
    for (final crop in crops) {
      final cropLower = crop.toLowerCase().trim();
      if (scheme.supportedCrops.any((c) => c.toLowerCase().trim() == cropLower)) {
        return true;
      }
    }

    return false;
  }

  /// Check if farmer's land size meets scheme requirements
  bool _isLandSizeEligible(Scheme scheme, double landSize) {
    // Handle zero or negative land size gracefully
    if (landSize <= 0) {
      // Only eligible for schemes with no land requirements
      return !scheme.hasLandRequirements;
    }

    // Check minimum land requirement
    if (scheme.minLandAcres != null && landSize < scheme.minLandAcres!) {
      return false;
    }

    // Check maximum land requirement
    if (scheme.maxLandAcres != null && landSize > scheme.maxLandAcres!) {
      return false;
    }

    return true;
  }

  /// Get count of eligible schemes for quick stats
  int getEligibleSchemeCount(FarmerProfile profile) {
    return getEligibleSchemes(profile).length;
  }

  /// Check if farmer is eligible for any scheme
  bool hasAnyEligibleScheme(FarmerProfile profile) {
    return getEligibleSchemes(profile).isNotEmpty;
  }
}
