/// District Model - Represents a district within a state from PMFBY API
/// Maps to the response from /landingPage/districtState
class DistrictModel {
  final String districtId;
  final String districtName;
  final String? stateId;

  const DistrictModel({
    required this.districtId,
    required this.districtName,
    this.stateId,
  });

  /// Create from JSON response
  factory DistrictModel.fromJson(Map<String, dynamic> json) {
    return DistrictModel(
      districtId: json['districtID']?.toString() ?? json['districtId']?.toString() ?? '',
      districtName: json['districtName']?.toString() ?? '',
      stateId: json['stateID']?.toString() ?? json['stateId']?.toString(),
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() => {
    'districtID': districtId,
    'districtName': districtName,
    if (stateId != null) 'stateID': stateId,
  };

  @override
  String toString() => 'DistrictModel(id: $districtId, name: $districtName)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DistrictModel &&
        other.districtId == districtId &&
        other.districtName == districtName;
  }

  @override
  int get hashCode => districtId.hashCode ^ districtName.hashCode;
}

