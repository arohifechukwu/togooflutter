import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../driver_home.dart'; //
import '../driver_screens/driver_orders.dart'; //
import '../driver_screens/driver_reports.dart'; //
import '../driver_screens/driver_account.dart'; //

class DriverBottomNavigationMenu extends StatelessWidget {
  final int currentIndex;
  final BuildContext context;

  const DriverBottomNavigationMenu({
    super.key,
    required this.currentIndex,
    required this.context,
  });

  void _navigate(int index) {
    if (index == currentIndex) return;
    Widget destination;
    switch (index) {
      case 0:
        destination = const DriverHomeScreen();
        break;
      case 1:
        destination = const DriverOrdersScreen();
        break;
      case 2:
        destination = const DriverReportsScreen();
        break;
      case 3:
        destination = const DriverAccountScreen();
        break;
      default:
        return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => destination),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      onTap: _navigate,
      items: [
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/ic_notification.png',
            width: 24,
            height: 24,
          ),
          label: 'Notification',
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/ic_buy.png',
            width: 24,
            height: 24,
          ),
          label: 'Orders',
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/ic_report.png',
            width: 24,
            height: 24,
          ),
          label: 'Reports',
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/ic_setting.png',
            width: 24,
            height: 24,
          ),
          label: 'Account',
        ),
      ],
    );
  }
}