import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'admin_home.dart';
import 'users_screen.dart';
import 'approvals_screen.dart';
import 'transaction_screen.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  /// ✅ Load stored theme preference
  void _loadThemePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('darkMode') ?? false;
    });
  }

  /// ✅ Toggle dark mode and save preference
  void _toggleTheme(bool isDark) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('darkMode', isDark);
    setState(() {
      _isDarkMode = isDark;
    });
  }

  /// ✅ Logout functionality
  void _logoutUser() async {
    await _auth.signOut();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => LoginScreen()));
  }

  /// ✅ UI for individual setting option with PNG Icons
  Widget _buildSettingOption({
    required String title,
    required String iconPath,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: Image.asset(iconPath, width: 28, height: 28),
        title: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
        backgroundColor: Colors.orange,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),

          /// ✅ Profile
          _buildSettingOption(
            title: "Profile",
            iconPath: "assets/icons/ic_profile.png",
            onTap: () {
              // TODO: Navigate to profile screen
            },
          ),

          /// ✅ Notifications
          _buildSettingOption(
            title: "Notifications",
            iconPath: "assets/icons/ic_notifications.png",
            onTap: () {
              // TODO: Navigate to notifications settings
            },
          ),

          /// ✅ About Us
          _buildSettingOption(
            title: "About Us",
            iconPath: "assets/icons/ic_info.png",
            onTap: () {
              // TODO: Navigate to About Us screen
            },
          ),

          /// ✅ FAQ
          _buildSettingOption(
            title: "FAQ",
            iconPath: "assets/icons/ic_faq.png",
            onTap: () {
              // TODO: Navigate to FAQ screen
            },
          ),

          /// ✅ Language
          _buildSettingOption(
            title: "Language",
            iconPath: "assets/icons/ic_language.png",
            onTap: () {
              // TODO: Navigate to Language selection screen
            },
          ),

          /// ✅ Dark Mode Toggle
          _buildSettingOption(
            title: "Dark Mode",
            iconPath: "assets/icons/ic_dark_mode.png",
            trailing: Switch(
              value: _isDarkMode,
              onChanged: (value) => _toggleTheme(value),
            ),
          ),

          /// ✅ Logout
          _buildSettingOption(
            title: "Logout",
            iconPath: "assets/icons/ic_logout.png",
            onTap: _logoutUser,
          ),

          const SizedBox(height: 20),
        ],
      ),

      /// ✅ Bottom Navigation with PNG Icons
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 4, // Settings screen index
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 0) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => AdminHome()));
          if (index == 1) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => UsersScreen()));
          if (index == 2) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ApprovalsScreen()));
          if (index == 3) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => TransactionScreen()));
          if (index == 4) return; // Stay on Settings
        },
        items: [
          BottomNavigationBarItem(
            icon: Image.asset("assets/icons/ic_dashboard.png", width: 24, height: 24),
            activeIcon: Image.asset("assets/icons/ic_dashboard_active.png", width: 24, height: 24),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(
            icon: Image.asset("assets/icons/ic_users.png", width: 24, height: 24),
            activeIcon: Image.asset("assets/icons/ic_users_active.png", width: 24, height: 24),
            label: "Users",
          ),
          BottomNavigationBarItem(
            icon: Image.asset("assets/icons/ic_approvals.png", width: 24, height: 24),
            activeIcon: Image.asset("assets/icons/ic_approvals_active.png", width: 24, height: 24),
            label: "Approvals",
          ),
          BottomNavigationBarItem(
            icon: Image.asset("assets/icons/ic_transaction.png", width: 24, height: 24),
            activeIcon: Image.asset("assets/icons/ic_transaction_active.png", width: 24, height: 24),
            label: "Transaction",
          ),
          BottomNavigationBarItem(
            icon: Image.asset("assets/icons/ic_settings.png", width: 24, height: 24),
            activeIcon: Image.asset("assets/icons/ic_settings_active.png", width: 24, height: 24),
            label: "Settings",
          ),
        ],
      ),
    );
  }
}