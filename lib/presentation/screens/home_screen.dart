import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/wallpaper_provider.dart';
import 'settings_screen.dart';
import 'favorites_screen.dart';
import '../../core/constants/app_constants.dart';
import 'home_tab.dart';
import 'trending_tab.dart';
import 'category_tab.dart';
import 'wallpaper_preview_screen.dart';

import 'package:wallpaper/l10n/app_localizations.dart';

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

  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                WallpaperPreviewScreen(localFile: File(image.path)),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);
    final favorites = ref.watch(favoritesProvider);
    final color = isDarkMode ? Colors.white : Colors.black;
    final l10n = AppLocalizations.of(context)!;

    final List<String> titles = [l10n.appTitle, l10n.trending, l10n.categories];

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
                              ? l10n.appTitle
                              : titles[_currentIndex],
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.w800,
                            fontSize: 24,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Row(
                          children: [
                            _buildHeaderIcon(
                              AppConstants.heartIcon,
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const FavoritesScreen(),
                                  ),
                                );
                              },
                              isDarkMode,
                              count: favorites.length,
                            ),
                            const SizedBox(width: 8),
                            // Gallery Icon
                            _buildHeaderIconButton(
                              CupertinoIcons.photo_on_rectangle,
                              _pickImageFromGallery,
                              isDarkMode,
                            ),
                            const SizedBox(width: 8),
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
                          l10n.home,
                        ),
                        _buildNavItem(
                          1,
                          CupertinoIcons.flame_fill,
                          CupertinoIcons.flame,
                          l10n.trending,
                        ),
                        _buildNavItem(
                          2,
                          CupertinoIcons.square_grid_2x2_fill,
                          CupertinoIcons.square_grid_2x2,
                          l10n.categories,
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

  Widget _buildHeaderIcon(
    String asset,
    VoidCallback onTap,
    bool isDarkMode, {
    int? count,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (isDarkMode ? Colors.white : Colors.black).withOpacity(
                0.05,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Image.asset(
              asset,
              color: isDarkMode ? Colors.white : Colors.black,
              width: 20,
              height: 20,
            ),
          ),
          if (count != null && count > 0)
            Positioned(
              top: -5,
              right: -5,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                child: Text(
                  count > 99 ? '99+' : count.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeaderIconButton(
    IconData icon,
    VoidCallback onTap,
    bool isDarkMode,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: (isDarkMode ? Colors.white : Colors.black).withOpacity(0.05),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          icon,
          color: isDarkMode ? Colors.white : Colors.black,
          size: 20,
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
