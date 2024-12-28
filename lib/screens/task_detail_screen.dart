import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:todo_app/componants/shard_componant.dart';
import 'package:todo_app/cubit/cubit.dart';
import 'package:todo_app/cubit/states.dart';
import 'package:todo_app/models/task_model.dart';

class TaskDetailScreen extends StatefulWidget {
  final TaskModel task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController titleController;
  late TextEditingController detailsController;
  late TextEditingController dateController;
  late TextEditingController timeController;
  late TaskModel currentTask;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  var formkey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    currentTask = widget.task;
    titleController = TextEditingController(text: currentTask.title);
    detailsController = TextEditingController(text: currentTask.details ?? '');
    dateController = TextEditingController(text: currentTask.date);
    timeController = TextEditingController(text: currentTask.time);

    // Set the priority from the task or default to 'medium'
    final todoCubit = TodoCubit.get(context);
    todoCubit.changePriority(currentTask.priority);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    titleController.dispose();
    detailsController.dispose();
    dateController.dispose();
    timeController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TodoCubit, TodoStates>(
      listener: (context, state) {
        if (state is UpdateTaskSuccessState) {
          Navigator.pop(context);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1A1A1A)
              : Theme.of(context).scaffoldBackgroundColor,
          floatingActionButton: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.deepOrange,
                  Colors.deepOrange.shade700,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.deepOrange.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: FloatingActionButton(
              elevation: 0,
              backgroundColor: Colors.transparent,
              child: Icon(
                Icons.edit_rounded,
                color: Colors.white,
                size: 24.w,
              ),
              onPressed: () => _showEditDialog(context),
            ),
          ),
          bottomNavigationBar: Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF2D2D2D)
                  : Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: const Offset(0, -4),
                  blurRadius: 16,
                ),
              ],
            ),
            child: Container(
              height: 56.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: currentTask.status == 'done'
                      ? [
                          Colors.green.shade400,
                          Colors.green.shade300,
                        ]
                      : [
                          Colors.deepOrange,
                          Colors.deepOrange.shade700,
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: (currentTask.status == 'done'
                            ? Colors.green
                            : Colors.deepOrange)
                        .withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16.r),
                  onTap: () {
                    final newStatus =
                        currentTask.status == 'done' ? 'new' : 'done';
                    final todoCubit = TodoCubit.get(context);
                    final scaffoldMessenger = ScaffoldMessenger.of(context);

                    if (currentTask.id == null) {
                      scaffoldMessenger.showSnackBar(
                        const SnackBar(
                          content: Text('Error: Task ID is missing'),
                        ),
                      );
                      return;
                    }

                    if (currentTask.id == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Cannot update task: Invalid task ID'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    todoCubit
                        .updateTaskStatus(
                      id: currentTask
                          .id!, // Safe to use ! operator now after null check
                      status: newStatus,
                    )
                        .then((_) {
                      if (mounted) {
                        setState(() {
                          currentTask = currentTask.copyWith(status: newStatus);
                        });
                      }

                      scaffoldMessenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            newStatus == 'done'
                                ? 'Task marked as complete'
                                : 'Task marked as incomplete',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                            ),
                          ),
                          backgroundColor:
                              Theme.of(context).brightness == Brightness.dark
                                  ? Colors.grey[800]
                                  : Colors.black87,
                          action: SnackBarAction(
                            label: 'Undo',
                            textColor: Colors.deepOrange,
                            onPressed: () {
                              final previousStatus =
                                  newStatus == 'done' ? 'new' : 'done';
                              todoCubit
                                  .updateTaskStatus(
                                id: currentTask
                                    .id!, // Safe to use ! operator now after null check
                                status: previousStatus,
                              )
                                  .then((_) {
                                if (mounted) {
                                  setState(() {
                                    currentTask = currentTask.copyWith(
                                        status: previousStatus);
                                  });
                                }
                              });
                            },
                          ),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          margin: EdgeInsets.only(
                            bottom: 20.h,
                            left: 16.w,
                            right: 16.w,
                          ),
                          duration: const Duration(seconds: 3),
                          elevation:
                              Theme.of(context).brightness == Brightness.dark
                                  ? 4
                                  : 2,
                        ),
                      );
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        currentTask.status == 'done'
                            ? Icons.check_circle_rounded
                            : Icons.check_circle_outline_rounded,
                        color: Colors.white,
                        size: 24.w,
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        currentTask.status == 'done'
                            ? 'Mark as Incomplete'
                            : 'Mark as Complete',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF2D2D2D)
                        : Colors.deepOrange.shade400,
                    Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF1A1A1A)
                        : Colors.deepOrange.shade300,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    offset: const Offset(0, 2),
                    blurRadius: 12,
                  ),
                ],
              ),
            ),
            centerTitle: true,
            title: Text(
              'Task Details',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.5,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.2),
                    offset: const Offset(0, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
            leading: Container(
              margin: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: Colors.white.withOpacity(0.15),
                  width: 1.2,
                ),
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: Icon(
                  Icons.arrow_back_ios_rounded,
                  size: 20.w,
                  color: Colors.white,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            actions: [
              Container(
                margin: EdgeInsets.all(10.w),
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.15),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    Icons.delete_rounded,
                    color: Colors.white,
                    size: 20.w,
                  ),
                  onPressed: () => _showDeleteDialog(context),
                ),
              ),
              SizedBox(width: 6.w),
            ],
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness:
                  Theme.of(context).brightness == Brightness.dark
                      ? Brightness.light
                      : Brightness.dark,
            ),
          ),
          body: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF1E1E1E)
                            : Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(24.r),
                        border: Border.all(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[850]!
                              : Colors.grey[200]!,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.black.withOpacity(0.4)
                                    : Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.all(20.w),
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? const Color(0xFF252525)
                                  : Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.05),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(24.r),
                                topRight: Radius.circular(24.r),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(12.w),
                                      decoration: BoxDecoration(
                                        color: _getPriorityColor(
                                                currentTask.priority)
                                            .withOpacity(0.1),
                                        borderRadius:
                                            BorderRadius.circular(16.r),
                                        border: Border.all(
                                          color: _getPriorityColor(
                                                  currentTask.priority)
                                              .withOpacity(0.2),
                                          width: 1,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.flag_rounded,
                                        color: _getPriorityColor(
                                            currentTask.priority),
                                        size: 24.w,
                                      ),
                                    ),
                                    SizedBox(width: 16.w),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            currentTask.title,
                                            style: TextStyle(
                                              fontSize: 20.sp,
                                              fontWeight: FontWeight.w600,
                                              color: Theme.of(context)
                                                          .brightness ==
                                                      Brightness.dark
                                                  ? Colors.grey[200]
                                                  : Theme.of(context)
                                                      .textTheme
                                                      .titleLarge
                                                      ?.color,
                                              decoration: currentTask.status ==
                                                      'done'
                                                  ? TextDecoration.lineThrough
                                                  : null,
                                            ),
                                          ),
                                          SizedBox(height: 8.h),
                                          Row(
                                            children: [
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 12.w,
                                                    vertical: 6.h),
                                                decoration: BoxDecoration(
                                                  color: _getPriorityColor(
                                                          currentTask.priority)
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20.r),
                                                  border: Border.all(
                                                    color: _getPriorityColor(
                                                            currentTask
                                                                .priority)
                                                        .withOpacity(0.2),
                                                    width: 1,
                                                  ),
                                                ),
                                                child: Text(
                                                  currentTask.priority
                                                      .toString()
                                                      .toUpperCase(),
                                                  style: TextStyle(
                                                    color: _getPriorityColor(
                                                        currentTask.priority),
                                                    fontSize: 12.sp,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(20.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Time and Date Section
                                Container(
                                  padding: EdgeInsets.all(16.w),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.grey[850]
                                        : Colors.grey[50],
                                    borderRadius: BorderRadius.circular(16.r),
                                    border: Border.all(
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.grey[800]!
                                          : Colors.grey[200]!,
                                      width: 1,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(10.w),
                                            decoration: BoxDecoration(
                                              color: Colors.deepOrange
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(12.r),
                                              border: Border.all(
                                                color: Colors.deepOrange
                                                    .withOpacity(0.2),
                                                width: 1,
                                              ),
                                            ),
                                            child: Icon(
                                              Icons.access_time_rounded,
                                              color: Colors.deepOrange,
                                              size: 20.w,
                                            ),
                                          ),
                                          SizedBox(width: 12.w),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Time',
                                                style: TextStyle(
                                                  fontSize: 12.sp,
                                                  fontWeight: FontWeight.w500,
                                                  color: Theme.of(context)
                                                              .brightness ==
                                                          Brightness.dark
                                                      ? Colors.grey[400]
                                                      : Colors.grey[600],
                                                ),
                                              ),
                                              SizedBox(height: 4.h),
                                              Text(
                                                currentTask.time,
                                                style: TextStyle(
                                                  fontSize: 14.sp,
                                                  fontWeight: FontWeight.w600,
                                                  color: Theme.of(context)
                                                              .brightness ==
                                                          Brightness.dark
                                                      ? Colors.grey[200]
                                                      : Colors.grey[800],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 16.h),
                                      Container(
                                        width: double.infinity,
                                        height: 1,
                                        color: Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.grey[800]
                                            : Colors.grey[300],
                                      ),
                                      SizedBox(height: 16.h),
                                      Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(10.w),
                                            decoration: BoxDecoration(
                                              color: Colors.deepOrange
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(12.r),
                                              border: Border.all(
                                                color: Colors.deepOrange
                                                    .withOpacity(0.2),
                                                width: 1,
                                              ),
                                            ),
                                            child: Icon(
                                              Icons.calendar_today_rounded,
                                              color: Colors.deepOrange,
                                              size: 20.w,
                                            ),
                                          ),
                                          SizedBox(width: 12.w),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Date',
                                                style: TextStyle(
                                                  fontSize: 12.sp,
                                                  fontWeight: FontWeight.w500,
                                                  color: Theme.of(context)
                                                              .brightness ==
                                                          Brightness.dark
                                                      ? Colors.grey[400]
                                                      : Colors.grey[600],
                                                ),
                                              ),
                                              SizedBox(height: 4.h),
                                              Text(
                                                currentTask.date,
                                                style: TextStyle(
                                                  fontSize: 14.sp,
                                                  fontWeight: FontWeight.w600,
                                                  color: Theme.of(context)
                                                              .brightness ==
                                                          Brightness.dark
                                                      ? Colors.grey[200]
                                                      : Colors.grey[800],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 20.h),
                                // Category Section
                                if (currentTask.category.isNotEmpty) ...[
                                  Container(
                                    padding: EdgeInsets.all(16.w),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.grey[850]
                                          : Colors.grey[50],
                                      borderRadius: BorderRadius.circular(16.r),
                                      border: Border.all(
                                        color: Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.grey[800]!
                                            : Colors.grey[200]!,
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(10.w),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(12.r),
                                            border: Border.all(
                                              color:
                                                  Colors.blue.withOpacity(0.2),
                                              width: 1,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.category_rounded,
                                            color: Colors.blue,
                                            size: 20.w,
                                          ),
                                        ),
                                        SizedBox(width: 12.w),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Category',
                                              style: TextStyle(
                                                fontSize: 12.sp,
                                                fontWeight: FontWeight.w500,
                                                color: Theme.of(context)
                                                            .brightness ==
                                                        Brightness.dark
                                                    ? Colors.grey[400]
                                                    : Colors.grey[600],
                                              ),
                                            ),
                                            SizedBox(height: 4.h),
                                            Text(
                                              currentTask.category,
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w600,
                                                color: Theme.of(context)
                                                            .brightness ==
                                                        Brightness.dark
                                                    ? Colors.grey[200]
                                                    : Colors.grey[800],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 20.h),
                                ],
                                // Status Indicator
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16.w, vertical: 12.h),
                                  decoration: BoxDecoration(
                                    color: currentTask.status == 'done'
                                        ? Colors.green.withOpacity(0.1)
                                        : Colors.deepOrange.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12.r),
                                    border: Border.all(
                                      color: currentTask.status == 'done'
                                          ? Colors.green.withOpacity(0.2)
                                          : Colors.deepOrange.withOpacity(0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        currentTask.status == 'done'
                                            ? Icons.check_circle_rounded
                                            : Icons.pending_rounded,
                                        color: currentTask.status == 'done'
                                            ? Colors.green
                                            : Colors.deepOrange,
                                        size: 20.w,
                                      ),
                                      SizedBox(width: 8.w),
                                      Text(
                                        currentTask.status == 'done'
                                            ? 'Completed'
                                            : 'In Progress',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w600,
                                          color: currentTask.status == 'done'
                                              ? Colors.green
                                              : Colors.deepOrange,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 20.h),
                                if (currentTask.details?.isNotEmpty ??
                                    false) ...[
                                  Text(
                                    'Description',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.color,
                                    ),
                                  ),
                                  SizedBox(height: 12.h),
                                  Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.all(16.w),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.grey[850]
                                          : Colors.grey[50],
                                      borderRadius: BorderRadius.circular(16.r),
                                      border: Border.all(
                                        color: Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.grey[800]!
                                            : Colors.grey[200]!,
                                        width: 1,
                                      ),
                                      boxShadow: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.2),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: Text(
                                      currentTask.details ?? '',
                                      style: TextStyle(
                                        fontSize: 15.sp,
                                        height: 1.5,
                                        color: Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.grey[300]
                                            : Colors.grey[800],
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 24.h),
                                ],
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
    );
  }

  void _showEditDialog(BuildContext context) {
    final todoCubit = TodoCubit.get(context);
    todoCubit.changePriority(currentTask.priority.toLowerCase());
    todoCubit.changeCategory(currentTask.category);

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => SafeArea(
        bottom: false,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.9,
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 20.h,
            left: 20.w,
            right: 20.w,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF2C2C2C)
                : Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20.r),
            ),
            border: Theme.of(context).brightness == Brightness.dark
                ? Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  )
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white.withOpacity(0.2)
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                SizedBox(height: 15.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(10.w),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.deepOrange,
                                      Colors.deepOrange.shade700,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(14.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.deepOrange.withOpacity(
                                          Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? 0.4
                                              : 0.25),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.edit_note_rounded,
                                  color: Colors.white,
                                  size: 28.sp,
                                ),
                              ),
                              SizedBox(width: 16.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Edit Task',
                                      style: TextStyle(
                                        fontSize: 32.sp,
                                        fontWeight: FontWeight.w800,
                                        color: Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.white
                                            : Colors.deepOrange,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    SizedBox(height: 8.h),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12.w,
                                        vertical: 6.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.deepOrange
                                                .withOpacity(0.15)
                                            : Colors.deepOrange
                                                .withOpacity(0.08),
                                        borderRadius:
                                            BorderRadius.circular(20.r),
                                        border: Border.all(
                                          color: Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.deepOrange
                                                  .withOpacity(0.3)
                                              : Colors.deepOrange
                                                  .withOpacity(0.2),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.auto_awesome,
                                            size: 16.sp,
                                            color:
                                                Theme.of(context).brightness ==
                                                        Brightness.dark
                                                    ? Colors.deepOrange.shade300
                                                    : Colors.deepOrange,
                                          ),
                                          SizedBox(width: 6.w),
                                          Text(
                                            'Make it perfect',
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              color: Theme.of(context)
                                                          .brightness ==
                                                      Brightness.dark
                                                  ? Colors.deepOrange.shade300
                                                  : Colors.deepOrange,
                                              fontWeight: FontWeight.w500,
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
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 16.w),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white.withOpacity(0.05)
                            : Colors.grey[50],
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white.withOpacity(0.1)
                              : Colors.grey[200]!,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 0,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.close_rounded,
                          size: 22.sp,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white.withOpacity(0.8)
                              : Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30.h),
                Form(
                  key: formkey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Basic Details',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black87,
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
                        onSubmit: (value) {},
                        onChange: (value) {},
                      ),
                      SizedBox(height: 15.h),
                      defaultFormField(
                        controller: detailsController,
                        context: context,
                        type: TextInputType.text,
                        validate: (value) {
                          if (value!.isEmpty) {
                            return 'Details must not be empty';
                          }
                          return null;
                        },
                        label: 'Task Details',
                        prefix: Icons.details_rounded,
                        maxLines: 3,
                      ),
                      SizedBox(height: 15.h),
                      defaultFormField(
                        controller: dateController,
                        context: context,
                        type: TextInputType.none,
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
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
                          );
                          if (picked != null) {
                            setState(() {
                              dateController.text =
                                  "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                            });
                          }
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
                      SizedBox(height: 15.h),
                      defaultFormField(
                        controller: timeController,
                        context: context,
                        type: TextInputType.none,
                        onTap: () async {
                          final TimeOfDay? picked = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (picked != null) {
                            setState(() {
                              timeController.text = picked.format(context);
                            });
                          }
                        },
                        validate: (value) {
                          if (value!.isEmpty) {
                            return 'Time must not be empty';
                          }
                          return null;
                        },
                        label: 'Task Time',
                        prefix: Icons.access_time,
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        'Task Properties',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black87,
                        ),
                      ),
                      SizedBox(height: 15.h),
                      Text(
                        'Priority Level',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 10.h),
                      StatefulBuilder(
                        builder: (context, setState) => _buildPrioritySection(
                          context,
                          TodoCubit.get(context),
                          setState,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        'Category',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 10.h),
                      StatefulBuilder(
                        builder: (context, setState) => _buildCategorySection(
                          context,
                          TodoCubit.get(context),
                          (category) {
                            setState(() {
                              TodoCubit.get(context).changeCategory(category);
                            });
                          },
                        ),
                      ),
                      SizedBox(height: 30.h),
                      Container(
                        width: double.infinity,
                        height: 55.h,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.deepOrange,
                              Colors.deepOrange.shade700,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.deepOrange.withOpacity(0.3),
                              blurRadius: 12,
                              spreadRadius: 2,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16.r),
                            splashColor: Colors.white.withOpacity(0.2),
                            highlightColor: Colors.white.withOpacity(0.1),
                            onTap: () async {
                              HapticFeedback.mediumImpact();
                              if (formkey.currentState!.validate()) {
                                final scaffoldMessenger =
                                    ScaffoldMessenger.of(context);
                                try {
                                  scaffoldMessenger.showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          SizedBox(
                                            height: 20.h,
                                            width: 20.w,
                                            child:
                                                const CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          ),
                                          SizedBox(width: 12.w),
                                          const Text('Updating task...'),
                                        ],
                                      ),
                                      duration: const Duration(seconds: 1),
                                      backgroundColor: Colors.deepOrange,
                                    ),
                                  );

                                  await TodoCubit.get(context).updateTask(
                                    id: currentTask.id!,
                                    title: titleController.text,
                                    time: timeController.text,
                                    date: dateController.text,
                                    details: detailsController.text,
                                    priority:
                                        TodoCubit.get(context).selectedPriority,
                                    category:
                                        TodoCubit.get(context).selectedCategory,
                                  );

                                  if (mounted) {
                                    setState(() {
                                      currentTask = currentTask.copyWith(
                                        title: titleController.text,
                                        time: timeController.text,
                                        date: dateController.text,
                                        details: detailsController.text,
                                        priority: TodoCubit.get(context)
                                            .selectedPriority,
                                        category: TodoCubit.get(context)
                                            .selectedCategory,
                                      );
                                    });
                                  }

                                  Navigator.pop(context);

                                  scaffoldMessenger.showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                          'Task updated successfully'),
                                      backgroundColor: Colors.green,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12.r),
                                      ),
                                      margin: EdgeInsets.only(
                                        bottom: 20.h,
                                        left: 16.w,
                                        right: 16.w,
                                      ),
                                    ),
                                  );
                                } catch (e) {
                                  scaffoldMessenger.showSnackBar(
                                    SnackBar(
                                      content: Text('Error: ${e.toString()}'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                            child: Center(
                              child: Text(
                                'Save Changes',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySection(
    BuildContext context,
    TodoCubit cubit,
    Function(String) onCategoryChanged,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          ...cubit.categories.map((category) {
            final categoryName = category['name'] as String;
            final bool isSelected = cubit.selectedCategory == categoryName;

            return Column(
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onCategoryChanged(categoryName);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (category['color'] as Color)
                                .withOpacity(isDark ? 0.2 : 0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: (category['color'] as Color)
                                  .withOpacity(isDark ? 0.2 : 0.1),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Icon(
                              category['icon'] as IconData,
                              color: isDark
                                  ? (category['color'] as Color).withOpacity(0.9)
                                  : category['color'] as Color,
                              size: 20.sp,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Text(
                            categoryName,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: isSelected
                                  ? (isDark
                                      ? (category['color'] as Color)
                                          .withOpacity(0.9)
                                      : category['color'] as Color)
                                  : (isDark
                                      ? Colors.white.withOpacity(0.9)
                                      : Colors.grey[700]),
                            ),
                          ),
                          const Spacer(),
                          if (isSelected)
                            Container(
                              padding: EdgeInsets.all(6.w),
                              decoration: BoxDecoration(
                                color: (category['color'] as Color)
                                    .withOpacity(isDark ? 0.2 : 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.check,
                                color: isDark
                                    ? (category['color'] as Color).withOpacity(0.9)
                                    : category['color'] as Color,
                                size: 16.sp,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (categoryName != cubit.categories.last['name'])
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.grey[200],
                  ),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildPrioritySection(
    BuildContext context,
    TodoCubit cubit,
    Function setState,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildPriorityOption(
            context,
            'High',
            cubit.selectedPriority.toLowerCase() == 'high',
            () => setState(() {
              cubit.selectedPriority = 'High';
              HapticFeedback.lightImpact();
            }),
            Colors.red[400]!,
            Icons.arrow_upward_rounded,
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[200],
          ),
          _buildPriorityOption(
            context,
            'Medium',
            cubit.selectedPriority.toLowerCase() == 'medium',
            () => setState(() {
              cubit.selectedPriority = 'Medium';
              HapticFeedback.lightImpact();
            }),
            Colors.orange[400]!,
            Icons.remove_rounded,
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[200],
          ),
          _buildPriorityOption(
            context,
            'Low',
            cubit.selectedPriority.toLowerCase() == 'low',
            () => setState(() {
              cubit.selectedPriority = 'Low';
              HapticFeedback.lightImpact();
            }),
            Colors.green[400]!,
            Icons.arrow_downward_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityOption(
    BuildContext context,
    String title,
    bool isSelected,
    VoidCallback onTap,
    Color color,
    IconData icon,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 12.h,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withOpacity(isDark ? 0.2 : 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: color.withOpacity(isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  icon,
                  color: isDark ? color.withOpacity(0.9) : color,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? (isDark ? color.withOpacity(0.9) : color)
                      : (isDark
                          ? Colors.white.withOpacity(0.9)
                          : Colors.grey[700]),
                ),
              ),
              const Spacer(),
              if (isSelected)
                Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    color: color.withOpacity(isDark ? 0.2 : 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    color: isDark ? color.withOpacity(0.9) : color,
                    size: 16.sp,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (currentTask.id == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cannot delete task: Invalid task ID'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              TodoCubit.get(context).deleteDatabase(currentTask
                  .id!); // Safe to use ! operator now after null check
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Return to previous screen
            },
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final normalizedPriority = priority.toLowerCase();

    switch (normalizedPriority) {
      case 'low':
        return isDark ? Colors.green.shade400 : Colors.green;
      case 'medium':
      case 'meduim': // Handle misspelling
        return isDark ? Colors.orange.shade300 : Colors.orange;
      case 'high':
        return isDark ? Colors.red.shade300 : Colors.red;
      default:
        return isDark
            ? Colors.orange.shade300
            : Colors.orange; // Default to medium priority color
    }
  }
}
