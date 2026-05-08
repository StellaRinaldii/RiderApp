import 'package:flutter/material.dart';
import 'package:workers_campe/screens/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workers_campe/screens/DeliveryDetailPage.dart';
import 'package:workers_campe/screens/Profilepage.dart';
import 'package:workers_campe/screens/Aftershift.dart';

const Color kGreen = Color(0xFF639922);
const Color kGreenLight = Color(0xFFEAF3DE);

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  final int points = 1250;
  final double effort = 0.8;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kGreenLight,

      appBar: AppBar(
        backgroundColor: kGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Let's Ride Kashar",
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 25,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 20),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.stars, color: kGreen),
                const SizedBox(width: 5),
                Text(
                  "$points pt",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: kGreen,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                        "Current effort",
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
                          widthFactor: effort.clamp(0.0, 1.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: effort < 0.4
                                  ? kGreen
                                  : effort < 0.7
                                      ? Colors.orange
                                      : Colors.red,
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        "${(effort * 100).round()}% - ${effort < 0.4 ? "Low effort" : effort < 0.7 ? "Moderate effort" : "High effort"}",
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                "Proposed deliveries",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: kGreen,
                ),
              ),

              const SizedBox(height: 12),

              deliveryCard(
                context: context,
                deliveryNumber: 1,
                deadline: "18:30",
                destinationAddress: "Via Roma 25, Padova",
                distanceKm: 12.0,
                estimatedMinutes: 45,
                deliveryPoints: 120,
                effortLabel: "High effort",
              ),

              deliveryCard(
                context: context,
                deliveryNumber: 2,
                deadline: "17:45",
                destinationAddress: "Piazza Garibaldi 8, Padova",
                distanceKm: 1.3,
                estimatedMinutes: 5,
                deliveryPoints: 40,
                effortLabel: "Low effort",
              ),

              deliveryCard(
                context: context,
                deliveryNumber: 3,
                deadline: "19:15",
                destinationAddress: "Via Venezia 10, Padova",
                distanceKm: 5.0,
                estimatedMinutes: 15,
                deliveryPoints: 80,
                effortLabel: "Moderate effort",
              ),

              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Activity started")),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text("Start"),
                  ),

                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => Aftershiftpage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text("Stop"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: kGreen,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        onTap: (index) {
          if (index == 2) {
            _toLoginPage(context);
          }
          if (index==1) {
            Navigator.push(
              context, 
              MaterialPageRoute(builder: (_) => Profilepage()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "User",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.logout),
            label: "Logout",
          ),
        ],
      ),
    );
  }

  Widget deliveryCard({
    required BuildContext context,
    required int deliveryNumber,
    required String deadline,
    required String destinationAddress,
    required double distanceKm,
    required int estimatedMinutes,
    required int deliveryPoints,
    required String effortLabel,
  }) {
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
          "Delivery #$deliveryNumber",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Distance: $distanceKm km"),
              Text("Estimated time: $estimatedMinutes min"),
              Text("Points: +$deliveryPoints pts"),
              Text("Effort: $effortLabel"),
            ],
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: kGreen,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DeliveryDetailPage(
                deliveryNumber: deliveryNumber,
                deadline: deadline,
                destinationAddress: destinationAddress,
                distanceKm: distanceKm,
                estimatedMinutes: estimatedMinutes,
                points: deliveryPoints,
              ),
            ),
          );
        },
      ),
    );
  }

  static void _toLoginPage(BuildContext context) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.remove('isUserLogged');

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }
}
