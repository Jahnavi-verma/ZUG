import 'package:flutter/material.dart';
import 'screens/onboarding_screen.dart';

void main() {
  runApp(const GigWorkerApp());
}

class GigWorkerApp extends StatelessWidget {
  const GigWorkerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gig Worker Insurance',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xfff5f5f5),
      ),
      home: const OnboardingPage1(),
    );
  }
}