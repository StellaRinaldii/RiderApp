import 'package:flutter/foundation.dart';
import '../models/exercise_activity.dart';
import '../models/possible_shift.dart';

class ActivityProvider extends ChangeNotifier {
  ExerciseActivity? selectedActivity;

  // Builds the activity from the shift data we already have — no API call needed.
  void setActivityFromShift(PossibleShift shift) {
    final speed = shift.estimatedMinutes > 0
        ? shift.distanceKm / (shift.estimatedMinutes / 60.0)
        : 15.0;
    final calories = shift.effortType == EffortType.high
        ? 350.0
        : shift.effortType == EffortType.moderate
            ? 220.0
            : 120.0;
    final hr = shift.effortType == EffortType.high
        ? 155.0
        : shift.effortType == EffortType.moderate
            ? 130.0
            : 108.0;

    selectedActivity = ExerciseActivity(
      logId: shift.logId,
      activityName: shift.activityName,
      date: shift.date,
      time: shift.time,
      duration: (shift.estimatedMinutes * 60000).toDouble(),
      distance: shift.distanceKm,
      distanceUnit: 'km',
      calories: calories,
      averageHeartRate: hr,
      speed: speed,
      elevationGain: shift.distanceKm * 4,
    );
    notifyListeners();
  }

  void clearSelectedActivity() {
    selectedActivity = null;
    notifyListeners();
  }
}