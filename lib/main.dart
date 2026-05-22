import 'package:flutter/material.dart';
import 'package:workers_campe/screens/splash.dart';

void main() {
  runApp(const MyApp());
}

const Color kGreen = Color(0xFF639922);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Splash(),
    );
  }
}//MyApp