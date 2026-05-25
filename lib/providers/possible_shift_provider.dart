import 'package:flutter/material.dart';
import '../models/exercise_activity.dart';
import '../models/possible_shift.dart';
import '../services/Impact.dart';

class PossibleShiftProvider extends ChangeNotifier {
  static final DateTime _baseDate = DateTime(2023, 6, 13);
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

  // Called when the user presses NO on DeliveryDetailPage
  void rejectShift(PossibleShift shift) {
    possibleShifts.remove(shift);
    notifyListeners();
    _fetchMoreShifts();
  }

  void completeCurrentDelivery(ExerciseActivity? activity) {
    if (currentPossibleShift == null) return;

    completedDeliveries++;
    totalPoints += currentPossibleShift!.points;
    totalEarnings += currentPossibleShift!.earning;

    if (activity != null) {
      totalDistanceKm += activity.distanceKm;
      totalDurationMinutes += activity.durationMinutes;
      totalCalories += activity.calories ?? 0;
    }

    lastCompletedShift = currentPossibleShift;
    possibleShifts.remove(currentPossibleShift);
    currentPossibleShift = null;
    notifyListeners();

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

        final raw = await Impact.fetchExerciseDataByDateRange(
          startDate: _fmt(start),
          endDate: _fmt(end),
        );

        if (raw == null) {
          errorMessage = 'Could not connect to IMPACT server.';
          break;
        }

        for (final dayObj in _extractDayList(raw)) {
          if (dayObj is! Map) continue;
          final date = dayObj['date']?.toString() ?? _fmt(start);
          final dataList = dayObj['data'];
          if (dataList is! List) continue;

          for (final item in dataList) {
            if (item is! Map) continue;
            final activity = ExerciseActivity.fromJson(
              Map<String, dynamic>.from(item), date);
           if (_isBici(activity) && activity.distanceKm > 0.01) {
             possibleShifts.add(_buildShift(activity, possibleShifts.length));
             if (possibleShifts.length == _maxProposals) break;
            }
          }
          if (possibleShifts.length == _maxProposals) break;
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

  bool _isBici(ExerciseActivity a) {
    final name = a.activityName.trim().toLowerCase();
    return name == 'bici' || name.contains('bici');
  }

  List<dynamic> _extractDayList(dynamic raw) {
    if (raw is List) return raw;
    if (raw is Map) {
      final data = raw['data'];
      if (data is List) return data;
    }
    return [];
  }

  PossibleShift _buildShift(ExerciseActivity activity, int index) {
    final effort = _calculateEffort(activity);
    final km = double.parse(activity.distanceKm.toStringAsFixed(2));
    final effortBonus = effort == EffortType.high ? 80 : effort == EffortType.moderate ? 40 : 15;
    final points = (km * 10).round() + effortBonus;
    final earning = double.parse(
      (km * 0.50 + effortBonus / 100).clamp(1.50, 50.0).toStringAsFixed(2),
    );

    final times = ['18:30', '19:00', '19:30'];
    final addresses = [
      'Via Venezia 10, Padova',
      'Via Roma 20, Padova',
      'Prato della Valle 5, Padova',
    ];

    return PossibleShift(
      logId: activity.logId,
      date: activity.date,
      activityName: activity.activityName,
      distanceKm: km,
      estimatedMinutes: activity.durationMinutes > 0 ? activity.durationMinutes : 30,
      points: points,
      earning: earning,
      effortType: effort,
      effortLabel: _effortLabel(effort),
      destinationAddress: addresses[index % addresses.length],
      activity: activity,
    );
  }

  static EffortType _calculateEffort(ExerciseActivity a) {
    final mins = a.durationMinutes;
    final km = a.distanceKm;
    final cal = a.calories ?? 0;
    final hr = a.averageHeartRate ?? 0;
    if (mins > 200 || km > 70|| cal > 2000 || hr > 150) return EffortType.high;
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

  static String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}