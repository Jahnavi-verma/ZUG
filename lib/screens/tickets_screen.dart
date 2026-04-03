import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TicketsScreen extends StatefulWidget {
  const TicketsScreen({super.key});

  @override
  State<TicketsScreen> createState() => _TicketsScreenState();
}

class _TicketsScreenState extends State<TicketsScreen> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  List<Map<String, dynamic>> _fraudLogs = [];

  @override
  void initState() {
    super.initState();
    _fetchFraudLogs();
  }

  Future<void> _fetchFraudLogs() async {
    try {
      final data = await _supabase
          .from('fraud_logs')
          .select()
          .order('detected_at', ascending: false);
      
      setState(() {
        _fraudLogs = List<Map<String, dynamic>>.from(data);
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching fraud logs: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const themeColor = Colors.indigo;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xfff5f7fa),
      appBar: AppBar(
        title: const Text('Fraud Detection Review'),
        backgroundColor: themeColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _isLoading = true);
              _fetchFraudLogs();
            },
          )
        ],
      ),
      body: _fraudLogs.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline_rounded, size: 100, color: Colors.green.shade400),
                  const SizedBox(height: 24),
                  const Text(
                    'Well done!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your good to go...',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _fraudLogs.length,
              itemBuilder: (context, index) {
                final log = _fraudLogs[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Log #${log['id']}',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 14),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                (log['status'] ?? 'PENDING').toUpperCase(),
                                style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          log['alert_type'] ?? 'Unknown Anomaly',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Detected on: ${log['detected_at']}',
                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                        if (log['fraud_score'] != null) ...[
                          const SizedBox(height: 12),
                          LinearProgressIndicator(
                            value: log['fraud_score'],
                            backgroundColor: Colors.grey.shade200,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 4),
                          Text('Risk Score: ${(log['fraud_score'] * 100).toStringAsFixed(0)}%', 
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.red)),
                        ]
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
