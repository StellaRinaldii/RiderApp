import 'package:flutter/material.dart';
import '../models/exercise_activity.dart';
import '../models/possible_shift.dart';
import '../services/Impact.dart';
import 'package:intl/intl.dart';
import '../utils/battery_algorithm.dart';
import 'package:shared_preferences/shared_preferences.dart';


class PossibleShiftProvider extends ChangeNotifier {
  static final DateTime _baseDate = DateTime(2023, 2, 9);
  static const int _maxProposals = 3;

  bool shiftStarted = false;
  bool isLoading = false;
  String? errorMessage;

  List<PossibleShift> possibleShifts = [];
  PossibleShift? currentPossibleShift;
  PossibleShift? lastCompletedShift;

  int completedDeliveries = 0;
  int totalPoints = 0;
  double totalEarnings = 0.0;
  double totalDistanceKm = 0.0;
  int totalDurationMinutes = 0;
  double totalCalories = 0.0;
  bool shiftClosedByEmergency = false;
  var currentBattery = Battery();

  // real battery reduction of the last completed delivery (computed with
  // real HR data), and the future sleep-recovery gain, updated elsewhere.
  int lastRealBatteryReduction = 0;
  int lastSleepBatteryGain = 0;

  // true right after the user comes back to the Home from the aftershift
  // screen: the Home will wait ~10 seconds and then apply the sleep
  // recovery exactly once.
  bool sleepRecoveryPending = false;

  int _weekOffset = 0;

  // subject's profile, loaded from SharedPreferences (set during onboarding),
  // used to estimate the battery reduction of a delivery before it happens.
  int? _age;
  String? _fitnessLevel;
  String? _sex;

  Future<void> startShift() async {
    completedDeliveries = 0;
    totalPoints = 0;
    totalEarnings = 0.0;
    totalDistanceKm = 0.0;
    totalDurationMinutes = 0;
    totalCalories = 0.0;
    shiftClosedByEmergency = false;
    lastCompletedShift = null;
    _weekOffset = 0;
    possibleShifts = [];
    shiftStarted = true;
    notifyListeners();
    await _loadUserProfile();
    await _fetchMoreShifts();
  }

  void finishShift({bool emergency = false}) {
    shiftStarted = false;
    shiftClosedByEmergency = emergency;
    currentPossibleShift = null;
    possibleShifts = [];
    notifyListeners();
  }

  void resetShiftSummary() {
    completedDeliveries = 0;
    totalPoints = 0;
    totalEarnings = 0.0;
    totalDistanceKm = 0.0;
    totalDurationMinutes = 0;
    totalCalories = 0.0;
    shiftClosedByEmergency = false;
    // NB: lastCompletedShift is intentionally NOT cleared here: it is still
    // needed right after this call to know which day to use for the sleep
    // recovery lookup once we are back on the Home. It will be cleared on
    // the next startShift().
    sleepRecoveryPending = true;
    notifyListeners();
  }

  // Applies the sleep recovery once, when called from the Home ~10 seconds
  // after the user comes back from the aftershift screen. Returns a message
  // ready to be shown in a SnackBar.
  Future<String> applySleepRecoveryAfterShift() async {
    int efficiency = 80;
    double durationMinutes = 480; // default: 8h
    bool usedRealData = false;

    if (lastCompletedShift != null) {
      try {
        final sleepData =
            await Impact.fetchSleepDataByDate(lastCompletedShift!.activity.date);
        if (sleepData != null) {
          efficiency = sleepData.efficiency;
          durationMinutes = sleepData.durationMinutes.toDouble();
          usedRealData = true;
        }
      } catch (e) {
        usedRealData = false;
      }
    }

    final int levelBeforeGain = currentBattery.batteryLevel;
    currentBattery.batterygain(efficiency, durationMinutes);
    lastSleepBatteryGain = currentBattery.batteryLevel - levelBeforeGain;

    sleepRecoveryPending = false;
    notifyListeners();

    final double sleepHours = durationMinutes / 60;
    if (usedRealData) {
      return 'Sleep recovery applied: you slept ${sleepHours.toStringAsFixed(1)} hours '
          'with $efficiency% efficiency. Battery +$lastSleepBatteryGain%';
    }
    return 'Sleep data not found, default recovery applied: 8h sleep, 80% efficiency. '
        'Battery +$lastSleepBatteryGain%';
  }

  void selectPossibleShift(PossibleShift shift) {
    currentPossibleShift = shift;
    notifyListeners();
  }

  void rejectShift(PossibleShift shift) {
    possibleShifts.remove(shift);
    notifyListeners();
    _fetchMoreShifts();
  }

  // Loads the subject's profile (saved during onboarding) needed to estimate
  // the battery reduction of a delivery before it happens.
  Future<void> _loadUserProfile() async {
    final sp = await SharedPreferences.getInstance();
    _age = sp.getInt('age');
    _fitnessLevel = sp.getString('trainingstat');
    _sex = sp.getString('gender');
  }

