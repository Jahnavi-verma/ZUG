import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TelemetryData {
  final DateTime timestamp;
  final double ax, ay, az; // Accelerometer
  final double mx, my, mz; // Magnetometer
  final double latitude, longitude;
  final double magnitude;

  TelemetryData({
    required this.timestamp,
    required this.ax,
    required this.ay,
    required this.az,
    required this.mx,
    required this.my,
    required this.mz,
    required this.latitude,
    required this.longitude,
  }) : magnitude = sqrt(ax * ax + ay * ay + az * az);

  Map<String, dynamic> toJson() => {
        't': timestamp.toIso8601String(),
        'acc': {'x': ax, 'y': ay, 'z': az, 'mag': magnitude},
        'mag': {'x': mx, 'y': my, 'z': mz},
        'loc': {'lat': latitude, 'lng': longitude},
      };
}

class TelemetryService {
  static final TelemetryService _instance = TelemetryService._internal();
  factory TelemetryService() => _instance;
  TelemetryService._internal();

  final List<TelemetryData> _buffer = [];
  final int _bufferLimitMinutes = 10;
  
  StreamSubscription? _accelSubscription;
  StreamSubscription? _magSubscription;
  Position? _currentPosition;
  
  double _lastAx = 0, _lastAy = 0, _lastAz = 0;
  double _lastMx = 0, _lastMy = 0, _lastMz = 0;

  final _supabase = Supabase.instance.client;
  final _storage = const FlutterSecureStorage();

  void startTracking() {
    // 1. Accelerometer Tracking
    _accelSubscription = accelerometerEventStream().listen((AccelerometerEvent event) {
      _lastAx = event.x;
      _lastAy = event.y;
      _lastAz = event.z;
      _updateBuffer();
    });

    // 2. Magnetometer Tracking
    _magSubscription = magnetometerEventStream().listen((MagnetometerEvent event) {
      _lastMx = event.x;
      _lastMy = event.y;
      _lastMz = event.z;
    });

    // 3. Location Tracking
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      _currentPosition = position;
    });
  }

  void _updateBuffer() {
    final now = DateTime.now();
    _buffer.add(TelemetryData(
      timestamp: now,
      ax: _lastAx,
      ay: _lastAy,
      az: _lastAz,
      mx: _lastMx,
      my: _lastMy,
      mz: _lastMz,
      latitude: _currentPosition?.latitude ?? 0.0,
      longitude: _currentPosition?.longitude ?? 0.0,
    ));

    // Maintain sliding window
    _buffer.removeWhere((data) =>
        now.difference(data.timestamp).inMinutes >= _bufferLimitMinutes);
    
    // Auto-analysis for trigger (Optional: can be called manually)
    _checkTriggerConditions();
  }

  /// Evaluates the buffer against your specific hardware thresholds
  bool isTravelingOnBike() {
    if (_buffer.length < 10) return false;

    // Get the last 5 seconds of data
    final recent = _buffer.where((d) => 
      DateTime.now().difference(d.timestamp).inSeconds <= 5).toList();
    
    if (recent.isEmpty) return false;

    // 1. Acceleration Magnitude Analysis
    double avgMag = recent.map((e) => e.magnitude).reduce((a, b) => a + b) / recent.length;
    
    // 2. Variance Analysis
    double variance = 0;
    for (var d in recent) {
      variance += pow(d.magnitude - avgMag, 2);
    }
    variance /= recent.length;

    // 3. Magnetic Change Analysis (Total flux change)
    double magChange = (recent.first.mx - recent.last.mx).abs() + 
                       (recent.first.my - recent.last.my).abs() + 
                       (recent.first.mz - recent.last.mz).abs();

    // Logic based on your table:
    // Traveling: Mag 10.5-15.0, Variance > 0.5, MagChange > 10.0
    bool traveling = avgMag > 10.5 && variance > 0.5 && magChange > 10.0;
    
    return traveling;
  }

  void _checkTriggerConditions() {
    // If a sudden severe "Disturbance" is detected, trigger claim
    // Example: Sudden impact (Magnitude > 25)
    final lastData = _buffer.last;
    if (lastData.magnitude > 25.0) {
      triggerClaim("Physical Disturbance / Road Impact");
    }
  }

  Future<void> triggerClaim(String triggerType) async {
    try {
      final workerIdStr = await _storage.read(key: 'worker_id');
      if (workerIdStr == null) return;
      final int workerId = int.parse(workerIdStr);

      // Create the claim immediately in Supabase
      final claimRes = await _supabase.from('claims').insert({
        'worker_id': workerId,
        'trigger_type': triggerType,
        'is_paid': false,
        'is_fraudulent': !isTravelingOnBike(), // Flag as suspicious if stationary
      }).select().single();

      final int claimId = claimRes['id'];
      final DateTime triggerTime = DateTime.now();

      // Wait 5 minutes to capture the "After" window, then upload full evidence
      Timer(const Duration(minutes: 5), () => _uploadEvidence(claimId, triggerTime));

    } catch (e) {
      print("Claim Trigger Error: $e");
    }
  }

  Future<void> _uploadEvidence(int claimId, DateTime triggerTime) async {
    try {
      final workerIdStr = await _storage.read(key: 'worker_id');
      if (workerIdStr == null) return;

      // Extract 10-minute snapshot: 5m before to 5m after
      final snapshot = _buffer.where((data) {
        final diff = data.timestamp.difference(triggerTime).inMinutes;
        return diff >= -5 && diff <= 5;
      }).map((e) => e.toJson()).toList();

      await _supabase.from('claim_evidence').insert({
        'claim_id': claimId,
        'worker_id': int.parse(workerIdStr),
        'sensor_snapshot': snapshot,
        'vibration_score': _calculateVibrationScore(triggerTime),
        'is_suspicious': !isTravelingOnBike(),
        'uploaded_at': DateTime.now().toIso8601String(),
      });

      print("Evidence Sync Complete for claim #$claimId");
    } catch (e) {
      print("Evidence Upload Error: $e");
    }
  }

  double _calculateVibrationScore(DateTime triggerTime) {
    final relevant = _buffer.where((d) => 
      d.timestamp.difference(triggerTime).inSeconds.abs() <= 30);
    if (relevant.isEmpty) return 0.0;
    return relevant.map((e) => e.magnitude).reduce(max);
  }

  void stopTracking() {
    _accelSubscription?.cancel();
    _magSubscription?.cancel();
  }
}
