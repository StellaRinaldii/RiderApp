import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workers_campe/screens/splash.dart';
import 'package:workers_campe/providers/possible_shift_provider.dart';

void main() {
  runApp(const MyApp());
}

const Color kGreen = Color(0xFF639922);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PossibleShiftProvider(),
      child:  MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Splash(),
      ),
    );
  }
}