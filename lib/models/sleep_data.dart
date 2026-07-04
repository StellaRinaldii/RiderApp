class SleepData {
  // This class models the sleep data needed by the battery algorithm.
  final int duration;
  final int efficiency;

  SleepData({
    required this.duration,
    required this.efficiency,
  });

  SleepData.fromJson(Map<String, dynamic> json)
      : duration = (json["duration"] as num).round(),
        efficiency = (json["efficiency"] as num).toInt();

  int get durationMinutes {
    return (duration / 60000).round();
  }

  @override
  String toString() {
    return 'SleepData{durationMinutes: $durationMinutes, efficiency: $efficiency}';
  }
}