import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TicketsScreen extends StatefulWidget {
  const TicketsScreen({super.key});

  @override
  State<TicketsScreen> createState() => _TicketsScreenState();
}

class _TicketsScreenState extends State<TicketsScreen> {
  final _supabase = Supabase.instance.client;
  final _storage = const FlutterSecureStorage();
  bool _isLoading = true;
  List<Map<String, dynamic>> _claims = [];

  @override
  void initState() {
    super.initState();
    _fetchFraudulentClaims();
  }

  Future<void> _fetchFraudulentClaims() async {
    try {
      final workerIdStr = await _storage.read(key: 'worker_id');
      if (workerIdStr == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }
      final int workerId = int.parse(workerIdStr);

      // Fetch only fraudulent claims from the claims table
      final data = await _supabase
          .from('claims')
          .select()
          .eq('worker_id', workerId)
          .eq('is_fraudulent', true);
      
      debugPrint('TicketsScreen: Fetched ${data.length} fraudulent claims for worker $workerId');

      if (mounted) {
        setState(() {
          _claims = List<Map<String, dynamic>>.from(data);
          
          // Safer local sorting using created_at
          _claims.sort((a, b) {
            String dateA = a['created_at'] ?? '';
            String dateB = b['created_at'] ?? '';
            return dateB.compareTo(dateA);
          });
          
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching fraudulent claims: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const themeColor = Colors.indigo;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: themeColor)),
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
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              setState(() => _isLoading = true);
              _fetchFraudulentClaims();
            },
          )
        ],
      ),
      body: _claims.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline_rounded, size: 100, color: Colors.green.shade400),
                  const SizedBox(height: 24),
                  const Text(
                    'All Clear!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No fraudulent claims found for your account.',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {
                      setState(() => _isLoading = true);
                      _fetchFraudulentClaims();
                    },
                    child: const Text('Refresh Data'),
                  )
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _fetchFraudulentClaims,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _claims.length,
                itemBuilder: (context, index) {
                  final claim = _claims[index];
                  final displayDate = (claim['created_at'] ?? 'Unknown Date').toString().split('T')[0];
                  
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
                                'Claim #${claim['id']}',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 14),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'FLAGGED',
                                  style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Reason: ${claim['trigger_type'] ?? 'Stationary Anomaly'}',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Created: $displayDate',
                            style: const TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                          const SizedBox(height: 16),
                          const Row(
                            children: [
                              Icon(Icons.gpp_maybe_rounded, color: Colors.orange, size: 16),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'This claim is under review due to stationary sensor data.',
                                  style: TextStyle(fontSize: 12, color: Colors.orange, fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
