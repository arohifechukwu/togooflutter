import 'package:flutter/material.dart';
import '../restaurant_screens/restaurant_account_screen.dart';
import '../restaurant_home.dart';
import '../restaurant_screens/restaurant_manage_screen.dart';
import '../restaurant_screens/restaurant_new_screen.dart';
import '../restaurant_screens/restaurant_report_screen.dart';

// ✅ Define color palette
const Color primaryColor = Color(0xFFF18D34); // Dark Orange
const Color darkGray = Color(0xFF757575); // Unselected label color

class RestaurantBottomNavigationMenu extends StatelessWidget {
  final int currentIndex;

  const RestaurantBottomNavigationMenu({
    Key? key,
    required this.currentIndex,
  }) : super(key: key);

  static final List<Widget> _pages = [
    RestaurantHomeScreen(),
    RestaurantNewScreen(),
    RestaurantReportScreen(),
    RestaurantManageScreen(),
    RestaurantAccountScreen(),
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
    Widget _coloredIcon(String assetPath, bool isSelected) {
      return ColorFiltered(
        colorFilter: ColorFilter.mode(
          isSelected ? primaryColor : darkGray,
          BlendMode.srcIn,
        ),
        child: Image.asset(
          assetPath,
          width: 24,
          height: 24,
        ),
      );
    }

    return BottomNavigationBar(
      currentIndex: currentIndex,
      showUnselectedLabels: true,
      selectedItemColor: primaryColor,
      unselectedItemColor: darkGray,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
      onTap: (index) => _onItemTapped(context, index),
      items: [
        BottomNavigationBarItem(
          icon: _coloredIcon('assets/ic_buy.png', currentIndex == 0),
          label: 'Orders',
        ),
        BottomNavigationBarItem(
          icon: _coloredIcon('assets/ic_create.png', currentIndex == 1),
          label: 'New',
        ),
        BottomNavigationBarItem(
          icon: _coloredIcon('assets/ic_report.png', currentIndex == 2),
          label: 'Reports',
        ),
        BottomNavigationBarItem(
          icon: _coloredIcon('assets/ic_manage.png', currentIndex == 3),
          label: 'Manage',
        ),
        BottomNavigationBarItem(
          icon: _coloredIcon('assets/ic_setting.png', currentIndex == 4),
          label: 'Account',
        ),
      ],
    );
  }
}
