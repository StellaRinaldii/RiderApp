import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:convert';

import 'package:workers_campe/screens/homepage.dart';
import 'package:workers_campe/screens/login.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

const Color kGreen = Color(0xFF639922);
const Color kGreenLight = Color(0xFFEAF3DE);

class Profilepage extends StatefulWidget {
  const Profilepage({super.key});

  @override
  State<Profilepage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<Profilepage> {
  Uint8List? _webImage;
  Uint8List? _savedImageBytes;
  final ImagePicker _picker = ImagePicker();

  String name = '';
  String surname = '';
  String age = '';
  String gender = '';
  String height = '';
  String weight = '';
  String city = '';
  String agency = '';
  bool flag = false;

  // Load possible profile images saved in SharedPreferences.
  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kGreenLight,
      appBar: AppBar(
        title: const Text(
          "Profile Page",
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 25,
          ),
        ),
        centerTitle: true,
        backgroundColor: kGreen,
        foregroundColor: kGreenLight,
      ),

      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 5,
          children: <Widget>[
            const SizedBox(height: 10),

            CircleAvatar(
              radius: 60,
              backgroundImage: _webImage != null
                  ? MemoryImage(_webImage!)
                  : (_savedImageBytes != null
                      ? MemoryImage(_savedImageBytes!)
                      : const AssetImage('assets/profilepage/profilepic.png')),
            ),

            const SizedBox(height: 1),

            SizedBox(
              width: 200,
              child: Column(
                children: [
                  FutureBuilder(
                    future: getSP('name'),
                    builder: (context, snapshot) {
                      final name = snapshot.data ?? '';
                      return Text(
                        "Hello $name!",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: kGreen,
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 10),

                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            backgroundColor: Colors.white,
                            title: const Text("Modify Profile"),
                            content: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _getInfoText(
                                    context,
                                    'name',
                                    name,
                                    'Insert your Name',
                                  ),
                                  const SizedBox(height: 5),
                                  _getInfoText(
                                    context,
                                    'surname',
                                    surname,
                                    'Insert your Surname',
                                  ),
                                  const SizedBox(height: 5),
                                  _getInfoText(
                                    context,
                                    'gender',
                                    gender,
                                    'Insert your Sex (Male/Female/Other)',
                                  ),
                                  const SizedBox(height: 5),
                                  _getInfoText(
                                    context,
                                    'weight',
                                    weight,
                                    'Insert your Weight (Kg)',
                                  ),
                                  const SizedBox(height: 5),
                                  _getInfoText(
                                    context,
                                    'height',
                                    height,
                                    'Insert your Height (cm)',
                                  ),
                                  const SizedBox(height: 5),
                                  _getInfoText(
                                    context,
                                    'city',
                                    city,
                                    'Insert the name of your City',
                                  ),
                                  const SizedBox(height: 5),
                                  _getInfoText(
                                    context,
                                    'agency',
                                    agency,
                                    'Insert the name of your Agency',
                                  ),
                                  const SizedBox(height: 10),

                                  // Button to modify the profile picture.
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: kGreen,
                                      foregroundColor: kGreenLight,
                                    ),
                                    onPressed: _pickImage,
                                    child: const Text("Modify Profile Picture"),
                                  ),
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () async {
                                  Navigator.of(context).pop();
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: kGreen,
                                  backgroundColor: Colors.transparent,
                                ),
                                child: const Text("Save Profile"),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kGreen,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text("Edit Profile"),
                  ),
                ],
              ),
            ),

            const Divider(),

            // Widget showing all personal information saved in SharedPreferences.
            _personalInfo(context),

            const Divider(),

            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.transparent,
                  width: 10.0,
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    "Trophy Case",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // Trophy #1
                        _showTrophy(
                          context,
                          "Trophy achieved! You rode for 10 km!",
                          Icons.pedal_bike,
                          10,
                        ),
                        const SizedBox(width: 20),

                        // Trophy #2
                        _showTrophy(
                          context,
                          "Trophy achieved! You rode for 100 km!",
                          Icons.bike_scooter,
                          100,
                        ),
                        const SizedBox(width: 20),

                        // Trophy #3
                        _showTrophy(
                          context,
                          "Trophy achieved! You rode for 500 km!",
                          Icons.flash_on,
                          500,
                        ),
                        const SizedBox(width: 20),

