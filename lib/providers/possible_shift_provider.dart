import 'package:flutter/material.dart';
import '../models/exercise_activity.dart';
import '../models/possible_shift.dart';
import '../services/Impact.dart';
import '../utils/battery_algorithm.dart';
import 'package:shared_preferences/shared_preferences.dart';



class PossibleShiftProvider extends ChangeNotifier {
  static final DateTime _baseDate = DateTime(2023, 2, 9);
  static const int _seasonWeeks = 42;
  static const int _maxProposals = 3;
  static const int restThreshold = 20;

  bool shiftStarted = false;
  bool isLoading = false;
  String? errorMessage;

  List<PossibleShift> possibleShifts = [];
  PossibleShift? currentPossibleShift;
  PossibleShift? lastCompletedShift;

  int completedDeliveries = 0;
  double totalEarnings = 0.0;
  double totalDistanceKm = 0.0;
  int totalDurationMinutes = 0;
  double totalCalories = 0.0;
  bool shiftClosedByEmergency = false;
  bool shiftClosedByLowBattery = false;
  Battery currentBattery = Battery();

  // real battery reduction of the last completed delivery (computed with
  // real HR data), and the future sleep-recovery gain
  int lastRealBatteryReduction = 0;
  int lastSleepBatteryGain = 0;

  List<int> batteryHistory = [];
  List<int> batteryReductionHistory = [];

  bool sleepRecoveryPending = false;

  int _weekOffset = 0;

  // subject's profile loaded from SharedPreferences (set during onboarding),
  // used to estimate the battery reduction of a delivery before it happens.
  int? _age;
  String? _fitnessLevel;
  String? _sex;

 // This Future is used to ensure that the battery level is loaded from SharedPreferences before any shift starts.
  late final Future<void> _batteryLoading;

  PossibleShiftProvider() {
  _batteryLoading = _loadBatteryLevel(); 
  }

  Future<void> startShift() async {
    await _batteryLoading;

    if (sleepRecoveryPending) {
      print('[SLEEP] Cannot start a new shift: sleep recovery is still pending.');
      return;
    }

    completedDeliveries = 0;
    totalEarnings = 0.0;
    totalDistanceKm = 0.0;
    totalDurationMinutes = 0;
    totalCalories = 0.0;

    shiftClosedByEmergency = false;
    shiftClosedByLowBattery = false;

    lastCompletedShift = null;
    _weekOffset = 0;
    possibleShifts = [];
    shiftStarted = true;

    batteryHistory.clear();
    batteryReductionHistory.clear();
    batteryHistory.add(currentBattery.batteryLevel);

    notifyListeners();

    await _loadUserProfile();
    await _fetchMoreShifts();
  }

  void finishShift({bool emergency = false, bool lowBattery = false}) {
    shiftStarted = false;
    shiftClosedByEmergency = emergency;
    shiftClosedByLowBattery = lowBattery;
    currentPossibleShift = null;
    possibleShifts = [];
    notifyListeners();
  }

  void resetShiftSummary() {
    final bool hadDeliveries = completedDeliveries > 0;

    completedDeliveries = 0;
    totalEarnings = 0.0;
    totalDistanceKm = 0.0;
    totalDurationMinutes = 0;
    totalCalories = 0.0;

    shiftClosedByEmergency = false;
    shiftClosedByLowBattery = false;

    sleepRecoveryPending = hadDeliveries;

    print('[SHIFT] Summary reset. Sleep recovery pending: $sleepRecoveryPending');

    notifyListeners();
  }

