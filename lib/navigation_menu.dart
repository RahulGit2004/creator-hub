import 'package:flutter/material.dart';
import 'core/constants/app_colors.dart';
import 'features/feed/screens/feed_screen.dart';
import 'features/chat/screens/chat_list_screen.dart';
import 'features/products/screens/product_list_screen.dart';

class NavigationMenu extends StatefulWidget {
  const NavigationMenu({super.key});

  @override
  State<NavigationMenu> createState() => _NavigationMenuState();
}

class _NavigationMenuState extends State<NavigationMenu> {
  int _selectedIndex = 0;

  // The list of screens connected to our navigation items
  final List<Widget> _screens = [
    const FeedScreen(),        // Tab 0: Social Feed
    const ChatListScreen(),    // Tab 1: 1-to-1 Chat Engine
    const ProductListScreen(), // Tab 2: Commerce Grid
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        elevation: 8,
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primaryAccent.withOpacity(0.2),
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dynamic_feed_outlined),
            selectedIcon: Icon(Icons.dynamic_feed, color: AppColors.primary),
            label: 'Feed',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble, color: AppColors.primary),
            label: 'Chat',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_bag_outlined),
            selectedIcon: Icon(Icons.shopping_bag, color: AppColors.primary),
            label: 'Products',
          ),
        ],
      ),
    );
  }
}