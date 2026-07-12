import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:convert';

import 'package:workers_campe/screens/homepage.dart';
import 'package:workers_campe/screens/login.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

import 'package:provider/provider.dart';
import 'package:workers_campe/providers/possible_shift_provider.dart';
import 'package:intl/intl.dart';

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
  String dob = '';
  final TextEditingController _dobController = TextEditingController();
  String trainingfit = '';
  bool flag = false;

  // carichiamo possibili immagini profilo salvate nelle sp:
  // load possible profile images saved in the shared preference

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  @override
void dispose() {
  _dobController.dispose();
  super.dispose();
}

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colors.secondary,
      appBar: AppBar(
        title: const Text(
          "Profile Page",
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 25,
          ),
        ),
        centerTitle: true,
        backgroundColor: colors.primary,
        foregroundColor: colors.secondary,
      ),

      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
            spacing: 5,
            children: 
            <Widget>[
              const SizedBox(height: 10),
              Stack(
                children: [
                  CircleAvatar(
                    radius: 60, 
                    backgroundImage: _webImage != null
                        ? MemoryImage(_webImage!) 
                        : (_savedImageBytes != null
                            ? MemoryImage(_savedImageBytes!) 
                            : const AssetImage('assets/profilepage/profilepic.png')), 
                  ),
                  // positioning an icon button such that we can modify the profile picture
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: colors.primary, 
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                        onPressed: () {
                          _pickImage();
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 1),
              SizedBox( width: 200, 
                        child: Column(
                          children: [

                            FutureBuilder(
                            future: getSP('name'), 
                            builder: (context, snapshot){
                              final name = snapshot.data ?? '';
                              return Text("Hello $name!", style: TextStyle(fontSize:20, fontWeight: FontWeight.bold, color: colors.primary),);
                            }),
                            
                            const SizedBox(height: 10),

                  ElevatedButton(
                    onPressed: () async {
                      _dobController.text== 'Date of Birth';
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
                                    Icons.person_outline,
                                  ),
                                  const SizedBox(height: 5),
                                  _getInfoText(
                                    context,
                                    'surname',
                                    surname,
                                    'Insert your Surname',
                                    Icons.badge_outlined
                                  ),
                                  const SizedBox(height: 5),
                                  _getDropdownMenu(
                                    context, 
                                    'gender', 
                                    gender, 
                                    ['Male', 'Female', 'Other'], 
                                    "Sex ", 
                                    Icons.wc_outlined
                                  ),
                                  const SizedBox(height: 5),
                                  _getDobField(context),
                                  const SizedBox(height: 5),
                                  _getInfoText(
                                    context,
                                    'weight',
                                    weight,
                                    'Insert your Weight (Kg)',
                                    Icons.scale_outlined,
                                  ),
                                  const SizedBox(height: 5),
                                  _getInfoText(
                                    context,
                                    'height',
                                    height,
                                    'Insert your Height (cm)',
                                    Icons.straighten_outlined,
                                  ),
                                  const SizedBox(height: 5),
                                  _getInfoText(
                                    context,
                                    'city',
                                    city,
                                    'Insert the name of your City',
                                    Icons.house,
                                  ),
                                  const SizedBox(height: 5),
                                  _getInfoText(
                                    context,
                                    'agency',
                                    agency,
                                    'Insert the name of your Agency',
                                    Icons.business
                                  ),
                                  const SizedBox(height: 5,),
                                  _getDropdownMenu(
                                    context, 
                                    "trainingstat", 
                                    trainingfit, 
                                    ['Beginner', 'Intermediate','Advanced'], 
                                    'Training Level', 
                                    Icons.directions_run_outlined,
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
                                  foregroundColor: colors.primary,
                                  backgroundColor: Colors.transparent,
                                ),
                                child: const Text("Done"),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: Colors.white,
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
              icon: Icon(Icons.home, color: colors.primary),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => HomePage()),
                  (route) => false,
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.person, color: colors.primary),
              onPressed: () {
                // Already on ProfilePage, do nothing.
              },
            ),
            IconButton(
              icon: Icon(Icons.logout, color: Theme.of(context).colorScheme.primary),
              onPressed: () async {
                final provider = Provider.of<PossibleShiftProvider>(
                  context,
                  listen: false,
                );

                if (provider.shiftStarted || provider.sleepRecoveryPending) {
                  ScaffoldMessenger.of(context)
                    ..removeCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        content: Text(
                          provider.shiftStarted
                              ? 'You cannot logout while a shift is in progress.'
                              : 'You cannot logout while recovery is in progress.',
                        ),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 3),
                      ),
                    );

                  return;
                }

                final sp = await SharedPreferences.getInstance();
                await sp.remove('isUserLogged');

                if (!context.mounted) return;

                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => const LoginPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
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

  // same thing but in this case to get an int
  Widget _informationRowint(BuildContext context, String titolo, String nomeSP, String munit){
    return Row(children: [
      Expanded(
        flex: 4, 
        child: Text(titolo, style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      Expanded(
        flex: 6, 
        child:FutureBuilder(
                      future: getSPint(nomeSP), 
                      builder: (context, snapshot){
                          final data = snapshot.data ?? -1;
                            if (data == Null || data < 0){
                              return Text("No data available");
                            } else {
                              return Text("$data $munit");
                            }
                          }
                    ),
      ),
    ],);
  }

  // Shows personal information saved by the subject.
  Widget _personalInfo(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card( 
                color: Colors.white, //light,
                child: Container(
                  margin: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const SizedBox(width: 50),
                      Text("Personal Informations:", style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colors.primary,)
                        ,),
                      SizedBox(height: 5),
                      _informationRow(context, "Gender", "gender", ""),
                      SizedBox(height: 5),
                       _informationRowint(context, "Age", "age", "years"),
                       SizedBox(height: 5),
                       _informationRow(context, "Date of Birth", "dob", ""),
                      SizedBox(height: 5),
                      _informationRow(context, "Weight", 'weight', "kg"),
                      SizedBox(height: 5),
                      _informationRow(context, "Height", "height", "cm"),
                      SizedBox(height: 5),
                      _informationRow(context, "City", "city", ""),
                      SizedBox(height: 5),
                      _informationRow(context, "Agency", "agency", ""),
                      SizedBox(height: 5),
                      _informationRow(context, "Physical fitness", "trainingstat", ""),
                      SizedBox(height: 5),

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
    IconData icona,
  ) {
    return TextFormField(
      onChanged: (text) {
        setState(() {
          val = text;
          saveSP(nomesp, val);
        });
      },
      keyboardType: TextInputType.text, 
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: nomesp,
        hintText: texttoinsert,
        prefixIcon: Icon(icona), // 
      ),
  validator: (value) {
    if (value == null || value.trim().isEmpty) {
      return texttoinsert;
    }
    if (double.tryParse(value.trim()) == null) {
      return 'Please enter a valid weight';
    }
    return null;
  },
  );
  }

  // Widget to pick and display the date of birth.
Widget _getDobField(BuildContext context) {
  return TextFormField(
    controller: _dobController,
    readOnly: true,
    decoration: const InputDecoration(
      border: OutlineInputBorder(),
      hintText: 'Date of Birth',
      prefixIcon: Icon(Icons.cake_outlined),
      suffixIcon: Icon(Icons.calendar_today_outlined),
    ),
    validator: (value) {
      if (value == null || value.trim().isEmpty) {
        return 'Please pick your date of birth';
      }
      return null;
    },
    onTap: () => _selectDob(context),
  );
}

// Opens the date picker, recomputes the age and saves both values.
Future<void> _selectDob(BuildContext context) async {
  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: DateTime(2000),
    firstDate: DateTime(1900),
    lastDate: DateTime.now(),
  );

  if (picked == null) return;

  int computedAge = DateTime.now().year - picked.year;
  if (DateTime.now().month < picked.month &&
      DateTime.now().day < picked.day) {
    computedAge -= 1;
  }

  setState(() {
    _dobController.text = DateFormat('dd/MM/yyyy').format(picked);
  });

  await saveSP('dob', _dobController.text);
  await saveSPint('age', computedAge);
}
  // widget to modify variables with a drop menu
  Widget _getDropdownMenu(
    BuildContext context,
    String nomesp,
    String currentValue,
    List<String> opzioni,
    String texttoinsert,
    IconData icona,
  ) {
    return DropdownButtonFormField<String>(
      value: opzioni.contains(currentValue) ? currentValue : null,
      items: opzioni.map((String opzione) {
        return DropdownMenuItem<String>(
          value: opzione,
          child: Text(opzione),
        );
      }).toList(),
      onChanged: (newValue) {
        if (newValue != null) {
          setState(() {
            // Nota: per aggiornare la UI, la variabile passata deve 
            // aggiornare lo stato della pagina principale.
            saveSP(nomesp, newValue);
          });
        }
      },
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        hintText: texttoinsert,
        prefixIcon: Icon(icona),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return texttoinsert;
        }
        return null;
      },
    );
  }

// widget that shows the prizes available that the subject has gained:
Widget _showTrophy (BuildContext context, String description, IconData icona, double soglia) {
  final colors = Theme.of(context).colorScheme;
  // inietto il provider nel widget:
   return FutureBuilder(
                      future: getSPdouble('kilometers'), 
                      builder: (context, sp){

      // salvo la flag dalla condizione del wiget
       final distanzainKm = sp.data ?? 0;
       // se ho percorso più della soglia, la flag è vera e quindi mostro il premio colorato
       bool flag = distanzainKm >= soglia;

  if (flag) {
  return ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context)
                            ..removeCurrentSnackBar()
                            ..showSnackBar(
                              SnackBar(
                                content: Text(description),
                                backgroundColor: colors.primary,
                                duration: Duration(seconds: 4),
                              ),
                            );
                          return;
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(120, 120),
                        shape: StarBorder(),  // forma del premio
                        backgroundColor: colors.primary, // Colore di sfondo
                        foregroundColor: colors.secondary, // Colore del testo/icona
                      ),
                      child: Icon(icona, size: 20), 
                    );
  } else {
  return ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context)
                            ..removeCurrentSnackBar()
                            ..showSnackBar(
                              SnackBar(
                                content: Text("Trophy not yet recived... keep riding!"),
                                backgroundColor: CupertinoColors.opaqueSeparator,
                                duration: Duration(seconds: 4),
                              ),
                            );
                          return;
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(120, 120),
                        shape: StarBorder(),  
                        backgroundColor: CupertinoColors.opaqueSeparator, 
                        foregroundColor: Colors.white
                      ),
                      child: Icon(icona, size: 20), 
                    );
      } // fine else
     }
   );
  }

