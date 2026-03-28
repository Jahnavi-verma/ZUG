import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'claim_result_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  double riskScore = 0.0;
  int premium = 0;
  int coverage = 0;

  @override
  void initState() {
    super.initState();
    _refreshRisk();
  }

  void _refreshRisk() async {
    try {
      final data = await ApiService.getRisk();

      setState(() {
        riskScore = data["risk_score"] ?? 0.0;
        premium = data["premium"] ?? 0;
        coverage = data["coverage"] ?? (premium * 20);
      });
    } catch (e) {
      debugPrint("API error: $e");
    }
  }

  void _simulateDisruption() {
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ClaimResultScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Color riskColor = riskScore < 0.5
        ? Colors.green.shade600
        : Colors.orange.shade700;

    String riskLabel = riskScore < 0.5
        ? 'Low Risk'
        : (riskScore > 0.8 ? 'High Risk' : 'Medium Risk');

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      backgroundColor: const Color(0xfff5f7fa),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 24,
                left: 24.0,
                right: 24.0,
                bottom: 80.0,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.indigo, Color(0xFF3F51B5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Hello, Rahul',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Policy Status: Active',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.person, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Content Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 50),

                  // Risk Card
                  Card(
                    elevation: 12,
                    shadowColor: Colors.black12,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Risk Profile',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      color: Colors.black87,
                                    ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: riskColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  riskLabel,
                                  style: TextStyle(
                                    color: riskColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildStatBox(
                                'Score',
                                riskScore.toString(),
                                Icons.speed_rounded,
                                riskColor,
                              ),
                              _buildStatBox(
                                'Premium',
                                '₹$premium',
                                Icons.payments_rounded,
                                Colors.indigo,
                                subText: '/wk',
                              ),
                              _buildStatBox(
                                'Coverage',
                                '₹$coverage',
                                Icons.security_rounded,
                                Colors.indigo,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _refreshRisk,
                          icon: const Icon(Icons.refresh_rounded, size: 20),
                          label: const Text(
                            'Refresh Risk',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.indigo,
                            backgroundColor: Colors.white,
                            side: const BorderSide(
                              color: Colors.indigo,
                              width: 1.5,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  ElevatedButton.icon(
                    onPressed: _simulateDisruption,
                    icon: const Icon(
                      Icons.warning_amber_rounded,
                      size: 22,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Simulate Disruption',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade600,
                      minimumSize: const Size(double.infinity, 64),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 8,
                      shadowColor: Colors.orange.shade300,
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox(
    String label,
    String value,
    IconData icon,
    Color color, {
    String subText = '',
  }) {
    return Column(
      children: [
        Icon(icon, color: color.withValues(alpha: 0.8), size: 28),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Colors.black87,
                letterSpacing: -0.5,
              ),
            ),
            if (subText.isNotEmpty)
              Text(
                subText,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
