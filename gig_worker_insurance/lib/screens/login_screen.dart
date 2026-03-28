import 'package:flutter/material.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _idController = TextEditingController();
  final _otpController = TextEditingController();
  bool _isOtpSent = false;

  void _sendOtp() {
    if (_idController.text.isNotEmpty) {
      setState(() {
        _isOtpSent = true;
      });
    }
  }

  void _login() {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    }
  }

  void _verifyOtp() {
    if (_otpController.text.isNotEmpty) {
      _login();
    }
  }

  void _biometricAuth() {
    showModalBottomSheet<bool>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.fingerprint_rounded, size: 80, color: Colors.indigo),
              const SizedBox(height: 24),
              const Text(
                'Touch the fingerprint sensor',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, true); // Close bottom sheet and return true
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Simulate Scan Success', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              )
            ],
          ),
        );
      },
    ).then((success) {
      if (success == true) {
        _login(); // Triggers only after the bottomsheet has gracefully popped
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isOtpSent,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_isOtpSent) {
          setState(() {
            _isOtpSent = false;
            _otpController.clear();
          });
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xfff5f7fa),
        // Add a back button in the AppBar if OTP is sent, for excellent UX
        appBar: _isOtpSent
            ? AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.indigo),
                  onPressed: () {
                    setState(() {
                      _isOtpSent = false;
                      _otpController.clear();
                    });
                  },
                ),
              )
            : null,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              height:
                  MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  (_isOtpSent ? 56 : 0), // Adjust for appbar height
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.security_rounded,
                      size: 80,
                      color: Colors.indigo,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Gig Worker Insurance',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: Colors.black87,
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Secure your daily income instantly.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 48),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        if (!_isOtpSent) ...[
                          TextField(
                            key: const ValueKey('id_field'), // Fixes element retention glitch
                            controller: _idController,
                            decoration: InputDecoration(
                              labelText: 'e-Shram ID / Phone',
                              labelStyle: TextStyle(color: Colors.grey.shade600),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon: const Icon(
                                Icons.badge_rounded,
                                color: Colors.indigo,
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 20,
                                horizontal: 20,
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            onSubmitted: (_) => _sendOtp(),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _sendOtp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 56),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: const Text('Send OTP', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              const Expanded(child: Divider()),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text('OR', style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.bold)),
                              ),
                              const Expanded(child: Divider()),
                            ],
                          ),
                          const SizedBox(height: 24),
                          OutlinedButton.icon(
                            onPressed: _biometricAuth,
                            icon: const Icon(Icons.fingerprint_rounded, size: 28),
                            label: const Text('Login with Fingerprint', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.indigo,
                              side: const BorderSide(color: Colors.indigo, width: 1.5),
                              minimumSize: const Size(double.infinity, 56),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ] else ...[
                          TextField(
                            key: const ValueKey('otp_field'), // Fixes element retention glitch
                            controller: _otpController,
                            decoration: InputDecoration(
                              labelText: 'Enter 6-digit OTP',
                              labelStyle: TextStyle(color: Colors.grey.shade600),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon: const Icon(Icons.password_rounded, color: Colors.indigo),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                            ),
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            onSubmitted: (_) => _verifyOtp(),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _verifyOtp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 56),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 0,
                            ),
                            child: const Text('Verify & Login', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isOtpSent = false;
                                _otpController.clear();
                              });
                            },
                            child: const Text('Edit Phone Number/ID', style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'Protected by modern parametric insurance protocols.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black38, fontSize: 13),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}