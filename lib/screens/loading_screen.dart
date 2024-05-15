import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dart:ui' as ui;

import 'package:lottie/lottie.dart';

class LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Stack(
          children: [
            // Background frosted glass effect
            Container(
              color: Colors.black.withOpacity(0), // Adjust opacity as needed
            ),
            // Centered Lottie animation
            Center(
              child: Container(
                width: 200, // Adjust width as needed
                height: 200, // Adjust height as needed
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .withOpacity(0), // Adjust opacity as needed
                      blurRadius: 10,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Lottie.asset(
                    'assets/animations/loading.json', // Replace with your Lottie animation file path
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
