import 'package:flutter/material.dart';
import '../driver_home.dart'; //
import '../driver_screens/driver_orders.dart'; //
import '../driver_screens/driver_reports.dart'; //
import '../driver_screens/driver_account.dart'; //

// ✅ Define color palette
const Color primaryColor = Color(0xFFF18D34); // Dark Orange
const Color darkGray = Color(0xFF757575); // Unselected label color

class DriverBottomNavigationMenu extends StatelessWidget {
  final int currentIndex;

  const DriverBottomNavigationMenu({required this.currentIndex, Key? key})
      : super(key: key);

  static final List<Widget> _pages = [
    DriverHomeScreen(),
    DriverOrdersScreen(),
    DriverReportsScreen(),
    DriverAccountScreen(),
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
          icon: _coloredIcon('assets/ic_notification.png', currentIndex == 0),
          label: "Notifications",
        ),
        BottomNavigationBarItem(
          icon: _coloredIcon('assets/ic_buy.png', currentIndex == 1),
          label: "My Orders",
        ),
        BottomNavigationBarItem(
          icon: _coloredIcon('assets/ic_report.png', currentIndex == 2),
          label: "Reports",
        ),
        BottomNavigationBarItem(
          icon: _coloredIcon('assets/ic_setting.png', currentIndex == 3),
          label: "Account",
        ),
      ],
    );
  }
}