                        // Trophy #4
                        _showTrophy(
                          context,
                          "Trophy achieved! You rode for 1000 km!",
                          Icons.emoji_events,
                          1000,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Widget showing total distance, total earnings and total points.
            _showDistance(context),

            const SizedBox(height: 16),
          ],
        ),
      ),

      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.home, color: kGreen),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => HomePage()),
                  (route) => false,
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.person, color: kGreen),
              onPressed: () {
                // Already on ProfilePage, do nothing.
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout, color: kGreen),
              onPressed: () {
                _toLoginPage(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  static void _toLoginPage(BuildContext context) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.remove('isUserLogged');

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  // WIDGETS

  // Widget to show each String information row from SharedPreferences.
  Widget _informationRow(
    BuildContext context,
    String titolo,
    String nomeSP,
    String munit,
  ) {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: Text(
            titolo,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          flex: 6,
          child: FutureBuilder(
            future: getSP(nomeSP),
            builder: (context, snapshot) {
              final data = snapshot.data ?? '';
              if (data.isEmpty) {
                return const Text("No data available");
              } else {
                return Text("$data $munit");
              }
            },
          ),
        ),
      ],
    );
  }

  // Same thing, but in this case to get an int.
  Widget _informationRowint(
    BuildContext context,
    String titolo,
    String nomeSP,
    String munit,
  ) {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: Text(
            titolo,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          flex: 6,
          child: FutureBuilder(
            future: getSPint(nomeSP),
            builder: (context, snapshot) {
              final data = snapshot.data ?? -1;
              if (data < 0) {
                return const Text("No data available");
              } else {
                return Text("$data $munit");
              }
            },
          ),
        ),
      ],
    );
  }

  // Shows personal information saved by the subject.
  Widget _personalInfo(BuildContext context) {
    return Card(
      color: Colors.white,
      child: Container(
        margin: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(width: 50),
            const Text(
              "Personal Informations:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: kGreen,
              ),
            ),
            const SizedBox(height: 5),
            _informationRow(context, "Gender", "gender", ""),
            const SizedBox(height: 5),
            _informationRowint(context, "Age", "age", "years old"),
            const SizedBox(height: 5),
            _informationRow(context, "Weight", 'weight', "kg"),
            const SizedBox(height: 5),
            _informationRow(context, "Height", "height", "cm"),
            const SizedBox(height: 5),
            _informationRow(context, "City", "city", ""),
            const SizedBox(height: 5),
            _informationRow(context, "Agency", "agency", ""),
            const SizedBox(height: 5),
            _informationRow(context, "Physical fitness:", "trainingstat", ""),
            const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }

  // Widget to get the information and save it in SharedPreferences.
  Widget _getInfoText(
    BuildContext context,
    String nomesp,
    String val,
    String texttoinsert,
  ) {
    return TextField(
      onChanged: (text) {
        setState(() {
          val = text;
          saveSP(nomesp, val);
        });
      },
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: nomesp,
        hintText: texttoinsert,
      ),
    );
  }

  // Widget that shows the prizes available that the subject has gained.
  Widget _showTrophy(
    BuildContext context,
    String description,
    IconData icona,
    double soglia,
  ) {
    return FutureBuilder(
      future: getSPdouble('kilometers'),
      builder: (context, sp) {
        final distanzainKm = sp.data ?? 0;
        final bool flag = distanzainKm >= soglia;

        if (flag) {
          return ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context)
                ..removeCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(description),
                    backgroundColor: kGreen,
                    duration: const Duration(seconds: 4),
                  ),
                );
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(120, 120),
              shape: const StarBorder(),
              backgroundColor: kGreen,
              foregroundColor: kGreenLight,
            ),
            child: Icon(icona, size: 20),
          );
        } else {
          return ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context)
                ..removeCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(
                    content: Text("Trophy not yet received... keep riding!"),
                    backgroundColor: CupertinoColors.opaqueSeparator,
                    duration: Duration(seconds: 4),
                  ),
                );
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(120, 120),
              shape: const StarBorder(),
              backgroundColor: CupertinoColors.opaqueSeparator,
              foregroundColor: Colors.white,
            ),
            child: Icon(icona, size: 20),
          );
        }
      },
    );
  }

  // Widget that shows total earnings, total distance and total points.
  Widget _showDistance(BuildContext context) {
    return Card(
      color: Colors.white,
      child: Container(
        margin: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              "Total distance travelled:",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            FutureBuilder(
              future: getSPdouble('kilometers'),
              builder: (context, sp) {
                final double value = sp.data ?? 0;
                return Text(
                  "${value.toStringAsFixed(2)} km",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),

            const Text(
              "Total earnings:",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            FutureBuilder(
              future: getSPdouble('earnings'),
              builder: (context, sp) {
                final double value = sp.data ?? 0;
                return Text(
                  "${value.toStringAsFixed(2)} €",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),

            const Text(
              "Total points:",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            FutureBuilder(
              future: getSPint('points'),
              builder: (context, sp) {
                final int value = sp.data ?? 0;
                return Text(
                  "$value points",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // FUNCTIONS

  // Function to save SharedPreferences values.
  Future<void> saveSP(String key, String value) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(key, value);
  }

  // Function to get SharedPreferences String values.
  Future<String?> getSP(String key) async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(key);
  }

  // Function to get SharedPreferences int values.
  Future<int?> getSPint(String key) async {
    final sp = await SharedPreferences.getInstance();
    return sp.getInt(key);
  }

  // Function to get SharedPreferences double values.
  Future<double?> getSPdouble(String key) async {
    final sp = await SharedPreferences.getInstance();
    return sp.getDouble(key);
  }

  // Function to upload a profile picture using image_picker from the gallery.
  Future<void> _pickImage() async {
    try {
      final XFile? chosenImage = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 75,
      );

      if (chosenImage != null) {
        final Uint8List imageBytes = await chosenImage.readAsBytes();

        // Save the image in SharedPreferences.
        final String base64Image = base64Encode(imageBytes);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_profile_pic', base64Image);

        setState(() {
          _webImage = imageBytes;
        });
      }
    } catch (e) {
      debugPrint("Error in the uploading of the picture: $e");
    }
  }

  // Function to load the profile picture saved in SharedPreferences.
  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final String? base64String = prefs.getString('user_profile_pic');

    if (base64String != null) {
      setState(() {
        _savedImageBytes = base64Decode(base64String);
      });
    }
  }
}