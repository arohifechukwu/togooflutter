import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../customer_bottom_navigation_menu.dart';

class AccountScreen extends StatefulWidget {
  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool("darkMode") ?? false;
    });
  }

  Future<void> _toggleTheme(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("darkMode", value);
    setState(() => isDarkMode = value);
  }


  void _logoutUser() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), // Cancel
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true), // Confirm
            child: const Text("Logout"),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // 👇 Clear session and navigate
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // You can also sign out of Firebase (optional)
      // await FirebaseAuth.instance.signOut();

      Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
    }
  }

  Widget _buildCard({required String iconPath, required String label, required VoidCallback onTap}) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Image.asset(iconPath, width: 28, height: 28),
        title: Text(label),
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
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildCard(
              iconPath: "assets/icons/ic_profile.png",
              label: "Profile",
              onTap: () => Navigator.pushNamed(context, "/profile"),
            ),
            _buildCard(
              iconPath: "assets/icons/ic_notifications.png",
              label: "Notifications",
              onTap: () => Navigator.pushNamed(context, "/notifications"),
            ),
            _buildCard(
              iconPath: "assets/icons/ic_info.png",
              label: "About Us",
              onTap: () => Navigator.pushNamed(context, "/about"),
            ),
            _buildCard(
              iconPath: "assets/icons/ic_faq.png",
              label: "FAQ",
              onTap: () => Navigator.pushNamed(context, "/faq"),
            ),
            _buildCard(
              iconPath: "assets/icons/ic_language.png",
              label: "Language",
              onTap: () => Navigator.pushNamed(context, "/language"),
            ),
            Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: SwitchListTile(
                value: isDarkMode,
                onChanged: _toggleTheme,
                secondary: Image.asset("assets/icons/ic_dark_mode.png", width: 28, height: 28),
                title: const Text("Dark Mode"),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
            _buildCard(
              iconPath: "assets/icons/ic_logout.png",
              label: "Logout",
              onTap: _logoutUser,
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomerBottomNavigationMenu(selectedIndex: 4),
    );
  }
}