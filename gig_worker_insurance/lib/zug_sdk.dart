import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
<<<<<<< HEAD
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
=======
>>>>>>> 15e8268 (ML upgraded+payout normalised)
import 'screens/onboarding_screen.dart';
import 'services/api_service.dart';


/// Allows the host app to provide its own Supabase and Python backend credentials.
>>>>>>> 15e8268 (ML upgraded+payout normalised)
class ZUGConfig {
  final String supabaseUrl;
  final String supabaseAnonKey;
  final String pythonBackendUrl;

  ZUGConfig({
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    required this.pythonBackendUrl,
  });
}

/// The main entry point for the ZUG SDK.
class ZUG {
  static final ZUG _instance = ZUG._internal();
  factory ZUG() => _instance;
  ZUG._internal();

  static ZUGConfig? _config;
<<<<<<< HEAD
  
  /// Global notifier for the user's name to ensure UI consistency across screens.
  static final ValueNotifier<String> userName = ValueNotifier("Rahul");
=======
>>>>>>> 15e8268 (ML upgraded+payout normalised)

  /// Initializes the ZUG SDK with the provided configuration.
  static Future<void> initialize(ZUGConfig config) async {
    _config = config;
    
<<<<<<< HEAD
    // Initialize Supabase
=======
    // Initialize Supabase with provided credentials
>>>>>>> 15e8268 (ML upgraded+payout normalised)
    await Supabase.initialize(
      url: config.supabaseUrl,
      anonKey: config.supabaseAnonKey,
    );

    // Inject the Python backend URL into the ApiService
    ApiService.setBaseUrl(config.pythonBackendUrl);

<<<<<<< HEAD
    // Load name from storage if available
    const storage = FlutterSecureStorage();
    final storedName = await storage.read(key: 'user_name');
    if (storedName != null) {
      userName.value = storedName;
    }

    debugPrint("✅ ZUG SDK: Initialized and Name Loaded: ${userName.value}");
  }

  /// Launches the ZUG Insurance UI module.
=======
    debugPrint("✅ ZUG SDK: Initialized with custom configuration");
  }

  /// Launches the ZUG Insurance UI module (Onboarding -> Login -> Dashboard).
>>>>>>> 15e8268 (ML upgraded+payout normalised)
  static void launch(BuildContext context) {
    if (_config == null) {
      throw Exception("ZUG SDK must be initialized before calling launch().");
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const OnboardingPage1()),
    );
  }

<<<<<<< HEAD
=======
  /// Public accessor for the configuration (internal use mostly)
>>>>>>> 15e8268 (ML upgraded+payout normalised)
  static ZUGConfig? get config => _config;
}
