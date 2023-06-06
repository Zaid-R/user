/* // ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:pharmacy_in_pocket/UI/model/checkbox_state.dart';
import 'package:pharmacy_in_pocket/UI/pages/account.dart';
import 'package:pharmacy_in_pocket/UI/pages/search.dart';

class BottomNavBar extends StatefulWidget {
  List medicines;
  BottomNavBar({
    Key? key,
    required this.medicines,
  }) : super(key: key);

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  late List pages ;
  int _selectedPageIndex = 0;
  @override
  void initState() {
    super.initState();
    setState(() {
      var medicines = widget.medicines;
      pages =  [  SearchPage(medicines: widget.medicines), const Account()];
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[_selectedPageIndex],
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(15), topRight: Radius.circular(15)),
        child: BottomNavigationBar(
          backgroundColor: Colors.indigo,
            onTap: (index) => setState(() => _selectedPageIndex = index),
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.black87,
            currentIndex: _selectedPageIndex,
            selectedFontSize: 15,
            unselectedIconTheme: const IconThemeData(size: 25),
            selectedIconTheme: const IconThemeData(size: 30),
            type: BottomNavigationBarType.fixed,
            items:  const [
              BottomNavigationBarItem(
                icon: Icon(Icons.search),
                label: 'Search',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Account',
              )
            ]),
      ),
    );
  }
} */