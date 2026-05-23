import 'package:flutter/material.dart';
import 'package:workers_campe/screens/HomePage.dart';

// useful variables
const Color kGreen = Color(0xFF639922);
const Color kGreenLight = Color(0xFFEAF3DE);

// functions

class Afterdelivery extends StatefulWidget{
  const Afterdelivery({super.key});

  @override
  State<Afterdelivery> createState() => _AfterdeliveryState();
}

class _AfterdeliveryState extends State<Afterdelivery> {
  // defining the battery level
  final double battery = 0.75;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kGreenLight,

      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
            children: [
              Text("Delivery Completed!", 
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: kGreen)
                ),

              Spacer(),

              Text("Your Delivery Summary:", 
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: kGreen)
                ),
              Card(
                color: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                    child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(children: [
                          deliveryStats("Total distance", "km", 25),
                          Spacer(),
                        ],),
                        Row(children: [
                          deliveryStats("Total time", "min", 30),
                          Spacer(),
                          deliveryStats("Average speed", "km/h", 40),
                        ],),
                        Row(children: [
                          deliveryStats("Height difference", "m", 100),
                          Spacer(),
                          deliveryStats("Average HR", "bpm", 100),
                        ],),
                         const Divider(),
                        deliveryInfo(Icons.stars, "Points Earned", "120"),
                        deliveryInfo(Icons.money, "Money Earned", "60")
                      ],
                    )
                  ),
                ),
              ),

              Spacer(),

              Text("Your Speed:", 
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: kGreen)
                ),
              Card(
                color: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 100,
                  padding: const EdgeInsets.all(16.0),
                  child: const Text("Graph not yet available", style: TextStyle(color: Colors.red)),
                ),
              ),

              Spacer(),

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
                        "Energy level",
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
                          color: Colors.white,
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
                        "${(battery * 100).round()}% - ${battery < 0.2 ? "Low energy" : battery < 0.7 ? "Moderate energy" : "High energy"}",
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Spacer(),

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
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => HomePage()),
                    (route) => false,
                  );
                },
                icon: Icon(Icons.home),
                label: Text(
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
    );

    
  }

  // Defining external widgets:
  Widget deliveryStats(String title, String measunit, int val){
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: kGreen, fontSize: 15),),
          Text('$val $measunit', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25, ),),
        ],
      ),
    );
  }

  Widget deliveryInfo(IconData icon, String title, String value, {Color valueColor = Colors.black}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: kGreen),
          SizedBox(width: 12),
          Text(
            '$title: ',
            style: TextStyle(fontWeight: FontWeight.bold),
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
}