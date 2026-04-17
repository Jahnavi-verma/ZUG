import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {
  // Synchronized with latest Mac IP
  static String _baseUrl = "http://10.210.9.203:8000"; 

  static String get baseUrl => _baseUrl;

  static void setBaseUrl(String url) {
    _baseUrl = url;
    debugPrint("ApiService: Base URL updated to $_baseUrl");
  }

  static Future<Map<String, dynamic>> predictRisk() async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/predict-risk"),
        headers: {"Content-Type": "application/json"},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Server error: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("ApiService Error (Check if Python backend is running at $_baseUrl): $e");
      return {
        "risk_score": 0.05,
        "premium": 50,
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
