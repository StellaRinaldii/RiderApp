import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workers_campe/screens/homepage.dart';
import 'package:workers_campe/screens/RegisterPage.dart';
import 'package:workers_campe/screens/onboarding.dart';
import 'package:workers_campe/services/impact.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const LoginPage(),
    );
  }
}

const Color kGreen = Color(0xFF639922);
const Color kGreenLight = Color(0xFFEAF3DE);

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController userController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final Impact impact = Impact();

  @override
  void dispose() {
    userController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  InputDecoration inputStyle(String label, String hint, IconData icon) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: kGreen, width: 2),
      ),
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey),
      floatingLabelStyle: const TextStyle(color: kGreen),
      hintText: hint,
      prefixIcon: Icon(icon, color: kGreen),
    );
  }

  Future<void> _login() async {
    final username = userController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Please enter username and password'),
            backgroundColor: Colors.orange,
          ),
        );
      return;
    }

    final result = await impact.getAndStoreTokens(username, password);

    if (!mounted) return;

    if (result == 200) {
      final sp = await SharedPreferences.getInstance();

      await sp.setString('username', username);
      await sp.setString('password', password);
      await sp.setBool('isUserLogged', true);

      final onboardingCompleted =
          sp.getBool('onboarding_completed') ?? false;

      if (onboardingCompleted == false) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const Onboarding(),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const HomePage(),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Username or password incorrect'),
            backgroundColor: Colors.red,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kGreenLight,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(
              left: 20.0,
              right: 20.0,
              top: 30,
              bottom: 10,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Image.asset(
                    'assets/logoproject.png',
                    scale: 4,
                  ),
                ),

                const SizedBox(height: 30),

                const Text(
                  'Login',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 25,
                    color: kGreen,
                  ),
                ),

                const SizedBox(height: 30),

                TextField(
                  controller: userController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: inputStyle(
                    'Username',
                    'Enter your username',
                    Icons.email_outlined,
                  ),
                ),

                const SizedBox(height: 20),

                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: inputStyle(
                    'Password',
                    'Enter password',
                    Icons.lock_outline,
                  ),
                ),

                const SizedBox(height: 24),

                Center(
                  child: SizedBox(
                    height: 52,
                    width: 250,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kGreen,
                        foregroundColor: Colors.white,
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      onPressed: _login,
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegisterPage(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: kGreen,
                      ),
                      child: const Text('Not yet registered?'),
                    ),
                  ],
                ),

                const SizedBox(height: 250),

                const Align(
                  alignment: Alignment.bottomCenter,
                  child: Text(
                    "By logging in, you agree to NameGroup's\nTerms & Conditions and Privacy Policy",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}