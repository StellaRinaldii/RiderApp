import 'package:flutter/material.dart';
import 'package:workers_campe/screens/homepage.dart';
import 'package:workers_campe/screens/login.dart';
import 'package:shared_preferences/shared_preferences.dart';


const Color kGreen = Color(0xFF639922);
const Color kGreenLight = Color(0xFFEAF3DE);

// Function to save the Shared Preferences values:
Future <void> saveSP(String key, String value) async{
  final sp = await SharedPreferences.getInstance();
  await sp.setString(key, value);
}

// Function to get the Shared Preferences values:
Future <String?> getSP(String key) async{
  final sp = await SharedPreferences.getInstance();
  return sp.getString(key);
}



class Profilepage extends StatefulWidget{
  const Profilepage({super.key});

  @override
  State<Profilepage> createState() => _ProfilePageState();
}


class _ProfilePageState extends State<Profilepage> {
  
  String name =  '';
  String surname = '';
  String age = '';
  String gender = '';
  String height = '';
  String weight = '';
  String city = '';
  String agency = '';

  
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: kGreenLight,
      appBar: AppBar(
        title: Text("Profile Page", style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 25,
        ),),
        centerTitle: true,
        backgroundColor: kGreen,
        foregroundColor: kGreenLight,
        actions: [Icon(Icons.settings)],
      ) ,

      body: Column(
            spacing: 5,
            children: 
            <Widget>[
              const SizedBox(height: 10),
              SizedBox(
                width: 120, height: 120,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(90),
                  child: Image.asset('assets/profilepage/profilepicture.png'),
                  ),
              ),
              const SizedBox(height: 1),
              SizedBox( width: 200, 
                        child: Column(
                          children: [

                            FutureBuilder(
                            future: getSP('name'), 
                            builder: (context, snapshot){
                              final name = snapshot.data ?? '';
                              return Text("Hello $name!", style: TextStyle(fontSize:20, fontWeight: FontWeight.bold, color: kGreen),);
                            }),
                            
                            const SizedBox(height: 10),
                            ElevatedButton(onPressed: () {
                                                           
                                   showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                                                            
                                      return AlertDialog(
                                        backgroundColor: Colors.white,
                                        title: Text("Modify Profile"),
                                        content: Column(
                                          children: [
                                            TextField(
                                              onChanged: (text) {
                                                  setState(() {
                                                    name = text;
                                                    saveSP('name', name);
                                                  });
                                                },
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(),
                                                labelText: 'Name',
                                                hintText: 'Insert your Name',     
                                              ),
                                            ),
                                            SizedBox(height: 5,),
                                            
                                            TextField(
                                              onChanged: (text) {
                                                  setState(() {
                                                    gender = text;
                                                    saveSP('gender', gender);
                                                  });
                                                },
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(),
                                                labelText: 'Gender',
                                                hintText: 'Insert your Gender (M/F)',     
                                              ),
                                            ),
                                            SizedBox(height: 5,),

                                            TextField(
                                              onChanged: (text) {
                                                  setState(() {
                                                    weight = text;
                                                    saveSP('weight', weight);
                                                  });
                                                },
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(),
                                                labelText: 'Weight',
                                                hintText: 'Insert your Weight',     
                                              ),
                                            ),
                                            SizedBox(height: 5,),

                                            TextField(
                                              onChanged: (text) {
                                                  setState(() {
                                                    height = text;
                                                    saveSP('height', height);
                                                  });
                                                },
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(),
                                                labelText: 'Height',
                                                hintText: 'Insert your Height',     
                                              ),
                                            ),
                                            SizedBox(height: 5,),

                                            TextField(
                                              onChanged: (text) {
                                                  setState(() {
                                                    city = text;
                                                    saveSP('city', city);
                                                  });
                                                },
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(),
                                                labelText: 'City',
                                                hintText: 'Insert your City',     
                                              ),
                                            ),
                                            SizedBox(height: 5,),

                                            TextField(
                                              onChanged: (text) {
                                                  setState(() {
                                                    agency = text;
                                                    saveSP('agency', agency);
                                                  });
                                                },
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(),
                                                labelText: 'Name of your Agency',
                                                hintText: 'Insert the name of your Agency',     
                                              ),
                                            ),
                                            
                                          ],
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () async{
                                              Navigator.of(context).pop(); // Chiude il dialog
                                            },
                                            style: TextButton.styleFrom(
                                              foregroundColor: kGreen,
                                              backgroundColor: Colors.transparent, 
                                            ),
                                            child: Text("Save Profile"),
                                          ),
                                        ],
                                      );
                                    },
                                  );}, 
                              style: ElevatedButton.styleFrom(
                                    backgroundColor: kGreen,
                                    foregroundColor: Colors.black,),
                              child: Text("Edit Profile"),
                              
                              ),
                          ],
                        ),
                ),

              const Divider(),
              
              Card( 
                color: Colors.white, //light,
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
                          FutureBuilder(
                            future: getSP('gender'), 
                            builder: (context, snapshot){
                              final gender = snapshot.data ?? '';
                              return Text(gender);
                            }),
                          SizedBox(height: 10,),
                          FutureBuilder(
                            future: getSP('weight'), 
                            builder: (context, snapshot){
                              final weight = snapshot.data ?? '';
                              return Text(weight);
                            }),
                          SizedBox(height: 10,),
                          FutureBuilder(
                            future: getSP('height'), 
                            builder: (context, snapshot){
                              final height = snapshot.data ?? '';
                              return Text(height);
                            }),
                          SizedBox(height: 10,),
                          FutureBuilder(
                            future: getSP('city'), 
                            builder: (context, snapshot){
                              final city = snapshot.data ?? '';
                              return Text(city);
                            }),
                          SizedBox(height: 10,),
                          FutureBuilder(
                            future: getSP('agency'), 
                            builder: (context, snapshot){
                              final agency = snapshot.data ?? '';
                              return Text(agency);
                            }),
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
                //width: 400,
                child: Column( children: [
                  Row(children: [
                    Text("Trophy Case", style: TextStyle(fontWeight: FontWeight.bold,),),
                    const Spacer(),
                    Text("130")
                  ],),
                  const SizedBox(height: 10,),
                  Row( children: [
                    ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context)
                            ..removeCurrentSnackBar()
                            ..showSnackBar(
                              SnackBar(
                                content: Text('Congratulations!You rode for 100 Km!'),
                                backgroundColor: kGreen,
                                duration: Duration(seconds: 4),
                              ),
                            );
                          return;
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(120, 120),
                        shape: StarBorder(),
                        backgroundColor: kGreen, // Colore di sfondo
                        foregroundColor: kGreenLight, // Colore del testo/icona
                      ),
                      child: Icon(Icons.bike_scooter, size: 20,), 
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context)
                            ..removeCurrentSnackBar()
                            ..showSnackBar(
                              SnackBar(
                                content: Text('Congratulations!You rode for 500 Km!'),
                                backgroundColor: kGreen,
                                duration: Duration(seconds: 4),
                              ),
                            );
                          return;
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(120, 120),
                        shape: StarBorder(),
                        backgroundColor: kGreen, // Colore di sfondo
                        foregroundColor: kGreenLight, // Colore del testo/icona
                      ),
                      child: Icon(Icons.pedal_bike, size: 20,), 
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context)
                            ..removeCurrentSnackBar()
                            ..showSnackBar(
                              SnackBar(
                                content: Text('Congratulations!You rode for 1000 Km!'),
                                backgroundColor: kGreen,
                                duration: Duration(seconds: 4),
                              ),
                            );
                          return;
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(120, 120),
                        shape: StarBorder(),
                        backgroundColor: kGreen, // Colore di sfondo
                        foregroundColor: kGreenLight, // Colore del testo/icona
                      ),
                      child: Icon(Icons.electric_bike, size: 20,),
                    ),
                    
                  ],)
                ],
                ),

              ),

              const Spacer(),

              Card(
                color: kGreen,
                child: Column(children: [
                    Text("TOTAL REACHED PRIZES:", style: TextStyle(fontWeight: FontWeight.bold,),),
                    Row( 
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                      Icon(Icons.attach_money, color: kGreen,),
                      const SizedBox(width: 10,),
                      Text("20 Euros")
                    ])
                  ],)
              )

          ],),
        
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 1,
          selectedItemColor: kGreen,
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.white,
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

