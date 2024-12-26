import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:todo_app/layout/home_layout.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_app/screens/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();

    Future.delayed(const Duration(seconds: 3), () async {
      if (mounted) {
        final prefs = await SharedPreferences.getInstance();
        final showOnboarding = prefs.getBool('showOnboarding') ?? true;

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) =>
                showOnboarding ? const OnboardingScreen() : HomeScreen(),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.deepOrange.shade900, // Deep Orange
              Colors.orange.shade300, // Light Orange
            ],
            stops: const [0.2, 0.9],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Transform.translate(
                      offset: Offset(0, _slideAnimation.value),
                      child: Transform.scale(
                        scale: _scaleAnimation.value,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.all(28.r),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      spreadRadius: 5,
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.check_circle_outline,
                                  size: 80.r,
                                  color: Colors.deepOrange.shade900,
                                ),
                              ),
                              SizedBox(height: 30.h),
                              Text(
                                'Todo App',
                                style: TextStyle(
                                  fontSize: 32.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1.2,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.3),
                                      offset: const Offset(0, 2),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 10.h),
                              Text(
                                'Organize your life',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: Colors.white.withOpacity(0.9),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(height: 20.h),
                              Text(
                                'v1.0.0',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
