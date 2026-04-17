import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'screens/onboarding_screen.dart';
import 'services/api_service.dart';

/// Configuration class for ZUG SDK.
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
  
  /// Global notifier for the user's name.
  static final ValueNotifier<String> userName = ValueNotifier("Rahul");

  /// Global notifier for premium status.
  static final ValueNotifier<bool> isPremiumActive = ValueNotifier(false);

  /// Initializes the ZUG SDK with the provided configuration.
  static Future<void> initialize(ZUGConfig config) async {
    _config = config;
    
    // Initialize Supabase
    await Supabase.initialize(
      url: config.supabaseUrl,
      anonKey: config.supabaseAnonKey,
    );

    // Inject the Python backend URL into the ApiService
    ApiService.setBaseUrl(config.pythonBackendUrl);

    const storage = FlutterSecureStorage();
    
    // Load name
    final storedName = await storage.read(key: 'user_name');
    if (storedName != null) {
      userName.value = storedName;
    }

    // Load premium status
    final premiumPaidAt = await storage.read(key: 'premium_paid_at');
    if (premiumPaidAt != null) {
      final paidAt = DateTime.parse(premiumPaidAt);
      if (DateTime.now().difference(paidAt).inDays < 7) {
        isPremiumActive.value = true;
      }
    }

    debugPrint("✅ ZUG SDK: Initialized. Name: ${userName.value}, Premium: ${isPremiumActive.value}");
  }

  /// Launches the ZUG Insurance UI module.
  static void launch(BuildContext context) {
    if (_config == null) {
      throw Exception("ZUG SDK must be initialized before calling launch().");
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const OnboardingPage1()),
    );
  }

  static ZUGConfig? get config => _config;
}
