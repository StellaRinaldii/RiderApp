import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workers_campe/screens/splash.dart';
import 'package:workers_campe/providers/possible_shift_provider.dart';
import 'package:workers_campe/providers/activity_provider.dart';

void main() {
  runApp(const MyApp());
}

const Color kGreen = Color(0xFF639922);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PossibleShiftProvider()),
        ChangeNotifierProvider(create: (_) => ActivityProvider()),
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Splash(),
      ),
    );
  }
}