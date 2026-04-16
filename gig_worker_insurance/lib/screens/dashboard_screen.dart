import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/api_service.dart';
import '../services/valid_claim_simulator.dart';
import '../services/fraud_claim_simulator.dart';
import '../services/api_service.dart';
import '../services/valid_claim_simulator.dart';
import '../services/fraud_claim_simulator.dart';
import '../zug_sdk.dart';
import 'tickets_screen.dart';
import 'profile_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _supabase = Supabase.instance.client;
  late Razorpay _razorpay;
  final _storage = const FlutterSecureStorage();
  
  bool _isLoading = true;
  String _workerName = "Rahul";
  bool _hasBoughtPremium = false;

  int _totalPayoutAccumulated = 0;

  // Real-time data metrics from Supabase from Supabase
  String _disturbancesCount = '0';
  String _amountPaidCount = '₹0';
  String _claimsCount = '0';
  String _fraudsCount = '0';
  List<Map<String, dynamic>> _recentActivity = [];

  // Data from Python Backend
  int _calculatedPremium = 150;
  String? _backendTrigger;
  Map<String, dynamic> _weather = {};
  double _traffic = 0.0;
  bool _fraudAlert = false;
  int _potentialPayout = 0;
  int _rtoToday = 0;
  int _rtoMode = 0;

  // Data from Python Backend
  int _calculatedPremium = 150;
  String? _backendTrigger;
  Map<String, dynamic> _weather = {};
  double _traffic = 0.0;
  bool _fraudAlert = false;
  int _potentialPayout = 0;
  int _rtoToday = 0;
  int _rtoMode = 0;

  @override
void initState() {
  super.initState();

  // Razorpay init
  _razorpay = Razorpay();
  _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
  _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
  _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

  _checkPremiumStatus();

  // Your existing logic
  _refreshDashboard();
}

Future<void> startPayment() async {
  try {
    final response = await http.post(
      Uri.parse("http://127.0.0.1:8000/create-order"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "weekly_income": 5000,
        "bracket": "B",
        "premium": _calculatedPremium   // ✅ IMPORTANT
      }),
    );

    if (response.statusCode != 200) {
      print("❌ ORDER ERROR: ${response.body}");
      return;
    }

    final data = jsonDecode(response.body);
    print("✅ ORDER CREATED: $data");

    openCheckout(data);

  } catch (e) {
    print("❌ PAYMENT INIT ERROR: $e");
  }
}

Future<void> _checkPremiumStatus() async {
  final value = await _storage.read(key: "premium_paid_at");

  if (value != null) {
    final paidAt = DateTime.parse(value);
    final now = DateTime.now();

    if (now.difference(paidAt).inDays < 7) {
      setState(() {
        _hasBoughtPremium = true;
      });
    } else {
      await _storage.delete(key: "premium_paid_at");
      await _storage.delete(key: "total_payout"); // ✅ ADD
      _totalPayoutAccumulated = 0;                // ✅ ADD

      setState(() {
        _hasBoughtPremium = false;
      });
    }
  }

  // ✅ LOAD PAYOUT
  final payout = await _storage.read(key: "total_payout");
  if (payout != null) {
    _totalPayoutAccumulated = int.parse(payout);
  }
}

void openCheckout(dynamic data) {
  var options = {
    'key': 'rzp_test_SdHevaeLdpy7Ym',   // ✅ your test key
    'amount': data['amount_paise'],
    'order_id': data['order_id'],
    'name': 'ZUG',
    'description': 'Insurance Payment',

    'prefill': {
      'contact': '9999999999',
      'email': 'test@zug.com'
    },

    'theme': {
      'color': '#3F51B5'
    }
  };

  try {
    _razorpay.open(options);
  } catch (e) {
    print("❌ RAZORPAY ERROR: $e");
  }
}


