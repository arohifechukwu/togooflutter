import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/scheduler.dart';
import '../restaurant_home.dart';
import 'restaurant_profile_screen.dart';
import 'restaurant_new_screen.dart';
import 'restaurant_report_screen.dart';
import 'restaurant_manage_screen.dart';

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
    SchedulerBinding.instance.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    setState(() => isDarkMode = value);
  }

  void _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
  }

  Widget _buildSettingCard(IconData icon, String label, VoidCallback onTap) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, size: 28),
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
          _buildSettingCard(Icons.person, "Profile", () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RestaurantProfileScreen()))),
          _buildSettingCard(Icons.notifications, "Notifications", () {}),
          _buildSettingCard(Icons.info, "About Us", () {}),
          _buildSettingCard(Icons.question_answer, "FAQ", () {}),
          _buildSettingCard(Icons.language, "Language", () {}),
          SwitchListTile(
            contentPadding: const EdgeInsets.all(16),
            title: const Text("Dark Mode", style: TextStyle(fontSize: 16)),
            secondary: const Icon(Icons.dark_mode),
            value: isDarkMode,
            onChanged: _toggleTheme,
          ),
          _buildSettingCard(Icons.logout, "Logout", _logout),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 4,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.deepOrange,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RestaurantHomeScreen()));
              break;
            case 1:
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RestaurantNewScreen()));
              break;
            case 2:
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RestaurantReportScreen()));
              break;
            case 3:
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RestaurantManageScreen()));
              break;
            case 4:
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.create), label: 'New'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Reports'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_applications), label: 'Manage'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
        ],
      ),
    );
  }
}
