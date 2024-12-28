import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_app/cubit/cubit.dart';
import 'package:todo_app/cubit/search/search_cubit.dart';
import 'package:todo_app/main.dart';
import 'package:todo_app/models/task_model.dart';
import 'package:todo_app/screens/search_screen.dart';
import 'package:todo_app/screens/task_detail_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

DateTime now = DateTime.now();
String currentDate = DateFormat('MMMM d, yyyy').format(now);
String currentDay = DateFormat('EEEE').format(now);

Widget defaultFormField({
  required TextEditingController controller,
  required TextInputType type,
  required BuildContext context,
  void Function(String)? onSubmit,
  void Function(String)? onChange,
  required String? Function(String?) validate,
  required String label,
  required IconData prefix,
  IconData? suffix,
  bool isPassword = false,
  bool enabled = true,
  void Function()? onPressed,
  void Function()? onTap,
  int? maxLines,
}) =>
    TextFormField(
      controller: controller,
      keyboardType: type,
      obscureText: isPassword,
      onFieldSubmitted: onSubmit,
      onChanged: onChange,
      validator: validate,
      maxLines: maxLines ?? 1,
      onTap: onTap,
      enabled: enabled,
      cursorColor: Colors.deepOrange,
      cursorWidth: 2.w,
      cursorHeight: 24.h,
      style: TextStyle(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black87,
        fontSize: 14.sp,
        letterSpacing: 0.5,
      ),
      decoration: InputDecoration(
        hintText: label,
        hintStyle: TextStyle(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[400]
              : Colors.grey[600],
          fontSize: 14.sp,
          letterSpacing: 0.5,
        ),
        alignLabelWithHint: maxLines != null,
        prefixIcon: Icon(
          prefix,
          color: Colors.deepOrange.shade400,
          size: 22.w,
        ),
        suffixIcon: suffix != null
            ? IconButton(
                onPressed: onPressed,
                icon: Icon(
                  suffix,
                  color: Colors.deepOrange.shade400,
                  size: 22.w,
                ),
              )
            : null,
        filled: true,
        fillColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[800]!.withOpacity(0.5)
            : Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.r),
          borderSide: BorderSide(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.transparent
                : Colors.grey[200]!,
            width: 1.w,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.r),
          borderSide: BorderSide(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.transparent
                : Colors.grey[200]!,
            width: 1.w,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.r),
          borderSide: BorderSide(
            color: Colors.deepOrange.shade400,
            width: 1.5.w,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.r),
          borderSide: BorderSide(
            color: Colors.red.shade300,
            width: 1.5.w,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.r),
          borderSide: BorderSide(
            color: Colors.red.shade400,
            width: 1.5.w,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: maxLines != null ? 16.h : 12.h,
        ),
      ),
    );

