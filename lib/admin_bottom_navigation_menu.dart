import 'package:flutter/material.dart';
import 'users_screen.dart';
import 'approvals_screen.dart';
import 'transaction_screen.dart';
import 'settings_screen.dart';
import 'admin_home.dart';

class AdminBottomNavigationMenu extends StatefulWidget {
  @override
  _AdminBottomNavigationMenuState createState() => _AdminBottomNavigationMenuState();
}

class _AdminBottomNavigationMenuState extends State<AdminBottomNavigationMenu> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    AdminHome(),
    UsersScreen(),
    ApprovalsScreen(),
    TransactionScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => _pages[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      selectedItemColor: Colors.orange,
      unselectedItemColor: Colors.grey,
      onTap: _onItemTapped,
      items: [
        BottomNavigationBarItem(
          icon: Image.asset(
            _selectedIndex == 0 ? 'assets/icons/ic_dashboard_active.png' : 'assets/icons/ic_dashboard.png',
            width: 24, height: 24,
          ),
          label: "Dashboard",
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            _selectedIndex == 1 ? 'assets/icons/ic_users_active.png' : 'assets/icons/ic_users.png',
            width: 24, height: 24,
          ),
          label: "Users",
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            _selectedIndex == 2 ? 'assets/icons/ic_approvals_active.png' : 'assets/icons/ic_approvals.png',
            width: 24, height: 24,
          ),
          label: "Approvals",
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            _selectedIndex == 3 ? 'assets/icons/ic_transaction_active.png' : 'assets/icons/ic_transaction.png',
            width: 24, height: 24,
          ),
          label: "Transaction",
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            _selectedIndex == 4 ? 'assets/icons/ic_settings_active.png' : 'assets/icons/ic_settings.png',
            width: 24, height: 24,
          ),
          label: "Settings",
        ),
      ],
    );
  }
}