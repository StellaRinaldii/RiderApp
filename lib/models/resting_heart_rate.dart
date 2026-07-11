class RestingHeartRate {
  final int value;

  RestingHeartRate({required this.value});

  RestingHeartRate.fromJson(Map<String, dynamic> json)
      : value = (json["value"] as num).round();

  @override
  String toString() {
    return 'RestingHeartRate{value: $value}';
  }
}