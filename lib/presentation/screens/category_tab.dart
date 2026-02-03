import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/wallpaper_provider.dart';
import '../widgets/wallpaper_card.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../data/models/wallpaper_model.dart';
import 'package:flutter/cupertino.dart';

class CategoryTab extends ConsumerWidget {
  const CategoryTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallpapersAsync = ref.watch(wallpapersProvider);
    final isDarkMode = ref.watch(themeProvider);

    return wallpapersAsync.when(
      data: (categories) {
        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final category = categories[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _CategoryItem(
                    category: category,
                    isDarkMode: isDarkMode,
                  ),
                );
              }, childCount: categories.length),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ), // Bottom padding for nav bar
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final CategoryModel category;
  final bool isDarkMode;

  const _CategoryItem({required this.category, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryDetailScreen(category: category),
          ),
        );
      },
      child: Container(
        height: 120,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: category.wallpapers.isNotEmpty
              ? DecorationImage(
                  image: NetworkImage(category.wallpapers.first.url),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.4),
                    BlendMode.darken,
                  ),
                )
              : null,
          color: isDarkMode ? Colors.white10 : Colors.grey[200],
        ),
        child: Center(
          child: Text(
            category.name.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }
}

class CategoryDetailScreen extends ConsumerWidget {
  final CategoryModel category;

  const CategoryDetailScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        title: Text(
          category.name,
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            CupertinoIcons.back,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverMasonryGrid.count(
              crossAxisCount: 2,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              itemBuilder: (context, index) {
                return WallpaperCard(wallpaper: category.wallpapers[index]);
              },
              childCount: category.wallpapers.length,
            ),
          ),
        ],
      ),
    );
  }
}
