import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:togoo/featured_category_screen.dart';
import 'firebase_options.dart';
import 'food_detail.dart';
import 'models/food_item.dart';
import 'screens/splash_screen.dart';
import 'checkout_screen.dart';
import 'models/cart_item.dart';
import 'models/restaurant.dart';
import 'profile_screen.dart';
import 'login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("✅ Firebase initialized successfully");
  } catch (e) {
    print("🚨 Firebase initialization failed: $e");
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter App',
      home: SplashScreen(),

      // ✅ Static routes
      routes: {
        '/profile': (context) => ProfileScreen(),
        '/login': (context) => LoginScreen(),
        '/featured-category': (context) => FeaturedCategoryScreen(
          selectedCategory: ModalRoute.of(context)!.settings.arguments as String,
        ),

      },
      onGenerateRoute: (settings) {
        if (settings.name == '/checkout') {
          final args = settings.arguments as Map<String, dynamic>;
          final cartItems = args['cartItems'] as List<CartItem>;
          final selectedRestaurant = args['selectedRestaurant'] as Restaurant;

          return MaterialPageRoute(
            builder: (context) => CheckoutScreen(
              cartItems: cartItems,
              selectedRestaurant: selectedRestaurant,
            ),
          );
        } else if (settings.name == '/food-detail') {
          final food = settings.arguments as FoodItem;
          return MaterialPageRoute(
            builder: (context) => FoodDetailScreen(
              foodId: food.id ?? "",
              foodDescription: food.description ?? "",
              foodImage: food.imageUrl ?? "",
              foodPrice: food.price,
              restaurantId: food.restaurantId, food: food,
            ),
          );
        }
        return null;
      },
    );
  }
}