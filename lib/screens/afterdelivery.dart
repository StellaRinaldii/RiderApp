import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workers_campe/providers/activity_provider.dart';
import 'package:workers_campe/providers/possible_shift_provider.dart';
import 'package:workers_campe/screens/homepage.dart';

const Color kGreen = Color(0xFF639922);
const Color kGreenLight = Color(0xFFEAF3DE);

class Afterdelivery extends StatelessWidget {
  const Afterdelivery({super.key});

  @override
  Widget build(BuildContext context) {
    final actProv = context.watch<ActivityProvider>();
    final shiftProv = context.watch<PossibleShiftProvider>();
    final activity = actProv.selectedActivity;
    final shift = shiftProv.currentPossibleShift;
    const double battery = 0.75;

    return Scaffold(
      backgroundColor: kGreenLight,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Delivery Completed!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: kGreen,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Your Delivery Summary:',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: kGreen,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  color: Colors.white,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: activity == null
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: Text(
                              'No delivery data available.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : Column(
                            children: [
                              Row(
                                children: [
                                  _stat('Total distance', 'km', activity.distanceKm.toStringAsFixed(2)),
                                  const Spacer(),
                                  _stat('Total time', 'min', activity.durationMinutes.toString()),
                                ],
                              ),
                              Row(
                                children: [
                                  _stat('Avg speed', 'km/h', activity.averageSpeedKmh.toStringAsFixed(1)),
                                  const Spacer(),
                                  _stat('Elevation', 'm', (activity.elevationGain ?? 0).round().toString()),
                                ],
                              ),
                              Row(
                                children: [
                                  _stat('Avg HR', 'bpm', (activity.averageHeartRate ?? 0).round().toString()),
                                  const Spacer(),
                                  _stat('Calories', 'kcal', (activity.calories ?? 0).round().toString()),
                                ],
                              ),
                              const Divider(),
                              _info(Icons.directions_bike, 'Activity', activity.activityName),
                              _info(Icons.calendar_month, 'Date', activity.date),
                              _info(Icons.fitness_center, 'Effort', shift?.effortLabel ?? '-'),
                              _info(Icons.stars, 'Points Earned', shift != null ? '${shift.points}' : '-'),
                              _info(Icons.attach_money, 'Money Earned', shift != null ? '€${shift.earning.toStringAsFixed(2)}' : '-'),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Your Speed:',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: kGreen,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  color: Colors.white,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(
                    height: 100,
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: Text(
                        activity == null
                            ? 'Graph not available'
                            : 'Average speed: ${activity.averageSpeedKmh.toStringAsFixed(1)} km/h',
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Card(
                  color: Colors.white,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Energy level',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: kGreen,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          height: 18,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: battery.clamp(0.0, 1.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: battery < 0.21
                                    ? Colors.red
                                    : battery < 0.7
                                        ? Colors.yellow
                                        : Colors.green,
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '${(battery * 100).round()}% - ${battery < 0.2 ? "Low energy" : battery < 0.7 ? "Moderate energy" : "High energy"}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    onPressed: () => Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const HomePage()),
                      (route) => false,
                    ),
                    icon: const Icon(Icons.home),
                    label: const Text(
                      'Return to Homepage',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _stat(String title, String unit, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: kGreen, fontSize: 15)),
          Text(
            unit.isEmpty ? val : '$val $unit',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ],
      ),
    );
  }

  static Widget _info(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: kGreen),
          const SizedBox(width: 12),
          Text('$title: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