// widget che mostra i guadagni totali e i km tot percorsi usando il provider
Widget _showDistance (BuildContext context) {
  return Card(
    color: Colors.white, //light,
                child: Container(
                  margin: const EdgeInsets.all(20),
                  child: Column(
                      children: [
                          const Text("Total distance travelled:",
                              style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold),
                          ),
                          FutureBuilder(
                            future: getSPdouble('kilometers'), 
                            builder: (context, sp){
                              final double value = sp.data ?? 0;
                              return Text("${value.toStringAsFixed(2)} km",
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              );
                            },
                          ),
                          const Text("Total earnings:",
                              style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold),
                          ),
                          FutureBuilder(
                            future: getSPdouble('earnings'), 
                            builder: (context, sp){
                              final double value = sp.data ?? 0;
                              return Text("${value.toStringAsFixed(2)} €",
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              );
                            },
                          )
                      ]
      )
    )
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

  Future <int?> getSPint(String key) async{
    final sp = await SharedPreferences.getInstance();
    return sp.getInt(key);
  }

  Future <double?> getSPdouble(String key) async{
    final sp = await SharedPreferences.getInstance();
    return sp.getDouble(key);
  }

  Future<void> saveSPint(String key, int value) async {
  final sp = await SharedPreferences.getInstance();
  await sp.setInt(key, value);
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