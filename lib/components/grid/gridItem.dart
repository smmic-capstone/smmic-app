import 'package:flutter/material.dart';

class GridItem extends StatelessWidget {
  final Color color;
  final String text;
  final BoxDecoration? decoration;
  final String imagePath;

  GridItem({
    required this.text,
    required this.color,
    required this.imagePath,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: decoration ??
          BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 6))
              ]),
      margin: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            imagePath,
            height: 50,
            width: 50,
          ),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
