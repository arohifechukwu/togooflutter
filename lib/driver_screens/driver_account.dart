import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:togoo/driver_home.dart';  // Driver home screen
import '../driver_screens/driver_profile.dart';  // Driver profile screen
import 'package:togoo/driver_screens/driver_reports.dart';  // Driver reports
import 'package:togoo/driver_screens/driver_bottom_navigation_menu.dart';  // Bottom navigation menu

class DriverAccountScreen extends StatefulWidget {
  const DriverAccountScreen({Key? key}) : super(key: key);

  @override
  _DriverAccountScreenState createState() => _DriverAccountScreenState();
}

class _DriverAccountScreenState extends State<DriverAccountScreen> {
  late Switch themeSwitch, availabilitySwitch;
  late DatabaseReference driverRef;
  late SharedPreferences sharedPreferences;
  bool isDarkMode = false;
  String driverId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _loadDriverData();
    _loadPreferences();
  }

  // Load preferences (e.g., theme setting)
  void _loadPreferences() async {
    sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = sharedPreferences.getBool("darkMode") ?? false;
    });
  }

  void _loadDriverData() {
    driverRef = FirebaseDatabase.instance.ref("driver").child(driverId);

    driverRef.once().then((DatabaseEvent snapshot) {
      if (snapshot.snapshot.value != null) { // Check if data exists
        String availability = snapshot.snapshot.child("availability").value.toString();
        setState(() {
          availabilitySwitch = Switch(
            value: availability == "available",
            onChanged: (value) => _updateAvailability(value),
          );
        });
      }
    }).catchError((error) {
      // Handle any errors here
      print('Error loading driver data: $error');
    });
  }

  // Update availability in Firebase
  void _updateAvailability(bool isAvailable) {
    driverRef.child("availability").set(isAvailable ? "available" : "unavailable").then((_) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Availability set to ${isAvailable ? "available" : "unavailable"}')));
    });
  }

  // Logout the user
  void _logoutUser() {
    FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/login');  // Navigate to the login screen
  }

  // Handle theme switch change
  void _onThemeChanged(bool isDarkMode) {
    setState(() {
      this.isDarkMode = isDarkMode;
    });
    sharedPreferences.setBool('darkMode', isDarkMode);
    if (isDarkMode) {
      // Enable dark theme
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ThemeMode.dark;
      });
    } else {
      // Enable light theme
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ThemeMode.light;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Driver Account'),
      ),
      body: Column(
        children: [
          Card(
            child: ListTile(
              leading: Image.asset('assets/ic_profile.png', width: 40, height: 40),
              title: Text('Profile'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DriverProfileScreen()),
                );
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: Image.asset('assets/ic_notifications.png', width: 40, height: 40),
              title: Text('Notifications'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DriverHomeScreen()),
                );
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: Image.asset('assets/ic_info.png', width: 40, height: 40),
              title: Text('About Us'),
              onTap: () {
                // Navigate to about us page
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: Image.asset('assets/ic_faq.png', width: 40, height: 40),
              title: Text('FAQ'),
              onTap: () {
                // Navigate to FAQ page
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: Image.asset('assets/ic_language.png', width: 40, height: 40),
              title: Text('Language'),
              onTap: () {
                // Navigate to language settings page
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: Image.asset('assets/ic_dark_mode.png', width: 40, height: 40),
              title: Text('Dark Mode'),
              trailing: Switch(
                value: isDarkMode,
                onChanged: _onThemeChanged,
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: Image.asset('assets/ic_available.png', width: 40, height: 40),
              title: Text('Availability'),
              trailing: Switch(
                value: availabilitySwitch.value,
                onChanged: _updateAvailability,
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: Image.asset('assets/ic_logout.png', width: 40, height: 40),
              title: Text('Logout'),
              onTap: _logoutUser,
            ),
          ),
        ],
      ),
      bottomNavigationBar: DriverBottomNavigationMenu(currentIndex: 3, context: context),
    );
  }
}