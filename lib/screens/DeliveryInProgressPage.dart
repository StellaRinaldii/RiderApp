import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workers_campe/providers/possible_shift_provider.dart';
import 'package:workers_campe/screens/afterdelivery.dart';
import 'package:workers_campe/screens/aftershift.dart';

const Color kGreen = Color(0xFF639922);
const Color kGreenLight = Color(0xFFEAF3DE);

class DeliveryInProgressPage extends StatelessWidget {
  const DeliveryInProgressPage({super.key});

  void _completeDelivery(BuildContext context) {
    context.read<PossibleShiftProvider>().completeCurrentDelivery();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const Afterdelivery()),
    );
  }

  void _onEmergencyConfirmed(BuildContext context) {
    Navigator.of(context).pop();
    context.read<PossibleShiftProvider>().finishShift(emergency: true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
        content: Text('Emergency request sent. Calling 118...'),
      ),
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const Aftershiftpage()),
    );
  }

  void _showEmergencyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: kGreenLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Emergency call',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
        content: Text('Do you want to call 118 and report an emergency?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, height: 1.4, color: Colors.grey[700])),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel',
                style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            onPressed: () => _onEmergencyConfirmed(context),
            child: const Text('Call 118'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kGreenLight,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Active delivery'),
        backgroundColor: kGreen,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 25),
            const Text('Delivery in progress...',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: kGreen)),
            const SizedBox(height: 10),
            Text('Stay safe and enjoy the ride!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.grey[700])),
            const SizedBox(height: 35),
            Container(
              height: 160,
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: kGreenLight, borderRadius: BorderRadius.circular(28)),
              child: Image.asset('assets/gifs/rider.gif',
                  fit: BoxFit.contain, filterQuality: FilterQuality.none),
            ),
            const SizedBox(height: 35),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))],
              ),
              child: Column(
                children: [
                  const Icon(Icons.navigation, color: kGreen, size: 36),
                  const SizedBox(height: 10),
                  Text('Keep going! You\'re almost there.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15, height: 1.4, color: Colors.grey[700])),
                ],
              ),
            ),
            const Spacer(),
            Center(
              child: SizedBox(
                width: 190,
                height: 46,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
                  onPressed: () => _showEmergencyDialog(context),
                  child: const Text('Emergency',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: kGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
                onPressed: () => _completeDelivery(context),
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Complete delivery',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}