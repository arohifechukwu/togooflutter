import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'food_detail.dart';
import 'models/food_item.dart';
import 'screens/splash_screen.dart';
import 'checkout_screen.dart';
import 'models/cart_item.dart';
import '../profile_screen.dart';
import '../login_screen.dart';

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

      },

      // ✅ Dynamic routes
      onGenerateRoute: (settings) {
        if (settings.name == '/checkout') {
          final args = settings.arguments as List<CartItem>;
          return MaterialPageRoute(
            builder: (context) => CheckoutScreen(cartItems: args),
          );
        } else if (settings.name == '/food-detail') {
          final food = settings.arguments as FoodItem;
          return MaterialPageRoute(
            builder: (context) => FoodDetailScreen(
              foodId: food.id,
              foodDescription: food.description,
              foodImage: food.imageUrl,
              foodPrice: food.price,
            ),
          );
        }
        return null;
      },
    );
  }
}