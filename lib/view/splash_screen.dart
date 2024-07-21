// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:gmniai/view/chat_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Call the navigation function after the widget has been built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      navigateTo();
    });
  }

  Future<void> navigateTo() async {
    await Future.delayed(const Duration(seconds: 2)); // Adjust delay as needed
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
            builder: (context) =>
                Chatscreen()), // Replace with your route or widget
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 55, 55, 55),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/Screenshot_2024-07-21_160227-removebg-preview.png', // Replace with your logo image path
                  width: 140, // Adjust width as needed
                ),
                const SizedBox(height: 20), // Adjust height as needed
                const Text(
                  'LumiConvo',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
