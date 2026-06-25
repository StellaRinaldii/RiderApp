class HeartRateZone {
  final String name;
  final int min;
  final int max;
  final int minutes;
  final double caloriesOut;

  HeartRateZone({
    required this.name,
    required this.min,
    required this.max,
    required this.minutes,
    required this.caloriesOut,
  });

  HeartRateZone.fromJson(Map<String, dynamic> json)
      : name = json['name']?.toString() ?? '',
        min = (json['min'] as num?)?.toInt() ?? 0,
        max = (json['max'] as num?)?.toInt() ?? 0,
        minutes = (json['minutes'] as num?)?.toInt() ?? 0,
        caloriesOut = (json['caloriesOut'] as num?)?.toDouble() ?? 0.0;

   @override
  String toString() {
    return 'HeartRateZone(name: $name, min: $min, max: $max, minutes: $minutes, caloriesOut: $caloriesOut)';
  }
}

class ExerciseActivity {
  final String activityName;
  final String date;
  final String time;
  final double? averageHeartRate;
  final double? calories;
  final double? distance;
  final String? distanceUnit;
  final double? duration;
  final double? activeDuration;
  final List<HeartRateZone> heartRateZones;
  final double? speed;
  final double? elevationGain;

  ExerciseActivity({
    required this.activityName,
    required this.date,
    required this.time,
    this.averageHeartRate,
    this.calories,
    this.distance,
    this.distanceUnit,
    this.duration,
    this.activeDuration,
    this.heartRateZones = const [],
    this.speed,
    this.elevationGain,
  });


    ExerciseActivity.fromJson(Map<String, dynamic> json, String date)
      : activityName = json['activityName']?.toString() ?? '',
        date = date,
        time = json['time']?.toString() ?? '',
        averageHeartRate =
            (json['averageHeartRate'] as num?)?.toDouble(),
        calories = (json['calories'] as num?)?.toDouble(),
        distance = (json['distance'] as num?)?.toDouble(),
        distanceUnit = json['distanceUnit']?.toString(),
        duration = (json['duration'] as num?)?.toDouble(),
        activeDuration = (json['activeDuration'] as num?)?.toDouble(),
        speed = (json['speed'] as num?)?.toDouble(),
        elevationGain = (json['elevationGain'] as num?)?.toDouble(),
        heartRateZones = (json['heartRateZones'] as List<dynamic>? ?? [])
            .map((zone) => HeartRateZone.fromJson(
                  Map<String, dynamic>.from(zone),
                ))
            .toList();

  double get distanceKm {
    if (distance == null) return 0.0;
    final unit = distanceUnit?.toLowerCase() ?? '';
    if (unit.contains('meter') && !unit.contains('kilo')) return distance! / 1000.0;
    return distance!;
  }

  int get durationMinutes => duration != null ? (duration! / 60000).round() : 0;
  int get activeDurationMinutes => activeDuration != null ? (activeDuration! / 60000).round() : 0;

  @override
  String toString() {
    return 'ExerciseActivity(activityName: $activityName, date: $date, time: $time, '
        'averageHeartRate: $averageHeartRate, distance: $distance, '
        'distanceUnit: $distanceUnit,';
  }
}