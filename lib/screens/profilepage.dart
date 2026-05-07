import 'package:flutter/material.dart';
import 'package:workers_campe/screens/homepage.dart';

class Profilepage extends StatelessWidget {
  const Profilepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile Page", style: Theme.of(context).textTheme.headlineSmall),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 187, 186, 179),
        actions: [Icon(Icons.home)],
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
              const SizedBox(height: 10),
              SizedBox( width: 200, 
                        child: ElevatedButton(
                                  onPressed: (){}, 
                                  child: const Text("Edit profile"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,),
                                  ),
                      ),
              const SizedBox(height: 10),
              const Divider(),
              const SizedBox(height: 10),

              ListTile(
                leading: Container(
                  width: 30, height: 430,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: const Color.fromARGB(255, 172, 176, 182),
                  ),
                  child: Icon(Icons.settings),
                  ),
                  title: Text("Settings"),
                 
              ),

              Text("Age"),
              Text("Gender"),
              Text("Weight"),
              Text("Height"),
              Text("City"),
              Text("Agency"),
              Text("Total Km"),
              const Spacer(),

              Card(
                color: Colors.greenAccent,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                  Icon(Icons.star),
                  const SizedBox(width: 30),
                  Column(children: [
                    Text("REACHED PRIZES:"),
                    Row( children: [
                      Icon(Icons.money),
                      Text("20 Euros")
                    ])
                  ],)
                ],)
              )

          ],),

        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 1,
          selectedItemColor: Colors.green,
          unselectedItemColor: Colors.grey,
          onTap: (index) {
            if (index == 2) {
              // _toLoginPage(context);
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

