import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import '../providers/wallpaper_provider.dart';
import 'home_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _lottieController;
  late AnimationController _mainController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _blurAnimation;
  late Animation<double> _textOpacityAnimation;
  late AnimationController _driftController;

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(vsync: this);

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );

    _driftController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.8,
          end: 1.05,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.05,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 60,
      ),
    ]).animate(_mainController);

    _blurAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
      ),
    );

    _textOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.5, 0.85, curve: Curves.easeIn),
      ),
    );

    // Start pre-fetching wallpapers immediately
    ref.read(wallpapersProvider);

    _mainController.forward();
  }

  @override
  void dispose() {
    _lottieController.dispose();
    _mainController.dispose();
    _driftController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF000000),
        body: Stack(
          children: [
            // iPhone-style Ethereal Moving Background
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _driftController,
                builder: (context, child) {
                  return Stack(
                    children: [
                      _AtmosphericLight(
                        color: const Color(0xFF4F46E5).withOpacity(0.25),
                        beginAlignment: Alignment.topLeft,
                        endAlignment: Alignment.centerLeft,
                        controller: _driftController,
                        size: 700,
                      ),
                      _AtmosphericLight(
                        color: const Color(0xFF9333EA).withOpacity(0.2),
                        beginAlignment: Alignment.bottomRight,
                        endAlignment: Alignment.centerRight,
                        controller: _driftController,
                        size: 600,
                      ),
                      _AtmosphericLight(
                        color: const Color(0xFFDB2777).withOpacity(0.15),
                        beginAlignment: Alignment.topRight,
                        endAlignment: Alignment.bottomLeft,
                        controller: _driftController,
                        size: 500,
                      ),
                    ],
                  );
                },
              ),
            ),

            // Glassmorphic Layer
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                child: Container(color: Colors.transparent),
              ),
            ),

            // Main Content
            Center(
              child: AnimatedBuilder(
                animation: _mainController,
                builder: (context, child) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(flex: 3),

                      // The Center Piece (Logo)
                      Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Soft Glow
                            Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF4F46E5,
                                    ).withOpacity(0.3),
                                    blurRadius: 100,
                                    spreadRadius: 30,
                                  ),
                                ],
                              ),
                            ),

                            // Lottie Animation
                            ImageFiltered(
                              imageFilter: ImageFilter.blur(
                                sigmaX: _blurAnimation.value,
                                sigmaY: _blurAnimation.value,
                              ),
                              child: Lottie.asset(
                                'assets/wallpapers.json',
                                controller: _lottieController,
                                width: 200,
                                height: 200,
                                onLoaded: (composition) {
                                  _lottieController
                                    ..duration = composition.duration
                                    ..forward().then((_) async {
                                      // Wait for data to be ready before navigating
                                      await ref.read(wallpapersProvider.future);
                                      _navigateToHome();
                                    });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Elegant iPhone-style Typography
                      FadeTransition(
                        opacity: _textOpacityAnimation,
                        child: Column(
                          children: [
                            Text(
                              'AMOZEA',
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.w900, // Extra Bold
                                letterSpacing: 14,
                                color: Colors.white,
                                fontFamily:
                                    'SF Pro Display', // This handles fallbacks automatically on iOS
                                shadows: [
                                  Shadow(
                                    color: Colors.white.withOpacity(0.35),
                                    blurRadius: 30,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'UNLEASH YOUR DISPLAY',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 6,
                                color: Colors.white.withOpacity(0.4),
                                fontFamily: 'SF Pro Text',
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(flex: 4),

                      // iOS Style Loading Indicator
                      FadeTransition(
                        opacity: _textOpacityAnimation,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 60),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.04),
                                  borderRadius: BorderRadius.circular(100),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.1),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white.withOpacity(0.6),
                                            ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Text(
                                      'PREPARING EXPERIENCE',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.5),
                                        fontSize: 9,
                                        letterSpacing: 2,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToHome() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const HomeScreen(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }
}

class _AtmosphericLight extends StatelessWidget {
  final Color color;
  final Alignment beginAlignment;
  final Alignment endAlignment;
  final AnimationController controller;
  final double size;

  const _AtmosphericLight({
    required this.color,
    required this.beginAlignment,
    required this.endAlignment,
    required this.controller,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final alignment = Alignment.lerp(
          beginAlignment,
          endAlignment,
          controller.value,
        )!;
        return Align(
          alignment: alignment,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [color, color.withOpacity(0.0)]),
            ),
          ),
        );
      },
    );
  }
}
