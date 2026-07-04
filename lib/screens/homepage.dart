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

class HomePage extends StatefulWidget {
  final bool applySleepRecoveryAfterShift;

  const HomePage({
    super.key,
    this.applySleepRecoveryAfterShift = false,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();

    if (widget.applySleepRecoveryAfterShift) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startSleepRecoveryTimer();
      });
    }
  }

  void _startSleepRecoveryTimer() {
    Future.delayed(const Duration(seconds: 10), () async {
      if (!mounted) return;

      final provider = context.read<PossibleShiftProvider>();

      // Safety check: do not apply sleep recovery if a new shift has started.
      if (!provider.sleepRecoveryPending || provider.shiftStarted) {
        print('[SLEEP] Recovery skipped: pending=${provider.sleepRecoveryPending}, shiftStarted=${provider.shiftStarted}');
        return;
      }

      final message = await provider.applySleepRecoveryAfterShift();

      if (!mounted) return;

      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(message),
          backgroundColor: kGreen,
          duration: const Duration(seconds: 4),
        ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kGreenLight,
      appBar: AppBar(
        backgroundColor: kGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        title: FutureBuilder<String?>(
          future: SharedPreferences.getInstance().then((sp) => sp.getString('name')),
          builder: (_, snap) => Text("Let's Ride ${snap.data ?? ''}!",
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 25)),
        ),
      ),
      body: Consumer<PossibleShiftProvider>(
        builder: (context, provider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _energyCard(provider),
                const SizedBox(height: 30),
                const Text('Proposed deliveries',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: kGreen)),
                const SizedBox(height: 12),
                _deliveriesSection(context, provider),
                const SizedBox(height: 10),
                if (provider.shiftStarted)
                  Center(
                    child: Card(
                      color: Colors.white,
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        child: Column(children: [
                          const Text('Current earnings',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: kGreen)),
                          const SizedBox(height: 4),
                          Text('€${provider.totalEarnings.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                          Text('${provider.completedDeliveries} deliveries · ${provider.totalPoints} pts',
                              style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                        ]),
                      ),
                    ),
                  ),
                if (provider.shiftStarted) const SizedBox(height: 12),
                Center(
                  child: SizedBox(
                    width: 250,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: provider.shiftStarted
                          ? () {
                              provider.finishShift();
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (_) => const Aftershiftpage()));
                            }
                          : provider.sleepRecoveryPending
                              ? null
                              : () => provider.startShift(),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: provider.shiftStarted ? Colors.red : kGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
                      child: Text(
                          provider.shiftStarted
                              ? 'Stop shift'
                              : provider.sleepRecoveryPending
                                  ? 'Recovering...'
                                  : 'Start shift',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(icon: const Icon(Icons.home, color: kGreen), onPressed: () {}),
            IconButton(
              icon: const Icon(Icons.person, color: kGreen),
              onPressed: () => Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (_) => const Profilepage())),
            ),
            IconButton(
              icon: const Icon(Icons.logout, color: kGreen),
              onPressed: () async {
                final sp = await SharedPreferences.getInstance();
                await sp.remove('isUserLogged');
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const LoginPage()));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _deliveriesSection(BuildContext context, PossibleShiftProvider provider) {
    if (!provider.shiftStarted) {
      return _msgCard('Press Start shift to show available deliveries', Icons.directions_bike_rounded);
    }
    if (provider.isLoading) {
      return const Center(child: Padding(
          padding: EdgeInsets.all(32), child: CircularProgressIndicator(color: kGreen)));
    }
    if (provider.errorMessage != null) {
      return _msgCard(provider.errorMessage!, Icons.info_outline);
    }
    if (provider.possibleShifts.isEmpty) {
      return _msgCard('No proposed delivery available.', Icons.hourglass_empty);
    }
    return Column(
      children: [
        for (int i = 0; i < provider.possibleShifts.length; i++)
          _deliveryCard(context, provider.possibleShifts[i], i + 1),
      ],
    );
  }


  Widget _energyCard(PossibleShiftProvider provider) {
    final double battery = provider.currentBattery.batteryLevel / 100.0;

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

  Widget _msgCard(String msg, IconData icon) => Card(
        color: Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(children: [
            Icon(icon, color: kGreen),
            const SizedBox(width: 12),
            Expanded(child: Text(msg, style: const TextStyle(fontSize: 15))),
          ]),
        ),
      );

  Widget _deliveryCard(BuildContext context, PossibleShift shift, int index) {
    final effortColor = shift.effortType == EffortType.high
        ? Colors.red
        : shift.effortType == EffortType.low
            ? Colors.green
            : Colors.orange;
    return Card(
      color: Colors.white,
      elevation: 5,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: const Icon(Icons.directions_bike_rounded, color: kGreen, size: 32),
        title: Text('Delivery #$index', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Distance: ${shift.activity.distanceKm.toStringAsFixed(2)} km'),
            Text('Estimated time: ${shift.activity.durationMinutes} min'),
            Text('Earning: €${shift.earning.toStringAsFixed(2)}'),
            RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black87, fontSize: 14),
                children: [
                  const TextSpan(text: 'Effort: '),
                  TextSpan(
                      text: shift.effortLabel,
                      style: TextStyle(fontWeight: FontWeight.bold, color: effortColor)),
                ],
              ),
            ),
          ]),
        ),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.emoji_events, color: kGreen, size: 20),
          const SizedBox(width: 4),
          Text('${shift.points} pts',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: kGreen)),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_ios, color: kGreen, size: 18),
        ]),
        onTap: () {
          context.read<PossibleShiftProvider>().selectPossibleShift(shift);
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => DeliveryDetailPage(possibleShift: shift, deliveryIndex: index)));
        },
      ),
    );
  }
}