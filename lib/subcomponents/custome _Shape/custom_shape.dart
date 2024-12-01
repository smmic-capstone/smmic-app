import 'package:flutter/material.dart';

class RightCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    // Start at the left-top corner of the circle
    path.moveTo(0, 0);

    // Add a curve at the top-center
    path.quadraticBezierTo(
      size.width / 2, // Control point (center of the width)
      -size.height * 0.2, // Move upward for the bump
      size.width, // End point at the top-right corner
      0, // Back to the original height
    );

    // Complete the circular shape
    path.addOval(Rect.fromLTWH(0, 0, size.width, size.height));
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
