import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pharmacy_in_pocket/UI/pages/registration_page.dart';
import 'package:pharmacy_in_pocket/UI/pages/search.dart';
import 'package:provider/provider.dart';

import '../model/auth.dart';
import '../model/medicines.dart';

class Account extends StatefulWidget {
  const Account({super.key});

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My account')),
      drawer: Drawer(
        child: ListView(
          children: [
            SizedBox(height: 20,),
            ElevatedButton(
              style: ButtonStyle(
                  backgroundColor: const MaterialStatePropertyAll(Colors.indigo),
                  elevation: const MaterialStatePropertyAll(5),
                  shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)))
                ),
              child: const Text('Search'),
              onPressed: ()  {
                // List medicines = [];
                // var x = await FirebaseFirestore.instance
                //     .collection('medicines')
                //     .get();

                // var list = x.docs;
                // for (int i = 0; i < list.length; i++) {
                //   var doc = list[i];
                //   var data = doc.data();
                //   medicines.add(data);
                // }
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => SearchPage(medicines:Provider.of<Medicines>(context).medicines),
                ));
              },
            ),
          ],
        ),
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('users').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            var currentUser = snapshot.data!.docs.firstWhere(
              (element) =>
                  element['email'] == FirebaseAuth.instance.currentUser!.email,
            );
            return Container(
              color: Colors.blueGrey[100],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.person_pin,
                        size: 70,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentUser['username'],
                            style: const TextStyle(
                                fontSize: 30, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            currentUser['email'],
                            style: const TextStyle(fontSize: 15),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Divider(
                    thickness: 3,
                    color: Colors.grey[600],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextButton(
                        onPressed: () {}, child: const Text('Change email')),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextButton(
                        onPressed: () {}, child: const Text('Change password')),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextButton(
                      onPressed: () async {
                        Provider.of<Auth>(context, listen: false).setIsLoading(false);
                        await FirebaseAuth.instance.signOut();
                        await Navigator.pushReplacement(context, MaterialPageRoute(builder:(context) => RegistrationPage(),));
                      },
                      child: const Text('Logout'),
                    ),
                  ),
                ],
              ),
            );
          }),
    );
  }
}
