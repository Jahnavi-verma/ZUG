import 'telemetry_service.dart';

class ValidClaimSimulator {
  /// Simulates a claim where the worker is actively traveling on a bike.
  /// Hardcodes the date to Oct 2024 to match your database partition.
  static Future<void> run() async {
    print("🚀 Starting Valid Claim Simulation...");
    await TelemetryService().triggerClaim(
      "Simulated Rain", 
      forceFraud: false,
      simulatedTime: DateTime(2024, 10, 15, 12, 0, 0),
    );
  }
}
