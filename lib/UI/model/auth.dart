import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Auth with ChangeNotifier {
  bool isLoading = false;
  
  void setIsLoading(bool val){
    isLoading = val;
    notifyListeners();
  }
  Future<void> authenticate(
      String email, String password, String username,String city,String phoneNumber, bool isLogin,bool addedByAdmin) async {
    UserCredential authResult;
    final _auth = FirebaseAuth.instance;
    String Email = email.trim().toLowerCase();
    try {
      isLoading = true;
      if (isLogin) {
        authResult = await _auth.signInWithEmailAndPassword(
            email: Email, password: password);
      } else {
        if(!addedByAdmin) {
          await FirebaseFirestore.instance
            .collection('users')
            .doc(email)
            .set({
          'username': username,
          'password': password,
          'email': Email,
          'phoneNumber':phoneNumber,
          'city':city,
          'isAdmin': 0,
        });
        authResult = await _auth.createUserWithEmailAndPassword(
            email: Email, password: password);
        }
      }
    } on FirebaseAuthException catch (e) {
      String message = "error Occurred";

      if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'The account already exists for that email.';
      } else if (e.code == 'user-not-found') {
        message = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        message = 'Wrong password provided for that user.';
      }
      isLoading = false;
      throw message;
    } catch (e) {
      print(e);
      isLoading = false;
      rethrow;
    }
  }
}