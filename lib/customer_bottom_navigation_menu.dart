// import 'package:flutter/material.dart';
// import 'package:togoo/screens/my_order.dart';
// import 'admin_bottom_navigation_menu.dart';
// import 'customer_home.dart';
// import 'screens/restaurant_screen.dart';
// import 'screens/my_order.dart';
// import 'screens/orders_screen.dart';
// import 'screens/account_screen.dart';
//
// class CustomerBottomNavigationMenu extends StatefulWidget {
//   final int selectedIndex;
//   const CustomerBottomNavigationMenu({Key? key, required this.selectedIndex}) : super(key: key);
//
//   @override
//   _CustomerBottomNavigationMenuState createState() => _CustomerBottomNavigationMenuState();
// }
//
// class _CustomerBottomNavigationMenuState extends State<CustomerBottomNavigationMenu> {
//   late int _currentIndex;
//
//   final List<Widget> _pages = [
//     CustomerHome(),
//     RestaurantScreen(),
//     MyOrderScreen(),
//     OrdersScreen(),
//     AccountScreen(),
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     _currentIndex = widget.selectedIndex;
//   }
//
//   void _onItemTapped(int index, int currentIndex) {
//     if (index == _currentIndex) return;
//
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (context) => _pages[index]),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return BottomNavigationBar(
//       currentIndex: _currentIndex,
//       showUnselectedLabels: true, // ✅ Ensure all labels are always visible
//       selectedItemColor: primaryColor, // ✅ Highlight selected icon label
//       unselectedItemColor: darkGray, // ✅ Keep unselected icon labels visible
//       selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold), // ✅ Make selected label more prominent
//       unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal), // ✅ Keep unselected labels readable
//       onTap: (index) => _onItemTapped(index, _currentIndex),
//       items: [
//         BottomNavigationBarItem(
//           icon: Image.asset(
//             _currentIndex == 0 ? 'assets/ic_home_active.png' : 'assets/ic_home.png',
//             width: 24,
//             height: 24,
//             errorBuilder: (context, error, stackTrace) => const Icon(Icons.home),
//           ),
//           label: "Home",
//         ),
//         BottomNavigationBarItem(
//           icon: Image.asset(
//             _currentIndex == 1 ? 'assets/ic_restaurant_active.png' : 'assets/ic_restaurant.png',
//             width: 24, height: 24,
//           ),
//           label: "Restaurants",
//         ),
//         BottomNavigationBarItem(
//           icon: Image.asset(
//             _currentIndex == 2 ? 'assets/ic_browse_active.png' : 'assets/ic_browse.png',
//             width: 24, height: 24,
//           ),
//           label: "My Orders",
//         ),
//         BottomNavigationBarItem(
//           icon: Image.asset(
//             _currentIndex == 3 ? 'assets/ic_order_active.png' : 'assets/ic_order.png',
//             width: 24, height: 24,
//           ),
//           label: "Order",
//         ),
//         BottomNavigationBarItem(
//           icon: Image.asset(
//             _currentIndex == 4 ? 'assets/ic_account_active.png' : 'assets/ic_account.png',
//             width: 24, height: 24,
//               errorBuilder: (context, error, stackTrace) => const Icon(Icons.home)
//           ),
//           label: "Account",
//         ),
//       ],
//     );
//   }
// }




import 'package:flutter/material.dart';
import 'package:togoo/screens/my_order.dart';
import 'admin_bottom_navigation_menu.dart';
import 'customer_home.dart';
import 'screens/restaurant_screen.dart';
import 'screens/my_order.dart';
import 'screens/orders_screen.dart';
import 'screens/account_screen.dart';

// You might have defined these color constants somewhere in your project.
const primaryColor = Colors.deepOrange;
const darkGray = Colors.grey;

class CustomerBottomNavigationMenu extends StatefulWidget {
  final int selectedIndex;
  const CustomerBottomNavigationMenu({Key? key, required this.selectedIndex}) : super(key: key);

  @override
  _CustomerBottomNavigationMenuState createState() => _CustomerBottomNavigationMenuState();
}

class _CustomerBottomNavigationMenuState extends State<CustomerBottomNavigationMenu> {
  late int _currentIndex;

  // Define the pages in the order you want them:
  final List<Widget> _pages = [
    CustomerHome(),
    RestaurantScreen(),
    MyOrderScreen(), // This is the "My Orders" screen.
    OrdersScreen(),
    AccountScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.selectedIndex;
  }

  void _onItemTapped(int index) {
    if (index == _currentIndex) return;

    // When a different tab is tapped, pushReplacement to the new screen.
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => _pages[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      showUnselectedLabels: true,
      selectedItemColor: primaryColor,
      unselectedItemColor: darkGray,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
      onTap: _onItemTapped,
      items: [
        BottomNavigationBarItem(
          icon: Image.asset(
            _currentIndex == 0 ? 'assets/ic_home_active.png' : 'assets/ic_home.png',
            width: 24,
            height: 24,
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.home),
          ),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            _currentIndex == 1 ? 'assets/ic_restaurant_active.png' : 'assets/ic_restaurant.png',
            width: 24,
            height: 24,
          ),
          label: "Restaurants",
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            _currentIndex == 2 ? 'assets/ic_browse_active.png' : 'assets/ic_browse.png',
            width: 24,
            height: 24,
          ),
          label: "My Orders",
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            _currentIndex == 3 ? 'assets/ic_order_active.png' : 'assets/ic_order.png',
            width: 24,
            height: 24,
          ),
          label: "Order",
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            _currentIndex == 4 ? 'assets/ic_account_active.png' : 'assets/ic_account.png',
            width: 24,
            height: 24,
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.home),
          ),
          label: "Account",
        ),
      ],
    );
  }
}