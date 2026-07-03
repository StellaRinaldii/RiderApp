import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:convert';

import 'package:workers_campe/screens/homepage.dart';
import 'package:workers_campe/screens/login.dart';
import 'package:workers_campe/providers/possible_shift_provider.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

const Color kGreen = Color(0xFF639922);
const Color kGreenLight = Color(0xFFEAF3DE);

class Profilepage extends StatefulWidget{
  const Profilepage({super.key});

  @override
  State<Profilepage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<Profilepage> {
  Uint8List? _webImage;
  Uint8List? _savedImageBytes;
  final ImagePicker _picker = ImagePicker();
  String name =  '';
  String surname = '';
  String age = '';
  String gender = '';
  String height = '';
  String weight = '';
  String city = '';
  String agency = '';
  bool flag = false ;

  // carichiamo possibili immagini profilo salvate nelle sp:
  // load possible profile images saved in the shared preference
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
        title: Text("Profile Page", style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 25,
        ),),
        centerTitle: true,
        backgroundColor: kGreen,
        foregroundColor: kGreenLight,  
      ) ,

      body: Column(
            spacing: 5,
            children: 
            <Widget>[
              const SizedBox(height: 10),
              CircleAvatar(
                radius: 60, 
                backgroundImage: _webImage != null
                    ? MemoryImage(_webImage!) // 1. Nuova foto appena scelta
                    : (_savedImageBytes != null
                        ? MemoryImage(_savedImageBytes!) // 2. Vecchia foto caricata all'avvio
                        : const AssetImage('assets/profilepage/profilepic.png')), // 3. Default
              ),
              const SizedBox(height: 1),
              SizedBox( width: 200, 
                        child: Column(
                          children: [

                            FutureBuilder(
                            future: getSP('name'), 
                            builder: (context, snapshot){
                              final name = snapshot.data ?? '';
                              return Text("Hello $name!", style: TextStyle(fontSize:20, fontWeight: FontWeight.bold, color: kGreen),);
                            }),
                            
                            const SizedBox(height: 10),

                            ElevatedButton(onPressed: () {                         
                                   showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                                                            
                                      return AlertDialog(
                                        backgroundColor: Colors.white,
                                        title: Text("Modify Profile"),
                                        content: Column(
                                          children: [
                                            _getInfoText(context, 'name', name, 'Insert your Name'),
                                            SizedBox(height: 5,),
                                            _getInfoText(context, 'surname', surname, 'Insert your Surname'),
                                            SizedBox(height: 5,),
                                            _getInfoText(context, 'gender', gender, 'Insert your Gender (M/F)'),
                                            SizedBox(height: 5,),
                                            _getInfoText(context, 'weight', weight, 'Insert your Weight (Kg)'),
                                            SizedBox(height: 5,),
                                            _getInfoText(context, 'height', height, 'Insert your Height (cm)'),
                                            SizedBox(height: 5,),
                                            _getInfoText(context, 'city', city, 'Insert the name of your City'),
                                            SizedBox(height: 5,),
                                           _getInfoText(context, 'agency', agency, 'Insert the name of your Agency'),
                                            SizedBox(height: 10,),

                                            // button to modify the profile picture:
                                            ElevatedButton (
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: kGreen, // Colore di sfondo
                                                foregroundColor: kGreenLight, // Colore del testo/icona
                                              ),
                                              onPressed: _pickImage,
                                              child: const Text("Modify Profile Picture")
                                            )
                                          ],
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () async{
                                              Navigator.of(context).pop(); // Chiude il dialog
                                            },
                                            style: TextButton.styleFrom(
                                              foregroundColor: kGreen,
                                              backgroundColor: Colors.transparent, 
                                            ),
                                            child: Text("Save Profile"),
                                          ),
                                        ],
                                      );
                                    },
                                  );}, 
                              style: ElevatedButton.styleFrom(
                                    backgroundColor: kGreen,
                                    foregroundColor: Colors.black,),
                              child: Text("Edit Profile"),
                              ),
                          ],
                        ),
                ),

              const Divider(),

              // widget showing all the personal informations of the subject saved in the SP
              _personalInfo(context),
             
              const Divider(),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.transparent,
                    width: 10.0,
                  )
                ),
                //width: 400,
                child: Column( children: [
                  Text("Trophy Case", style: TextStyle(fontWeight: FontWeight.bold,),),
                  const SizedBox(height: 10,),
                  Row( children: [
                    // PREMIO #1
                       _showTrophy(context,"Trophy achieved! You rode for 10 km!", Icons.pedal_bike, 10),
                        const Spacer(),
                    // PREMIO #2
                       _showTrophy(context, "Trophy achieved! You rode for 100 km!", Icons.bike_scooter, 100),
                        const Spacer(),
                    // PREMIO #3
                       _showTrophy(context, "Trophy achieved! You rode for 1000 km!", Icons.flash_on, 1000) 
                  ],)
                ],
                ),
              ),

              const Spacer(),
              // widget che mostra la distanza totale percorsa e i guadagni totali
              _showDistance(context)
          ],),

   bottomNavigationBar: BottomAppBar(
      color: Colors.white,
      child : Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children : [
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
              // Already on ProfilePage, do nothing
            },
          ),

          IconButton(
            icon: const Icon(Icons.logout, color: kGreen),
            onPressed: () {
              _toLoginPage(context);
            },
          ),
        ]
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
  // widget to show each row information from the SP
  Widget _informationRow(BuildContext context, String titolo, String nomeSP, String munit){
    return Row(children: [
      Expanded(
        flex: 4, 
        child: Text(titolo, style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      Expanded(
        flex: 6, 
        child:FutureBuilder(
                      future: getSP(nomeSP), 
                      builder: (context, snapshot){
                          final data = snapshot.data ?? '';
                            if (data.isEmpty){
                              return Text("No data available");
                            } else {
                              return Text("$data $munit");
                            }
                          }
                    ),
      ),
    ],);
  }

  // shows personal informations saved by the subject
  Widget _personalInfo(BuildContext context) {
    return Card( 
                color: Colors.white, //light,
                child: Container(
                  margin: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const SizedBox(width: 50),
                      Text("Personal Informations:", style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: kGreen,)
                        ,),
                      SizedBox(height: 5),
                      _informationRow(context, "Gender", "gender", ""),
                      SizedBox(height: 5),
                      _informationRow(context, "Weight", 'weight', "kg"),
                      SizedBox(height: 5),
                      _informationRow(context, "Height", "height", "cm"),
                      SizedBox(height: 5),
                      _informationRow(context, "City", "city", ""),
                      SizedBox(height: 5),
                      _informationRow(context, "Agency", "agency", ""),
                      SizedBox(height: 5),
                          //_informationRow(context, "Total Km", "gender", ""),
                          // mancano le informazioni sui Km

                    ],
                  ),
                ),
              );
  }

  // widget to get the information and save it in the SP 
  Widget _getInfoText(BuildContext context, String nomesp, String val, String texttoinsert) {
    return TextField(
                      onChanged: (text) {
                          setState(() {
                            val = text;
                            saveSP(nomesp, val);
                          });
                        },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: nomesp,
                        hintText: texttoinsert,     
                      ),
                    );
  }

