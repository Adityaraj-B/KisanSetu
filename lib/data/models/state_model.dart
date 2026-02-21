/// State Model - Represents an Indian state from PMFBY API
/// Maps to the response from /landingPage/stateList
class StateModel {
  final String stateId;
  final String stateName;

  const StateModel({
    required this.stateId,
    required this.stateName,
  });

  /// Create from JSON response
  factory StateModel.fromJson(Map<String, dynamic> json) {
    return StateModel(
      stateId: json['stateID']?.toString() ?? '',
      stateName: json['stateName']?.toString() ?? '',
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() => {
    'stateID': stateId,
    'stateName': stateName,
  };

  @override
  String toString() => 'StateModel(id: $stateId, name: $stateName)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StateModel &&
        other.stateId == stateId &&
        other.stateName == stateName;
  }

  @override
  int get hashCode => stateId.hashCode ^ stateName.hashCode;
}

