import 'package:flutter/material.dart';
import 'package:workers_campe/screens/login.dart';
import 'package:workers_campe/screens/profilepage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workers_campe/screens/homepage.dart';

const Color kGreen = Color(0xFF639922);
const Color kGreenLight = Color(0xFFEAF3DE);
int flag1 = 0;
int flag2 = 0;

// Function to save the Shared Preferences values:
Future <void> saveSP(String key, int value) async{
  final sp = await SharedPreferences.getInstance();
  await sp.setInt(key, value);
}

class Aftershiftpage extends StatelessWidget{
  const Aftershiftpage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kGreenLight,
      body: SafeArea(
        child: Container(
               margin: const EdgeInsets.all(16.0),    
        child:Column( 
          children:[
              Text("SHIFT ENDED!", 
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: kGreen
                )
            ),

            Spacer(),

            Container(
            padding: EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(children: [
              Card( 
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Image.asset('assets/consegna.png'),
              ),
              SizedBox(height: 5,),
              filledShift(Icons.local_activity, "Total n° of activities", '5'),
              filledShift(Icons.monetization_on, "Earnings", '100'),
              filledShift(Icons.attach_money, "Bonuses", '8'),
              filledShift(Icons.money, "Total income", '108'),
              ],)
            ),

            const Spacer(),

            Card(
            color: Colors.white,
            margin: const EdgeInsets.only(bottom: 12),
            child: Column( 
              
              children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 15,
                children: [
                  Text("Were you compleatley free of injuries?",style: TextStyle(fontWeight: FontWeight.bold)),
                  Row( 
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 30,
                    children: [
                                  ElevatedButton( onPressed:(){
                                    flag1 = 1;
                                  }, 
                                  style: ElevatedButton.styleFrom( backgroundColor: Colors.green, foregroundColor: Colors.lightGreen),
                                                  child: Icon(Icons.check),
                                                  
                                                  ),
                                  ElevatedButton( onPressed:(){
                                    flag1 = 1;
                                                  ScaffoldMessenger.of(context)
                                          ..removeCurrentSnackBar()
                                          ..showSnackBar(
                                            SnackBar(
                                              content: Text('Redirecting Injuries to Occupational Health Physician'),
                                              backgroundColor: Colors.red,
                                              duration: Duration(seconds: 4),
                                            ),
                                          );
                                          return;
                                  }, 
                                                  style: ElevatedButton.styleFrom( backgroundColor: Colors.red, foregroundColor: Colors.deepOrangeAccent),
                                                  child: Icon(Icons.cancel),
                                                  )
                                  ],),
                  Text("How would you rate your level of fatigue?", style: TextStyle(fontWeight: FontWeight.bold)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 5,
                    children: [
                      TextButton( onPressed: (){
                        flag2 = 1;
                        saveSP("fatigueLevel", 4);
                        ScaffoldMessenger.of(context)
                                          ..removeCurrentSnackBar()
                                          ..showSnackBar(
                                            SnackBar(
                                              content: Text('Chosen fatigue level: 4',style: TextStyle(color: Colors.red)),
                                              backgroundColor: const Color.fromARGB(255, 227, 227, 227),
                                              duration: Duration(seconds: 4),
                                            ),
                                          );
                                          return;
                      }, style: TextButton.styleFrom(foregroundColor: Colors.red),child: Icon(Icons.sentiment_dissatisfied)),
                      TextButton( onPressed: (){
                        flag2 = 1;
                        saveSP("fatigueLevel", 3);
                        ScaffoldMessenger.of(context)
                                          ..removeCurrentSnackBar()
                                          ..showSnackBar(
                                            SnackBar(
                                              content: Text('Chosen fatigue level: 3',style: TextStyle(color: Colors.orange)),
                                              backgroundColor: const Color.fromARGB(255, 227, 227, 227),
                                              duration: Duration(seconds: 4),
                                            ),
                                          );
                                          return;
                      }, style: TextButton.styleFrom(foregroundColor: Colors.orange),child: Icon(Icons.sentiment_neutral)),
                      TextButton( onPressed: (){
                        flag2 = 1;
                        saveSP("fatigueLevel", 2);
                        ScaffoldMessenger.of(context)
                                          ..removeCurrentSnackBar()
                                          ..showSnackBar(
                                            SnackBar(
                                              content: Text('Chosen fatigue level: 2',style: TextStyle(color: Colors.amber)),
                                              backgroundColor: const Color.fromARGB(255, 227, 227, 227),
                                              duration: Duration(seconds: 4),
                                            ),
                                          );
                                          return;
                      }, style: TextButton.styleFrom(foregroundColor: Colors.yellow),child: Icon(Icons.sentiment_satisfied)),
                      TextButton( onPressed: (){
                        flag2 = 1;
                        saveSP("fatigueLevel", 1);
                        ScaffoldMessenger.of(context)
                                          ..removeCurrentSnackBar()
                                          ..showSnackBar(
                                            SnackBar(
                                              content: Text('Chosen fatigue level: 1',style: TextStyle(color: Colors.green)),
                                              backgroundColor: const Color.fromARGB(255, 227, 227, 227),
                                              duration: Duration(seconds: 4),
                                            ),
                                          );
                                          return;
                      }, style: TextButton.styleFrom(foregroundColor: Colors.green),child: Icon(Icons.sentiment_very_satisfied)),
                    ],
                  )
                ],
              )  
          ])
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
                onPressed: () {
                  if (flag1 + flag2 == 2){
                    flag1 = 0;
                    flag2 = 0;
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => HomePage()),
                    (route) => false,
                  );
                  } else {
                    ScaffoldMessenger.of(context)
                                          ..removeCurrentSnackBar()
                                          ..showSnackBar(
                                            SnackBar(
                                              content: Text('Please answer all the questions before returning to homepage'),
                                              backgroundColor: Colors.orange,
                                              duration: Duration(seconds: 4),
                                            ),
                                          );
                                          return;

                  }
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
          ]
        ),
      ),
      ),

      // bottomNavigationBar:  BottomNavigationBar(
        //   currentIndex: 1,
        //   selectedItemColor: kGreen,
        //   unselectedItemColor: Colors.grey,
        //   backgroundColor: Colors.white,
        //   onTap: (index) {
        //     if (index == 2) {
        //       Navigator.pushAndRemoveUntil(
        //         context,
        //         MaterialPageRoute(builder: (context) => LoginPage()),
        //         (route) => false,
        //       );
        //       // _toLogoutPage(context);
        //     } else if (index == 0){
        //       Navigator.pop(context);
        //     } else if (index == 1){
        //       Navigator.of(context).pushReplacement(
        //          MaterialPageRoute(builder: (context) => Profilepage()),
        //       );
        //     }
        //   },
        //   items: const [
        //   BottomNavigationBarItem(
        //     icon: Icon(Icons.home),
        //     label: "Home",
        //   ),
        //   BottomNavigationBarItem(
        //     icon: Icon(Icons.person),
        //     label: "User",
        //   ),
        //   BottomNavigationBarItem(
        //     icon: Icon(Icons.logout),
        //     label: "Logout",
        //   ),
        // ],
        // ),
    );
  }

  Widget filledShift(IconData icon, String title, String value) {
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

// puoi fare un widget per gestire le features dell'aftershift