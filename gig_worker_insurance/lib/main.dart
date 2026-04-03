import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Load environment variables for Supabase
    await dotenv.load(fileName: ".env");

    await Supabase.initialize(
      url: dotenv.get('SUPABASE_URL'),
      anonKey: dotenv.get('SUPABASE_ANON_KEY'),
    );
  } catch (e) {
    debugPrint("Configuration Error: $e");
  }

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
