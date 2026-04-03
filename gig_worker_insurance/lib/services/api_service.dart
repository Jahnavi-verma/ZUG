import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {
  // Use your Mac's network IP: 10.210.29.152
  static const _macIp = "10.210.29.152";

  static const baseUrl = kIsWeb ? "http://127.0.0.1:8000" : "http://$_macIp:8000";

  static Future<Map<String, dynamic>> predictRisk() async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/predict-risk"),
        headers: {"Content-Type": "application/json"},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Ensure premium never exceeds 50
        if (data['premium'] != null && data['premium'] > 50) {
          data['premium'] = 50;
        }
        
        return data;
      } else {
        throw Exception("Server error: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("ApiService Error: $e");
      // Safety Fallback with max premium cap of 50
      return {
        "risk_score": 0.05,
        "premium": 50,
        "coverage": 1000,
        "trigger": null,
        "fraud": false,
        "payout": 0,
        "details": {
          "weather": {"current": {"temp": 25, "rain": 0}},
          "traffic": {"current": 0.3},
          "rto": {"today": 0, "mode": 0}
        }
      };
    }
  }
}
