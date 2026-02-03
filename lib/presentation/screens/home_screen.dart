import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart'; // Keep this one for SliverMasonryGrid.count

import '../providers/wallpaper_provider.dart';
import 'settings_screen.dart';
import 'favorites_screen.dart';
import '../../core/constants/app_constants.dart';
import '../widgets/wallpaper_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const HomeContent();
  }
}

class HomeContent extends ConsumerStatefulWidget {
  const HomeContent({super.key});

  @override
  ConsumerState<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends ConsumerState<HomeContent> {
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final wallpapersAsync = ref.watch(wallpapersProvider);
    final isDarkMode = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      body: wallpapersAsync.when(
        data: (categories) {
          if (categories.isEmpty) {
            return const Center(child: Text('No wallpapers found.'));
          }

          final allWallpapers = categories.expand((c) => c.wallpapers).toList();
          final displayedWallpapers = _selectedCategory == 'All'
              ? allWallpapers
              : allWallpapers
                    .where((w) => w.category == _selectedCategory)
                    .toList();

          final allCategories = ['All', ...categories.map((c) => c.name)];

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // iOS Style Integrated Header
              SliverAppBar(
                floating: true,
                pinned: true,
                backgroundColor: isDarkMode ? Colors.black : Colors.white,
                elevation: 0,
                scrolledUnderElevation: 0,
                automaticallyImplyLeading: false,
                titleSpacing: 20,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppConstants.appName,
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w700,
                        fontSize: 22,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: Icon(
                            CupertinoIcons.heart,
                            color: isDarkMode ? Colors.white : Colors.black,
                            size: 24,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const FavoritesScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: Icon(
                            CupertinoIcons.settings,
                            color: isDarkMode ? Colors.white : Colors.black,
                            size: 22,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SettingsScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(54),
                  child: Container(
                    height: 54,
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: allCategories.length,
                      itemBuilder: (context, index) {
                        final category = allCategories[index];
                        final isSelected = _selectedCategory == category;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _selectedCategory = category),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (isDarkMode ? Colors.white : Colors.black)
                                  : (isDarkMode
                                        ? Colors.white12
                                        : Colors.grey[100]),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Center(
                              child: Text(
                                category,
                                style: TextStyle(
                                  color: isSelected
                                      ? (isDarkMode
                                            ? Colors.black
                                            : Colors.white)
                                      : (isDarkMode
                                            ? Colors.white60
                                            : Colors.black54),
                                  fontWeight: isSelected
                                      ? FontWeight.w800
                                      : FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              // Grid with Premium Aspect Ratio
              displayedWallpapers.isEmpty
                  ? SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              CupertinoIcons.photo,
                              size: 64,
                              color: isDarkMode
                                  ? Colors.white24
                                  : Colors.black12,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No wallpapers in this category',
                              style: TextStyle(
                                color: isDarkMode
                                    ? Colors.white60
                                    : Colors.black54,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
                      sliver: SliverMasonryGrid.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 20,
                        crossAxisSpacing: 20,
                        itemBuilder: (context, index) {
                          final wallpaper = displayedWallpapers[index];
                          return WallpaperCard(wallpaper: wallpaper);
                        },
                        childCount: displayedWallpapers.length,
                      ),
                    ),
            ],
          );
        },
        loading: () => Center(
          child: CircularProgressIndicator(
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                CupertinoIcons.exclamationmark_circle,
                size: 48,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                err.toString(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                  fontSize: 12,
                ),
              ),
              TextButton(
                onPressed: () => ref.refresh(wallpapersProvider),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
