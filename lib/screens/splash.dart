import 'package:flutter/material.dart';
import 'package:workers_campe/screens/homepage.dart';
import 'package:workers_campe/screens/login.dart';
import 'package:workers_campe/services/impact.dart';

class Splash extends StatelessWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future.delayed(
      const Duration(seconds: 3),
      () => _checkLogin(context),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFEAF3DE),
      body: Center(
        child: Image.asset(
          'assets/logoproject.png',
          scale: 4,
        ),
      ),
    );
  }

  // Method for navigation SplashPage -> HomePage
  void _toHomePage(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const HomePage(),
      ),
    );
  }

  // Method for navigation SplashPage -> LoginPage
  void _toLoginPage(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
    );
  }

  // Method for checking if the user has still valid tokens
  // If yes, navigate to HomePage, if not, navigate to LoginPage
  void _checkLogin(BuildContext context) async {
    final result = await Impact().refreshTokens();

    if (result == 200) {
      _toHomePage(context);
    } else {
      _toLoginPage(context);
    }
  }
}