import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workers_campe/screens/homepage.dart';
import 'package:workers_campe/screens/RegisterPage.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}

const Color kGreen = Color(0xFF639922);
const Color kGreenLight = Color(0xFFEAF3DE);

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController userController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

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
                    'Enter valid email id',
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
                      onPressed: () async {
                        final sharedPreferences = await SharedPreferences.getInstance();

                        final savedEmail = sharedPreferences.getString('userEmail');
                        final savedPassword = sharedPreferences.getString('userPassword');

                        if (savedEmail == null || savedPassword == null) {
                          ScaffoldMessenger.of(context).removeCurrentSnackBar();

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('No account found. Please register first.'),
                              backgroundColor: Colors.orange,
                            ),
                          );

                          return;
                        }

                        if (userController.text == savedEmail &&
                            passwordController.text == savedPassword) {
                          await sharedPreferences.setBool('isUserLogged', true);

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => HomePage()),
                          );
                        } else {
                          ScaffoldMessenger.of(context).removeCurrentSnackBar();

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Wrong email or password'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },

                    
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
                          MaterialPageRoute(builder: (_) => RegisterPage()),
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: kGreen,
                      ),
                      child: const Text('Not yet registered?'),
                    ),
                  ],
                ),

                const SizedBox(height: 60),

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