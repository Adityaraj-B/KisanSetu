/// Form Validators - Utility class for form field validation
/// Provides reusable validation functions for farmer onboarding
class FormValidators {
  FormValidators._();

  /// Validate state selection
  static String? validateState(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select your state';
    }
    return null;
  }

  /// Validate district selection
  static String? validateDistrict(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select your district';
    }
    return null;
  }

  /// Validate crop selection (at least one required)
  static String? validateCrops(List<dynamic>? crops) {
    if (crops == null || crops.isEmpty) {
      return 'Please select at least one crop';
    }
    return null;
  }

  /// Validate land area input
  /// - Required field
  /// - Must be a valid number
  /// - Minimum: 0.01 acres
  /// - Maximum: 1000 acres
  /// - Up to 2 decimal places allowed
  static String? validateLandArea(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter land area';
    }

    // Remove any whitespace
    final cleanValue = value.trim();

    // Try to parse as double
    final double? area = double.tryParse(cleanValue);
    if (area == null) {
      return 'Please enter a valid number';
    }

    // Check minimum
    if (area < 0.01) {
      return 'Minimum land area is 0.01 acres';
    }

    // Check maximum
    if (area > 1000) {
      return 'Maximum land area is 1000 acres';
    }

    // Validate decimal places (max 2)
    if (cleanValue.contains('.')) {
      final decimalPart = cleanValue.split('.')[1];
      if (decimalPart.length > 2) {
        return 'Maximum 2 decimal places allowed';
      }
    }

    return null;
  }

  /// Validate mobile number (optional, but if provided must be valid)
  static String? validateMobileNumber(String? value, {bool isRequired = false}) {
    if (value == null || value.isEmpty) {
      if (isRequired) {
        return 'Please enter mobile number';
      }
      return null; // Optional field, empty is OK
    }

    // Remove any spaces or dashes
    final cleanNumber = value.replaceAll(RegExp(r'[\s-]'), '');

    // Check if it's a valid Indian mobile number
    // Should be 10 digits starting with 6, 7, 8, or 9
    final mobileRegex = RegExp(r'^[6-9]\d{9}$');
    if (!mobileRegex.hasMatch(cleanNumber)) {
      return 'Please enter a valid 10-digit mobile number';
    }

    return null;
  }

  /// Validate a generic required field
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $fieldName';
    }
    return null;
  }

  /// Format land area to 2 decimal places
  static String formatLandArea(double value) {
    return value.toStringAsFixed(2);
  }

  /// Parse land area from string, returns 0.0 if invalid
  static double parseLandArea(String value) {
    final cleanValue = value.trim();
    return double.tryParse(cleanValue) ?? 0.0;
  }
}

