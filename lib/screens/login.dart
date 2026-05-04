import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workers_campe/screens/homepage.dart';
import 'package:workers_campe/screens/RegisterPage.dart';
// voglio creare una schermata di login per la mia app
// void main() {
//   runApp(MyApp());
// }

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  TextEditingController userController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
              left: 20.0, right: 20.0, top: 30, bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                'assets/logoproject.png',
                scale: 4,),
              const SizedBox(
                  height: 30,
                ),
            const Text(
              'Login',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 25),
            ),
            const SizedBox(
              height: 30,
            ),
            // TextField widgets to take the username and password from the user
            TextField(
              controller: userController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                labelText: 'Username',
                hintText: 'Enter valid email id as abc@gmail.com',
              ),
            ),
            const SizedBox(
                height: 20,
              ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                labelText: 'Password',
                hintText: 'Enter password',
              ),
            ),
            const SizedBox(
                height: 20,
              ),
            Center(
              child: Container(
                height: 50,
                width: 250,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
                child: ElevatedButton(
                  onPressed: () async {
                    if (userController.text == 'ciao@icloud.com' && 
                    passwordController.text == '3210') {
                      final sharedPreferences = await SharedPreferences.getInstance();
                      await sharedPreferences.setBool('isUserLogged', true);

                      Navigator.pushReplacement(
                        context, MaterialPageRoute(builder: (_) => HomePage()));
                    }//if
                  else{
                    //If the credentials are not correct, say it!
                    ScaffoldMessenger.of(context)
                    ..removeCurrentSnackBar()
                    ..showSnackBar(SnackBar(content: Text('Wrong email/password')));
                  }//else
                },
                child: Text(
                  'Login',
                ),
              ),
            ),
            ),
            SizedBox(
              height: 10,
              ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
              onPressed: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (_) => RegisterPage()));
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
                ),
              child: const Text('Non sei ancora registrato?'),
              ),
            ],
          ),
          const Spacer(),
            const Align(
                alignment: Alignment.bottomCenter,
                child: Text(
                  "By logging in, you agree to NameGroup's\nTerms & Conditions and Privacy Policy",
                  style: TextStyle(fontSize: 12),
                )
              ),
          ], 
          ),
    ),),);
  }
}