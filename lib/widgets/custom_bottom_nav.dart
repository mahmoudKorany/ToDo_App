import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      height: 80.h + MediaQuery.of(context).padding.bottom,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 8.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context,
                index: 0,
                icon: Icons.task_alt,
                label: 'Tasks',
                isSelected: currentIndex == 0,
              ),
              _buildNavItem(
                context,
                index: 1,
                icon: Icons.done_all,
                label: 'Done',
                isSelected: currentIndex == 1,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    required String label,
    required bool isSelected,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 24.w : 20.w,
          vertical: 8.h,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark
                  ? primaryColor.withOpacity(0.15)
                  : primaryColor.withOpacity(0.1))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(
                begin: 0.0,
                end: isSelected ? 1.0 : 0.8,
              ),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              builder: (context, value, child) => Transform.scale(
                scale: value,
                child: child,
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? primaryColor
                    : (isDark ? Colors.grey[400] : Colors.grey[600]),
                size: 24.sp,
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: isSelected ? 8.w : 0,
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: SizedBox(
                width: isSelected ? null : 0,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: isSelected ? 1.0 : 0.0,
                  child: Text(
                    isSelected ? label : '',
                    style: TextStyle(
                      color: isSelected
                          ? primaryColor
                          : (isDark ? Colors.grey[400] : Colors.grey[600]),
                      fontSize: 12.sp,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
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
}
