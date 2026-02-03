import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/wallpaper_provider.dart';
import 'settings_screen.dart';
import 'favorites_screen.dart';
import '../../core/constants/app_constants.dart';
import 'home_tab.dart';
import 'trending_tab.dart';
import 'category_tab.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const HomeTab(),
    const TrendingTab(),
    const CategoryTab(),
  ];

  final List<String> _titles = ['Amozea', 'Trending', 'Categories'];

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);
    final color = isDarkMode ? Colors.white : Colors.black;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDarkMode
            ? Brightness.light
            : Brightness.dark,
        systemNavigationBarColor: isDarkMode ? Colors.black : Colors.white,
        systemNavigationBarIconBrightness: isDarkMode
            ? Brightness.light
            : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: (isDarkMode ? Colors.black : Colors.white),
        body: Stack(
          children: [
            // Content
            IndexedStack(index: _currentIndex, children: _tabs),

            // Custom AppBar Over Content
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    height: 90, // Reduced from 100
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      48,
                      20,
                      0,
                    ), // Adjusted top padding
                    color: (isDarkMode ? Colors.black : Colors.white)
                        .withOpacity(0.7),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _currentIndex == 0
                              ? 'Amozea'
                              : _titles[_currentIndex],
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.w800,
                            fontSize: 24,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Row(
                          children: [
                            _buildHeaderIcon(AppConstants.heartIcon, () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const FavoritesScreen(),
                                ),
                              );
                            }, isDarkMode),
                            const SizedBox(width: 8), // Reduced from 16
                            _buildHeaderIcon(AppConstants.settingsIcon, () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SettingsScreen(),
                                ),
                              );
                            }, isDarkMode),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // iOS Style Glassmorphic Bottom Navigation
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                  child: Container(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).padding.bottom + 8,
                      top: 12,
                    ),
                    decoration: BoxDecoration(
                      color: (isDarkMode ? Colors.black : Colors.white)
                          .withOpacity(0.75),
                      border: Border(
                        top: BorderSide(
                          color: (isDarkMode ? Colors.white : Colors.black)
                              .withOpacity(0.08),
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        _buildNavItem(
                          0,
                          CupertinoIcons.house_fill,
                          CupertinoIcons.house,
                          'Home',
                        ),
                        _buildNavItem(
                          1,
                          CupertinoIcons.flame_fill,
                          CupertinoIcons.flame,
                          'Trending',
                        ),
                        _buildNavItem(
                          2,
                          CupertinoIcons.square_grid_2x2_fill,
                          CupertinoIcons.square_grid_2x2,
                          'Categories',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderIcon(String asset, VoidCallback onTap, bool isDarkMode) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(
          10,
        ), // Increased slightly for better tap area while compact
        decoration: BoxDecoration(
          color: (isDarkMode ? Colors.white : Colors.black).withOpacity(0.05),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Image.asset(
          asset,
          color: isDarkMode ? Colors.white : Colors.black,
          width: 20, // Slightly smaller icons
          height: 20,
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData activeIcon,
    IconData inactiveIcon,
    String label,
  ) {
    final isSelected = _currentIndex == index;
    final isDarkMode = ref.watch(themeProvider);
    final activeColor = isDarkMode ? Colors.white : Colors.black;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (!isSelected) {
            setState(() => _currentIndex = index);
            HapticFeedback.selectionClick();
          }
        },
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              duration: const Duration(milliseconds: 200),
              scale: isSelected ? 1.05 : 1.0,
              child: Icon(
                isSelected ? activeIcon : inactiveIcon,
                color: isSelected ? activeColor : activeColor.withOpacity(0.4),
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? activeColor : activeColor.withOpacity(0.4),
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
