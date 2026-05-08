import 'package:flutter/material.dart';
import 'package:workers_campe/screens/HomePage.dart';

const Color kGreen = Color(0xFF639922);
const Color kGreenLight = Color(0xFFEAF3DE);

class DeliveryInProgressPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kGreenLight,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Active delivery'),
        backgroundColor: kGreen,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            SizedBox(height: 25),

            Text(
              'Delivery in progress...',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: kGreen,
              ),
            ),

            SizedBox(height: 10),

            Text('Stay safe and enjoy the ride!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[700],
              ),
            ),

            SizedBox(height: 35),

            Container(
              height: 160,
              width: double.infinity,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: kGreenLight,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Image.asset(
                'assets/gifs/rider.gif',
                fit: BoxFit.contain,
                filterQuality: FilterQuality.none,
              ),
            ),

            SizedBox(height: 35),

            Container(
              width: double.infinity,
              padding: EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.navigation,
                    color: kGreen,
                    size: 36,
                  ),
                  SizedBox(height: 10),
                  Text('Keep going! You’re almost there.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.4,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),

            Spacer(),

            Center(
              child: SizedBox(
                width: 190,
                height: 46,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          backgroundColor: kGreenLight,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          title: Text(
                            'Emergency call',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          content: Text(
                            'Do you want to call 118 and report an emergency?',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.4,
                              color: Colors.grey[700],
                            ),
                          ),
                          actionsAlignment: MainAxisAlignment.center,
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: () {
                                Navigator.pop(context);

                                ScaffoldMessenger.of(context)
                                  ..removeCurrentSnackBar()
                                  ..showSnackBar(
                                    SnackBar(
                                      backgroundColor: Colors.red,
                                      behavior: SnackBarBehavior.floating,
                                      margin: EdgeInsets.all(8),
                                      duration: Duration(seconds: 3),
                                      content: Text(
                                        'Emergency request sent. Calling 118...',
                                      ),
                                    ),
                                  );
                              },
                              child: Text('Call 118'),
                          
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Text(
                    'Emergency',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
                icon: Icon(Icons.check_circle_outline),
                label: Text(
                  'Complete delivery',
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
}