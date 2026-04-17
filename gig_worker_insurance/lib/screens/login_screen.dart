import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:persistent_device_id/persistent_device_id.dart';
import '../services/telemetry_service.dart';
import 'dashboard_screen.dart';
import 'terms_conditions_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  int _currentStep = 1; // 1: e-Shram, 2: SMS Phone, 3: OTP
  final _storage = const FlutterSecureStorage();
  final _auth = LocalAuthentication();
  final _supabase = Supabase.instance.client;

  final _eshramController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  bool _isLoading = false;
  String? _hashedId;

  Future<void> _handleEShramSubmit() async {
    if (_eshramController.text.isEmpty) return;

    setState(() => _isLoading = true);

    final String plainId = _eshramController.text;
    final bytes = utf8.encode(plainId);
    _hashedId = sha256.convert(bytes).toString();

    try {
      final existingWorker = await _supabase
          .from('workers')
          .select()
          .eq('eshram_hash', _hashedId!)
          .maybeSingle();

      if (existingWorker != null) {
        await _storage.write(key: 'worker_id', value: existingWorker['id'].toString());
        await _storage.write(key: 'plain_eshram_id', value: plainId);

        final lastSmsStr = await _storage.read(key: 'last_sms_date');
        if (lastSmsStr != null) {
          final lastSmsDate = DateTime.parse(lastSmsStr);
          if (DateTime.now().difference(lastSmsDate).inDays < 14) {
            final didAuthenticate = await _auth.authenticate(
              localizedReason: 'Secure login via biometrics',
              options: const AuthenticationOptions(biometricOnly: true),
            );

            if (didAuthenticate) {
              TelemetryService().startTracking();
              
              bool termsAccepted = existingWorker['terms_accepted'] == true;
              if (!termsAccepted) {
                final localTerms = await _storage.read(key: 'terms_accepted');
                termsAccepted = localTerms == 'true';
              }

              if (mounted) {
                setState(() => _isLoading = false);
                _proceed(termsAccepted: termsAccepted);
                return;
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Supabase select error: $e');
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
        _currentStep = 2;
      });
    }
  }

  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) return;
    
    setState(() => _isLoading = true);
    try {
      await _supabase.auth.signInWithOtp(phone: phone);
      if (mounted) {
        setState(() {
          _currentStep = 3;
        });
      }
    } catch (e) {
      debugPrint('Error sending OTP: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to send OTP. Use E.164 format (+91...)')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();
    final phone = _phoneController.text.trim();
    if (otp.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final response = await _supabase.auth.verifyOTP(
        phone: phone,
        token: otp,
        type: OtpType.sms,
      );

      if (response.session != null) {
        await _onOtpSuccess();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid OTP')));
        }
      }
    } catch (e) {
      debugPrint('OTP Verification Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Verification failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _onOtpSuccess() async {
    bool? allowAccess = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Required'),
        content: const Text('Allow this app to access your persistent device ID?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Deny')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Allow')),
        ],
      ),
    );

    if (allowAccess != true) return;

    try {
      final bool didAuthenticate = await _auth.authenticate(
        localizedReason: 'Verify biometrics to link account',
        options: const AuthenticationOptions(biometricOnly: true, stickyAuth: true),
      );
      if (!didAuthenticate) return;
    } catch (e) {
      debugPrint('Biometric error: $e');
      return;
    }

    try {
      String deviceId;
      try {
        deviceId = await PersistentDeviceId.getDeviceId() ?? 'unknown_id';
      } catch (e) {
        deviceId = 'unknown_hw_id';
      }

      final response = await _supabase.from('workers').upsert({
        'eshram_hash': _hashedId,
        'device_id': deviceId,
        'last_biometric_at': DateTime.now().toIso8601String(),
        'is_trusted': true,
      }, onConflict: 'eshram_hash').select().single();

      await _storage.write(key: 'worker_id', value: response['id'].toString());
      await _storage.write(key: 'plain_eshram_id', value: _eshramController.text);
      await _storage.write(key: 'phone_number', value: _phoneController.text);
      await _storage.write(key: 'last_sms_date', value: DateTime.now().toIso8601String());

      TelemetryService().startTracking();

      bool termsAccepted = response['terms_accepted'] == true;
      if (!termsAccepted) {
        final localTerms = await _storage.read(key: 'terms_accepted');
        termsAccepted = localTerms == 'true';
      }

      _proceed(termsAccepted: termsAccepted);
    } catch (e) {
      debugPrint('Sync failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sync error: $e')));
      }
    }
  }

  void _proceed({required bool termsAccepted}) {
    if (mounted) {
      if (termsAccepted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainNavigationScreen()));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const TermsConditionsScreen()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f7fa),
      appBar: AppBar(
        title: Text(_currentStep == 1 ? 'e-Shram Login' : 'Verification'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              if (_currentStep == 1) _buildEShramStep(),
              if (_currentStep == 2) _buildPhoneStep(),
              if (_currentStep == 3) _buildOtpStep(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEShramStep() {
    return Column(
      children: [
        const Icon(Icons.badge_rounded, size: 80, color: Colors.indigo),
        const SizedBox(height: 32),
        const Text('Step 1: e-Shram Verification', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        TextField(
          controller: _eshramController, 
          decoration: InputDecoration(labelText: 'e-Shram ID', border: OutlineInputBorder(borderRadius: BorderRadius.circular(16))), 
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 24),
        _isLoading 
          ? const CircularProgressIndicator() 
          : ElevatedButton(
              onPressed: _handleEShramSubmit, 
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo, 
                foregroundColor: Colors.white, 
                minimumSize: const Size(double.infinity, 56), 
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ), 
              child: const Text('Continue'),
            ),
      ],
    );
  }

  Widget _buildPhoneStep() {
    return Column(
      children: [
        const Icon(Icons.phone_android_rounded, size: 80, color: Colors.indigo),
        const SizedBox(height: 32),
        const Text('Step 2: SMS Verification', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        TextField(
          controller: _phoneController, 
          decoration: InputDecoration(
            labelText: 'Phone Number (+91...)', 
            hintText: '+919876543210',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          ), 
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 24),
        _isLoading 
          ? const CircularProgressIndicator() 
          : ElevatedButton(
              onPressed: _sendOtp, 
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo, 
                foregroundColor: Colors.white, 
                minimumSize: const Size(double.infinity, 56), 
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ), 
              child: const Text('Send OTP'),
            ),
      ],
    );
  }

  Widget _buildOtpStep() {
    return Column(
      children: [
        const Icon(Icons.lock_person_rounded, size: 80, color: Colors.indigo),
        const SizedBox(height: 32),
        const Text('Enter 6-digit OTP', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        TextField(
          controller: _otpController, 
          decoration: InputDecoration(labelText: 'OTP', border: OutlineInputBorder(borderRadius: BorderRadius.circular(16))), 
          keyboardType: TextInputType.number, 
          maxLength: 6,
        ),
        const SizedBox(height: 24),
        _isLoading 
          ? const CircularProgressIndicator() 
          : ElevatedButton(
              onPressed: _verifyOtp, 
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo, 
                foregroundColor: Colors.white, 
                minimumSize: const Size(double.infinity, 56), 
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ), 
              child: const Text('Verify & Login'),
            ),
      ],
    );
  }
}
