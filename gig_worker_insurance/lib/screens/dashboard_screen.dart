import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/api_service.dart';
import '../services/valid_claim_simulator.dart';
import '../services/fraud_claim_simulator.dart';
import 'tickets_screen.dart';
import 'profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _supabase = Supabase.instance.client;
  final _storage = const FlutterSecureStorage();
  
  bool _isLoading = true;
  String _workerName = "Rahul";
  bool _hasBoughtPremium = true;

  // Real-time data metrics from Supabase
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

  @override
  void initState() {
    super.initState();
    _refreshDashboard();
  }

  Future<void> _refreshDashboard() async {
    setState(() => _isLoading = true);
    await Future.wait([
      _fetchRealDashboardData(),
      _fetchRiskFromBackend(),
    ]);
    setState(() => _isLoading = false);
  }

  Future<void> _fetchRiskFromBackend() async {
    try {
      final data = await ApiService.predictRisk();
      if (mounted) {
        setState(() {
          // Capturing premium calculated by Python
          _calculatedPremium = (data['premium'] as num).toInt();
          _backendTrigger = data['trigger'];
          _weather = data['details']['weather']['current'] ?? {};
          _traffic = (data['details']['traffic']['current'] as num).toDouble();
        });
      }
    } catch (e) {
      debugPrint('Backend calculation error: $e');
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

      final payoutsResponse = await _supabase.from('payouts').select('amount').eq('worker_id', workerId).eq('status', 'paid');
      double totalPaid = 0;
      for (var p in payoutsResponse) {
        totalPaid += (p['amount'] as num).toDouble();
      }
      _amountPaidCount = '₹${totalPaid.toStringAsFixed(0)}';

      final fraudsResponse = await _supabase.from('fraud_logs').select('id').eq('worker_id', workerId).eq('status', 'pending');
      _fraudsCount = fraudsResponse.length.toString();

      final activityResponse = await _supabase.from('claims').select().eq('worker_id', workerId).order('created_at', ascending: false).limit(3);
      _recentActivity = List<Map<String, dynamic>>.from(activityResponse);
    } catch (e) {
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
        trailing: hasAlert ? const Text('INSURED', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.orange)) : null,
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
                    Text('Hello, $_workerName', 
                      style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
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
            const Expanded(
              child: Text('Next week premium price:', 
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.indigo)),
            ),
            Text('₹$_calculatedPremium', 
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Colors.indigo)),
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
  const PersistentBottomBarScaffold({super.key, required this.items});
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
          onTap: (index) => setState(() => _selectedTab = index),
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
