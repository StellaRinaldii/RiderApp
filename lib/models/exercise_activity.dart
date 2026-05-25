// Model for a single exercise activity returned by IMPACT
class ExerciseActivity {
  final String logId;
  final String activityName;
  final String date;
  final String time;
  final double? duration;       
  final double? activeDuration; 
  final double? distance;
  final String? distanceUnit;
  final double? calories;
  final int? steps;
  final double? averageHeartRate;
  final double? speed;
  final double? pace;
  final double? elevationGain;
  final bool hasGps;
  final bool hasActiveZoneMinutes;

  ExerciseActivity({
    required this.logId,
    required this.activityName,
    required this.date,
    required this.time,
    this.duration,
    this.activeDuration,
    this.distance,
    this.distanceUnit,
    this.calories,
    this.steps,
    this.averageHeartRate,
    this.speed,
    this.pace,
    this.elevationGain,
    this.hasGps = false,
    this.hasActiveZoneMinutes = false,
  });

  static double? _parseDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  // IMPACT returns duration and activeDuration in milliseconds.
  // This also supports HH:MM:SS if a different endpoint returns a time string.
  static double? _parseDurationMs(dynamic v) {
    if (v == null) return null;
    if (v is int) return v.toDouble();
    if (v is double) return v;
    if (v is String) {
      final parts = v.split(':');
      if (parts.length == 3) {
        final h = int.tryParse(parts[0]) ?? 0;
        final m = int.tryParse(parts[1]) ?? 0;
        final s = int.tryParse(parts[2]) ?? 0;
        return ((h * 3600 + m * 60 + s) * 1000).toDouble();
      }
      return double.tryParse(v);
    }
    return null;
  }

  factory ExerciseActivity.fromJson(Map<String, dynamic> json, String date) {
    return ExerciseActivity(
      logId: json['logId']?.toString() ?? '',
      activityName: json['activityName']?.toString() ?? 'Activity',
      date: date,
      time: json['startTime']?.toString() ?? json['time']?.toString() ?? '',
      duration: _parseDurationMs(json['duration']),
      activeDuration: _parseDurationMs(json['activeDuration']),
      distance: _parseDouble(json['distance']),
      distanceUnit: json['distanceUnit']?.toString(),
      calories: _parseDouble(json['calories']),
      steps: _parseInt(json['steps']),
      averageHeartRate: _parseDouble(json['averageHeartRate']),
      speed: _parseDouble(json['speed']),
      pace: _parseDouble(json['pace']),
      elevationGain: _parseDouble(json['elevationGain']),
      hasGps: json['hasGps'] == true,
      hasActiveZoneMinutes: json['hasActiveZoneMinutes'] == true,
    );
  }

  // Duration in minutes
  int get durationMinutes => duration != null ? (duration! / 60000).round() : 0;

  // Active duration in minutes
  int get activeDurationMinutes => activeDuration != null ? (activeDuration! / 60000).round() : 0;

  // Distance in km
  double get distanceKm {
    if (distance == null) return 0.0;
    final unit = distanceUnit?.toLowerCase() ?? '';
    if (unit.contains('meter') && !unit.contains('kilo')) return distance! / 1000.0;
    return distance!;
  }

  // Average speed in km/h, from the API speed field or calculated from duration.
  double get averageSpeedKmh {
    if (speed != null && speed! > 0) return speed!;
    if (duration != null && duration! > 0 && distanceKm > 0) {
      return distanceKm / (duration! / 3600000.0);
    }
    return 0.0;
  }
}
