import 'package:flutter/material.dart';
import 'package:workers_campe/screens/Profilepage.dart';
import 'package:shared_preferences/shared_preferences.dart';

const Color kGreen = Color(0xFF639922);
const Color kGreenLight = Color(0xFFEAF3DE);

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

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
        borderSide: BorderSide(color: kGreen, width: 2),
      ),
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey),
      floatingLabelStyle: TextStyle(color: kGreen),
      hintText: hint,
      prefixIcon: Icon(icon, color: kGreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kGreenLight,
      appBar: AppBar(
        title: Text("Create an Account"),
        backgroundColor: kGreen,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Container(
              padding: EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: <Widget>[
                  CircleAvatar(
                    radius: 38,
                    backgroundColor: kGreenLight,
                    child: Icon(Icons.directions_bike, size: 46, color: kGreen),
                  ),

                  SizedBox(height: 12),

                  Text(
                    'Ride protected. Deliver more.',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),

                  SizedBox(height: 28),

                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: inputStyle(
                      'Email',
                      'Enter a valid email',
                      Icons.email_outlined,
                    ),
                  ),

                  SizedBox(height: 15),

                  TextField(
                    obscureText: true,
                    controller: passwordController,
                    decoration: inputStyle(
                      'Password',
                      'Choose a password',
                      Icons.lock_outline,
                    ),
                  ),

                  SizedBox(height: 15),

                  TextField(
                    obscureText: true,
                    controller: confirmPasswordController,
                    decoration: inputStyle(
                      'Confirm Password',
                      'Repeat the password',
                      Icons.lock_outline,
                    ),
                  ),

                  SizedBox(height: 24),

                  SizedBox(
                    height: 52,
                    width: double.infinity,
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
                        if (emailController.text.isEmpty ||
                            passwordController.text.isEmpty ||
                            confirmPasswordController.text.isEmpty) {
                          ScaffoldMessenger.of(context)
                            ..removeCurrentSnackBar()
                            ..showSnackBar(
                              SnackBar(
                                content: Text('Please fill in all fields'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          return;
                        }

                        if (passwordController.text !=
                            confirmPasswordController.text) {
                          ScaffoldMessenger.of(context)
                            ..removeCurrentSnackBar()
                            ..showSnackBar(
                              SnackBar(
                                content: Text('Passwords do not match'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          return;
                        }

                        final sharedPreferences =
                            await SharedPreferences.getInstance();

                        await sharedPreferences.setString(
                            'userEmail', emailController.text);
                        await sharedPreferences.setString(
                            'userPassword', passwordController.text);
                        await sharedPreferences.setBool('isUserLogged', true);

                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => Profilepage()),
                          (route) => false,
            );
                      },
                      child: Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 22),

                  Text(
                    '🚴 By creating an account you agree to our Terms of Service and Privacy Policy. '
                    'Your data is used solely for your personal statistics.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}