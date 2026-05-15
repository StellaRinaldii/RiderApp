import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workers_campe/screens/login.dart';
import 'package:workers_campe/screens/homepage.dart';

void main() {
  runApp(MyApp());
} //main

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FutureBuilder(
        future: SharedPreferences.getInstance(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final sharedPreferences = snapshot.data!;
            
            if (sharedPreferences.getBool('isUserLogged') == true) {
              return HomePage();
            } //if
            else {
              return LoginPage();
            } //else
          } //if
          else {
            return Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } //else
        },
      ),
    );
  } //build
} //MyApp