import 'exercise_activity.dart';

enum EffortType { low, moderate, high }

class PossibleShift {
  final ExerciseActivity activity;
  final int points;
  final double earning;
  final EffortType effortType;
  final String effortLabel;
  final String destinationAddress;
  final int estimatedBatteryReduction;

  PossibleShift({
    required this.activity,
    required this.points,
    required this.earning,
    required this.effortType,
    required this.effortLabel,
    required this.destinationAddress,
    required this.estimatedBatteryReduction,
  });
}