  Future<String> applySleepRecoveryAfterShift() async {
    if (!sleepRecoveryPending) {
      print('[SLEEP] No sleep recovery pending.');
      return 'No sleep recovery pending.';
    }

    int efficiency = 80;
    double durationMinutes = 480; // default: 8h
    bool usedRealData = false;

    if (lastCompletedShift != null) {
      final sleepDate = Impact.formatDate(lastCompletedShift!.activity.date);
      print('[SLEEP] Searching sleep data for date: $sleepDate');

      try {
        final sleepData = await Impact.fetchSleepDataByDate(sleepDate);

        if (sleepData != null) {
          efficiency = sleepData.efficiency;
          durationMinutes = sleepData.durationMinutes.toDouble();
          usedRealData = true;

          print('[SLEEP] FOUND sleep data -> duration: ${durationMinutes / 60} h, efficiency: $efficiency%');
        } else {
          print('[SLEEP] NOT FOUND sleep data for $sleepDate. Using default 8h, 80%.');
        }
      } catch (e) {
        print('[SLEEP] ERROR while fetching sleep data: $e. Using default 8h, 80%.');
        usedRealData = false;
      }
    } else {
      print('[SLEEP] No lastCompletedShift available. Using default 8h, 80%.');
    }

    final int levelBeforeGain = currentBattery.batteryLevel;

    final int rawSleepGain = currentBattery.computeSleepGain(efficiency, durationMinutes);

    // Read the fatigue level selected in Aftershift.
    // fatigueLevel is saved when the user presses one of the fatigue icons.
    final sp = await SharedPreferences.getInstance();
    final int fatigueLevel = sp.getInt('fatigueLevel') ?? 1;

    // Borg-inspired correction:
    // higher perceived fatigue means lower effective recovery.
    double recoveryFactor;

    switch (fatigueLevel) {
      case 4:
        recoveryFactor = 0.55;
        break;
      case 3:
        recoveryFactor = 0.70;
        break;
      case 2:
        recoveryFactor = 0.85;
        break;
      default:
        recoveryFactor = 1.0;
    }

    final int adjustedSleepGain = (rawSleepGain * recoveryFactor).round();

    currentBattery.batteryLevel = levelBeforeGain + adjustedSleepGain;

    if (currentBattery.batteryLevel > currentBattery.maxLevel) {
      currentBattery.batteryLevel = currentBattery.maxLevel;
    }

    await _saveBatteryLevel();

    lastSleepBatteryGain = adjustedSleepGain;
    sleepRecoveryPending = false;

    print('[SLEEP] Battery before sleep recovery: $levelBeforeGain%');
    print('[SLEEP] Raw battery gain from sleep: +$rawSleepGain%');
    print('[SLEEP] Fatigue level: $fatigueLevel');
    print('[SLEEP] Borg recovery factor: $recoveryFactor');
    print('[SLEEP] Adjusted battery gain: +$lastSleepBatteryGain%');
    print('[SLEEP] Battery after sleep recovery: ${currentBattery.batteryLevel}%');

    notifyListeners();

    final double sleepHours = durationMinutes / 60;

    if (usedRealData) {
      return 'Sleep recovery applied: you slept ${sleepHours.toStringAsFixed(1)} hours '
          'with $efficiency% efficiency. Fatigue level: $fatigueLevel. '
          'Battery +$lastSleepBatteryGain%';
    }

    return 'Sleep data not found, default recovery applied: 8h sleep, 80% efficiency. '
        'Fatigue level: $fatigueLevel. Battery +$lastSleepBatteryGain%';
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

  static const String _batteryKey = 'batteryLevel';

  Future<void> _saveBatteryLevel() async {
  final sp = await SharedPreferences.getInstance();
  await sp.setInt(_batteryKey, currentBattery.batteryLevel);
}

Future<void> _loadBatteryLevel() async {
  final sp = await SharedPreferences.getInstance();
  final saved = sp.getInt(_batteryKey);
  if (saved != null) {
    currentBattery.batteryLevel = saved;
  }
  notifyListeners();
}

  int _exerciseMinutes(ExerciseActivity activity) {
    if (activity.activeDurationMinutes > 0) {
      return activity.activeDurationMinutes;
    }
    return activity.durationMinutes;
  }

  bool _canAffordShift(PossibleShift shift) {
    final int batteryAfter =
        currentBattery.batteryLevel - shift.estimatedBatteryReduction;

    return batteryAfter > restThreshold;
  }

  void _filterAndSortPossibleShifts() {
    possibleShifts.removeWhere((shift) => !_canAffordShift(shift));
    possibleShifts.sort((a, b) => b.points.compareTo(a.points));
  }

  Future<void> completeCurrentDelivery() async {
    if (currentPossibleShift == null) return;
    final shift = currentPossibleShift!;

    completedDeliveries++;
    totalEarnings += shift.earning;
    totalDistanceKm += shift.activity.distanceKm;
    totalDurationMinutes += shift.activity.durationMinutes;
    totalCalories += shift.activity.calories ?? 0.0;

    final int age = _age ?? 30;
    final int hrex = (shift.activity.averageHeartRate ??
            currentBattery.estimateExerciseHeartRate(_fitnessLevel ?? 'Beginner')).round();
    final int exerciseMinutes = _exerciseMinutes(shift.activity);

    // Try to get the resting HR of the day of the delivery; if not
    // available, fall back to the same estimation used before the delivery.
    int hrrest = currentBattery.estimateRestingHeartRate(
      age,
      _sex ?? 'Other',
      _fitnessLevel ?? 'Beginner',
    );

    print('[HR REST] Searching resting HR for date: ${shift.activity.date}');

    final restingHeartRate =
        await Impact.fetchRestingHeartRateByDate(Impact.formatDate(shift.activity.date));

    if (restingHeartRate != null) {
      hrrest = restingHeartRate.value;
      print('[HR REST] FOUND resting HR: $hrrest bpm');
    } else {
      print('[HR REST] NOT FOUND resting HR for ${shift.activity.date}. Using estimated default: $hrrest bpm');
    }

    lastRealBatteryReduction = currentBattery.computeRealBatteryLoss(
      age,
      hrex,
      hrrest,
      exerciseMinutes,
    );

    print('[BATTERY] Real TRIMP calculation');
    print('[BATTERY] age: $age');
    print('[BATTERY] hrex average: $hrex bpm');
    print('[BATTERY] hrrest used: $hrrest bpm');
    print('[BATTERY] exercise minutes used: $exerciseMinutes');
    print('[BATTERY] real battery reduction: $lastRealBatteryReduction%');

    currentBattery.batteryloss(lastRealBatteryReduction);

    await _saveBatteryLevel();

    batteryReductionHistory.add(lastRealBatteryReduction);
    batteryHistory.add(currentBattery.batteryLevel);

    print('[BATTERY] Battery after real loss: ${currentBattery.batteryLevel}%');

    if (currentBattery.batteryLevel <= restThreshold) {
      print('[BATTERY] Battery <= $restThreshold%. Closing shift automatically.');
    }

    lastCompletedShift = shift;
    possibleShifts.remove(shift);
    currentPossibleShift = null;

    // Saves the cumulative counters in SharedPreferences.
    try {
      final sp = await SharedPreferences.getInstance();
      
      double? globalKm = sp.getDouble('kilometers');
      double? globalEarnings = sp.getDouble('earnings');

      globalKm = (globalKm ?? 0) + shift.activity.distanceKm;
      globalEarnings = (globalEarnings ?? 0) + shift.earning;

      await sp.setDouble('kilometers', globalKm);
      await sp.setDouble('earnings', globalEarnings);
    } catch (e) {
      print('Unsuccesfull Saving of SharedPreferences: $e');
    }

    if (currentBattery.batteryLevel <= restThreshold) {
      finishShift(lowBattery: true);
      return;
    }

    _filterAndSortPossibleShifts();

    notifyListeners();
    await _fetchMoreShifts();
  }

  Future<void> _fetchMoreShifts() async {
    if (isLoading) return;

    if (currentBattery.batteryLevel <= restThreshold) {
      possibleShifts = [];
      errorMessage =
          'Battery too low. No more deliveries can be suggested because it may be unsafe.';
      isLoading = false;
      notifyListeners();
      return;
    }

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
        while (candidates.length < neededCount * 4 && checked < _seasonWeeks) {
          final int effectiveOffset = _weekOffset % _seasonWeeks;
          final start = _baseDate.add(Duration(days: effectiveOffset * 7));
          final end = start.add(const Duration(days: 6));
          _weekOffset++;
          checked++;

          final activities = await Impact.fetchExerciseDataByDateRange(
            startDate: Impact.formatDate(start),
            endDate: Impact.formatDate(end),
          );

          if (activities == null) {
            errorMessage = 'Could not connect to IMPACT server.';
            break;
          }

          for (final activity in activities) {
            if (activity.activityName == 'Bici' && activity.distanceKm > 2.0) {
              final shift = _buildShift(
                activity,
                possibleShifts.length + candidates.length,
              );

              final canAfford = _canAffordShift(shift);

              if (canAfford) {
                candidates.add(shift);
              }
            }
          }
        }

        // Rank compatible candidates by points and keep only the best ones.
        candidates.sort((a, b) => b.points.compareTo(a.points));
        possibleShifts.addAll(candidates.take(neededCount));
        _filterAndSortPossibleShifts();
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
    final km = double.parse(activity.distanceKm.toStringAsFixed(2));
    final int exerciseMinutes = _exerciseMinutes(activity);
    final estimation = currentBattery.lossEstimation(
      _age ?? 30,
      _fitnessLevel ?? 'Beginner',
      exerciseMinutes,
      _sex ?? 'Other',
    );
    // Battery loss estimation using the linear model
    /*final estimation = currentBattery.lossEstimationLinear(
      _fitnessLevel ?? 'Beginner',
      exerciseMinutes,
      _age ?? 30,
      _sex ?? 'Other',
    );*/

    final effort = _effort(estimation);
    final earning = double.parse((km * 0.50).clamp(3.0, 100.0).toStringAsFixed(2),);

    final int headroom = currentBattery.batteryLevel - restThreshold;

    final double relativeCost =
        (estimation / headroom).clamp(0.0, 1.0).toDouble();

    final double earningFraction =
        (earning / 100.0).clamp(0.0, 1.0).toDouble();

    // Points: battery-aware convenience score.
    // Rewards higher earnings and penalizes deliveries that would consume
    // a large fraction of the battery margin currently available before rest.
    final int points = (earningFraction * (1.0 - relativeCost) * 1000)
        .round()
        .clamp(1, 1000)
        .toInt();

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

static EffortType _effort(int batteryReduction) {
    if (batteryReduction <= 10) return EffortType.low;
    if (batteryReduction < 25) return EffortType.moderate;
    return EffortType.high;
  }

  static String _effortLabel(EffortType e) {
    switch (e) {
      case EffortType.low:
        return 'Low effort';
      case EffortType.moderate:
        return 'Moderate effort';
      case EffortType.high:
        return 'High effort';
    }
  }
}