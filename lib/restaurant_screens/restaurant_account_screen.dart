import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/scheduler.dart';
import '../restaurant_home.dart';
import 'restaurant_profile_screen.dart';
import 'restaurant_new_screen.dart';
import 'restaurant_report_screen.dart';
import 'restaurant_manage_screen.dart';
import 'package:togoo/restaurant_bottom_navigation_menu.dart';

class RestaurantAccountScreen extends StatefulWidget {
  const RestaurantAccountScreen({super.key});

  @override
  State<RestaurantAccountScreen> createState() => _RestaurantAccountScreenState();
}

class _RestaurantAccountScreenState extends State<RestaurantAccountScreen> {
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() => isDarkMode = prefs.getBool("darkMode") ?? false);
  }

  Future<void> _toggleTheme(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("darkMode", value);
    SchedulerBinding.instance.handleAppLifecycleStateChanged(
        AppLifecycleState.inactive);
    setState(() => isDarkMode = value);
  }

  void _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
  }

  Widget _buildSettingCard(String iconPath, String label, VoidCallback onTap) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Image.asset(iconPath, width: 28, height: 28),
        title: Text(label, style: const TextStyle(fontSize: 16)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        title: const Text("Account Dashboard"),
        centerTitle: true,
        backgroundColor: Colors.orange,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSettingCard("assets/ic_profile.png", "Profile", () =>
              Navigator.push(context, MaterialPageRoute(
                  builder: (_) => const RestaurantProfileScreen()))),
          _buildSettingCard("assets/ic_notifications.png", "Notifications", () {}),
          _buildSettingCard("assets/ic_info.png", "About Us", () {}),
          _buildSettingCard("assets/ic_faq.png", "FAQ", () {}),
          _buildSettingCard("assets/ic_language.png", "Language", () {}),
          Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              title: const Text("Dark Mode", style: TextStyle(fontSize: 16)),
              secondary: Image.asset("assets/ic_dark_mode.png", width: 28, height: 28),
              value: isDarkMode,
              onChanged: _toggleTheme,
            ),
          ),
          _buildSettingCard("assets/ic_logout.png", "Logout", _logout),
        ],
      ),
      bottomNavigationBar: RestaurantBottomNavigationMenu(
          currentIndex: 4
      ),
    );
  }
}