Widget buildTaskItem(TaskModel model, BuildContext context) {
  final cubit = TodoCubit.get(context);
  final categoryData = cubit.categories.firstWhere(
    (cat) => cat['name'] == model.category,
    orElse: () => cubit.categories.last,
  );
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return Dismissible(
    key: Key(model.id.toString()),
    background: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.shade400,
            Colors.green.shade300,
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.green.shade400.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            color: Colors.white,
            size: 24.w,
          ),
          SizedBox(width: 8.w),
          Text(
            'Complete',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
    secondaryBackground: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.red.shade300,
            Colors.red.shade400,
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.red.shade400.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      alignment: Alignment.centerRight,
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            'Delete',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: 8.w),
          Icon(
            Icons.delete_outline_rounded,
            color: Colors.white,
            size: 24.w,
          ),
        ],
      ),
    ),
    confirmDismiss: (direction) async {
      if (direction == DismissDirection.startToEnd) {
        // Complete task
        if (model.status != 'done') {
          HapticFeedback.mediumImpact();
          await cubit.updateTask(
            id: model.id!,
            title: model.title,
            details: model.details ?? '',
            date: model.date,
            time: model.time,
            priority: model.priority,
            category: model.category,
            status: 'done',
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8.w),
                  Text('Task completed successfully!'),
                ],
              ),
              backgroundColor: Colors.green.shade400,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
              margin: EdgeInsets.all(8.r),
            ),
          );
          return false; // Don't dismiss the item
        }
        return false;
      } else {
        // Delete task
        HapticFeedback.mediumImpact();
        final result = await showDeleteConfirmationDialog(context);
        if (result == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.delete_forever, color: Colors.white),
                  SizedBox(width: 8.w),
                  Text('Task deleted successfully!'),
                ],
              ),
              backgroundColor: Colors.red.shade400,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
              margin: EdgeInsets.all(8.r),
            ),
          );
        }
        return result ?? false;
      }
    },
    onDismissed: (direction) {
      if (direction == DismissDirection.endToStart) {
        cubit.deleteDatabase(model.id!);
      }
    },
    child: TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      tween: Tween<double>(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.95 + (0.05 * value),
          child: Opacity(
            opacity: value,
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        TaskDetailScreen(task: model),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      const begin = Offset(0.0, 0.05);
                      const end = Offset.zero;
                      const curve = Curves.easeOutCubic;
                      
                      var slideTween = Tween(begin: begin, end: end).chain(
                        CurveTween(curve: curve),
                      );
                      
                      var scaleTween = Tween(begin: 0.95, end: 1.0).chain(
                        CurveTween(curve: curve),
                      );

                      var opacityTween = Tween(begin: 0.0, end: 1.0).chain(
                        CurveTween(curve: curve),
                      );
                      
                      return SlideTransition(
                        position: animation.drive(slideTween),
                        child: ScaleTransition(
                          scale: animation.drive(scaleTween),
                          child: FadeTransition(
                            opacity: animation.drive(opacityTween),
                            child: child,
                          ),
                        ),
                      );
                    },
                    transitionDuration: const Duration(milliseconds: 400),
                  ),
                );
              },
              child: Container(
                margin: EdgeInsets.only(bottom: 12.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark 
                        ? [
                            const Color(0xFF1E1E1E),
                            const Color(0xFF2A2A2A),
                          ]
                        : [
                            Colors.white,
                            Colors.grey.shade50,
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: isDark 
                        ? Colors.white.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.2),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark 
                          ? Colors.black.withOpacity(0.3)
                          : Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    if (model.status == 'done')
                      Positioned(
                        right: 12.w,
                        top: 12.h,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.green.shade400,
                                Colors.green.shade300,
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(20.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                color: Colors.white,
                                size: 16.w,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                'Completed',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    Padding(
                      padding: EdgeInsets.all(20.r),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      (categoryData['color'] as Color).withOpacity(0.2),
                                      (categoryData['color'] as Color).withOpacity(0.1),
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(20.r),
                                  border: Border.all(
                                    color: (categoryData['color'] as Color).withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      categoryData['icon'] as IconData,
                                      color: categoryData['color'] as Color,
                                      size: 16.w,
                                    ),
                                    SizedBox(width: 4.w),
                                    Text(
                                      model.category,
                                      style: TextStyle(
                                        color: categoryData['color'] as Color,
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      _getPriorityColor(model.priority).withOpacity(0.2),
                                      _getPriorityColor(model.priority).withOpacity(0.1),
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(20.r),
                                  border: Border.all(
                                    color: _getPriorityColor(model.priority).withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      model.priority == 'High'
                                          ? Icons.arrow_upward_rounded
                                          : model.priority == 'Low'
                                              ? Icons.arrow_downward_rounded
                                              : Icons.remove_rounded,
                                      color: _getPriorityColor(model.priority),
                                      size: 16.w,
                                    ),
                                    SizedBox(width: 4.w),
                                    Text(
                                      model.priority,
                                      style: TextStyle(
                                        color: _getPriorityColor(model.priority),
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            model.title,
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black87,
                              decoration: model.status == 'done' ? TextDecoration.lineThrough : null,
                            ),
                          ),
                          if (model.details != null && model.details!.isNotEmpty) ...[
                            SizedBox(height: 8.h),
                            Text(
                              model.details!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14.sp,
                                height: 1.4,
                                color: isDark ? Colors.white70 : Colors.black54,
                                decoration: model.status == 'done' ? TextDecoration.lineThrough : null,
                              ),
                            ),
                          ],
                          SizedBox(height: 16.h),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(
                                color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.access_time_rounded,
                                  size: 16.w,
                                  color: isDark ? Colors.white60 : Colors.black45,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  '${model.time} • ${model.date}',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: isDark ? Colors.white60 : Colors.black45,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}

Future<void> showTaskBottomSheet(BuildContext context) {
  var cubit = TodoCubit.get(context);
  var titleController = TextEditingController();
  var timeController = TextEditingController();
  var dateController = TextEditingController();
  var detailsController = TextEditingController();
  var formKey = GlobalKey<FormState>();

  return showModalBottomSheet(
    isScrollControlled: true,
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 20.h,
        left: 20.w,
        right: 20.w,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20.r),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'Add New Task',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20.h),
            defaultFormField(
              controller: titleController,
              context: context,
              type: TextInputType.text,
              validate: (value) {
                if (value!.isEmpty) {
                  return 'Title must not be empty';
                }
                return null;
              },
              label: 'Task Title',
              prefix: Icons.title,
            ),
            SizedBox(height: 15.h),
            defaultFormField(
              controller: detailsController,
              type: TextInputType.multiline,
              context: context,
              validate: (value) {
                if (value!.isEmpty) {
                  return 'Details must not be empty';
                }
                return null;
              },
              label: 'Task Details',
              prefix: Icons.details,
              maxLines: 3,
            ),
            SizedBox(height: 15.h),
            defaultFormField(
              controller: timeController,
              type: TextInputType.none,
              context: context,
              onTap: () {
                showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                ).then((value) {
                  timeController.text = value!.format(context);
                });
              },
              validate: (value) {
                if (value!.isEmpty) {
                  return 'Time must not be empty';
                }
                return null;
              },
              label: 'Task Time',
              prefix: Icons.watch_later_outlined,
            ),
            SizedBox(height: 15.h),
            defaultFormField(
              context: context,
              controller: dateController,
              type: TextInputType.none,
              onTap: () {
                showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 36500)), // 100 years
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.light(
                          primary: Theme.of(context).primaryColor,
                          onPrimary: Colors.white,
                          surface: Theme.of(context).scaffoldBackgroundColor,
                          onSurface: Theme.of(context).textTheme.bodyLarge!.color!,
                        ),
                      ),
                      child: child!,
                    );
                  },
                ).then((value) {
                  dateController.text = DateFormat.yMMMd().format(value!);
                });
              },
              validate: (value) {
                if (value!.isEmpty) {
                  return 'Date must not be empty';
                }
                return null;
              },
              label: 'Task Date',
              prefix: Icons.calendar_today,
            ),
            SizedBox(height: 20.h),
            Text(
              'Priority',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 10.h),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildPriorityOption(
                    context,
                    'High',
                    Colors.red,
                    cubit.selectedPriority == 'high',
                    () => cubit.changePriority('high'),
                  ),
                  SizedBox(width: 8.w),
                  _buildPriorityOption(
                    context,
                    'Medium',
                    Colors.orange,
                    cubit.selectedPriority == 'medium',
                    () => cubit.changePriority('medium'),
                  ),
                  SizedBox(width: 8.w),
                  _buildPriorityOption(
                    context,
                    'Low',
                    Colors.green,
                    cubit.selectedPriority == 'low',
                    () => cubit.changePriority('low'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'Category',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 10.h),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: cubit.categories.map((category) {
                  return Padding(
                    padding: EdgeInsets.only(right: 8.w),
                    child: _buildCategoryOption(
                      context,
                      category['name'],
                      category['icon'],
                      category['color'],
                      cubit.selectedCategory == category['name'],
                      () => cubit.changeCategory(category['name']),
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 20.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    cubit.InsertDB(
                      title: titleController.text,
                      time: timeController.text,
                      date: dateController.text,
                      details: detailsController.text,
                      priority: cubit.selectedPriority,
                      category: cubit.selectedCategory,
                    ).then((_) {
                      Navigator.pop(context);
                      titleController.clear();
                      timeController.clear();
                      dateController.clear();
                      detailsController.clear();
                      cubit.changePriority('medium');
                      cubit.changeCategory('Personal');
                    });
                  }
                },
                child: Text(
                  'Add Task',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    ),
  );
}

Future<bool?> showDeleteConfirmationDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.red),
          SizedBox(width: 10.w),
          const Text('Delete Task'),
        ],
      ),
      content: const Text('Are you sure you want to delete this task?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text(
            'Delete',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    ),
  );
}

