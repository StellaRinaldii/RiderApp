import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workers_campe/models/possible_shift.dart';
import 'package:workers_campe/providers/possible_shift_provider.dart';
import 'package:workers_campe/screens/aftershift.dart';
import 'package:workers_campe/screens/deliveryDetailPage.dart';
import 'package:workers_campe/screens/login.dart';
import 'package:workers_campe/screens/profilepage.dart';

const Color kGreen = Color(0xFF639922);
const Color kGreenLight = Color(0xFFEAF3DE);

Future<String?> getSP(String key) async {
  final sp = await SharedPreferences.getInstance();
  return sp.getString(key);
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final double battery = 0.75;
  bool shiftStarted = false;
  double earnings = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<PossibleShiftProvider>();
      if (!provider.hasLoadedOnce && provider.possibleShifts.isEmpty) {
        provider.loadPossibleShifts(reset: true);
      }
    });
  }

  void startShift() {
    setState(() {
      shiftStarted = true;
      earnings = 0.0;
    });
  }

  void stopShift() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const Aftershiftpage()),
    );

    setState(() {
      shiftStarted = false;
      earnings = 0.0;
    });
  }

  void _openDelivery(PossibleShift shift) {
    context.read<PossibleShiftProvider>().selectPossibleShift(shift);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DeliveryDetailPage(possibleShift: shift),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kGreenLight,
      appBar: AppBar(
        backgroundColor: kGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        title: FutureBuilder(
          future: getSP('name'),
          builder: (context, snapshot) => Text(
            "Let's Ride ${snapshot.data ?? ''}!",
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 25,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _energyCard(),
              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Proposed deliveries',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: kGreen,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => context
                        .read<PossibleShiftProvider>()
                        .loadPossibleShifts(),
                    icon: const Icon(Icons.refresh, color: kGreen),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Consumer<PossibleShiftProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(color: kGreen),
                      ),
                    );
                  }

                  if (provider.errorMessage != null) {
                    return _messageCard(
                      provider.errorMessage!,
                      Icons.info_outline,
                    );
                  }

                  if (provider.possibleShifts.isEmpty) {
                    return _messageCard(
                      'No proposed delivery available.',
                      Icons.hourglass_empty,
                    );
                  }

                  return Column(
                    children: provider.possibleShifts
                        .map((shift) => _deliveryCard(context, shift))
                        .toList(),
                  );
                },
              ),

              const SizedBox(height: 10),

              if (shiftStarted)
                Center(
                  child: Card(
                    color: Colors.white,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Current earnings',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: kGreen,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '€${earnings.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              if (shiftStarted) const SizedBox(height: 12),

              Center(
                child: SizedBox(
                  width: 250,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () => shiftStarted ? stopShift() : startShift(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: shiftStarted ? Colors.red : kGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: Text(
                      shiftStarted ? 'Stop shift' : 'Start shift',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.home, color: kGreen),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.person, color: kGreen),
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const Profilepage()),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.logout, color: kGreen),
              onPressed: () => _logout(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _energyCard() {
    return Card(
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
    );
  }

  Widget _messageCard(String msg, IconData icon) {
    return Card(
      color: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(icon, color: kGreen),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                msg,
                style: const TextStyle(fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _deliveryCard(BuildContext context, PossibleShift shift) {
    final effortColor = shift.effortType == EffortType.high
        ? Colors.red
        : shift.effortType == EffortType.low
            ? Colors.green
            : Colors.orange;

    return Card(
      color: Colors.white,
      elevation: 5,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: const Icon(
          Icons.directions_bike_rounded,
          color: kGreen,
          size: 32,
        ),
        title: Text(
          '${shift.activityName} - ${shift.date}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Distance: ${shift.distanceKm} km'),
              Text('Estimated time: ${shift.estimatedMinutes} min'),
              Text('Earning: €${shift.earning.toStringAsFixed(2)}'),
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                  ),
                  children: [
                    const TextSpan(text: 'Effort: '),
                    TextSpan(
                      text: shift.effortLabel,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: effortColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.emoji_events,
              color: kGreen,
              size: 20,
            ),
            const SizedBox(width: 4),
            Text(
              '${shift.points} pts',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: kGreen,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_ios,
              color: kGreen,
              size: 18,
            ),
          ],
        ),
        onTap: () => _openDelivery(shift),
      ),
    );
  }

  static void _logout(BuildContext context) async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove('isUserLogged');

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }
}
