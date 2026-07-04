import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/find_locale.dart';
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
  var currentBattery = Battery() ;

  int _weekOffset = 0;

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
    lastCompletedShift = null;
    notifyListeners();
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

  Future<void> completeCurrentDelivery() async{
    if (currentPossibleShift == null) return;
    final shift = currentPossibleShift!;
    completedDeliveries++;
    totalPoints += shift.points;
    totalEarnings += shift.earning;
    totalDistanceKm += shift.activity.distanceKm;
    totalDurationMinutes += shift.activity.durationMinutes;
    totalCalories += shift.activity.calories ?? 0;
    lastCompletedShift = shift;
    possibleShifts.remove(shift);
    currentPossibleShift = null;
    notifyListeners();

    // aggiornamento delle sp:
    try {
      final sp = await SharedPreferences.getInstance();
      // get the values from the SP
      int? globalPoints = sp.getInt('points');
      double? globalKm = sp.getDouble('kilometers');
      double? globalEarnings = sp.getDouble('earnings');
      // increments the values
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
    _fetchMoreShifts();
  }

  Future<void> _fetchMoreShifts() async {
    if (isLoading) return;
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      int checked = 0;
      while (possibleShifts.length < _maxProposals && checked < 52) {
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
          // va aggiunta la condizione per le battery reduction
          if (activity.activityName=='Bici' && activity.distanceKm > 0.01) {
            possibleShifts.add(_buildShift(activity, possibleShifts.length));
            if (possibleShifts.length == _maxProposals) break;
          }
        }
      }

      if (possibleShifts.isEmpty && errorMessage == null) {
        errorMessage = 'No Bici activities found.';
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
    //final estimation = currentBattery.lossEstimation(age, hrex, hrrest, activity.durationMinutes);
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
      //estimatedBatteryReduction: estimation,
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