Color _getPriorityColor(String priority) {
  switch (priority.toLowerCase()) {
    case 'high':
      return Colors.red;
    case 'medium':
      return Colors.orange;
    case 'low':
      return Colors.green;
    default:
      return Colors.orange;
  }
}

Widget buildTasksScreen(context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello Friend 👋🏻',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black87,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Welcome back',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[300]
                          : Colors.grey[600],
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    margin: EdgeInsets.only(right: 8.w),
                    decoration: BoxDecoration(
                      color: Colors.deepOrange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.search_rounded,
                        color: Colors.deepOrange,
                        size: 22.w,
                      ),
                      onPressed: () {
                        final todoCubit = TodoCubit.get(context);
                        final allTasks = [
                          ...todoCubit.tasks.map((task) => task.toJson()),
                          ...todoCubit.doneTasks.map((task) => task.toJson()),
                        ];

                        Navigator.of(context).push(
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    BlocProvider(
                              create: (context) => SearchCubit(
                                allTasks: allTasks,
                              ),
                              child: const SearchScreen(),
                            ),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              const begin = Offset(1.0, 0.0);
                              const end = Offset.zero;
                              const curve = Curves.easeInOut;
                              
                              var tween = Tween(begin: begin, end: end)
                                  .chain(CurveTween(curve: curve));
                              
                              var offsetAnimation = animation.drive(tween);
                              return SlideTransition(
                                position: offsetAnimation,
                                child: child,
                              );
                            },
                            transitionDuration:
                                const Duration(milliseconds: 300),
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[800]
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: ThemeSwitcher(
                      builder: (context) => IconButton(
                        icon: Icon(
                          Theme.of(context).brightness == Brightness.dark
                              ? Icons.light_mode_rounded
                              : Icons.dark_mode_rounded,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black87,
                          size: 22.w,
                        ),
                        onPressed: () async {
                          final todoCubit = TodoCubit.get(context);
                          todoCubit.fabIcon = Icons.edit;
                          todoCubit.isBottomSheetShown = false;
                          final switcher = ThemeSwitcher.of(context);
                          final prefs = await SharedPreferences.getInstance();
                          final isDark =
                              Theme.of(context).brightness == Brightness.dark;
                          await prefs.setBool('isDark', !isDark);
                          switcher.changeTheme(
                            theme: isDark ? lightTheme : darkTheme,
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            'Ready to do your Daily Tasks??',
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black87,
              letterSpacing: 0.3,
            ),
          ),
          SizedBox(height: 10.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[800]!.withOpacity(0.5)
                  : Colors.grey[200]!.withOpacity(0.7),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 16.w,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[300]
                      : Colors.grey[700],
                ),
                SizedBox(width: 8.w),
                Text(
                  currentDay,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.deepOrange,
                  ),
                ),
                Text(
                  ' • ',
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[300]
                        : Colors.grey[700],
                  ),
                ),
                Text(
                  currentDate,
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[300]
                        : Colors.grey[700],
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.h),
            child: Row(
              children: [
                const Spacer(),
                CircleAvatar(
                  radius: 2.r,
                  backgroundColor: Colors.black,
                ),
                Container(
                  color: Colors.black,
                  height: 1.5.h,
                  width: 240.w,
                )
              ],
            ),
          ),
          Row(
            children: [
              Text(
                'Ongoing',
                style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              SizedBox(width: 10.w),
              IconButton(
                icon: Icon(
                  Icons.filter_alt,
                  color: Colors.red,
                  size: 30.w,
                ),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) {
                      String selectedPriority = 'medium';
                      return StatefulBuilder(
                        builder: (context, setState) => Container(
                          padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom,
                            top: 20.h,
                            left: 20.w,
                            right: 20.w,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20.r),
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Container(
                                  width: 40.w,
                                  height: 4.h,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(2.r),
                                  ),
                                ),
                              ),
                              SizedBox(height: 20.h),
                              Text(
                                'Filter Tasks by Priority',
                                style: TextStyle(
                                  fontSize: 24.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 20.h),
                              SizedBox(
                                height: 50.h,
                                width: double.infinity,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  child: Row(
                                    children: [
                                      _buildPriorityOption(
                                        context,
                                        'All',
                                        Colors.blue,
                                        selectedPriority == 'all',
                                        () => setState(
                                            () => selectedPriority = 'all'),
                                      ),
                                      SizedBox(width: 8.w),
                                      _buildPriorityOption(
                                        context,
                                        'High',
                                        Colors.red,
                                        selectedPriority == 'high',
                                        () => setState(
                                            () => selectedPriority = 'high'),
                                      ),
                                      SizedBox(width: 8.w),
                                      _buildPriorityOption(
                                        context,
                                        'Medium',
                                        Colors.orange,
                                        selectedPriority == 'medium',
                                        () => setState(
                                            () => selectedPriority = 'medium'),
                                      ),
                                      SizedBox(width: 8.w),
                                      _buildPriorityOption(
                                        context,
                                        'Low',
                                        Colors.green,
                                        selectedPriority == 'low',
                                        () => setState(
                                            () => selectedPriority = 'low'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 20.h),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.deepOrange,
                                    padding:
                                        EdgeInsets.symmetric(vertical: 12.h),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                  ),
                                  onPressed: () {
                                    TodoCubit.get(context)
                                        .filterTasksByPriority(
                                            selectedPriority);
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    'Apply Filter',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 20.h),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

Widget _buildPriorityOption(
  BuildContext context,
  String label,
  Color color,
  bool isSelected,
  VoidCallback onTap,
) {
  return GestureDetector(
    onTap: () {
      HapticFeedback.mediumImpact();
      onTap();
    },
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isSelected
              ? [
                  color.withOpacity(0.8),
                  color,
                ]
              : [
                  Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[800]!
                      : Colors.grey[100]!,
                  Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[850]!
                      : Colors.grey[50]!,
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isSelected
              ? color
              : Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[700]!
                  : Colors.grey[300]!,
          width: isSelected ? 2.w : 1.w,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 12.w,
            height: 12.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? Colors.white : color.withOpacity(0.5),
              border: Border.all(
                color: isSelected ? Colors.white : color,
                width: 2.w,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black87,
              fontSize: 14.sp,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildCategoryOption(
  BuildContext context,
  String category,
  IconData icon,
  Color color,
  bool isSelected,
  VoidCallback onTap,
) {
  return GestureDetector(
    onTap: () {
      HapticFeedback.mediumImpact();
      onTap();
    },
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isSelected
              ? [
                  color.withOpacity(0.8),
                  color,
                ]
              : [
                  Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[800]!
                      : Colors.grey[100]!,
                  Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[850]!
                      : Colors.grey[50]!,
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isSelected
              ? color
              : Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[700]!
                  : Colors.grey[300]!,
          width: isSelected ? 2.w : 1.w,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected
                  ? Colors.white.withOpacity(0.2)
                  : color.withOpacity(0.1),
            ),
            child: Icon(
              icon,
              color: isSelected ? Colors.white : color,
              size: 20.r,
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            category,
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black87,
              fontSize: 14.sp,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    ),
  );
}
