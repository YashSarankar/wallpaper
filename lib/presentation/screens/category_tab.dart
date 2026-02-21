import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/wallpaper_provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../data/models/wallpaper_model.dart';
import 'package:flutter/cupertino.dart';
import '../widgets/universal_image.dart';
import '../providers/settings_provider.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../widgets/wallpaper_card.dart';

import 'package:wallpaper/l10n/app_localizations.dart';
import 'package:wallpaper/core/extensions/l10n_extensions.dart';

class CategoryTab extends ConsumerWidget {
  const CategoryTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallpapersAsync = ref.watch(wallpapersProvider);
    final isDarkMode = ref.watch(themeProvider);
    final gridColumns = ref.watch(
      settingsProvider.select((s) => s.gridColumns),
    );
    final l10n = AppLocalizations.of(context)!;

    return wallpapersAsync.when(
      data: (categories) {
        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: SizedBox(height: MediaQuery.of(context).padding.top + 70),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: gridColumns,
                  mainAxisSpacing: gridColumns == 2 ? 16 : 10,
                  crossAxisSpacing: gridColumns == 2 ? 16 : 10,
                  childAspectRatio: gridColumns == 2 ? 0.85 : 0.75,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final category = categories[index];
                  return TweenAnimationBuilder<double>(
                    duration: Duration(milliseconds: 400 + (index * 60)),
                    tween: Tween(begin: 0.0, end: 1.0),
                    curve: Curves.easeOutQuart,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 30 * (1 - value)),
                          child: _CategoryItem(
                            category: category,
                            isDarkMode: isDarkMode,
                            isCompact: gridColumns == 3,
                          ),
                        ),
                      );
                    },
                  );
                }, childCount: categories.length),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 110)),
          ],
        );
      },
      loading: () => CustomScrollView(
        physics: const NeverScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(height: MediaQuery.of(context).padding.top + 70),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) =>
                    _SkeletonCategoryCard(isDarkMode: isDarkMode),
                childCount: 8,
              ),
            ),
          ),
        ],
      ),
      error: (err, stack) =>
          Center(child: Text('${l10n.serverSleeping}: $err')),
    );
  }
}

class _CategoryItem extends StatefulWidget {
  final CategoryModel category;
  final bool isDarkMode;
  final bool isCompact;

  const _CategoryItem({
    required this.category,
    required this.isDarkMode,
    this.isCompact = false,
  });

  @override
  State<_CategoryItem> createState() => _CategoryItemState();
}

class _CategoryItemState extends State<_CategoryItem> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) =>
                CategoryDetailScreen(category: widget.category),
          ),
        );
      },
      child: AnimatedScale(
        duration: const Duration(milliseconds: 200),
        scale: _isPressed ? 0.94 : 1.0,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.isCompact ? 24 : 32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: widget.isCompact ? 15 : 25,
                offset: Offset(0, widget.isCompact ? 6 : 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.isCompact ? 24 : 32),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background Image
                if (widget.category.wallpapers.isNotEmpty)
                  UniversalImage(
                    path:
                        widget.category.wallpapers.first.midUrl ??
                        widget.category.wallpapers.first.url,
                    fit: BoxFit.cover,
                  )
                else
                  Container(
                    color: widget.isDarkMode
                        ? Colors.white10
                        : Colors.grey[200],
                  ),

                // Premium Gradient Overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.4, 1.0],
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.85),
                      ],
                    ),
                  ),
                ),

                // Category Name
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(widget.isCompact ? 12 : 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          AppLocalizations.of(
                            context,
                          )!.getLocalizedCategory(widget.category.name),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: widget.isCompact ? 14 : 18,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (!widget.isCompact) ...[
                          const SizedBox(height: 4),
                          Container(
                            width: 20,
                            height: 3,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ],
                      ],
                    ),
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

class CategoryDetailScreen extends ConsumerWidget {
  final CategoryModel category;

  const CategoryDetailScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);
    final gridColumns = ref.watch(
      settingsProvider.select((s) => s.gridColumns),
    );
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            floating: false,
            pinned: true,
            elevation: 0,
            scrolledUnderElevation: 0,
            backgroundColor: (isDarkMode ? Colors.black : Colors.white)
                .withOpacity(0.8),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                AppLocalizations.of(
                  context,
                )!.getLocalizedCategory(category.name),
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              background: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(color: Colors.transparent),
                ),
              ),
            ),
            leading: IconButton(
              icon: Icon(
                CupertinoIcons.back,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
            sliver: SliverMasonryGrid.count(
              crossAxisCount: gridColumns,
              mainAxisSpacing: gridColumns == 2 ? 12 : 8,
              crossAxisSpacing: gridColumns == 2 ? 12 : 8,
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

class _SkeletonCategoryCard extends StatefulWidget {
  final bool isDarkMode;
  const _SkeletonCategoryCard({required this.isDarkMode});

  @override
  State<_SkeletonCategoryCard> createState() => _SkeletonCategoryCardState();
}

class _SkeletonCategoryCardState extends State<_SkeletonCategoryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final baseColor = widget.isDarkMode
            ? Colors.white.withOpacity(0.06)
            : Colors.black.withOpacity(0.06);
        final highlightColor = widget.isDarkMode
            ? Colors.white.withOpacity(0.12)
            : Colors.black.withOpacity(0.10);
        return Container(
          decoration: BoxDecoration(
            color: Color.lerp(baseColor, highlightColor, _animation.value),
            borderRadius: BorderRadius.circular(32),
          ),
        );
      },
    );
  }
}
