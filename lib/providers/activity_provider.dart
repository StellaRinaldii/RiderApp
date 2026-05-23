import 'package:flutter/foundation.dart';
import '../models/exercise_activity.dart';
import '../services/Impact.dart';

class ActivityProvider extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;
  ExerciseActivity? selectedActivity;

  List<dynamic> _extractActivityList(dynamic raw) {
    if (raw is List) return raw;

    if (raw is Map) {
      if (raw['activityName'] != null) return [raw];

      final data = raw['data'];

      // Day object: { date: ..., data: [activities] }
      if (data is List && raw['date'] != null) return data;

      // Wrapper with activity list or day list.
      if (data is List) {
        if (data.isNotEmpty && data.first is Map) {
          final first = data.first as Map;
          if (first['data'] is List) return first['data'];
        }
        return data;
      }

      // Wrapper with day object: { status: ..., data: { date: ..., data: [...] } }
      if (data is Map && data['data'] is List) return data['data'];
    }

    return [];
  }

  String _extractDate(dynamic raw, String fallback) {
    if (raw is Map) {
      if (raw['date'] != null) return raw['date'].toString();

      final data = raw['data'];
      if (data is Map && data['date'] != null) return data['date'].toString();

      if (data is List && data.isNotEmpty && data.first is Map) {
        final first = data.first as Map;
        if (first['date'] != null) return first['date'].toString();
      }
    }
    return fallback;
  }

  // Load full activity details when the rider accepts the delivery.
  Future<bool> loadActivityDetails({
    required String day,
    required String logId,
  }) async {
    isLoading = true;
    errorMessage = null;
    selectedActivity = null;
    notifyListeners();

    try {
      final raw = await Impact.fetchExerciseDataByDay(
        username: Impact.patientUsername,
        day: day,
      );

      if (raw == null) {
        errorMessage = 'Could not load activity details.';
        isLoading = false;
        notifyListeners();
        return false;
      }

      final date = _extractDate(raw, day);
      final activities = _extractActivityList(raw);

      for (final item in activities) {
        if (item is! Map) continue;

        final itemMap = Map<String, dynamic>.from(item);

        if (itemMap['logId']?.toString() == logId) {
          selectedActivity = ExerciseActivity.fromJson(itemMap, date);
          isLoading = false;
          notifyListeners();
          return true;
        }
      }

      errorMessage = 'Activity not found for this day.';
    } catch (e) {
      errorMessage = 'Error: $e';
    }

    isLoading = false;
    notifyListeners();
    return false;
  }
}
