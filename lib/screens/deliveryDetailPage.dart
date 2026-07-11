import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workers_campe/models/possible_shift.dart';
import 'package:workers_campe/providers/possible_shift_provider.dart';
import 'package:workers_campe/screens/DeliveryInProgressPage.dart';


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
  final imageNumber = deliveryIndex % 3 + 1;

  if (km <= 20.0) {
    return 'assets/routes/short/route_$imageNumber.png';
  }

  if (km <= 60.0) {
    return 'assets/routes/medium/route_$imageNumber.png';
  }

  return 'assets/routes/long/route_$imageNumber.png';
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

    final String estimatedEffortLabel = shift.effortLabel;
    final Color estimatedEffortColor = switch (shift.effortType) {
      EffortType.low => Colors.green,
      EffortType.moderate => Colors.orange,
      EffortType.high => Colors.red,
    };
    
final colorScheme = Theme.of(context).colorScheme;


    return Scaffold(
      backgroundColor: colorScheme.secondary,
      appBar: AppBar(
        title: const Text('Delivery details'),
        backgroundColor: colorScheme.primary,
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
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
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
                  _row(Icons.place, 'Destination', shift.destinationAddress,iconColor: colorScheme.primary),
                  _row(
                    Icons.route,
                    'Distance',
                    '${activity.distanceKm.toStringAsFixed(2)} km',iconColor: colorScheme.primary
                  ),
                  _row(
                    Icons.timer,
                    'Estimated time',
                    '${activity.durationMinutes} min',iconColor: colorScheme.primary
                  ),
                  _row(
                    Icons.attach_money,
                    'Earning',
                    '€${shift.earning.toStringAsFixed(2)}',
                    iconColor: colorScheme.primary
                  ),
                  _row(
                    Icons.fitness_center,
                    'Estimated effort',
                    estimatedEffortLabel,
                    valueColor: estimatedEffortColor,
                    iconColor: colorScheme.primary
                  ),
                  _row(
                    Icons.battery_alert,
                    'Estimated battery reduction',
                    '${shift.estimatedBatteryReduction}%',
                    iconColor: colorScheme.primary
                  ),
                  _row(
                    Icons.battery_charging_full,
                    'Estimated battery after delivery',
                    '$estimatedBatteryAfter%',
                    iconColor: colorScheme.primary
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
                      foregroundColor: colorScheme.primary,
                      side: BorderSide(color: colorScheme.primary),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      Provider.of<PossibleShiftProvider>(context,listen: false).rejectShift(shift);
                      Navigator.pop(context);
                    },
                    child: const Text('NO'),
                  ),
                ),

                const SizedBox(width: 15),

                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
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
    required Color iconColor,
    Color valueColor = Colors.black,
  }) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: iconColor),
            const SizedBox(width: 12),
            Text(
              '$title: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: valueColor,
                  fontWeight: valueColor == Colors.black
                      ? FontWeight.normal
                      : FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
}