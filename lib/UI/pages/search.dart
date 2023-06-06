// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:provider/provider.dart';

import 'package:pharmacy_in_pocket/UI/model/checkbox_state.dart';
import 'package:pharmacy_in_pocket/UI/model/medicines.dart';
import 'package:pharmacy_in_pocket/UI/pages/account.dart';

class SearchPage extends StatefulWidget {
  List<Map<String, dynamic>> medicines;
  SearchPage({
    Key? key,
    required this.medicines,
  }) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();
  List<CheckBoxState> medicinesCheckValues = [];
  double totalPrice = 0;
  List medicines = [];
  var quantityButtonsStyle = ButtonStyle(
      backgroundColor: const MaterialStatePropertyAll(Colors.transparent),
      shape: MaterialStatePropertyAll(RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(100),
      )));
  var orderButtonsStyle = ButtonStyle(
      shape: MaterialStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(0))),
      backgroundColor: const MaterialStatePropertyAll(Colors.indigo));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {
      medicinesCheckValues =
          List.generate(widget.medicines.length, (val) => CheckBoxState());
      medicines = Provider.of<Medicines>(context).medicines;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Search')),
        drawer: Drawer(
          child: ListView(
            children: [
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                style: ButtonStyle(
                    backgroundColor:
                        const MaterialStatePropertyAll(Colors.indigo),
                    elevation: const MaterialStatePropertyAll(5),
                    shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0)))),
                child: const Text('account'),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => const Account(),
                  ));
                },
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            //Search row
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: TextField(
                      controller: searchController,
                      cursorColor: Theme.of(context).primaryColor,
                      decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  width: 3,
                                  color: Theme.of(context).primaryColor)),
                          border: const OutlineInputBorder(
                              borderSide:
                                  BorderSide(width: 3, color: Colors.grey)),
                          hintText: 'Search using medicine name...'),
                      onChanged: (value) => setState(() {
                        if(value.isNotEmpty) {
                          medicines = widget.medicines
                            .where((medicine) => medicine['name']
                                .toString().toLowerCase()
                                .contains(value.toLowerCase()))
                            .toList();
                        }else{
                          medicines = widget.medicines;
                        }
                      }),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: ElevatedButton(
                      style: const ButtonStyle(
                          backgroundColor:
                              MaterialStatePropertyAll(Colors.indigo)),
                      onPressed: () async {
                        String? result;
                        try {
                          result = await FlutterBarcodeScanner.scanBarcode(
                              '#FF0000', 'Cancel', true, ScanMode.BARCODE);
                          //if (!mounted) return;
                          setState(() {
                            var medicien = widget.medicines.firstWhereOrNull((element) => element['id'].toString().compareTo(result!)==0);
                            medicines = medicien==null?[]:[medicien];
                            searchController.text = result!;
                          });
                        } on PlatformException {
                          result = 'Failed to get platform version.';
                        }
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Text('Scan barcode'),
                      )),
                )
              ],
            ),
            Divider(
              thickness: 3,
              color: Colors.grey[600],
            ),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount: medicines.length,
                itemBuilder: (_, index) {
                  var medicine = medicines[index];
                  Widget medicineWidget = Column(
                    children: [
                      Material(
                        elevation: 5,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () {
                                showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                          content: Column(
                                            children: [
                                              Text('Name: ' +
                                                  medicine['name'].toString()),
                                              const Divider(),
                                              Text('Physical status: ' +
                                                  (medicine['isLiquid'] as bool
                                                      ? 'liquid'
                                                      : 'solid')),
                                              const Divider(),
                                              Text('Scientific name: ' +
                                                  medicine['scientificName']
                                                      .toString()),
                                              const Divider(),
                                              Text('Dose usage: ' +
                                                  medicine['dose'].toString()),
                                              const Divider(),
                                              Text('Price: ' +
                                                  medicine['price'].toString() +
                                                  ' JD')
                                            ],
                                          ),
                                          actions: [
                                            ElevatedButton(
                                              onPressed: () {
                                                Navigator.pop(ctx);
                                              },
                                              child: const Text('Close'),
                                            )
                                          ],
                                        ));
                              },
                              child: Container(
                                margin: const EdgeInsets.only(left: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      medicine['name'].toString(),
                                      style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    Text(medicine['price'].toString() + ' JD')
                                  ],
                                ),
                              ),
                            ),
                            StatefulBuilder(
                              builder: (_, setstate) {
                              return Checkbox(
                                  value: medicinesCheckValues[index].value,
                                  onChanged: (val) {
                                    setState(() {
                                      medicinesCheckValues[index] =
                                          medicinesCheckValues[index]
                                              .copyWith(value: val!);
                                      if (val) {
                                        totalPrice += medicine['price'];
                                      } else {
                                        totalPrice -= medicine['price'];
                                      }
                                      totalPrice = double.parse(
                                          totalPrice.toStringAsFixed(2));
                                    });
                                  });
                            })
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      )
                    ],
                  );
                    return medicineWidget;
                
                  //When search text field is empty, display all medicines
                  // if (name.isEmpty) {
                  //   return medicineWidget;
                  // }
                  // //When user search using barcode, display the matching medicine
                  // else if (isBarcode &&
                  //     widget.medicines
                  //         .contains(scanResult!)) {
                  //   return medicineWidget;
                  // }
                  // //When user search using name, display the matching medicines
                  // else if (widget
                  //     .medicines[index]['name']
                  //     .toLowerCase()
                  //     .contains(name.toLowerCase())) {
                  //   return medicineWidget;
                  // }
                },
              ),
            ),
            Container(
                width: double.infinity,
                child: ElevatedButton(
                    style: orderButtonsStyle,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Buy',
                            style: TextStyle(fontSize: 20),
                          ),
                          Text(
                            totalPrice.toString() + ' JD',
                            style: const TextStyle(fontSize: 20),
                          )
                        ],
                      ),
                    ),
                    onPressed: () {
                      if (totalPrice > 0) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: Colors.green,
                            content: const Text(
                              'Successful order',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600),
                            ),
                            actions: [
                              ElevatedButton(
                                style: const ButtonStyle(
                                    backgroundColor: MaterialStatePropertyAll(
                                        Colors.indigo)),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('Okay'),
                              )
                            ],
                          ),
                        );
                        setState(() {
                          totalPrice = 0;
                          medicinesCheckValues = List.generate(
                              widget.medicines.length,
                              (val) => CheckBoxState());
                        });
                      }
                    })),
          ],
        ));
  }
}