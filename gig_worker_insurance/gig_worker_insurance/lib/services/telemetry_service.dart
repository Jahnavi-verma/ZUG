import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TelemetryData {
  final DateTime timestamp;
  final double ax, ay, az;
  final double mx, my, mz;
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
  
  DateTime _lastSampleTime = DateTime.now();

  final _supabase = Supabase.instance.client;
  final _storage = const FlutterSecureStorage();

  void startTracking() {
    _accelSubscription = accelerometerEventStream().listen((AccelerometerEvent event) {
      _lastAx = event.x;
      _lastAy = event.y;
      _lastAz = event.z;
      
      if (DateTime.now().difference(_lastSampleTime).inSeconds >= 1) {
        _updateBuffer();
        _lastSampleTime = DateTime.now();
      }
    });

    _magSubscription = magnetometerEventStream().listen((MagnetometerEvent event) {
      _lastMx = event.x;
      _lastMy = event.y;
      _lastMz = event.z;
    });

    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 10),
    ).listen((Position position) {
      _currentPosition = position;
    });
  }

  void _updateBuffer() {
    final now = DateTime.now();
    _buffer.add(TelemetryData(
      timestamp: now,
      ax: _lastAx, ay: _lastAy, az: _lastAz,
      mx: _lastMx, my: _lastMy, mz: _lastMz,
      latitude: _currentPosition?.latitude ?? 0.0,
      longitude: _currentPosition?.longitude ?? 0.0,
    ));
    _buffer.removeWhere((data) => now.difference(data.timestamp).inMinutes >= _bufferLimitMinutes);
  }

  bool isTravelingOnBike() {
    if (_buffer.length < 5) return false;
    final recent = _buffer.where((d) => DateTime.now().difference(d.timestamp).inSeconds <= 10).toList();
    if (recent.isEmpty) return false;
    double avgMag = recent.map((e) => e.magnitude).reduce((a, b) => a + b) / recent.length;
    double variance = recent.map((d) => pow(d.magnitude - avgMag, 2)).reduce((a, b) => a + b) / recent.length;
    double magChange = (recent.first.mx - recent.last.mx).abs() + (recent.first.my - recent.last.my).abs() + (recent.first.mz - recent.last.mz).abs();
    return avgMag > 10.5 && variance > 0.5 && magChange > 10.0;
  }

  List<Map<String, dynamic>> getBufferSnapshot() {
    return _buffer.map((e) => e.toJson()).toList();
  }

  /// Triggers a claim. If [simulatedTime] is provided, it uses that for partitioning compatibility.
  Future<void> triggerClaim(String triggerType, {bool? forceFraud, DateTime? simulatedTime}) async {
    try {
      final workerIdStr = await _storage.read(key: 'worker_id');
      if (workerIdStr == null) return;
      final int workerId = int.parse(workerIdStr);

      bool fraudulent = forceFraud ?? !isTravelingOnBike();

      // Ensure triggerType fits VARCHAR(20)
      String safeTrigger = triggerType.length > 20 ? triggerType.substring(0, 20) : triggerType;
      
      // Use current time or simulated time
      final DateTime triggerTime = simulatedTime ?? DateTime.now();

      final claimRes = await _supabase.from('claims').insert({
        'worker_id': workerId,
        'trigger_type': safeTrigger,
        'is_paid': false,
        'is_fraudulent': fraudulent,
        'created_at': triggerTime.toIso8601String(), 
      }).select().single();

      final int claimId = claimRes['id'];
      
      // Simulation: upload evidence immediately if time is forced, otherwise use window
      if (simulatedTime != null) {
        await uploadEvidence(claimId, triggerTime, fraudulent);
      } else {
        Timer(const Duration(minutes: 5), () => uploadEvidence(claimId, triggerTime, fraudulent));
      }

    } catch (e) {
      print("Claim Trigger Error: $e");
    }
  }

  Future<void> uploadEvidence(int claimId, DateTime triggerTime, bool isFraudulent) async {
    try {
      final workerIdStr = await _storage.read(key: 'worker_id');
      if (workerIdStr == null) return;

      final snapshot = getBufferSnapshot();

      await _supabase.from('claim_evidence').insert({
        'claim_id': claimId,
        'worker_id': int.parse(workerIdStr),
        'sensor_snapshot': snapshot,
        'vibration_score': isFraudulent ? 9.8 : 12.5,
        'is_suspicious': isFraudulent,
        'uploaded_at': triggerTime.toIso8601String(),
      });

      if (isFraudulent) {
        await _supabase.from('fraud_logs').insert({
          'worker_id': int.parse(workerIdStr),
          'claim_id': claimId,
          'alert_type': 'Stationary Alert', // Shortened
          'fraud_score': 0.9,
          'status': 'pending',
        });
      }
    } catch (e) {
      print("Evidence Sync Error: $e");
    }
  }

  void stopTracking() {
    _accelSubscription?.cancel();
    _magSubscription?.cancel();
  }
}
