import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/menu_screen.dart';
import 'screens/cart_screen.dart';

// Supabase project settings (provided by user). For learning only.
// Note: Anon key is public but avoid committing to a public repo if you later enable auth-sensitive tables.
const supabaseUrl = 'https://fjvgjyjnkwgicilbshbn.supabase.co';
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZqdmdqeWpua3dnaWNpbGJzaGJuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ5ODg4MzUsImV4cCI6MjA3MDU2NDgzNX0.kHJ3Nnlj-UuBUEq_hEUFV9lpoK7RVHrog4f3sJkpaCE';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );
  runApp(const QuickBiteLiteApp());
}

class QuickBiteLiteApp extends StatefulWidget {
  const QuickBiteLiteApp({super.key});

  @override
  State<QuickBiteLiteApp> createState() => _QuickBiteLiteAppState();
}

class _QuickBiteLiteAppState extends State<QuickBiteLiteApp> {
  List<Map<String, dynamic>> cart = [];
  Set<int> favorites = {};
  bool darkMode = true;

  void toggleFavorite(int id) {
    setState(() {
      if (favorites.contains(id)) {
        favorites.remove(id);
      } else {
        favorites.add(id);
      }
    });
  }

  double cartTotal() {
    double t = 0;
  for (final it in cart) t += ((it['price'] as num?)?.toDouble() ?? 0) * ((it['quantity'] as num?)?.toInt() ?? 0);
    return t;
  }

  @override
  Widget build(BuildContext context) {
    final lightTheme = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange, brightness: Brightness.light),
      scaffoldBackgroundColor: const Color(0xFFFFF6F0),
      useMaterial3: true,
    );
    final darkTheme = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange, brightness: Brightness.dark),
      scaffoldBackgroundColor: const Color(0xFF1E1A17),
      useMaterial3: true,
    );

    return MaterialApp(
      title: 'QuickBite Lite',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,
      home: MenuScreen(
        cart: cart,
        onCartChanged: (newCart) => setState(() => cart = newCart),
        favorites: favorites,
        onToggleFavorite: toggleFavorite,
        isDark: darkMode,
        onToggleTheme: () => setState(() => darkMode = !darkMode),
        cartTotalGetter: cartTotal,
      ),
      routes: {
        '/cart': (_) => CartScreen(
              cart: cart,
              onCartChanged: (newCart) => setState(() => cart = newCart),
              onClearCart: () => setState(() => cart = []),
              isDark: darkMode,
              onToggleTheme: () => setState(() => darkMode = !darkMode),
              cartTotalGetter: cartTotal,
            ),
      },
    );
  }
}
