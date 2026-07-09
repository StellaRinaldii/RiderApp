import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workers_campe/models/possible_shift.dart';
import 'package:workers_campe/providers/possible_shift_provider.dart';
import 'package:workers_campe/screens/DeliveryInProgressPage.dart';
import 'package:workers_campe/screens/homepage.dart';

const Color kGreen = Color(0xFF639922);
const Color kGreenLight = Color(0xFFEAF3DE);

class DeliveryDetailPage extends StatelessWidget {
  final PossibleShift possibleShift;
  final int deliveryIndex;

  const DeliveryDetailPage({
    super.key,
    required this.possibleShift,
    required this.deliveryIndex,
  });

  String get _routeImage {
    final km = possibleShift.activity.distanceKm;
    if (km <= 2.0) return 'assets/routes/short/route_1.png';
    if (km <= 5.0) return 'assets/routes/medium/route_1.png';
    return 'assets/routes/long/route_1.png';
  }

  Color get _effortColor {
    switch (possibleShift.effortType) {
      case EffortType.low:
        return Colors.green;
      case EffortType.moderate:
        return Colors.orange;
      case EffortType.high:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final shift = possibleShift;
    final activity = shift.activity;

    final currentBattery = Provider.of<PossibleShiftProvider>(
      context,
      listen: true,
    ).currentBattery;

    final int estimatedBatteryAfter =
        (currentBattery.batteryLevel - shift.estimatedBatteryReduction)
            .clamp(0, currentBattery.maxLevel);

    return Scaffold(
      backgroundColor: kGreenLight,
      appBar: AppBar(
        title: const Text('Delivery details'),
        backgroundColor: kGreen,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
          left: 20,
          right: 20,
          top: 30,
          bottom: 24,
        ),
        child: Column(
          children: [
            Text(
              'Delivery #$deliveryIndex',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: kGreen,
              ),
            ),

            const SizedBox(height: 20),

            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                _routeImage,
                width: double.infinity,
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  _row(Icons.place, 'Destination', shift.destinationAddress),
                  _row(
                    Icons.route,
                    'Distance',
                    '${activity.distanceKm.toStringAsFixed(2)} km',
                  ),
                  _row(
                    Icons.timer,
                    'Estimated time',
                    '${activity.durationMinutes} min',
                  ),
                  _row(
                    Icons.attach_money,
                    'Earning',
                    '€${shift.earning.toStringAsFixed(2)}',
                  ),
                  _row(
                    Icons.fitness_center,
                    'Effort',
                    shift.effortLabel,
                    valueColor: _effortColor,
                  ),
                  _row(
                    Icons.stars,
                    'Points',
                    '+${shift.points} pts',
                  ),
                  _row(
                    Icons.battery_alert,
                    'Estimated battery reduction',
                    '-${shift.estimatedBatteryReduction}%',
                  ),
                  _row(
                    Icons.battery_charging_full,
                    'Estimated battery after delivery',
                    '$estimatedBatteryAfter%',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            const Text(
              'Accept the delivery?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 18),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: kGreen,
                      side: const BorderSide(color: kGreen),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HomePage(),
                        ),
                        (route) => false,
                      );
                    },
                    child: const Text('NO'),
                  ),
                ),

                const SizedBox(width: 15),

                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      Provider.of<PossibleShiftProvider>(
                        context,
                        listen: false,
                      ).selectPossibleShift(shift);

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DeliveryInProgressPage(),
                        ),
                      );
                    },
                    child: const Text('YES'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(
    IconData icon,
    String title,
    String value, {
    Color valueColor = Colors.black,
  }) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: kGreen),
            const SizedBox(width: 12),
            Text(
              '$title: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: TextStyle(color: valueColor),
              ),
            ),
          ],
        ),
      );
}