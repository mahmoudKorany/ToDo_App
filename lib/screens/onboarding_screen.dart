import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:todo_app/layout/home_layout.dart';
import '../models/onboarding_model.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  bool isLastPage = false;

  final List<OnboardingModel> onboardingPages = [
    OnboardingModel(
      title: 'Welcome to TodoApp',
      description:
          'Your personal task manager designed to boost your productivity and organize your daily life with ease',
      imagePath: 'assets/images/svg.png',
    ),
    OnboardingModel(
      title: 'Create & Manage Tasks',
      description:
          'Create, prioritize, and manage your tasks effortlessly. Set deadlines, add reminders, and stay on top of your goals',
      imagePath: 'assets/images/hero.png',
    ),
    OnboardingModel(
      title: 'Track Your Progress',
      description:
          'Visualize your productivity journey, celebrate completed tasks, and build better habits for success',
      imagePath: 'assets/images/note.jpg',
    ),
  ];

  void _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showOnboarding', false);
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  isLastPage = index == onboardingPages.length - 1;
                });
              },
              itemCount: onboardingPages.length,
              itemBuilder: (context, index) {
                return SingleChildScrollView(
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Hero(
                          tag: 'onboarding_image_$index',
                          child: Container(
                            height: 280.h,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24.r),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24.r),
                              child: Image.asset(
                                onboardingPages[index].imagePath,
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 48.h),
                        Text(
                          onboardingPages[index].title,
                          style: TextStyle(
                            fontSize: 32.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrange,
                            height: 1.2,
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 24.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Text(
                            onboardingPages[index].description,
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.grey[800],
                              height: 1.6,
                              letterSpacing: 0.3,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => _completeOnboarding(),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            horizontal: 24.w, vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SmoothPageIndicator(
                      controller: _pageController,
                      count: onboardingPages.length,
                      effect: WormEffect(
                        spacing: 12.w,
                        dotWidth: 10.w,
                        dotHeight: 10.h,
                        dotColor: Colors.grey[300]!,
                        activeDotColor: Colors.deepOrange,
                        strokeWidth: 1.5,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.deepOrange,
                            Colors.deepOrange.shade800,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.deepOrange.shade900.withOpacity(0.3),
                            spreadRadius: 0,
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            if (isLastPage) {
                              _completeOnboarding();
                            } else {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeInOut,
                              );
                            }
                          },
                          borderRadius: BorderRadius.circular(12.r),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 32.w, vertical: 14.h),
                            child: Text(
                              isLastPage ? 'Get Started' : 'Next',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
