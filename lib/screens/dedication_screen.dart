import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:todo_app/screens/splash_screen.dart';

class DedicationScreen extends StatefulWidget {
  const DedicationScreen({super.key});

  @override
  State<DedicationScreen> createState() => _DedicationScreenState();
}

class _DedicationScreenState extends State<DedicationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _floatAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _floatAnimation = Tween<double>(begin: -10.0, end: 10.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _controller.reverse();
        } else if (status == AnimationStatus.dismissed) {
          _controller.forward();
        }
      });

    _rotateAnimation = Tween<double>(
      begin: -0.05,
      end: 0.05,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    Colors.deepOrange.withOpacity(0.15),
                    Colors.deepPurple.withOpacity(0.1),
                    Colors.blue.withOpacity(0.05),
                  ]
                : [
                    Theme.of(context).primaryColor.withOpacity(0.1),
                    Theme.of(context).primaryColor.withOpacity(0.05),
                  ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Background animated circles
              if (isDark) ...[
                Positioned(
                  top: -100,
                  right: -100,
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _rotateAnimation.value,
                        child: Container(
                          width: 300,
                          height: 300,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                Colors.deepOrange.withOpacity(0.1),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  bottom: -150,
                  left: -100,
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: -_rotateAnimation.value,
                        child: Container(
                          width: 400,
                          height: 400,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                Colors.deepPurple.withOpacity(0.1),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated Photo
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Transform(
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..translate(0.0, _floatAnimation.value)
                          ..rotateZ(_rotateAnimation.value)
                          ..scale(_scaleAnimation.value),
                        alignment: Alignment.center,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Container(
                            width: 200.w,
                            height: 200.w,
                            margin: EdgeInsets.symmetric(horizontal: 20.w),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: isDark
                                      ? Colors.deepOrange.withOpacity(0.3)
                                      : Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                                if (isDark) ...[
                                  BoxShadow(
                                    color: Colors.deepOrange.withOpacity(0.2),
                                    blurRadius: 30,
                                    spreadRadius: 10,
                                  ),
                                  BoxShadow(
                                    color: Colors.deepPurple.withOpacity(0.2),
                                    blurRadius: 25,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ],
                              border: isDark
                                  ? Border.all(
                                      color: Colors.white.withOpacity(0.1),
                                      width: 2,
                                    )
                                  : null,
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/images/menna.jpeg',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 30.h),
                  // Animated Dedication Text
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: isDark
                                ? [
                                    Colors.white,
                                    Colors.white.withOpacity(0.9),
                                    Colors.deepOrange.withOpacity(0.8),
                                  ]
                                : [Colors.black87, Colors.black87],
                          ).createShader(bounds),
                          child: Text(
                            'Dedicated to',
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                              letterSpacing: isDark ? 1.2 : 0,
                            ),
                          ),
                        ),
                        SizedBox(height: 10.h),
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: isDark
                                ? [
                                    Colors.deepOrange,
                                    Colors.white,
                                    Colors.deepPurple,
                                  ]
                                : [
                                    Theme.of(context).primaryColor,
                                    Theme.of(context).primaryColor,
                                  ],
                          ).createShader(bounds),
                          child: Text(
                            'Dr. Menna Omar',
                            style: TextStyle(
                              fontSize: 32.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: isDark ? 2.0 : 0,
                            ),
                          ),
                        ),
                        SizedBox(height: 20.h),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 20.w),
                          padding: EdgeInsets.symmetric(
                            horizontal: 30.w,
                            vertical: 20.h,
                          ),
                          decoration: isDark
                              ? BoxDecoration(
                                  borderRadius: BorderRadius.circular(15.r),
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white.withOpacity(0.1),
                                      Colors.deepOrange.withOpacity(0.05),
                                      Colors.deepPurple.withOpacity(0.1),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.1),
                                    width: 1,
                                  ),
                                )
                              : null,
                          child: Text(
                            'With deep gratitude for your guidance and inspiration in the field of mobile development.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: isDark
                                  ? Colors.white.withOpacity(0.9)
                                  : Colors.black54,
                              height: 1.5,
                              letterSpacing: isDark ? 0.5 : 0,
                              shadows: isDark
                                  ? [
                                      Shadow(
                                        color: Colors.white.withOpacity(0.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1),
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                        ),
                        SizedBox(height: 40.h),
                        // Continue Button
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: GestureDetector(
                            onTap: () => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SplashScreen(),
                              ),
                            ),
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 40.w),
                              padding: EdgeInsets.symmetric(vertical: 15.h),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.deepOrange,
                                    Colors.deepOrange.shade800,
                                    Colors.deepOrange.shade900,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(30.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.deepOrange.withOpacity(0.3),
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                    spreadRadius: 1,
                                  ),
                                  if (isDark)
                                    BoxShadow(
                                      color: Colors.deepOrange.withOpacity(0.2),
                                      blurRadius: 20,
                                      offset: const Offset(0, -2),
                                      spreadRadius: 0,
                                    ),
                                ],
                                border: isDark
                                    ? Border.all(
                                        color:
                                            Colors.deepOrange.withOpacity(0.3),
                                        width: 1,
                                      )
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  'Continue to App',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black26,
                                        offset: const Offset(0, 1),
                                        blurRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),
                  // Credit Text
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: isDark
                            ? [
                                Colors.deepOrange.withOpacity(0.8),
                                Colors.white.withOpacity(0.9),
                                Colors.deepPurple.withOpacity(0.8),
                              ]
                            : [
                                Colors.deepOrange.withOpacity(0.7),
                                Colors.deepOrange.withOpacity(0.9),
                              ],
                      ).createShader(bounds),
                      child: Text(
                        'Made by Mahmoud Mohamed',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          letterSpacing: 1.0,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
