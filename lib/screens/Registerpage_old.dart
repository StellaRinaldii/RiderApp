import 'package:flutter/material.dart';
import 'package:workers_campe/screens/HomePage.dart';
import 'package:shared_preferences/shared_preferences.dart';

const Color kGreen = Color(0xFF639922);
const Color kGreenLight = Color(0xFFEAF3DE);

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
} //RegisterPage

class _RegisterPageState extends State<RegisterPage> {

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kGreenLight,
      appBar: AppBar(
        title: Text("Create an Account"),
        backgroundColor: kGreen,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[

            Icon(Icons.directions_bike, size: 56, color: kGreen),
            SizedBox(height: 8),
            Text(
              'Ride protected. Deliver more.',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
            SizedBox(height: 24),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: kGreen, width: 2)),
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Colors.grey),
                  floatingLabelStyle: TextStyle(color: kGreen),
                  hintText: 'Enter a valid email as abc@gmail.com',
                  prefixIcon: Icon(Icons.email_outlined, color: kGreen),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, top: 15),
              child: TextField(
                obscureText: true,
                controller: passwordController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: kGreen, width: 2)),
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Colors.grey),
                  floatingLabelStyle: TextStyle(color: kGreen),
                  hintText: 'Choose a password',
                  prefixIcon: Icon(Icons.lock_outline, color: kGreen),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, top: 15, bottom: 20),
              child: TextField(
                obscureText: true,
                controller: confirmPasswordController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: kGreen, width: 2)),
                  labelText: 'Confirm Password',
                  labelStyle: TextStyle(color: Colors.grey),
                  floatingLabelStyle: TextStyle(color: kGreen),
                  hintText: 'Repeat the password',
                  prefixIcon: Icon(Icons.lock_outline, color: kGreen),
                ),
              ),
            ),

            Container(
              height: 50,
              width: 250,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
                onPressed: () async {
                  // Check that no field is empty
                  if (emailController.text.isEmpty ||
                      passwordController.text.isEmpty ||
                      confirmPasswordController.text.isEmpty) {
                    ScaffoldMessenger.of(context)
                      ..removeCurrentSnackBar()
                      ..showSnackBar(SnackBar(
                          content: Text('Please fill in all fields'),
                          backgroundColor: Colors.orange));
                    return;
                  } //if

                  // Check that both passwords match
                  if (passwordController.text != confirmPasswordController.text) {
                    ScaffoldMessenger.of(context)
                      ..removeCurrentSnackBar()
                      ..showSnackBar(SnackBar(
                          content: Text('Passwords do not match'),
                          backgroundColor: Colors.red));
                    return;
                  } //if

                  // Save credentials and mark the user as logged in
                  final sharedPreferences = await SharedPreferences.getInstance();
                  await sharedPreferences.setString('userEmail', emailController.text);
                  await sharedPreferences.setString('userPassword', passwordController.text);
                  await sharedPreferences.setBool('isUserLogged', true);

                  // Navigate to HomePage
                  Navigator.pushReplacement(
                      context, MaterialPageRoute(builder: (_) => HomePage()));
                },
                child: Text('Create Account'),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(left: 30, right: 30, top: 20),
              child: Text(
                '🚴 By creating an account you agree to our Terms of Service and Privacy Policy. '
                'Your data (deliveries, routes and activity) is used solely for your personal statistics.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: Colors.grey, height: 1.5),
              ),
            ), //Padding disclaimer

            SizedBox(height: 30),
          ],
        ),
      ),
    );
  } //build
} //_RegisterPageState
