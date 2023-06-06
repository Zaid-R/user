
import 'package:flutter/material.dart';

class Medicines with ChangeNotifier {
  bool isLoaded = false;
  List<Map<String,dynamic>> medicines=[];
  void setMedicines(List<Map<String,dynamic>> x){
    medicines = x;
    isLoaded = true;
    notifyListeners();
  }
}