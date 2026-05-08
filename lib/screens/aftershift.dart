import 'package:flutter/material.dart';
import 'package:workers_campe/screens/homepage.dart';
import 'package:workers_campe/screens/login.dart';
import 'package:workers_campe/screens/profilepage.dart';

class Aftershiftpage extends StatelessWidget{
  const Aftershiftpage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.all(60.0),
        child:
        Column( 
          children:[
          Text("SHIFT ENDED!", style: TextStyle(fontSize: 40)),

   

         Row(
          mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column( 
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                  Text("Total n° of activities: ", style: TextStyle(fontSize: 15),),
                  Text("Earnings: ", style: TextStyle(fontSize: 15)),
                  Text("Bonuses: ", style: TextStyle(fontSize: 15)),
                  Text("Total Income: ", style: TextStyle(fontSize: 15)),
                ]),
                const Spacer(),
                Column( 
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                  Text("5", textAlign: TextAlign.start, style: TextStyle(fontSize: 15)),
                  Text("100 euros", textAlign: TextAlign.start, style: TextStyle(fontSize: 15)),
                  Text("8 euros", textAlign: TextAlign.start, style: TextStyle(fontSize: 15)),
                  Text("108 euros", textAlign: TextAlign.start, style: TextStyle(fontSize: 15)),
                ]),
              ],
            ),
            const Spacer(),
            Card(
            color: const Color.fromARGB(255, 200, 227, 227),
            child: Column( children: [
              Column(
                spacing: 15,
                children: [
                  Text("Did you had any injuries?"),
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
                  Text("How would you rate your level of fatigue?"),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 30,
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
          selectedItemColor: Colors.green,
          unselectedItemColor: Colors.grey,
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
}