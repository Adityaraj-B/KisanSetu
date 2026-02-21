/// Crop Model - Represents a crop from PMFBY API
/// Maps to the response from /cropNotification/cropList
class CropModel {
  final String cropId;
  final String cropName;
  final String? districtId;
  final String? seasonId;

  const CropModel({
    required this.cropId,
    required this.cropName,
    this.districtId,
    this.seasonId,
  });

  /// Create from JSON response
  factory CropModel.fromJson(Map<String, dynamic> json) {
    return CropModel(
      cropId: json['cropID']?.toString() ?? json['cropId']?.toString() ?? '',
      cropName: json['cropName']?.toString() ?? '',
      districtId: json['districtID']?.toString() ?? json['districtId']?.toString(),
      seasonId: json['sssyID']?.toString() ?? json['seasonId']?.toString(),
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() => {
    'cropID': cropId,
    'cropName': cropName,
    if (districtId != null) 'districtID': districtId,
    if (seasonId != null) 'sssyID': seasonId,
  };

  @override
  String toString() => 'CropModel(id: $cropId, name: $cropName)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CropModel &&
        other.cropId == cropId &&
        other.cropName == cropName;
  }

  @override
  int get hashCode => cropId.hashCode ^ cropName.hashCode;
}