void _handlePaymentSuccess(PaymentSuccessResponse response) async {
  print("SUCCESS ORDER: ${response.orderId}");
  print("SUCCESS PAYMENT: ${response.paymentId}");
  print("SIGNATURE: ${response.signature}");

   await http.post(
  Uri.parse("http://127.0.0.1:8000/verify-payment"),
  headers: {"Content-Type": "application/json"},
  body: jsonEncode({
    "order_id": response.orderId,
    "payment_id": response.paymentId,
    "signature": response.signature
  }),
);

setState(() {
  _hasBoughtPremium = true;
});

await _storage.write(
  key: "premium_paid_at",
  value: DateTime.now().toIso8601String(),
);

} // ✅ ADD THIS LINE

void _handlePaymentError(PaymentFailureResponse response) {
  print("❌ PAYMENT FAILED: ${response.message}");
}


void _handleExternalWallet(ExternalWalletResponse response) {
  print("Wallet: ${response.walletName}");
}


  Future<void> _refreshDashboard() async {
    setState(() => _isLoading = true);
    await Future.wait([
      _fetchRealDashboardData(),
      _fetchBackendAnalysis(),
    ]);
    setState(() => _isLoading = false);
  }

  Future<void> _fetchBackendAnalysis() async {
    try {
      final data = await ApiService.predictRisk();
      if (mounted) {
        setState(() {
          // Robust parsing with null-safety
          _calculatedPremium = (data['premium'] ?? 150) as int;
          _backendTrigger = data['trigger'];
          
          final details = data['details'] ?? {};
          _weather = details['weather']?['current'] ?? {};
          
          final trafficData = details['traffic'] ?? {};
          _traffic = (trafficData['current'] ?? 0.0).toDouble();
          
          _fraudAlert = data['fraud'] ?? false;
         
         final newPayout = (data['payout'] ?? 0).toInt();

final maxLimit = _calculatedPremium * 2;

if (_hasBoughtPremium && _totalPayoutAccumulated < maxLimit) {
  _totalPayoutAccumulated += newPayout;

  if (_totalPayoutAccumulated > maxLimit) {
    _totalPayoutAccumulated = maxLimit;
  }

  // save payout
  await _storage.write(
    key: "total_payout",
    value: _totalPayoutAccumulated.toString(),
  );
}

// display accumulated payout
_potentialPayout = _totalPayoutAccumulated;
          
          final rtoData = details['rto'] ?? {};
          _rtoToday = (rtoData['today'] ?? 0).toInt();
          _rtoMode = (rtoData['mode'] ?? 0).toInt();
        });
      }
    } catch (e) {
      debugPrint('Backend Analysis Error: $e');
    }
  }

  Future<void> _fetchRealDashboardData() async {
    try {
      final workerIdStr = await _storage.read(key: 'worker_id');
      if (workerIdStr == null) return;
      final int workerId = int.parse(workerIdStr);

      final claimsResponse = await _supabase.from('claims').select('id').eq('worker_id', workerId);
      _claimsCount = claimsResponse.length.toString();
      _disturbancesCount = _claimsCount;
    try {
      final workerIdStr = await _storage.read(key: 'worker_id');
      if (workerIdStr == null) return;
      final int workerId = int.parse(workerIdStr);

      final claimsResponse = await _supabase.from('claims').select('id').eq('worker_id', workerId);
      _claimsCount = claimsResponse.length.toString();
      _disturbancesCount = _claimsCount;

      final payoutsResponse = await _supabase.from('payouts').select('amount').eq('worker_id', workerId).eq('status', 'paid');
      double totalPaid = 0;
      for (var p in payoutsResponse) {
        totalPaid += (p['amount'] as num).toDouble();
      }
      _amountPaidCount = '₹${totalPaid.toStringAsFixed(0)}';
      final payoutsResponse = await _supabase.from('payouts').select('amount').eq('worker_id', workerId).eq('status', 'paid');
      double totalPaid = 0;
      for (var p in payoutsResponse) {
        totalPaid += (p['amount'] as num).toDouble();
      }
      _amountPaidCount = '₹${totalPaid.toStringAsFixed(0)}';

      final fraudsResponse = await _supabase.from('fraud_logs').select('id').eq('worker_id', workerId).eq('status', 'pending');
      _fraudsCount = fraudsResponse.length.toString();
      final fraudsResponse = await _supabase.from('fraud_logs').select('id').eq('worker_id', workerId).eq('status', 'pending');
      _fraudsCount = fraudsResponse.length.toString();

      final activityResponse = await _supabase.from('claims').select().eq('worker_id', workerId).order('created_at', ascending: false).limit(3);
      _recentActivity = List<Map<String, dynamic>>.from(activityResponse);
      final activityResponse = await _supabase.from('claims').select().eq('worker_id', workerId).order('created_at', ascending: false).limit(3);
      _recentActivity = List<Map<String, dynamic>>.from(activityResponse);
    } catch (e) {
      debugPrint('Supabase fetch error: $e');
      debugPrint('Supabase fetch error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: Colors.indigo)));
    }

    final List<Map<String, dynamic>> metrics = [
      {'label': 'Disturbances this week', 'value': _disturbancesCount, 'icon': Icons.warning_amber_rounded},
      {'label': 'Amount paid this week', 'value': _amountPaidCount, 'icon': Icons.attach_money},
      {'label': 'Claims this week', 'value': _claimsCount, 'icon': Icons.assignment_turned_in_rounded},
      {'label': 'Frauds detected this week', 'value': _fraudsCount, 'icon': Icons.gpp_bad_rounded},
    ];

    return Scaffold(
      backgroundColor: const Color(0xfff5f7fa),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLiveStatusCard(),
                  const SizedBox(height: 12),
                  if (_fraudAlert) _buildFraudWarningCard(),
                  if (_fraudAlert) const SizedBox(height: 12),
                  _buildPremiumCard(),
                  const SizedBox(height: 12),
                  _buildSimulationRow(),
                  const SizedBox(height: 12),
                  _buildMetricsGrid(metrics),
                  const SizedBox(height: 24),
                  Text('Recent Activity', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ..._recentActivity.map((activity) => _buildActivityTile(activity)).toList(),
                  if (_recentActivity.isEmpty)
                    const Card(child: ListTile(title: Text('No recent activity found', style: TextStyle(color: Colors.grey)))),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshDashboard,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            _buildSliverAppBar(),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLiveStatusCard(),
                    const SizedBox(height: 12),
                    if (_fraudAlert) _buildFraudWarningCard(),
                    if (_fraudAlert) const SizedBox(height: 12),
                    _buildPremiumCard(),
                    const SizedBox(height: 12),
                    _buildSimulationRow(),
                    const SizedBox(height: 12),
                    _buildMetricsGrid(metrics),
                    const SizedBox(height: 24),
                    Text('Recent Activity', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    ..._recentActivity.map((activity) => _buildActivityTile(activity)).toList(),
                    if (_recentActivity.isEmpty)
                      const Card(child: ListTile(title: Text('No recent activity found', style: TextStyle(color: Colors.grey)))),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveStatusCard() {
    bool hasAlert = _backendTrigger != null;
    return Card(
      elevation: 4,
      color: hasAlert ? Colors.orange.shade50 : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: hasAlert ? BorderSide(color: Colors.orange.shade300, width: 2) : BorderSide.none,
      ),
      child: ListTile(
        leading: Icon(
          hasAlert ? Icons.warning_amber_rounded : Icons.cloud_done_rounded,
          color: hasAlert ? Colors.orange : Colors.green,
          size: 32,
        ),
        title: Text(
          hasAlert ? 'Alert: $_backendTrigger Detected' : 'Environment: Normal',
          style: TextStyle(fontWeight: FontWeight.bold, color: hasAlert ? Colors.orange.shade900 : Colors.green.shade900),
        ),
        subtitle: Text('Temp: ${_weather['temp'] ?? '--'}°C | Rain: ${_weather['rain'] ?? '0'}mm | Traffic: ${(_traffic * 10).toStringAsFixed(1)}/10'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('PAYOUT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
            Text('₹$_potentialPayout', style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.indigo, fontSize: 18)),
          ],
        ),
      ),
    );
  }

  Widget _buildFraudWarningCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.gpp_maybe_rounded, color: Colors.red),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'High Fraud Probability Detected in your RTO patterns. Claims may be flagged for manual review.',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimulationRow() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () async {
              await ValidClaimSimulator.run();
              _refreshDashboard();
            },
            icon: const Icon(Icons.check_circle_outline, size: 18),
            label: const Text('Valid Claim'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () async {
              await FraudClaimSimulator.run();
              _refreshDashboard();
            },
            icon: const Icon(Icons.error_outline, size: 18),
            label: const Text('Fraud Claim'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildLiveStatusCard() {
    bool hasAlert = _backendTrigger != null;
    return Card(
      elevation: 4,
      color: hasAlert ? Colors.orange.shade50 : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: hasAlert ? BorderSide(color: Colors.orange.shade300, width: 2) : BorderSide.none,
      ),
      child: ListTile(
        leading: Icon(
          hasAlert ? Icons.warning_amber_rounded : Icons.cloud_done_rounded,
          color: hasAlert ? Colors.orange : Colors.green,
          size: 32,
        ),
        title: Text(
          hasAlert ? 'Alert: $_backendTrigger Detected' : 'Environment: Normal',
          style: TextStyle(fontWeight: FontWeight.bold, color: hasAlert ? Colors.orange.shade900 : Colors.green.shade900),
        ),
        subtitle: Text('Temp: ${_weather['temp'] ?? '--'}°C | Rain: ${_weather['rain'] ?? '0'}mm | Traffic: ${(_traffic * 10).toStringAsFixed(1)}/10'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('PAYOUT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
            Column(
  crossAxisAlignment: CrossAxisAlignment.end,
  children: [
    Text(
      '₹$_totalPayoutAccumulated',
      style: const TextStyle(
        fontWeight: FontWeight.w900,
        color: Colors.indigo,
        fontSize: 18,
      ),
    ),
    Text(
      '/ ₹${_calculatedPremium * 2}',
      style: const TextStyle(fontSize: 10, color: Colors.grey),
    ),
    if (_totalPayoutAccumulated >= _calculatedPremium * 2)
      const Text(
        "⚠ Max limit reached",
        style: TextStyle(color: Colors.red, fontSize: 10),
      ),
  ],
)
        ),
      ),
    );
  }

  Widget _buildFraudWarningCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.gpp_maybe_rounded, color: Colors.red),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'High Fraud Probability Detected in your RTO patterns. Claims may be flagged for manual review.',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimulationRow() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () async {
              await ValidClaimSimulator.run();
              _refreshDashboard();
            },
            icon: const Icon(Icons.check_circle_outline, size: 18),
            label: const Text('Valid Claim'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () async {
              await FraudClaimSimulator.run();
              _refreshDashboard();
            },
            icon: const Icon(Icons.error_outline, size: 18),
            label: const Text('Fraud Claim'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.indigo,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo, Color(0xFF3F51B5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 24, right: 24, top: 60),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ValueListenableBuilder<String>(
                      valueListenable: ZUG.userName,
                      builder: (context, name, _) {
                        return Text('Hello, $name', 
                          style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold));
                      }
                    ),
                    const SizedBox(height: 4),
                    Text(_hasBoughtPremium ? 'Premium Active for this week' : 'No active premium',
                      style: const TextStyle(color: Colors.white70, fontSize: 14)),
                  ],
                ),
                const CircleAvatar(radius: 28, backgroundColor: Colors.white24, child: Icon(Icons.person, size: 35, color: Colors.white)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumCard() {
  return Card(
    elevation: 2,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          const Icon(Icons.stars_rounded, color: Colors.indigo, size: 32),
          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Next week premium price:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.indigo,
                  ),
                ),
                Text(
                  'RTO Benchmarking: $_rtoToday (vs avg $_rtoMode)',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),

          // 👉 RIGHT SIDE (price + button)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹$_calculatedPremium',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                  color: Colors.indigo,
                ),
              ),
              const SizedBox(height: 8),
              _hasBoughtPremium
  ? Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        "✅ Paid",
        style: TextStyle(color: Colors.white),
      ),
    )
  : ElevatedButton(
      onPressed: startPayment,
      child: Text("Pay"),
    )
            ],
          ),
        ],
      ),
    ),
  );
}

  Widget _buildMetricsGrid(List<Map<String, dynamic>> metrics) {
    return GridView.count(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: metrics.map((m) => Card(
        elevation: 2,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(m['icon'] as IconData, color: Colors.indigo, size: 24),
              const SizedBox(height: 4),
              Text(m['value'] as String,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(m['label'] as String,
                  style: const TextStyle(fontSize: 11, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildActivityTile(Map<String, dynamic> data) {
    bool isPaid = data['is_paid'] == true;
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isPaid ? Colors.green.shade50 : Colors.orange.shade50,
          child: Icon(Icons.receipt_long_rounded, color: isPaid ? Colors.green : Colors.orange, size: 20),
        ),
        title: Text('Claim ${data['trigger_type'] ?? 'ID #' + data['id'].toString()}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(data['created_at'].toString().substring(0, 10), style: const TextStyle(fontSize: 12)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isPaid ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(isPaid ? 'PAID' : 'PENDING', 
            style: TextStyle(color: isPaid ? Colors.green : Colors.orange, fontWeight: FontWeight.bold, fontSize: 10)),
        ),
      ),
    );
  }
}


// Main Navigation & Persistance (Refactored for correctness)
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});
  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedTab = 0;
  final _tab1navigatorKey = GlobalKey<NavigatorState>();
  final _tab2navigatorKey = GlobalKey<NavigatorState>();
  final _tab3navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return PersistentBottomBarScaffold(
      onTabChanged: (index) {
      },
      items: [
        PersistentTabItem(tab: const DashboardScreen(), icon: Icons.home, title: 'Home', navigatorkey: _tab1navigatorKey),
        PersistentTabItem(tab: const TicketsScreen(), icon: Icons.confirmation_number_rounded, title: 'Tickets', navigatorkey: _tab2navigatorKey),
        PersistentTabItem(tab: const ProfileScreen(), icon: Icons.person, title: 'Profile', navigatorkey: _tab3navigatorKey),
      ],
    );
  }
}

