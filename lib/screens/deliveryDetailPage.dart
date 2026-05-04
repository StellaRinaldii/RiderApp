import 'package:flutter/material.dart';
import 'package:workers_campe/screens/DeliveryInProgressPage.dart';

const Color kGreen = Color(0xFF639922);
const Color kGreenLight = Color(0xFFEAF3DE);

class DeliveryDetailPage extends StatelessWidget {
  final int deliveryNumber;
  final String deadline;
  final String destinationAddress;
  final double distanceKm;
  final int estimatedMinutes;
  final int points;

  DeliveryDetailPage({
    required this.deliveryNumber,
    required this.deadline,
    required this.destinationAddress,
    required this.distanceKm,
    required this.estimatedMinutes,
    required this.points,
  });

  String getRouteImage(double distanceKm, int deliveryNumber) {
  List<String> images;

  if (distanceKm <= 2.0) {
    images = [
      'assets/routes/short/route_1.png',
      'assets/routes/short/route_2.png',
    ];
  } else if (distanceKm <= 5.0) {
    images = [
      'assets/routes/medium/route_1.png',
      'assets/routes/medium/route_2.png',
    ];
  } else {
    images = [
      'assets/routes/long/route_1.png',
      'assets/routes/long/route_2.png',
    ];
  }

  return images[deliveryNumber % images.length];
}

  @override
  Widget build(BuildContext context) {
    final routeImage = getRouteImage(distanceKm, deliveryNumber);
    return Scaffold(
      backgroundColor: kGreenLight,
      appBar: AppBar(
        title: Text('Delivery #$deliveryNumber'),
        backgroundColor: kGreen,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Deliver by $deadline',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: kGreen,
              ),
            ),

            SizedBox(height: 20),

            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(routeImage,height: 180, width: double.infinity,fit: BoxFit.cover,),
              ),

            SizedBox(height: 24),

            Container(
              padding: EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  deliveryInfo(Icons.place, 'Destination', destinationAddress),
                  deliveryInfo(Icons.route, 'Distance', '$distanceKm km'),
                  deliveryInfo(Icons.timer, 'Estimated time', '$estimatedMinutes min'),
                  deliveryInfo(Icons.stars, 'Points', '+$points pts'),
                ],
              ),
            ),

            Spacer(),

            Text(
              'Accept the delivery?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 18),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: kGreen,
                      side: BorderSide(color: kGreen),
                      padding: EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('NO'),
                  ),
                ),

                SizedBox(width: 15),

                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kGreen,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DeliveryInProgressPage(),
                        ),
                      );
                    },
                    child: Text('YES'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget deliveryInfo(IconData icon, String title, String value) {
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
            ),
          ),
        ],
      ),
    );
  }
}
