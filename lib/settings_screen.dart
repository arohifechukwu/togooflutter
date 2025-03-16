import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'admin_bottom_navigation_menu.dart';
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

      /// ✅ Bottom Navigation (Fixed `currentIndex: 4` to highlight "Settings")
      bottomNavigationBar: AdminBottomNavigationMenu(currentIndex: 4),
    );
  }
}