class PersistentBottomBarScaffold extends StatefulWidget {
  final List<PersistentTabItem> items;
  final Function(int)? onTabChanged;
  const PersistentBottomBarScaffold({super.key, required this.items, this.onTabChanged});
  @override
  State<PersistentBottomBarScaffold> createState() => _PersistentBottomBarScaffoldState();
}

class _PersistentBottomBarScaffoldState extends State<PersistentBottomBarScaffold> {
  int _selectedTab = 0;
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (val, result) async {
        if (widget.items[_selectedTab].navigatorkey?.currentState?.canPop() ?? false) {
          widget.items[_selectedTab].navigatorkey?.currentState?.pop();
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _selectedTab,
          children: widget.items.map((page) => Navigator(
            key: page.navigatorkey,
            onGenerateInitialRoutes: (navigator, initialRoute) => [MaterialPageRoute(builder: (context) => page.tab)],
          )).toList(),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedTab,
          selectedItemColor: Colors.indigo,
          onTap: (index) {
            setState(() => _selectedTab = index);
            widget.onTabChanged?.call(index);
          },
          items: widget.items.map((item) => BottomNavigationBarItem(icon: Icon(item.icon), label: item.title)).toList(),
        ),
      ),
    );
  }
}

class PersistentTabItem {
  final Widget tab;
  final GlobalKey<NavigatorState>? navigatorkey;
  final String title;
  final IconData icon;
  PersistentTabItem({required this.tab, this.navigatorkey, required this.title, required this.icon});
}
