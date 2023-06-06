// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class Pharmacy extends StatelessWidget {
  final String label;
  final Function() onTap;
  const Pharmacy({
    Key? key,
    required this.label,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:onTap,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Theme.of(context).primaryColor,
                width: 5,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Image.asset(
                'images/flower.jpg',
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 20,),
          Text(
            label,
            style: const TextStyle(fontSize: 20, color: Colors.black),
          )
        ],
      ),
    );
  }
}
