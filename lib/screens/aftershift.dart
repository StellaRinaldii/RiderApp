import 'package:flutter/material.dart';
import 'package:workers_campe/screens/homepage.dart';
import 'package:workers_campe/screens/login.dart';
import 'package:workers_campe/screens/profilepage.dart';

const Color kGreen = Color(0xFF639922);
const Color kGreenLight = Color(0xFFEAF3DE);

class Aftershiftpage extends StatelessWidget{
  const Aftershiftpage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kGreenLight,
      body: Container(
        margin: const EdgeInsets.all(60.0),
        child:
        Column( 
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
            child: Column( children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 15,
                children: [
                  Text("Did you had any injuries?",style: TextStyle(fontWeight: FontWeight.bold)),
                  Row( 
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 30,
                    children: [
                                  ElevatedButton( onPressed:(){}, 
                                                  style: ElevatedButton.styleFrom( backgroundColor: Colors.green, foregroundColor: Colors.lightGreen),
                                                  child: Icon(Icons.check),
                                                  ),
                                  ElevatedButton( onPressed:(){}, 
                                                  style: ElevatedButton.styleFrom( backgroundColor: Colors.red, foregroundColor: Colors.deepOrangeAccent),
                                                  child: Icon(Icons.cancel),
                                                  )
                                  ],),
                  Text("How would you rate your level of fatigue?", style: TextStyle(fontWeight: FontWeight.bold)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 5,
                    children: [
                      TextButton( onPressed: (){}, style: TextButton.styleFrom(foregroundColor: Colors.red),child: Icon(Icons.sentiment_dissatisfied)),
                      TextButton( onPressed: (){}, style: TextButton.styleFrom(foregroundColor: Colors.orange),child: Icon(Icons.sentiment_neutral)),
                      TextButton( onPressed: (){}, style: TextButton.styleFrom(foregroundColor: Colors.yellow),child: Icon(Icons.sentiment_satisfied)),
                      TextButton( onPressed: (){}, style: TextButton.styleFrom(foregroundColor: Colors.green),child: Icon(Icons.sentiment_very_satisfied)),
                    ],
                  )
                ],
              )  
          ])
          )
          ]
        ),
      ),
      bottomNavigationBar:  BottomNavigationBar(
          currentIndex: 1,
          selectedItemColor: kGreen,
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.white,
          onTap: (index) {
            if (index == 2) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
                (route) => false,
              );
              // _toLogoutPage(context);
            } else if (index == 0){
              Navigator.pop(context);
            } else if (index == 1){
              Navigator.of(context).pushReplacement(
                 MaterialPageRoute(builder: (context) => Profilepage()),
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