import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workers_campe/models/possible_shift.dart';
import 'package:workers_campe/providers/activity_provider.dart';
import 'package:workers_campe/providers/possible_shift_provider.dart';
import 'package:workers_campe/screens/DeliveryInProgressPage.dart';

const Color kGreen = Color(0xFF639922);
const Color kGreenLight = Color(0xFFEAF3DE);

class DeliveryDetailPage extends StatelessWidget {
  final PossibleShift possibleShift;

  const DeliveryDetailPage({super.key, required this.possibleShift});

  String get _routeImage {
    if (possibleShift.distanceKm <= 2.0) return 'assets/routes/short/route_1.png';
    if (possibleShift.distanceKm <= 5.0) return 'assets/routes/medium/route_1.png';
    return 'assets/routes/long/route_1.png';
  }

  Color get _effortColor {
    switch (possibleShift.effortType) {
      case EffortType.low: return Colors.green;
      case EffortType.moderate: return Colors.orange;
      case EffortType.high: return Colors.red;
    }
  }

  void _onYes(BuildContext context) {
    context.read<PossibleShiftProvider>().selectPossibleShift(possibleShift);
    context.read<ActivityProvider>().setActivityFromShift(possibleShift);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DeliveryInProgressPage()),
    );
  }

  void _onNo(BuildContext context) {
    context.read<PossibleShiftProvider>().rejectShift(possibleShift);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final shift = possibleShift;

    return Scaffold(
      backgroundColor: kGreenLight,
      appBar: AppBar(
        title: const Text('Delivery details'),
        backgroundColor: kGreen,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 30, bottom: 24),
        child: Column(
          children: [
            Text(
              'Deliver by ${shift.time}',
              style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: kGreen),
            ),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(_routeImage, width: double.infinity, fit: BoxFit.contain),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(24)),
              child: Column(
                children: [
                  _row(Icons.place, 'Destination', shift.destinationAddress),
                  _row(Icons.route, 'Distance', '${shift.distanceKm} km'),
                  _row(Icons.timer, 'Estimated time', '${shift.estimatedMinutes} min'),
                  _row(Icons.attach_money, 'Earning', '€${shift.earning.toStringAsFixed(2)}'),
                  _row(Icons.fitness_center, 'Effort', shift.effortLabel, valueColor: _effortColor),
                  _row(Icons.stars, 'Points', '+${shift.points} pts'),
                ],
              ),
            ),
            const Spacer(),
            const Text('Accept the delivery?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                    onPressed: () => _onNo(context),
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
                    onPressed: () => _onYes(context),
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

  Widget _row(IconData icon, String title, String value, {Color valueColor = Colors.black}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: kGreen),
          const SizedBox(width: 12),
          Text('$title: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(value, textAlign: TextAlign.right, style: TextStyle(color: valueColor)),
          ),
        ],
      ),
    );
  }
}