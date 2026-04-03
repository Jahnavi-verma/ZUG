import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'telemetry_service.dart';

class SimulationService {
  static final SimulationService _instance = SimulationService._internal();
  factory SimulationService() => _instance;
  SimulationService._internal();

  final _supabase = Supabase.instance.client;
  final _storage = const FlutterSecureStorage();

  /// Simulates a VALID claim by ensuring telemetry reflects a "Traveling" state
  Future<void> simulateValidClaim(String triggerType) async {
    print("Simulating VALID claim for: $triggerType");
    
    // In a real simulation, we'd mock the isTravelingOnBike to return true
    // For this implementation, we directly trigger the claim with is_fraudulent = false
    await _triggerSimulatedClaim(triggerType, isFraudulent: false);
  }

  /// Simulates a FRAUDULENT claim by ensuring telemetry reflects a "Stationary" state
  Future<void> simulateFraudClaim(String triggerType) async {
    print("Simulating FRAUD claim for: $triggerType");
    
    // Directly trigger the claim with is_fraudulent = true
    await _triggerSimulatedClaim(triggerType, isFraudulent: true);
  }

  Future<void> _triggerSimulatedClaim(String triggerType, {required bool isFraudulent}) async {
    try {
      final workerIdStr = await _storage.read(key: 'worker_id');
      if (workerIdStr == null) throw Exception("No worker ID found. Please login.");
      final int workerId = int.parse(workerIdStr);

      // 1. Create the claim in Supabase
      final claimRes = await _supabase.from('claims').insert({
        'worker_id': workerId,
        'trigger_type': triggerType,
        'is_paid': false,
        'is_fraudulent': isFraudulent,
      }).select().single();

      final int claimId = claimRes['id'];
      final DateTime triggerTime = DateTime.now();

      // 2. If Fraudulent, immediately log it in fraud_logs for the manager
      if (isFraudulent) {
        await _supabase.from('fraud_logs').insert({
          'worker_id': workerId,
          'claim_id': claimId,
          'alert_type': 'Simulation: Stationary Trigger',
          'fraud_score': 0.95,
          'status': 'pending',
          'manager_notes': 'Automated flag: No movement telemetry detected during claim window.',
        });
      }

      // 3. Sync Telemetry Evidence (Mocking the 10-minute window upload)
      // For simulation, we'll upload the current buffer immediately
      await _uploadSimulatedEvidence(claimId, workerId, isFraudulent);

    } catch (e) {
      print("Simulation Error: $e");
      rethrow;
    }
  }

  Future<void> _uploadSimulatedEvidence(int claimId, int workerId, bool isFraudulent) async {
    final snapshot = TelemetryService().getBufferSnapshot();
    
    await _supabase.from('claim_evidence').insert({
      'claim_id': claimId,
      'worker_id': workerId,
      'sensor_snapshot': snapshot,
      'vibration_score': isFraudulent ? 9.8 : 12.5, // Stationary vs Traveling
      'is_suspicious': isFraudulent,
      'uploaded_at': DateTime.now().toIso8601String(),
    });
  }
}
