import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {
  // Use localhost for Web, and 10.0.2.2 for Android Emulator
  static const baseUrl = kIsWeb ? "http://127.0.0.1:8000" : "http://10.0.2.2:8000";

  static Future<Map<String, dynamic>> getRisk() async {
    final response = await http.post(
      Uri.parse("$baseUrl/predict-risk"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "zone_rto_rate": 0.3,
        "rain": 0.8,
        "traffic": 0.6,
        "time_of_day": 18,
        "past_claims": 2
      }),
    );

    return jsonDecode(response.body);
  }
}