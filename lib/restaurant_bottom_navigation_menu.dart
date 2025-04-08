import 'package:flutter/material.dart';
import '../restaurant_screens/restaurant_account_screen.dart';
import '../restaurant_home.dart';
import '../restaurant_screens/restaurant_manage_screen.dart';
import '../restaurant_screens/restaurant_new_screen.dart';
import '../restaurant_screens/restaurant_report_screen.dart';

class RestaurantBottomNavigationMenu extends StatelessWidget {
  final int currentIndex;
  final BuildContext context;

  const RestaurantBottomNavigationMenu({
    super.key,
    required this.currentIndex,
    required this.context,
  });

  void _navigate(int index) {
    if (index == currentIndex) return;
    Widget destination;
    switch (index) {
      case 0:
        destination = const RestaurantHomeScreen();
        break;
      case 1:
        destination = const RestaurantNewScreen();
        break;
      case 2:
        destination = const RestaurantReportScreen();
        break;
      case 3:
        destination = const RestaurantManageScreen();
        break;
      case 4:
        destination = const RestaurantAccountScreen();
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
      selectedItemColor: Colors.deepOrange,
      unselectedItemColor: Colors.grey,
      onTap: _navigate,
      items: [
        BottomNavigationBarItem(
          icon: Image.asset('assets/ic_buy.png', width: 24, height: 24),
          label: 'Orders',
        ),
        BottomNavigationBarItem(
          icon: Image.asset('assets/ic_create.png', width: 24, height: 24),
          label: 'New',
        ),
        BottomNavigationBarItem(
          icon: Image.asset('assets/ic_report.png', width: 24, height: 24),
          label: 'Reports',
        ),
        BottomNavigationBarItem(
          icon: Image.asset('assets/ic_manage.png', width: 24, height: 24),
          label: 'Manage',
        ),
        BottomNavigationBarItem(
          icon: Image.asset('assets/ic_setting.png', width: 24, height: 24),
          label: 'Account',
        ),
      ],
    );
  }
}