import 'package:flutter/material.dart';
import 'admin_bottom_navigation_menu.dart';
import 'customer_home.dart';
import 'screens/restaurants_screen.dart';
import 'screens/browse_screen.dart';
import 'screens/orders_screen.dart';
import 'screens/account_screen.dart';

class CustomerBottomNavigationMenu extends StatefulWidget {
  final int selectedIndex;
  const CustomerBottomNavigationMenu({Key? key, required this.selectedIndex}) : super(key: key);

  @override
  _CustomerBottomNavigationMenuState createState() => _CustomerBottomNavigationMenuState();
}

class _CustomerBottomNavigationMenuState extends State<CustomerBottomNavigationMenu> {
  late int _currentIndex;

  final List<Widget> _pages = [
    CustomerHome(),
    RestaurantsScreen(),
    BrowseScreen(),
    OrdersScreen(),
    AccountScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.selectedIndex;
  }

  void _onItemTapped(int index, int currentIndex) {
    if (index == _currentIndex) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => _pages[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      showUnselectedLabels: true, // ✅ Ensure all labels are always visible
      selectedItemColor: primaryColor, // ✅ Highlight selected icon label
      unselectedItemColor: darkGray, // ✅ Keep unselected icon labels visible
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold), // ✅ Make selected label more prominent
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal), // ✅ Keep unselected labels readable
      onTap: (index) => _onItemTapped(index, _currentIndex),
      items: [
        BottomNavigationBarItem(
          icon: Image.asset(
            _currentIndex == 0 ? 'assets/icons/ic_home_active.png' : 'assets/icons/ic_home.png',
            width: 24,
            height: 24,
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.home),
          ),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            _currentIndex == 1 ? 'assets/icons/ic_restaurant_active.png' : 'assets/icons/ic_restaurant.png',
            width: 24, height: 24,
          ),
          label: "Restaurants",
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            _currentIndex == 2 ? 'assets/icons/ic_browse_active.png' : 'assets/icons/ic_browse.png',
            width: 24, height: 24,
          ),
          label: "Browse",
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            _currentIndex == 3 ? 'assets/icons/ic_order_active.png' : 'assets/icons/ic_order.png',
            width: 24, height: 24,
          ),
          label: "Order",
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            _currentIndex == 4 ? 'assets/icons/ic_account_active.png' : 'assets/icons/ic_account.png',
            width: 24, height: 24,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.home)
          ),
          label: "Account",
        ),
      ],
    );
  }
}