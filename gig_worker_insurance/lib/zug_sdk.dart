import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/onboarding_screen.dart';
import 'services/api_service.dart';

/// Configuration class for ZUG SDK.
/// Allows the host app to provide its own Supabase and Python backend credentials.
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

  /// Initializes the ZUG SDK with the provided configuration.
  static Future<void> initialize(ZUGConfig config) async {
    _config = config;
    
    // Initialize Supabase with provided credentials
    await Supabase.initialize(
      url: config.supabaseUrl,
      anonKey: config.supabaseAnonKey,
    );

    // Inject the Python backend URL into the ApiService
    ApiService.setBaseUrl(config.pythonBackendUrl);

    debugPrint("✅ ZUG SDK: Initialized with custom configuration");
  }

  /// Launches the ZUG Insurance UI module (Onboarding -> Login -> Dashboard).
  static void launch(BuildContext context) {
    if (_config == null) {
      throw Exception("ZUG SDK must be initialized before calling launch().");
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const OnboardingPage1()),
    );
  }

  /// Public accessor for the configuration (internal use mostly)
  static ZUGConfig? get config => _config;
}
