import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pharmacy_in_pocket/UI/model/auth.dart';
import 'package:pharmacy_in_pocket/UI/pages/search.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';

import 'UI/model/medicines.dart';
import 'UI/pages/registration_page.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
//Disable landscape (force portrait)
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(MultiProvider(
    providers: [
      ListenableProvider(create: (_) => Auth()),
      ListenableProvider(create: (_) => Medicines()),
    ],
    child: MyApp(),
  ));
  /* runApp(ChangeNotifierProvider<Auth>(
    create: (_) => Auth(),
    child: MyApp(),
  )); */
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  void load(BuildContext ctx) async {
    var firebaseInstance = FirebaseFirestore.instance;
    //1. get the city of the user
    String cityOfUser = '';
    var usersDoc = await firebaseInstance.collection('users').get();
    var users = usersDoc.docs;
    if (users.isNotEmpty) {
      print('Condition satisfied');
      var user = users.firstWhereOrNull((user) {
        return user
                .data()['email']
                .toString()
                .compareTo(FirebaseAuth.instance.currentUser!.email!) ==
            0;
      });
      if (user != null) {
        setState(() {
          cityOfUser = user.data()['city'];
        });
      } else {
        print('user is null');
      }
    } else {
      print('users list is empty');
    }
    //2.Filter medicines depends on cityOfUser
    //2.A. get all pharmacies which are in the cityOfUser
    List<String> pharmacies = [''];
    var pharmaciesDoc = await firebaseInstance.collection('pharmacies').get();
    var pharmaciesList = pharmaciesDoc.docs;
    for (int i = 0; i < pharmaciesList.length; i++) {
      var pharmacy = pharmaciesList[i].data();
      if (pharmacy['location'].toString().compareTo(cityOfUser) == 0) {
        pharmacies.add(pharmacy['name'].toString());
      }
    }
    pharmacies.forEach((element) {
      print(element);
    });
    //2.B. any medicine exist in any of the pharmacies list, add it to medicines list
    List<Map<String, dynamic>> medicines = [];
    var medicinesDoc = await firebaseInstance.collection('medicines').get();
    var medicinesList = medicinesDoc.docs;
    //loop for medicines
    for (int i = 0; i < medicinesList.length; i++) {
      var doc = medicinesList[i];
      var medicine = doc.data();
      List pharmaciesOfMedicine = medicine['pharmacies'];
      //loop for medicie['pharmacies']

      middle:
      for (int j = 0; j < pharmaciesOfMedicine.length; j++) {
        for (int k = 0; k < pharmacies.length; k++) {
          if (pharmaciesOfMedicine.contains(pharmacies[k])) {
            medicines.add(medicine);
            //To avoid duplicating the displayed medicines
            break middle;
          }
        }
      }
    }
    Provider.of<Medicines>(ctx, listen: false).setMedicines(medicines);
  }

  Map<int, Color> x = const {
    50: Color.fromRGBO(93, 63, 211, 0.1),
    100: Color.fromRGBO(93, 63, 211, 0.2),
    200: Color.fromRGBO(93, 63, 211, 0.3),
    300: Color.fromRGBO(93, 63, 211, 0.4),
    400: Color.fromRGBO(93, 63, 211, 0.5),
    500: Color.fromRGBO(93, 63, 211, 0.6),
    600: Color.fromRGBO(93, 63, 211, 0.7),
    700: Color.fromRGBO(93, 63, 211, 0.8),
    800: Color.fromRGBO(93, 63, 211, 0.9),
    900: Color.fromRGBO(93, 63, 211, 1),
  };

  @override
  Widget build(BuildContext context) {
    MaterialColor colorCustom = MaterialColor(0xFF880E4F, x);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pharmacy In Pocket',
      theme: ThemeData(
          primaryColor: const Color.fromRGBO(93, 63, 211, 1),
          primarySwatch: Colors.indigo,
          //canvasColor: Color.fromRGBO(168, 61, 234,1),
          textTheme: const TextTheme(
              bodyMedium: TextStyle(
            color: Colors.black,
          )),
          textButtonTheme: const TextButtonThemeData(
              style: ButtonStyle(
                  foregroundColor: MaterialStatePropertyAll(Colors.white),
                  backgroundColor: MaterialStatePropertyAll(Colors.indigo))),
          elevatedButtonTheme: ElevatedButtonThemeData(
              style: ButtonStyle(
                  shape: MaterialStatePropertyAll<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0))),
                  backgroundColor: const MaterialStatePropertyAll(
                      Color.fromRGBO(93, 63, 211, 1))))),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (_, snapshot) {
          if (snapshot.hasError) {
            return const Text('No data avaible right now');
          } else if (snapshot.hasData) {
            if (!Provider.of<Medicines>(context).isLoaded) {
              load(context);
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else {
              return SearchPage(
                  medicines: Provider.of<Medicines>(context).medicines);
            }
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.red,
              ),
            );
          } else {
            return RegistrationPage();
          }
        },
      ),
    );
  }
}
