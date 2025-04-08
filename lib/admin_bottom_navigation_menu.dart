import 'package:flutter/material.dart';
import 'users_screen.dart';
import 'approvals_screen.dart';
import 'transaction_screen.dart';
import 'settings_screen.dart';
import 'admin_home.dart';

// ✅ Define color palette
const Color primaryColor = Color(0xFFF18D34); // Dark Orange
const Color darkGray = Color(0xFF757575); // Unselected label color

class AdminBottomNavigationMenu extends StatelessWidget {
  final int currentIndex;

  const AdminBottomNavigationMenu({required this.currentIndex, Key? key}) : super(key: key);

  static final List<Widget> _pages = [
    AdminHome(),
    UsersScreen(),
    ApprovalsScreen(),
    TransactionScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(BuildContext context, int index) {
    if (index != currentIndex) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => _pages[index]),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      showUnselectedLabels: true, // ✅ Ensure all labels are always visible
      selectedItemColor: primaryColor, // ✅ Highlight selected icon label
      unselectedItemColor: darkGray, // ✅ Keep unselected icon labels visible
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold), // ✅ Make selected label more prominent
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal), // ✅ Keep unselected labels readable
      onTap: (index) => _onItemTapped(context, index),
      items: [
        BottomNavigationBarItem(
          icon: Image.asset(
            currentIndex == 0 ? 'assets/ic_dashboard_active.png' : 'assets/ic_dashboard.png',
            width: 24, height: 24,
          ),
          label: "Dashboard",
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            currentIndex == 1 ? 'assets/ic_users_active.png' : 'assets/ic_users.png',
            width: 24, height: 24,
          ),
          label: "Users",
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            currentIndex == 2 ? 'assets/ic_approvals_active.png' : 'assets/ic_approvals.png',
            width: 24, height: 24,
          ),
          label: "Approvals",
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            currentIndex == 3 ? 'assets/ic_transaction_active.png' : 'assets/ic_transaction.png',
            width: 24, height: 24,
          ),
          label: "Transaction",
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            currentIndex == 4 ? 'assets/ic_settings_active.png' : 'assets/ic_settings.png',
            width: 24, height: 24,
          ),
          label: "Settings",
        ),
      ],
    );
  }
}
