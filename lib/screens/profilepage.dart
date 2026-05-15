import 'package:flutter/material.dart';
import 'package:workers_campe/screens/homepage.dart';
import 'package:workers_campe/screens/login.dart';

class Profilepage extends StatelessWidget {
  const Profilepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile Page", style: Theme.of(context).textTheme.headlineSmall),
        centerTitle: true,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [Icon(Icons.settings)],
      ) ,

      body: Column(
            spacing: 10,
            children: <Widget>[
              const SizedBox(height: 10),
              SizedBox(
                width: 120, height: 120,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(90),
                  child: Card(),
                  ),
              ),
              const SizedBox(height: 1),
              SizedBox( width: 200, 
                        child: Column(
                          children: [
                            Text("Kahshar Cognome", style: TextStyle(fontSize:20, fontWeight: FontWeight.bold),),
                            const SizedBox(height: 10),
                            ElevatedButton(
                                      onPressed: (){}, 
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.black,),
                                      child: const Text("Edit profile"),
                                      ),
                          ],
                        ),
                ),

              const Divider(),

              Card( 
                color: Colors.lightGreen, //light,
                child: Container(
                  margin: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      const SizedBox(width: 50,),
                      Column(
                        children: [
                          Text("Biografia", style: TextStyle(fontWeight: FontWeight.bold,),),
                          SizedBox(height: 10,),
                          Text("Gender"),
                          SizedBox(height: 10,),
                          Text("Weight"),
                          SizedBox(height: 10,),
                          Text("Height"),
                          SizedBox(height: 10,),
                          Text("City"),
                          SizedBox(height: 10,),
                          Text("Agency"),
                          SizedBox(height: 10,),
                          Text("Total Km"),
                        ],
                      ),
                      SizedBox(width: 100,),
                      Column(
                        children: [
                          Text(""),
                          SizedBox(height: 10,),
                          Text("M"),
                          SizedBox(height: 10,),
                          Text("70 Kg"),
                          SizedBox(height: 10,),
                          Text("170 cm"),
                          SizedBox(height: 10,),
                          Text("Padua (PD)"),
                          SizedBox(height: 10,),
                          Text("Deliveroo"),
                          SizedBox(height: 10,),
                          Text("1500 Km"),
                          
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const Divider(),
              SizedBox(
                width: 400,
                child: Column( children: [
                  Row(children: [
                    Text("Trophy Case", style: TextStyle(fontWeight: FontWeight.bold,),),
                    const Spacer(),
                    Text("130")
                  ],),
                  const SizedBox(height: 10,),
                  Row( children: [
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(120, 120),
                        shape: StarBorder(),
                        backgroundColor: Colors.green, // Colore di sfondo
                        foregroundColor: Colors.lightGreen, // Colore del testo/icona
                      ),
                      child: Icon(Icons.bike_scooter, size: 20,), 
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(120, 120),
                        shape: StarBorder(),
                        backgroundColor: Colors.green, // Colore di sfondo
                        foregroundColor: Colors.lightGreen, // Colore del testo/icona
                      ),
                      child: Icon(Icons.pedal_bike, size: 20,), 
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(120, 120),
                        shape: StarBorder(),
                        backgroundColor: Colors.green, // Colore di sfondo
                        foregroundColor: Colors.lightGreen, // Colore del testo/icona
                      ),
                      child: Icon(Icons.electric_bike, size: 20,),
                    ),
                    
                  ],)
                ],
                ),

              ),

              const Spacer(),

              Card(
                color: Colors.lightGreen,
                child: Column(children: [
                    Text("TOTAL REACHED PRIZES:", style: TextStyle(fontWeight: FontWeight.bold,),),
                    Row( 
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                      Icon(Icons.attach_money, color: Colors.green,),
                      const SizedBox(width: 10,),
                      Text("20 Euros")
                    ])
                  ],)
              )

          ],),
        
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 1,
          selectedItemColor: Colors.green,
          unselectedItemColor: Colors.grey,
          onTap: (index) {
            if (index == 2) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => LoginPage()),
              )
            ;
            } else if (index == 0){
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => HomePage()),
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

