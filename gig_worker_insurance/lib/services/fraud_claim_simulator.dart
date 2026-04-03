import 'telemetry_service.dart';

class FraudClaimSimulator {
  /// Simulates a fraudulent claim where the worker is stationary.
  /// Hardcodes the date to Oct 2024 to match your database partition.
  static Future<void> run() async {
    print("🚩 Starting Fraud Claim Simulation (Stationary)...");
    await TelemetryService().triggerClaim(
      "Stationary Spoof", 
      forceFraud: true,
      simulatedTime: DateTime(2024, 10, 15, 14, 0, 0),
    );
  }
}