// widget that shows the prizes available that the subject has gained:
Widget _showTrophy (BuildContext context, String description, IconData icona, double soglia) {
  // inietto il provider nel widget:
   return Consumer<PossibleShiftProvider>(
    builder: (context, provider, child) {

      // salvo la flag dalla condizione del wiget
       final distanzainKm = provider.totalDistanceKm;
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
                                backgroundColor: kGreen,
                                duration: Duration(seconds: 4),
                              ),
                            );
                          return;
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(120, 120),
                        shape: StarBorder(),  // forma del premio
                        backgroundColor: kGreen, // Colore di sfondo
                        foregroundColor: kGreenLight, // Colore del testo/icona
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
                        shape: StarBorder(),  // forma del premio
                        backgroundColor: CupertinoColors.opaqueSeparator, // Colore di sfondo
                        foregroundColor: Colors.white// Colore del testo/icona
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
                          Consumer<PossibleShiftProvider>(
                            builder: (context, provider, child) {
                              return Text(
                                "${provider.totalDistanceKm.toStringAsFixed(2)} km",
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              );
                            },
                          ),
                          const Text("Total earnings:",
                              style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold),
                          ),
                          Consumer<PossibleShiftProvider>(
                          builder: (context, provider, child) {
                            return Text(
                              "${provider.totalEarnings.toStringAsFixed(2)} €",
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            );
                          },
                        ),
                        const Text("Total points:",
                              style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold),
                          ),
                          Consumer<PossibleShiftProvider>(
                          builder: (context, provider, child) {
                            return Text(
                              "${provider.totalPoints.toStringAsFixed(2)} €",
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            );
                          },
                        ),
                      ]
      )
    )
  );
}

// FUNCTIONS
  // Function to save the Shared Preferences values:
  Future <void> saveSP(String key, String value) async{
    final sp = await SharedPreferences.getInstance();
    await sp.setString(key, value);
  }

  // Function to get the Shared Preferences values:
  Future <String?> getSP(String key) async{
    final sp = await SharedPreferences.getInstance();
    return sp.getString(key);
  }

  // function to upload a profile page using image_picker from the gallery
  Future<void> _pickImage() async{
    try{
      final XFile? chosenImage = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 75,
      );
      if (chosenImage != null){
        final Uint8List imageBytes = await chosenImage.readAsBytes();
            // save the image in the shared preferences
            String base64Image = base64Encode(imageBytes);
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

  // function to load the profile picture saved in the shared preferences:
  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    String? base64String = prefs.getString('user_profile_pic');
    if (base64String != null) {
      setState(() {
        _savedImageBytes = base64Decode(base64String);
      });
    }
  }
}

