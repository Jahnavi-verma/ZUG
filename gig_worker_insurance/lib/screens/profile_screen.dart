import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../zug_sdk.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _storage = const FlutterSecureStorage();
  
  final _nameController = TextEditingController(text: 'Rahul');
  final _upiController = TextEditingController(text: 'rahul@upi');
  
  bool _isEditingName = false;
  bool _isEditingUpi = false;
  
  String _phoneNumber = '+91 98765 43210';
  String _eshramId = '1234 5678 9012';

  @override
  void initState() {
    super.initState();
    _loadStoredData();
  }

  Future<void> _loadStoredData() async {
    final phone = await _storage.read(key: 'phone_number');
    final eshram = await _storage.read(key: 'plain_eshram_id');
    final name = await _storage.read(key: 'user_name');
    final upi = await _storage.read(key: 'user_upi');
    
    if (mounted) {
      setState(() {
        if (phone != null) _phoneNumber = phone;
        if (eshram != null) _eshramId = eshram;
        if (name != null) {
          _nameController.text = name;
          ZUG.userName.value = name;
        }
        if (upi != null) _upiController.text = upi;
      });
    }
  }

  Future<void> _saveName() async {
    await _storage.write(key: 'user_name', value: _nameController.text);
    // Update the global notifier so it reflects on Home screen immediately
    ZUG.userName.value = _nameController.text;
    setState(() => _isEditingName = false);
  }

  Future<void> _saveUpi() async {
    await _storage.write(key: 'user_upi', value: _upiController.text);
    setState(() => _isEditingUpi = false);
  }

  Future<void> _logout() async {
    await _storage.delete(key: 'last_sms_date');
    await _storage.delete(key: 'worker_id');
    await _storage.delete(key: 'phone_number');
    await _storage.delete(key: 'plain_eshram_id');
    await _storage.delete(key: 'user_name');
    await _storage.delete(key: 'user_upi');
    await _storage.delete(key: 'terms_accepted');
    
    ZUG.userName.value = "Rahul"; // Reset for next user

    if (mounted) {
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const themeColor = Colors.indigo;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Settings'),
        backgroundColor: themeColor,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          _buildHeader(context, isDark, themeColor),
          const Divider(),
          _buildSection(
            context,
            title: 'Details',
            isDark: isDark,
            children: [
              _buildEditableTile(
                icon: Icons.person_outline,
                label: 'Name',
                controller: _nameController,
                isEditing: _isEditingName,
                themeColor: themeColor,
                onToggle: () {
                  if (_isEditingName) {
                    _saveName();
                  } else {
                    setState(() => _isEditingName = true);
                  }
                },
              ),
              _buildSettingTile(
                context,
                icon: Icons.phone_android_outlined,
                title: 'Phone No.',
                subtitle: _phoneNumber,
                isDark: isDark,
                themeColor: themeColor,
                onTap: () {},
              ),
              _buildSettingTile(
                context,
                icon: Icons.badge_outlined,
                title: 'e-Shram ID',
                subtitle: _eshramId,
                isDark: isDark,
                themeColor: themeColor,
                onTap: () {},
              ),
            ],
          ),
          _buildSection(
            context,
            title: 'Payment Methods',
            isDark: isDark,
            children: [
              _buildEditableTile(
                icon: Icons.account_balance_wallet_outlined,
                label: 'UPI',
                controller: _upiController,
                isEditing: _isEditingUpi,
                themeColor: themeColor,
                onToggle: () {
                  if (_isEditingUpi) {
                    _saveUpi();
                  } else {
                    setState(() => _isEditingUpi = true);
                  }
                },
              ),
              _buildSettingTile(
                context,
                icon: Icons.account_balance_outlined,
                title: 'Bank',
                subtitle: 'State Bank of India - XXXX1234',
                isDark: isDark,
                themeColor: themeColor,
                onTap: () {},
              ),
            ],
          ),
          _buildSection(
            context,
            title: 'Subscription',
            isDark: isDark,
            children: [
              _buildSettingTile(
                context,
                icon: Icons.workspace_premium,
                title: 'Premium Plan',
                subtitle: 'Premium active for this week',
                isDark: isDark,
                themeColor: themeColor,
                trailing: const Text(
                  'Active',
                  style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                ),
                onTap: () {},
              ),
            ],
          ),
          _buildSection(
            context,
            title: 'Danger Zone',
            isDark: isDark,
            children: [
              _buildSettingTile(
                context,
                icon: Icons.logout,
                title: 'Log Out',
                subtitle: 'Sign out from this device',
                isDark: isDark,
                themeColor: Colors.red,
                textColor: Colors.red,
                onTap: _logout,
              ),
              _buildSettingTile(
                context,
                icon: Icons.delete_forever,
                title: 'Delete Account',
                subtitle: 'Permanently delete your account',
                isDark: isDark,
                themeColor: Colors.red,
                textColor: Colors.red,
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark, Color themeColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: themeColor,
            child: const Icon(Icons.person, color: Colors.white, size: 40),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ValueListenableBuilder<String>(
                  valueListenable: ZUG.userName,
                  builder: (context, name, _) {
                    return Text(
                      name,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    );
                  }
                ),
                Text(
                  'e-Shram ID: $_eshramId',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  'Premium active for this week',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required bool isDark,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: title == 'Danger Zone'
                  ? Colors.red
                  : (isDark ? Colors.white54 : Colors.grey[700]),
            ),
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildEditableTile({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    required bool isEditing,
    required Color themeColor,
    required VoidCallback onToggle,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: themeColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: themeColor),
      ),
      title: isEditing
          ? TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(isDense: true, border: InputBorder.none),
              style: const TextStyle(fontWeight: FontWeight.w600),
              onSubmitted: (_) => onToggle(),
            )
          : Text(controller.text, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(label, style: const TextStyle(fontSize: 12)),
      trailing: IconButton(
        icon: Icon(isEditing ? Icons.check : Icons.edit, size: 20, color: Colors.grey),
        onPressed: onToggle,
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required bool isDark,
    required Color themeColor,
    Color? textColor,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: (textColor ?? themeColor).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: textColor ?? themeColor),
      ),
      title: Text(title, style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                color: isDark ? Colors.white54 : Colors.grey[600],
                fontSize: 13,
              ),
            )
          : null,
      trailing:
          trailing ??
          Icon(
            Icons.chevron_right,
            color: isDark ? Colors.white30 : Colors.grey[400],
          ),
      onTap: onTap,
    );
  }
}
