import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {
  static String _baseUrl = "http://10.210.29.152:8000"; // Default fallback

  /// Allows the SDK to set the backend URL dynamically during initialization.
  static void setBaseUrl(String url) {
    _baseUrl = url;
  }

  static Future<Map<String, dynamic>> predictRisk() async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/predict-risk"),
        headers: {"Content-Type": "application/json"},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Server error: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("ApiService Error: $e");
      // Safety Fallback so dashboard doesn't crash
      return {
        "risk_score": 0.05,
        "premium": 50,
        "coverage": 1000,
        "trigger": null,
        "fraud": false,
        "payout": 0,
        "details": {
          "weather": {"current": {"temp": 25.0, "rain": 0.0}},
          "traffic": {"current": 0.3},
          "rto": {"today": 0, "mode": 0}
        }
      };
    }
  }
}
