import 'package:flutter/material.dart';
import 'tickets_screen.dart';
import 'profile_screen.dart';

const _metrics = [
  {'label': 'Disturbances this week', 'value': '3', 'change': '+1', 'icon': Icons.warning_amber_rounded},
  {'label': 'Amount paid this week', 'value': '₹450', 'change': '+₹50', 'icon': Icons.attach_money},
  {'label': 'Claims this week', 'value': '2', 'change': '+1', 'icon': Icons.assignment_turned_in_rounded},
  {'label': 'Frauds detected this week', 'value': '0', 'change': '0%', 'icon': Icons.gpp_bad_rounded},
];

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool hasBoughtPremium = true; // Mocked status

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f7fa),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
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
                  padding: const EdgeInsets.only(left: 24, right: 24, top: 80),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Hello, Rahul',
                            style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            hasBoughtPremium 
                                ? 'Premium Active for this week' 
                                : 'No active premium for this week',
                            style: const TextStyle(color: Colors.white70, fontSize: 16),
                          ),
                        ],
                      ),
                      Transform.translate(
                        offset: const Offset(0, -10),
                        child: const CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white24,
                          child: Icon(Icons.person, size: 40, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Overview', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  
                  Card(
                    elevation: 2,
                    margin: EdgeInsets.zero,
                    shadowColor: Colors.black12,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.indigo.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.stars_rounded, color: Colors.indigo, size: 32),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Buy premium for next week',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.indigo),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Maintain your protection & benefits.',
                                  style: TextStyle(fontSize: 13, color: Colors.black54),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: const [
                              Text(
                                '₹150',
                                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: Colors.indigo),
                              ),
                              Text(
                                'Next Week',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black38),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final count = constraints.maxWidth > 600 ? 4 : 2;
                      return GridView.count(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: count,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1.3,
                        children: _metrics.map((m) => Card(
                          elevation: 2,
                          margin: EdgeInsets.zero,
                          shadowColor: Colors.black12,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(m['icon'] as IconData, size: 28, color: Colors.indigo),
                                const SizedBox(height: 8),
                                Text(m['value'] as String,
                                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                                Text(m['label'] as String,
                                    style: Theme.of(context).textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                                Text(m['change'] as String,
                                    style: TextStyle(
                                      color: (m['change'] as String).startsWith('+')
                                          ? Colors.green
                                          : (m['change'] == '0%' ? Colors.grey : Colors.red),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    )),
                              ],
                            ),
                          ),
                        )).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Text('Recent Activity', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Card(
                    elevation: 2,
                    margin: EdgeInsets.zero,
                    shadowColor: Colors.black12,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: const ListTile(
                      leading: CircleAvatar(backgroundColor: Colors.indigo, child: Icon(Icons.send_rounded, color: Colors.white)),
                      title: Text('New claims sent'),
                      subtitle: Text('2 min ago'),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
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
        PersistentTabItem(
          tab: const DashboardScreen(),
          icon: Icons.home,
          title: 'Home',
          navigatorkey: _tab1navigatorKey,
        ),
        PersistentTabItem(
          tab: const TicketsScreen(),
          icon: Icons.confirmation_number_rounded,
          title: 'Tickets',
          navigatorkey: _tab2navigatorKey,
        ),
        PersistentTabItem(
          tab: const ProfileScreen(),
          icon: Icons.person,
          title: 'Profile',
          navigatorkey: _tab3navigatorKey,
        ),
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
        } else {
          // You might want to handle app exit here or do nothing if you're at the root of the tab
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _selectedTab,
          children: widget.items.map((page) => Navigator(
            key: page.navigatorkey,
            onGenerateInitialRoutes: (navigator, initialRoute) {
              return [MaterialPageRoute(builder: (context) => page.tab)];
            },
          )).toList(),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedTab,
          selectedItemColor: Colors.indigo,
          unselectedItemColor: Colors.grey,
          onTap: (index) {
            setState(() {
              _selectedTab = index;
            });
          },
          items: widget.items.map((item) => BottomNavigationBarItem(
            icon: Icon(item.icon),
            label: item.title,
          )).toList(),
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

  PersistentTabItem({
    required this.tab,
    this.navigatorkey,
    required this.title,
    required this.icon,
  });
}
