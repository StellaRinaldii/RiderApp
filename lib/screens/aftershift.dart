import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workers_campe/providers/possible_shift_provider.dart';
import 'package:workers_campe/screens/homepage.dart';


const Color kGreen = Color(0xFF639922);
const Color kGreenLight = Color(0xFFEAF3DE);
const Color darkRed = Color(0xFFC1121F);
const Color lightRed = Color.fromARGB(255, 229, 115, 122);


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

  void _onFatigue(int level) {
    // chose the color based on the level:
    Color levcol =  Colors.green;
    if (level == 4){
       levcol = Colors.red;
    } else if (level == 3){
       levcol = Colors.orange;
    } else if (level == 2){
       levcol = Colors.amber;
    } 
    setState(() => _fatigueAnswered = true);
    saveSP('fatigueLevel', level);
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text('Chosen fatigue level: $level'),
        backgroundColor: levcol,
        duration: const Duration(seconds: 4),
      ));
  }

   void _onReturn() {
    if (_injuryAnswered && _fatigueAnswered) {
      Provider.of<PossibleShiftProvider>(
        context,
        listen: false,
      ).resetShiftSummary();

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
        ..showSnackBar(
          const SnackBar(
            content: Text('Please answer all the questions before returning to homepage'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 4),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PossibleShiftProvider>(context);
    Color iconColorDark =  provider.shiftClosedByEmergency ? darkRed : kGreen;
    Color iconColorLight = provider.shiftClosedByEmergency ? lightRed : kGreenLight;
  

    return Scaffold(
      backgroundColor: iconColorLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              
              if (provider.shiftClosedByEmergency) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
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

              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    Text(
                      ' Your Shift Summary',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: iconColorDark,
                      ),
                    ),
                  
                  const SizedBox(height: 8),
                  _batteryHistoryBar(
                    batteryHistory: provider.batteryHistory,
                    batteryReductionHistory: provider.batteryReductionHistory,
                  ),
                const SizedBox(height: 18),
                Center(
                  child: Text(
                    '${provider.currentBattery.batteryLevel <= 25 ? "Low energy" : provider.currentBattery.batteryLevel < 70 ? "Moderate energy" : "High energy"} · ${provider.currentBattery.batteryLevel}%',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: provider.currentBattery.batteryLevel <= 25
                      ? Colors.red
                      : provider.currentBattery.batteryLevel < 70
                      ? Colors.orange
                      : Colors.green,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                    _row(
                      Icons.local_activity,
                      'Deliveries completed',
                      provider.completedDeliveries.toString(), iconColorDark
                    ),
                    _row(
                      Icons.monetization_on,
                      'Earnings',
                      '€${provider.totalEarnings.toStringAsFixed(2)}', iconColorDark
                    ),
                    _row(
                      Icons.route,
                      'Distance',
                      '${provider.totalDistanceKm.toStringAsFixed(2)} km', iconColorDark,
                    ),
                    _row(
                      Icons.timer,
                      'Total time',
                      '${provider.totalDurationMinutes} min', iconColorDark,
                    ),
                    _row(
                      Icons.local_fire_department,
                      'Calories',
                      '${provider.totalCalories.round()} kcal', iconColorDark,
                    ),
                    _row(
                      Icons.battery_charging_full,
                      'Battery after shift',
                      '${provider.currentBattery.batteryLevel}%', iconColorDark,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

                            Card(
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 12),
                child: Column(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                         const SizedBox(height: 10),
                        if (provider.shiftClosedByEmergency)
                          _injuryDelivery()
                        else
                          _noInjuryDelivery(),

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
              const SizedBox(height: 8),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: iconColorDark,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: _onReturn,
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

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(IconData icon, String title, String value, Color coloricon) {
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: coloricon),
          const SizedBox(width: 12),
          Text(
            '$title: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
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

  static Widget _batteryHistoryBar({
  required List<int> batteryHistory,
  required List<int> batteryReductionHistory,
  }) {
  final int currentBattery =
      batteryHistory.isNotEmpty ? batteryHistory.last : 0;

  final double battery = currentBattery / 100.0;

  return SizedBox(
    height: 120,
    child: LayoutBuilder(
      builder: (context, constraints) {
        final double barWidth = constraints.maxWidth;

        return Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              top: 52,
              child: Container(
                height: 22,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),

            Positioned(
              left: 0,
              top: 52,
              child: Container(
                height: 22,
                width: barWidth * battery.clamp(0.0, 1.0),
                decoration: BoxDecoration(
                  color: battery <= 0.25
                      ? Colors.red
                      : battery < 0.7
                          ? Colors.orange
                          : Colors.green,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),

            for (int i = 0; i < batteryReductionHistory.length; i++)
              if (i + 1 < batteryHistory.length)
                Positioned(
                  left: (barWidth *
                          (batteryHistory[i + 1] / 100.0).clamp(0.0, 1.0)) -
                      1.5,
                  top: 46,
                  child: Container(
                    width: 3,
                    height: 34,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),

            for (int i = 0; i < batteryReductionHistory.length; i++)
              if (i + 1 < batteryHistory.length)
                Positioned(
                  left: (barWidth *
                          (batteryHistory[i + 1] / 100.0).clamp(0.0, 1.0)) -
                      18,
                  top: i.isEven ? 16 : 84,
                  child: Text(
                    '-${batteryReductionHistory[i]}%',
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
          ],
        );
      },
    ),
  );
  }

  Widget _noInjuryDelivery(){
    return Column(
      children: [
        const Text(
        'Did you have any problems during the shift?',
        style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
        ElevatedButton(
        onPressed: _onProblemYes,
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
        onPressed: _onProblemNo,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.deepOrangeAccent,
        ),
        child: const Icon(Icons.cancel),
        ),
        ],
      )
    ],);
  }

  Widget _injuryDelivery(){
    final TextEditingController problemController = TextEditingController();
    return Column(
      children: [
        const Text('Describe Your Injury:'),
        const SizedBox(height: 10), // Spazio tra testo e input
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0), // Bordo interno di 32 pixel a destra e sinistra
          child: TextField(
            controller: problemController,
            maxLines: 3, 
            decoration: const InputDecoration(
              hintText: 'Describe what happened here...',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        TextButton(
            onPressed: _onProblemNo,
            child: const Text('Submit'),
          ),
      ],
    );
    
  }

  void _onProblemNo() {
    setState(() => _injuryAnswered = true);
  }

void _onProblemYes() {
  setState(() => _injuryAnswered = true);
  final TextEditingController problemController = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Describe the problem:'),
        content: TextField(
          controller: problemController,
          maxLines: 10, 
          decoration: const InputDecoration(
            hintText: 'Type your issue here...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              String problemDescription = problemController.text;
              if (problemDescription.trim().isEmpty) {
                return; 
              }
              Navigator.pop(context); 
            },
            child: const Text('Submit'),
            // at the moment we are not interested in saving the data regarding this message.
          ),
        ],
      );
    },
  );
}

}
