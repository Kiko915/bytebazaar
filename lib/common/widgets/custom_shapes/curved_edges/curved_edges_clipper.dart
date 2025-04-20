import 'package:flutter/material.dart';

class BHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    // Start from bottom-left, go up, curve across the top-right area (conceptually),
    // then curve down to the bottom-right, and close path.
    // We actually draw the visible part.
    path.lineTo(0, size.height); // Move to bottom-left

    // Define control points for the curve
    final firstControlPoint = Offset(0, size.height - 30); // Control point near bottom-left
    final firstEndPoint = Offset(30, size.height - 30); // End point of first small curve
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy, firstEndPoint.dx, firstEndPoint.dy);

    // Straight line across the bottom curved section
    path.lineTo(size.width - 30, size.height - 30);

    // Define control points for the second curve (mirror of the first)
    final secondControlPoint = Offset(size.width, size.height - 30); // Control point near bottom-right
    final secondEndPoint = Offset(size.width, size.height); // End point at bottom-right
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy, secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, 0); // Move to top-right
    path.close(); // Close path back to top-left (implicitly)
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true; // Reclip always for simplicity, optimize if needed
  }
}
