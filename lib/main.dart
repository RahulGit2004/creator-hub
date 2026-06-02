import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'features/auth/provider/auth_provider.dart';
import 'features/auth/screens/splash_screen.dart';
import 'features/chat/provider/chat_provider.dart';
import 'features/products/provider/product_provider.dart';
import 'firebase_options.dart';
import 'navigation_menu.dart';
import 'features/feed/provider/feed_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 2. UNCOMMENT AND PASS THE OPTIONS HERE
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => FeedProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

// Update the MyApp class inside main.dart:
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Creator Hub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
      ),
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (authProvider.userModel != null) {
            return const NavigationMenu();
          }
          return const SplashScreen();
        },
      ),
    );
  }
}