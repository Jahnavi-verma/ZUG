import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {
  // Use localhost for Web, and 10.0.2.2 for Android Emulator
  static const baseUrl = kIsWeb ? "http://127.0.0.1:8000" : "http://10.0.2.2:8000";

  static Future<Map<String, dynamic>> predictRisk() async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/predict-risk"),
        headers: {"Content-Type": "application/json"},
      ).timeout(const Duration(seconds: 5)); // Add 5 second timeout

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to load risk prediction");
      }
    } catch (e) {
      debugPrint("ApiService Error: $e");
      // Return a default mock value on failure so the dashboard can load
      return {
        "risk_score": 0.1,
        "premium": 150,
        "coverage": 3000,
        "trigger": null,
        "details": {
          "weather": {"current": {"temp": 25, "rain": 0}},
          "traffic": {"current": 0.3}
        }
      };
    }
  }
}
