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

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  bool isLastPage = false;
  late AnimationController _liquidController;
  double page = 0;

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

  @override
  void initState() {
    super.initState();
    _liquidController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _pageController.addListener(() {
      setState(() {
        page = _pageController.page ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _liquidController.dispose();
    _pageController.dispose();
    super.dispose();
  }

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
              physics: const CustomPageViewScrollPhysics(),
              itemBuilder: (context, index) {
                return AnimatedBuilder(
                  animation: _pageController,
                  builder: (context, child) {
                    double page = _pageController.position.haveDimensions
                        ? _pageController.page ?? 0
                        : 0;

                    double pageOffset = page - index;

                    return Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY(pageOffset * 0.8)
                        ..translate(
                            pageOffset * MediaQuery.of(context).size.width)
                        ..scale(1.0 - (pageOffset.abs() * 0.2)),
                      child: Opacity(
                        opacity: (1 - pageOffset.abs()).clamp(0.0, 1.0),
                        child: child,
                      ),
                    );
                  },
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 24.w, vertical: 32.h),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Hero(
                            tag: 'onboarding_image_$index',
                            child: Container(
                              height: 250.h,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20.r),
                                child: Image.asset(
                                  onboardingPages[index].imagePath,
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 32.h),
                          Text(
                            onboardingPages[index].title,
                            style: TextStyle(
                              fontSize: 28.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.deepOrange,
                              height: 1.2,
                              letterSpacing: 0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            onboardingPages[index].description,
                            style: TextStyle(
                              fontSize: 15.sp,
                              color: Colors.grey[700],
                              height: 1.5,
                              letterSpacing: 0.3,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: isLastPage ? 0.0 : 1.0,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        transform: Matrix4.translationValues(
                          isLastPage ? -50.0 : 0.0,
                          0.0,
                          0.0,
                        ),
                        child: TextButton.icon(
                          onPressed:
                              isLastPage ? null : () => _completeOnboarding(),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.w, vertical: 8.h),
                            backgroundColor: Colors.grey[100],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                          ),
                          icon: Icon(
                            Icons.skip_next_rounded,
                            color: Colors.deepOrange,
                            size: 20.sp,
                          ),
                          label: Text(
                            'Skip',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.deepOrange,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
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
                        color: Colors.deepOrange,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.deepOrange.withOpacity(0.3),
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
                          customBorder: CircleBorder(),
                          child: Container(
                            padding: EdgeInsets.all(16.w),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              transitionBuilder: (child, animation) {
                                return RotationTransition(
                                  turns: animation,
                                  child: ScaleTransition(
                                    scale: animation,
                                    child: child,
                                  ),
                                );
                              },
                              child: Icon(
                                isLastPage
                                    ? Icons.check_rounded
                                    : Icons.chevron_right_rounded,
                                key: ValueKey<bool>(isLastPage),
                                color: Colors.white,
                                size: 28.sp,
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

class CustomPageViewScrollPhysics extends ScrollPhysics {
  const CustomPageViewScrollPhysics({ScrollPhysics? parent})
      : super(parent: parent);

  @override
  CustomPageViewScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return CustomPageViewScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  SpringDescription get spring => const SpringDescription(
        mass: 80,
        stiffness: 100,
        damping: 1,
      );
}
