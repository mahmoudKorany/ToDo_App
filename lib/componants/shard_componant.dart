import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_app/cubit/cubit.dart';
import 'package:todo_app/cubit/search/search_cubit.dart';
import 'package:todo_app/main.dart';
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
      ),
      decoration: InputDecoration(
        hintText: label,
        alignLabelWithHint: maxLines != null,
        prefixIcon: Icon(
          prefix,
          color: Colors.deepOrange,
          size: 24.w,
        ),
        suffixIcon: suffix != null
            ? IconButton(
                onPressed: onPressed,
                icon: Icon(
                  suffix,
                  color: Colors.deepOrange,
                  size: 24.w,
                ),
              )
            : null,
        filled: true,
        fillColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[800]!.withOpacity(0.5)
            : Colors.grey[100]!,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.r),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.r),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.r),
          borderSide: BorderSide(
            color: Colors.deepOrange,
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
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      ),
    );

Widget buildTaskItem(Map model, BuildContext context) {
  return Dismissible(
    key: Key(model['id'].toString()),
    confirmDismiss: (direction) async {
      if (direction == DismissDirection.endToStart) {
        // Delete confirmation
        return await showDeleteConfirmationDialog(context);
      } else if (direction == DismissDirection.startToEnd) {
        if (model['status'] == 'new') {
          // Mark as done/undone
          await TodoCubit.get(context).updateData(
            id: model['id'],
            status: model['status'] == 'done' ? 'new' : 'done',
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                model['status'] == 'done'
                    ? 'Task marked as incomplete'
                    : 'Task completed',
                style: TextStyle(fontSize: 16.sp),
              ),
              behavior: SnackBarBehavior.floating,
              backgroundColor: model['status'] == 'done'
                  ? Colors.orange.shade400
                  : Colors.green.shade400,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
              duration: const Duration(seconds: 2),
            ),
          );
          return true;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Task already completed',
                style: TextStyle(fontSize: 16.sp, color: Colors.black),
              ),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.yellowAccent.shade400,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
              duration: const Duration(seconds: 2),
            ),
          );
          return false;
        }
      }
      return false;
    },
    onDismissed: (direction) {
      if (direction == DismissDirection.endToStart) {
        TodoCubit.get(context).deleteDatabase(model['id']);
      }
    },
    background: Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.green.shade400,
        borderRadius: BorderRadius.circular(16.r),
      ),
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Icon(
        Icons.check_circle_outline,
        color: Colors.white,
        size: 32.w,
      ),
    ),
    secondaryBackground: Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.red.shade400,
        borderRadius: BorderRadius.circular(16.r),
      ),
      alignment: Alignment.centerRight,
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Icon(
        Icons.delete_outline,
        color: Colors.white,
        size: 32.w,
      ),
    ),
    child: GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TaskDetailScreen(task: model),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(15.r),
        margin: EdgeInsets.symmetric(horizontal: 0.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 4.w,
              height: 50.h,
              decoration: BoxDecoration(
                color: _getPriorityColor(model['priority'] ?? 'medium'),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(width: 16.w),
            SizedBox(
              width: MediaQuery.of(context).size.width - 130.w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${model['title']}',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            decoration: model['status'] == 'done'
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                      ),
                      if (model['status'] == 'done')
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 16.sp,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                'Done',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  if (model['details'] != null &&
                      model['details'].toString().isNotEmpty) ...[
                    SizedBox(height: 8.h),
                    Text(
                      '${model['details'] ?? 'No Details'}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                  SizedBox(height: 8.h),
                  Flexible(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: _getPriorityColor(
                                      model['priority'] ?? 'medium')
                                  .withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.flag,
                                  color: _getPriorityColor(
                                      model['priority'] ?? 'medium'),
                                  size: 16.sp,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  model['priority']?.toString().toUpperCase() ??
                                      'MEDIUM',
                                  style: TextStyle(
                                    color: _getPriorityColor(
                                        model['priority'] ?? 'medium'),
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                color: Colors.grey,
                                size: 16.sp,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                '${model['time'] ?? 'No Time'}',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14.sp,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 16.w),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.calendar_today,
                                color: Colors.grey,
                                size: 16.sp,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                '${model['date'] ?? 'No Date'}',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14.sp,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
                          ...todoCubit.tasks,
                          ...todoCubit.doneTasks,
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

Future<dynamic> showAddTaskBottomSheet(BuildContext context) {
  var titleController = TextEditingController();
  var timeController = TextEditingController();
  var dateController = TextEditingController();
  var detailsController = TextEditingController();
  String selectedPriority = 'medium';
  var formKey = GlobalKey<FormState>();

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20.r),
        ),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20.r),
          child: Form(
            key: formKey,
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
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      defaultFormField(
                        context: context,
                        controller: titleController,
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
                        context: context,
                        controller: detailsController,
                        type: TextInputType.multiline,
                        maxLines: 3,
                        validate: (value) {
                          return null;
                        },
                        label: 'Task Details',
                        prefix: Icons.description,
                      ),
                      SizedBox(height: 15.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Priority',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 8.h),
                            StatefulBuilder(
                              builder: (context, setState) => Row(
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
                          ],
                        ),
                      ),
                      SizedBox(height: 15.h),
                      InkWell(
                        onTap: () {
                          showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          ).then((value) {
                            if (value != null) {
                              timeController.text = value.format(context);
                            }
                          });
                        },
                        child: defaultFormField(
                          context: context,
                          controller: timeController,
                          type: TextInputType.datetime,
                          validate: (value) {
                            if (value!.isEmpty) {
                              return 'Time must not be empty';
                            }
                            return null;
                          },
                          label: 'Task Time',
                          prefix: Icons.watch_later_outlined,
                          enabled: false,
                        ),
                      ),
                      SizedBox(height: 15.h),
                      InkWell(
                        onTap: () {
                          showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.parse('2025-12-31'),
                          ).then((value) {
                            if (value != null) {
                              dateController.text =
                                  DateFormat.yMMMd().format(value);
                            }
                          });
                        },
                        child: defaultFormField(
                          context: context,
                          controller: dateController,
                          type: TextInputType.datetime,
                          validate: (value) {
                            if (value!.isEmpty) {
                              return 'Date must not be empty';
                            }
                            return null;
                          },
                          label: 'Task Date',
                          prefix: Icons.calendar_today,
                          enabled: false,
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
                              TodoCubit.get(context).InsertDB(
                                title: titleController.text,
                                time: timeController.text,
                                date: dateController.text,
                                details: detailsController.text,
                                priority: selectedPriority,
                              );
                              Navigator.pop(context);
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
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

Widget _buildPriorityOption(
  BuildContext context,
  String label,
  Color color,
  bool isSelected,
  VoidCallback onTap,
) {
  return InkWell(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isSelected ? color : Colors.grey[300]!,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.flag,
            color: isSelected ? color : Colors.grey[400],
            size: 20.sp,
          ),
          SizedBox(width: 8.w),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? color : Colors.grey[600],
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    ),
  );
}
