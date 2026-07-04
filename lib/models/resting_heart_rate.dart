class RestingHeartRate {
  // This class models the resting heart rate value needed by the battery algorithm.
  final int value;

  RestingHeartRate({required this.value});

  RestingHeartRate.fromJson(Map<String, dynamic> json)
      : value = (json["value"] as num).round();

  @override
  String toString() {
    return 'RestingHeartRate{value: $value}';
  }
}