import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workers_campe/providers/possible_shift_provider.dart';
import 'package:workers_campe/screens/homepage.dart';

const Color kGreen = Color(0xFF639922);
const Color kGreenLight = Color(0xFFEAF3DE);

Future<void> saveSP(String key, int value) async {
  final sp = await SharedPreferences.getInstance();
  await sp.setInt(key, value);
}

class Aftershiftpage extends StatefulWidget {
  const Aftershiftpage({super.key});

  @override
  State<Aftershiftpage> createState() => _AftershiftpageState();
}

class _AftershiftpageState extends State<Aftershiftpage> {
  bool _injuryAnswered = false;
  bool _fatigueAnswered = false;

  void _onInjuryYes() {
    setState(() => _injuryAnswered = true);
  }

  void _onInjuryNo() {
    setState(() => _injuryAnswered = true);
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(const SnackBar(
        content: Text('Redirecting Injuries to Occupational Health Physician'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 4),
      ));
  }

  void _onFatigue(int level) {
    setState(() => _fatigueAnswered = true);
    saveSP('fatigueLevel', level);
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text('Chosen fatigue level: $level'),
        backgroundColor: const Color.fromARGB(255, 227, 227, 227),
        duration: const Duration(seconds: 4),
      ));
  }

  void _onReturn() {
    if (_injuryAnswered && _fatigueAnswered) {
      context.read<PossibleShiftProvider>().resetShiftSummary();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const HomePage(applySleepRecoveryAfterShift: true),
        ),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(const SnackBar(
          content: Text('Please answer all the questions before returning to homepage'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 4),
        ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PossibleShiftProvider>();

    return Scaffold(
      backgroundColor: kGreenLight,
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                'SHIFT ENDED!',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: kGreen,
                ),
              ),

              if (provider.shiftClosedByEmergency) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: const Text(
                    'Shift closed after emergency request',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],

              if (provider.shiftClosedByLowBattery) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: const Text(
                    'Battery low: it’s time to rest.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],

              const Spacer(),

              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Image.asset('assets/consegna.png'),
                    ),
                    const SizedBox(height: 5),
                    _row(Icons.local_activity, 'Deliveries completed',
                        provider.completedDeliveries.toString()),
                    _row(Icons.monetization_on, 'Earnings',
                        '€${provider.totalEarnings.toStringAsFixed(2)}'),
                    _row(Icons.stars, 'Points', provider.totalPoints.toString()),
                    _row(Icons.route, 'Distance',
                        '${provider.totalDistanceKm.toStringAsFixed(2)} km'),
                    _row(Icons.timer, 'Total time',
                        '${provider.totalDurationMinutes} min'),
                    _row(Icons.local_fire_department, 'Calories',
                        '${provider.totalCalories.round()} kcal'),
                    _row(Icons.battery_charging_full, 'Battery after shift',
                        '${provider.currentBattery.batteryLevel}%'),
                  ],
                ),
              ),

              const Spacer(),

              Card(
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 12),
                child: Column(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 10),
                        const Text(
                          'Were you completely free of injuries?',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: _onInjuryYes,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _injuryAnswered
                                    ? Colors.green.shade200
                                    : Colors.green,
                                foregroundColor: Colors.white,
                              ),
                              child: const Icon(Icons.check),
                            ),
                            const SizedBox(width: 30),
                            ElevatedButton(
                              onPressed: _onInjuryNo,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.deepOrangeAccent,
                              ),
                              child: const Icon(Icons.cancel),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'How would you rate your level of fatigue?',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                              onPressed: () => _onFatigue(4),
                              style: TextButton.styleFrom(foregroundColor: Colors.red),
                              child: const Icon(Icons.sentiment_dissatisfied),
                            ),
                            TextButton(
                              onPressed: () => _onFatigue(3),
                              style: TextButton.styleFrom(foregroundColor: Colors.orange),
                              child: const Icon(Icons.sentiment_neutral),
                            ),
                            TextButton(
                              onPressed: () => _onFatigue(2),
                              style: TextButton.styleFrom(foregroundColor: Colors.amber),
                              child: const Icon(Icons.sentiment_satisfied),
                            ),
                            TextButton(
                              onPressed: () => _onFatigue(1),
                              style: TextButton.styleFrom(foregroundColor: Colors.green),
                              child: const Icon(Icons.sentiment_very_satisfied),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ],
                ),
              ),

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
                  onPressed: _onReturn,
                  icon: const Icon(Icons.home),
                  label: const Text(
                    'Return to Homepage',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: kGreen),
          const SizedBox(width: 12),
          Text('$title: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value, textAlign: TextAlign.right)),
        ],
      ),
    );
  }
}