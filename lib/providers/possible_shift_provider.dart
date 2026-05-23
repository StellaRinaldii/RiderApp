import 'package:flutter/foundation.dart';
import '../models/exercise_activity.dart';
import '../models/possible_shift.dart';
import '../services/Impact.dart';

class PossibleShiftProvider extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;
  PossibleShift? currentPossibleShift;
  List<PossibleShift> possibleShifts = [];

  static final DateTime firstSearchDay = DateTime(2023, 5, 13);
  static const int weeksPerSearch = 12;
  static const int maxProposals = 3;

  int _nextWeekOffset = 0;
  bool hasLoadedOnce = false;
  final Set<String> _usedActivityKeys = {};

  static EffortType calculateEffort(ExerciseActivity a) {
    final mins = a.durationMinutes;
    final km = a.distanceKm;
    final cal = a.calories ?? 0;
    final hr = a.averageHeartRate ?? 0;

    if (mins > 45 || km > 8 || cal > 400 || hr > 150) {
      return EffortType.high;
    }

    if (mins < 20 && km < 3 && cal < 200) {
      return EffortType.low;
    }

    return EffortType.moderate;
  }

  static String effortLabel(EffortType e) {
    switch (e) {
      case EffortType.low:
        return 'Low effort';
      case EffortType.moderate:
        return 'Moderate effort';
      case EffortType.high:
        return 'High effort';
    }
  }

  static String _fmt(DateTime d) {
    return '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
  }

  bool _isBiciActivity(ExerciseActivity activity) {
    final name = activity.activityName.trim().toLowerCase();
    return name == 'bici' || name.contains('bici');
  }

  List<dynamic> _extractDayList(dynamic raw) {
    // Expected daterange response:
    // { status, code, message, data: [ { date: ..., data: [activities] } ] }
    if (raw is List) return raw;

    if (raw is Map) {
      final data = raw['data'];

      if (data is List) return data;

      if (data is Map) {
        if (data['data'] is List) return [data];
      }
    }

    return [];
  }

  String _activityKey(ExerciseActivity activity) {
    if (activity.logId.isNotEmpty) return activity.logId;
    return '${activity.date}_${activity.time}_${activity.activityName}_${activity.distanceKm}';
  }

  PossibleShift _buildPossibleShift(ExerciseActivity activity, int index) {
    final effort = calculateEffort(activity);
    final km = double.parse(activity.distanceKm.toStringAsFixed(2));

    final effortBonus = effort == EffortType.high
        ? 80
        : effort == EffortType.moderate
            ? 40
            : 15;

    final points = (km * 10).round() + effortBonus;

    final earning = double.parse(
      (km * 0.50 + effortBonus / 100).clamp(1.50, 50.0).toStringAsFixed(2),
    );

    final deliveryTimes = ['18:30', '19:00', '19:30'];
    final addresses = [
      'Via Venezia 10, Padova',
      'Via Roma 20, Padova',
      'Prato della Valle 5, Padova',
    ];

    return PossibleShift(
      logId: activity.logId,
      date: activity.date,
      activityName: activity.activityName,
      time: deliveryTimes[index % deliveryTimes.length],
      distanceKm: km,
      estimatedMinutes: activity.durationMinutes > 0 ? activity.durationMinutes : 30,
      points: points,
      earning: earning,
      effortType: effort,
      effortLabel: effortLabel(effort),
      destinationAddress: addresses[index % addresses.length],
    );
  }

  void resetSearch() {
    _nextWeekOffset = 0;
    _usedActivityKeys.clear();
    hasLoadedOnce = false;
    possibleShifts = [];
    currentPossibleShift = null;
    errorMessage = null;
    notifyListeners();
  }

  Future<void> loadPossibleShifts({bool reset = false}) async {
    if (isLoading) return;

    if (reset) {
      _nextWeekOffset = 0;
      _usedActivityKeys.clear();
      hasLoadedOnce = false;
    }

    isLoading = true;
    errorMessage = null;
    possibleShifts = [];
    currentPossibleShift = null;
    notifyListeners();

    try {
      for (int checkedWeeks = 0;
          checkedWeeks < weeksPerSearch && possibleShifts.length < maxProposals;
          checkedWeeks++) {
        final startDay = firstSearchDay.add(Duration(days: _nextWeekOffset * 7));
        final endDay = startDay.add(const Duration(days: 6));

        _nextWeekOffset++;

        final startDate = _fmt(startDay);
        final endDate = _fmt(endDay);

        final raw = await Impact.fetchExerciseDataByDateRange(
          username: Impact.patientUsername,
          startDate: startDate,
          endDate: endDate,
        );

        if (raw == null) {
          errorMessage = possibleShifts.isEmpty
              ? 'Could not connect to IMPACT server.'
              : null;
          break;
        }

        final dayList = _extractDayList(raw);
        print('Days received from $startDate to $endDate: ${dayList.length}');

        for (final dayObj in dayList) {
          if (dayObj is! Map) continue;

          // Robust case: if the API directly returns an activity object.
          if (dayObj['activityName'] != null) {
            final activity = ExerciseActivity.fromJson(
              Map<String, dynamic>.from(dayObj),
              startDate,
            );
            _tryAddActivity(activity);
            if (possibleShifts.length == maxProposals) break;
            continue;
          }

          final date = dayObj['date']?.toString() ?? startDate;
          final dataList = dayObj['data'];

          if (dataList is! List) continue;

          for (final item in dataList) {
            if (item is! Map) continue;

            final activity = ExerciseActivity.fromJson(
              Map<String, dynamic>.from(item),
              date,
            );

            _tryAddActivity(activity);

            if (possibleShifts.length == maxProposals) break;
          }

          if (possibleShifts.length == maxProposals) break;
        }
      }

      hasLoadedOnce = true;

      if (possibleShifts.isNotEmpty) {
        currentPossibleShift = possibleShifts.first;
        errorMessage = null;
      } else {
        final nextStart = firstSearchDay.add(Duration(days: _nextWeekOffset * 7));
        errorMessage = 'No Bici activity found. Press refresh to search from ${_fmt(nextStart)}.';
      }
    } catch (e) {
      errorMessage = 'Error: $e';
    }

    isLoading = false;
    notifyListeners();
  }

  void _tryAddActivity(ExerciseActivity activity) {
    print('Activity found in response: ${activity.activityName} ${activity.date} ${activity.time}');

    if (!_isBiciActivity(activity)) return;

    if (activity.durationMinutes < 1 && activity.distanceKm < 0.01) return;

    final key = _activityKey(activity);
    if (_usedActivityKeys.contains(key)) return;

    final shift = _buildPossibleShift(activity, possibleShifts.length);
    possibleShifts.add(shift);
    _usedActivityKeys.add(key);

    print('Bici proposal added: ${activity.date} ${activity.time} ${activity.distanceKm} km');
  }

  void selectPossibleShift(PossibleShift shift) {
    currentPossibleShift = shift;
    notifyListeners();
  }
}
