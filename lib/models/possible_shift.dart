// Summary model for a proposed delivery shown in HomePage and DeliveryDetailPage
enum EffortType { low, moderate, high }

class PossibleShift {
  final String logId;
  final String date;
  final String activityName;
  final String time;          // simulated deadline (e.g. "18:30")
  final double distanceKm;
  final int estimatedMinutes;
  final int points;
  final double earning;
  final EffortType effortType;
  final String effortLabel;
  final String destinationAddress; // simulated address

  PossibleShift({
    required this.logId,
    required this.date,
    required this.activityName,
    required this.time,
    required this.distanceKm,
    required this.estimatedMinutes,
    required this.points,
    required this.earning,
    required this.effortType,
    required this.effortLabel,
    required this.destinationAddress,
  });
}
