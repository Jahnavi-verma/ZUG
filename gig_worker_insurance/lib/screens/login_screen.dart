import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  int _currentStep = 1; // 1: e-Shram, 2: SMS Phone, 3: OTP
  final _storage = const FlutterSecureStorage();
  final _auth = LocalAuthentication();

  final _eshramController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  bool _isLoading = false;
  String? _hashedId;

  Future<void> _handleEShramSubmit() async {
    if (_eshramController.text.isEmpty) return;

    // Step 1: Hash the ID
    final bytes = utf8.encode(_eshramController.text);
    _hashedId = sha256.convert(bytes).toString();
    debugPrint('Hashed e-Shram ID: $_hashedId');

    // Step 2: 14-Day Logic
    final lastSmsStr = await _storage.read(key: 'last_sms_date');
    bool useBiometrics = false;

    if (lastSmsStr != null) {
      final lastSmsDate = DateTime.parse(lastSmsStr);
      final difference = DateTime.now().difference(lastSmsDate).inDays;
      if (difference < 14) {
        useBiometrics = true;
      }
    }

    if (useBiometrics) {
      final didAuthenticate = await _auth.authenticate(
        localizedReason: 'Please authenticate to login',
        options: const AuthenticationOptions(biometricOnly: true),
      );

      if (didAuthenticate) {
        _navigateToHome();
        return;
      }
    }

    // If no biometrics or failed/older than 14 days, go to Step 3 (SMS)
    setState(() {
      _currentStep = 2;
    });
  }

  Future<void> _sendOtp() async {
    if (_phoneController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    // Mock 2-second delay
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
      _currentStep = 3;
    });
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text == '123456') {
      // Update last_sms_date
      await _storage.write(
        key: 'last_sms_date',
        value: DateTime.now().toIso8601String(),
      );
      _navigateToHome();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid OTP. Use 123456')),
      );
    }
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f7fa),
      appBar: AppBar(
        title: const Text('Secure Login'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.indigo,
        leading: _currentStep > 1
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    if (_currentStep == 3) {
                      _currentStep = 2;
                    } else {
                      _currentStep = 1;
                    }
                  });
                },
              )
            : null,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
        const Text(
          'Step 1: e-Shram Verification',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _eshramController,
          decoration: InputDecoration(
            labelText: 'e-Shram ID',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 24),
        ElevatedButton(
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
        const Text(
          'Step 2: SMS Verification',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _phoneController,
          decoration: InputDecoration(
            labelText: 'Phone Number',
            filled: true,
            fillColor: Colors.white,
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
        const Text(
          'Enter OTP',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text('Sent to ${_phoneController.text}'),
        const SizedBox(height: 24),
        TextField(
          controller: _otpController,
          decoration: InputDecoration(
            labelText: '6-digit OTP',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          ),
          keyboardType: TextInputType.number,
          maxLength: 6,
        ),
        const SizedBox(height: 24),
        ElevatedButton(
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
