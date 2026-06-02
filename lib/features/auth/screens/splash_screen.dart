import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/constants/app_colors.dart';
import '../../../navigation_menu.dart'; // Adjust path if your NavigationMenu is elsewhere
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // Animation variables
  double _opacity = 0.0;
  double _scale = 0.5;

  @override
  void initState() {
    super.initState();

    // 1. Trigger the entrance animation slightly after the screen loads
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _opacity = 1.0;
          _scale = 1.0;
        });
      }
    });

    // 2. Start the routing logic
    _checkAuthStateAndRoute();
  }

  Future<void> _checkAuthStateAndRoute() async {
    // Keep the splash screen visible for at least 2.5 seconds so users see the animation
    await Future.delayed(const Duration(milliseconds: 2500));

    if (!mounted) return;

    // Check Firebase for an existing saved session
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // User is logged in, take them to the Feed!
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const NavigationMenu(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child); // Smooth fade transition
          },
        ),
      );
    } else {
      // No user, take them to Login!
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface, // Clean white background
      body: Center(
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 1200),
          curve: Curves.bounceInOut,
          opacity: _opacity,
          child: AnimatedScale(
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeOutBack, // Gives a nice little "bounce" effect
            scale: _scale,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // The Custom "Awesome" App Icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryAccent, AppColors.primary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.hub_rounded, // Perfect for "Creator Hub"
                    size: 64,
                    color: AppColors.surface,
                  ),
                ),

                const SizedBox(height: 24),

                // The App Title
                const Text(
                  'Creator Hub',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 8),

                // Subtitle
                const Text(
                  'Empowering Creators',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}