  Future<void> completeCurrentDelivery() async {
    if (currentPossibleShift == null) return;
    final shift = currentPossibleShift!;

    completedDeliveries++;
    totalPoints += shift.points;
    totalEarnings += shift.earning;
    totalDistanceKm += shift.activity.distanceKm;
    totalDurationMinutes += shift.activity.durationMinutes;
    totalCalories += shift.activity.calories ?? 0;

    final int age = _age ?? 30;
    final int hrex = shift.activity.averageHeartRate!.round();

    // try to get the resting HR of the day of the delivery; if not
    // available, fall back to the same estimation used before the delivery.
    int hrrest = currentBattery.estimateRestingHeartRate(
      age,
      _sex ?? 'Other',
      _fitnessLevel ?? 'Beginner',
    );
    final restingHeartRate =
        await Impact.fetchRestingHeartRateByDate(shift.activity.date);
    if (restingHeartRate != null) {
      hrrest = restingHeartRate.value;
    }

    lastRealBatteryReduction = currentBattery.computeRealBatteryLoss(
      age,
      hrex,
      hrrest,
      shift.activity.durationMinutes,
    );
    currentBattery.batteryloss(lastRealBatteryReduction);

    lastCompletedShift = shift;
    possibleShifts.remove(shift);
    currentPossibleShift = null;

    // saves the cumulative counters in SharedPreferences
    try {
      final sp = await SharedPreferences.getInstance();
      // get the values from the SP
      int? globalPoints = sp.getInt('points');
      double? globalKm = sp.getDouble('kilometers');
      double? globalEarnings = sp.getDouble('earnings');
      //  increments the values
      globalPoints = (globalPoints ?? 0) + shift.points;
      globalKm = (globalKm ?? 0) + shift.activity.distanceKm;
      globalEarnings = (globalEarnings ?? 0) + shift.earning;
      // saves the new counters in the SP
      await sp.setInt('points', globalPoints);
      await sp.setDouble('kilometers', globalKm);
      await sp.setDouble('earnings', globalEarnings);
    } catch (e) {
      print("Unsuccesfull Saving of SharedPreferences: $e");
    }

    notifyListeners();
    await _fetchMoreShifts();
  }

  Future<void> _fetchMoreShifts() async {
    if (isLoading) return;
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    if (_age == null || _fitnessLevel == null || _sex == null) {
      await _loadUserProfile();
    }

    try {
      final int neededCount = _maxProposals - possibleShifts.length;

      if (neededCount > 0) {
        final List<PossibleShift> candidates = [];
        int checked = 0;

        // collect a small pool of compatible candidates, so that they can
        // be ranked by points before picking the best ones.
        while (candidates.length < neededCount * 3 && checked < 52) {
          final start = _baseDate.add(Duration(days: _weekOffset * 7));
          final end = start.add(const Duration(days: 6));
          _weekOffset++;
          checked++;

          final activities = await Impact.fetchExerciseDataByDateRange(
            startDate: _fmt(start),
            endDate: _fmt(end),
          );

          if (activities == null) {
            errorMessage = 'Could not connect to IMPACT server.';
            break;
          }

          for (final activity in activities) {
            if (activity.activityName == 'Bici' && activity.distanceKm > 0.01) {
              final shift = _buildShift(
                activity,
                possibleShifts.length + candidates.length,
              );

              final canAfford = currentBattery.batteryLevel -
                      shift.estimatedBatteryReduction >=
                  currentBattery.minLevel;

              if (canAfford) {
                candidates.add(shift);
              }
            }
          }
        }

        // rank compatible candidates by points and keep only the best ones
        candidates.sort((a, b) => b.points.compareTo(a.points));
        possibleShifts.addAll(candidates.take(neededCount));
      }

      if (possibleShifts.isEmpty && errorMessage == null) {
        errorMessage = 'No compatible Bici activities found.';
      }
    } catch (e) {
      errorMessage = 'Error: $e';
    }

    isLoading = false;
    notifyListeners();
  }


  PossibleShift _buildShift(ExerciseActivity activity, int index) {
    final effort = _effort(activity);
    final km = double.parse(activity.distanceKm.toStringAsFixed(2));
    final bonus = effort == EffortType.high ? 80 : effort == EffortType.moderate ? 40 : 15;
    final points = (km * 10).round() + bonus;
    final earning = double.parse(
      (km * 0.50 + bonus / 100).clamp(1.50, 50.0).toStringAsFixed(2),
    );
    final estimation = currentBattery.lossEstimation(
      _age ?? 30,
      _fitnessLevel ?? 'Beginner',
      activity.durationMinutes,
      _sex ?? 'Other',
    );
    const addresses = [
      'Via Venezia 10, Padova',
      'Via Roma 20, Padova',
      'Prato della Valle 5, Padova',
    ];
    return PossibleShift(
      activity: activity,
      points: points,
      earning: earning,
      effortType: effort,
      effortLabel: _effortLabel(effort),
      destinationAddress: addresses[index % addresses.length],
      estimatedBatteryReduction: estimation,
    );
  }

  static EffortType _effort(ExerciseActivity a) {
    final mins = a.durationMinutes;
    final km = a.distanceKm;
    final cal = a.calories ?? 0;
    final hr = a.averageHeartRate ?? 0;
    if (mins > 200 || km > 70 || cal > 2000 || hr > 150) return EffortType.high;
    if (mins < 20 && km < 3 && cal < 200) return EffortType.low;
    return EffortType.moderate;
  }

  static String _effortLabel(EffortType e) {
    switch (e) {
      case EffortType.low: return 'Low effort';
      case EffortType.moderate: return 'Moderate effort';
      case EffortType.high: return 'High effort';
    }
  }
  
  static String _fmt(DateTime d) {
    return DateFormat('yyyy-MM-dd').format(d);
}
}