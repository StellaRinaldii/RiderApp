import 'package:flutter/foundation.dart';
import '../models/exercise_activity.dart';
import '../models/possible_shift.dart';

class ActivityProvider extends ChangeNotifier {
  ExerciseActivity? selectedActivity;

  // Uses the real ExerciseActivity already associated with the selected shift.
  void setActivityFromShift(PossibleShift shift) {
    selectedActivity = shift.activity;
    notifyListeners();
  }

  void clearSelectedActivity() {
    selectedActivity = null;
    notifyListeners();
  }
}