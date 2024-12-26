import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:todo_app/componants/shard_componant.dart';
import 'package:todo_app/cubit/cubit.dart';
import 'package:todo_app/cubit/states.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/services/notification_service.dart';

class TaskDetailScreen extends StatefulWidget {
  final Map task;

  const TaskDetailScreen({Key? key, required this.task}) : super(key: key);

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController titleController;
  late TextEditingController detailsController;
  late TextEditingController dateController;
  late TextEditingController timeController;
  late Map<String, dynamic> currentTask;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  var formkey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    currentTask = Map<String, dynamic>.from(widget.task);
    titleController = TextEditingController(text: currentTask['title']);
    detailsController =
        TextEditingController(text: currentTask['details'] ?? '');
    dateController = TextEditingController(text: currentTask['date']);
    timeController = TextEditingController(text: currentTask['time']);

    // Set the priority from the task or default to 'medium'
    final todoCubit = TodoCubit.get(context);
    todoCubit.changePriority(currentTask['priority'] ?? 'medium');

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
                  colors: currentTask['status'] == 'done'
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
                    color: (currentTask['status'] == 'done'
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
                        currentTask['status'] == 'done' ? 'new' : 'done';
                    final todoCubit = TodoCubit.get(context);
                    final scaffoldMessenger = ScaffoldMessenger.of(context);

                    todoCubit
                        .updateTaskStatus(
                      id: currentTask['id'],
                      status: newStatus,
                    )
                        .then((_) {
                      if (mounted) {
                        setState(() {
                          currentTask['status'] = newStatus;
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
                                id: currentTask['id'],
                                status: previousStatus,
                              )
                                  .then((_) {
                                if (mounted) {
                                  setState(() {
                                    currentTask['status'] = previousStatus;
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
                        currentTask['status'] == 'done'
                            ? Icons.check_circle_rounded
                            : Icons.check_circle_outline_rounded,
                        color: Colors.white,
                        size: 24.w,
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        currentTask['status'] == 'done'
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
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).brightness == Brightness.dark
                                ? const Color(0xFF2D2D2D)
                                : Theme.of(context).cardColor,
                            Theme.of(context).brightness == Brightness.dark
                                ? const Color(0xFF252525)
                                : Theme.of(context).cardColor.withOpacity(0.95),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
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
                              gradient: LinearGradient(
                                colors: [
                                  Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? const Color(0xFF2D2D2D)
                                      : Theme.of(context)
                                          .primaryColor
                                          .withOpacity(0.1),
                                  Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? const Color(0xFF252525)
                                      : Theme.of(context)
                                          .primaryColor
                                          .withOpacity(0.05),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
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
                                                currentTask['priority'] ??
                                                    'medium')
                                            .withOpacity(0.1),
                                        borderRadius:
                                            BorderRadius.circular(16.r),
                                      ),
                                      child: Icon(
                                        Icons.flag_rounded,
                                        color: _getPriorityColor(
                                            currentTask['priority'] ??
                                                'medium'),
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
                                            currentTask['title'],
                                            style: TextStyle(
                                              fontSize: 20.sp,
                                              fontWeight: FontWeight.w600,
                                              decoration:
                                                  currentTask['status'] ==
                                                          'done'
                                                      ? TextDecoration
                                                          .lineThrough
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
                                                          currentTask[
                                                                  'priority'] ??
                                                              'medium')
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20.r),
                                                ),
                                                child: Text(
                                                  (currentTask['priority'] ??
                                                          'MEDIUM')
                                                      .toString()
                                                      .toUpperCase(),
                                                  style: TextStyle(
                                                    color: _getPriorityColor(
                                                        currentTask[
                                                                'priority'] ??
                                                            'medium'),
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
                                if (currentTask['details']?.isNotEmpty ??
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
                                          ? const Color(0xFF2D2D2D)
                                          : Theme.of(context)
                                              .cardColor
                                              .withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(16.r),
                                      border: Border.all(
                                        color: Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.grey.shade800
                                            : Theme.of(context)
                                                .dividerColor
                                                .withOpacity(0.1),
                                      ),
                                    ),
                                    child: Text(
                                      currentTask['details'],
                                      style: TextStyle(
                                        fontSize: 15.sp,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.color
                                            ?.withOpacity(0.8),
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 24.h),
                                ],
                                Text(
                                  'Schedule',
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
                                Column(
                                  children: [
                                    _buildInfoCard(
                                      context,
                                      Icons.calendar_today_rounded,
                                      'Due Date',
                                      currentTask['date'],
                                    ),
                                    SizedBox(height: 16.h),
                                    _buildInfoCard(
                                      context,
                                      Icons.access_time_rounded,
                                      'Time',
                                      currentTask['time'],
                                    ),
                                  ],
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
    );
  }

  Widget _buildInfoCard(
      BuildContext context, IconData icon, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            isDark ? const Color(0xFF2D2D2D) : Theme.of(context).cardColor,
            isDark
                ? const Color(0xFF252525)
                : Theme.of(context).cardColor.withOpacity(0.95),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isDark
              ? Colors.grey.shade800
              : Theme.of(context).dividerColor.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  isDark
                      ? Colors.deepOrange.withOpacity(0.2)
                      : Theme.of(context).primaryColor.withOpacity(0.2),
                  isDark
                      ? Colors.deepOrange.withOpacity(0.1)
                      : Theme.of(context).primaryColor.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Icon(
              icon,
              color:
                  isDark ? Colors.deepOrange : Theme.of(context).primaryColor,
              size: 24.w,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? Colors.grey[400]
                        : Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.color
                            ?.withOpacity(0.7),
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? Colors.white
                        : Theme.of(context).textTheme.titleMedium?.color,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    titleController.text = currentTask['title'];
    detailsController.text = currentTask['details'] ?? '';
    dateController.text = currentTask['date'];
    timeController.text = currentTask['time'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF1A1A1A)
                : Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20.r),
            ),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(20.r),
              child: Form(
                key: formkey,
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
                      'Edit Task',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Container(
                      decoration: BoxDecoration(
                        //color: Theme.of(context).cardColor,
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
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),
                    _buildPrioritySection(
                        context, TodoCubit.get(context), setState),
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
                        onPressed: () async {
                          if (formkey.currentState!.validate()) {
                            try {
                              // Schedule alarm for the task
                              final DateTime taskDateTime = DateFormat('yyyy-MM-dd HH:mm')
                                  .parse('${dateController.text} ${timeController.text}');
                              
                              await NotificationService.createTaskNotification(
                                title: '⏰ Task Alarm!',
                                body: 'Time for task: ${titleController.text}',
                                scheduleTime: taskDateTime,
                              );

                              await TodoCubit.get(context).updateTask(
                                id: currentTask['id'],
                                title: titleController.text,
                                details: detailsController.text,
                                date: dateController.text,
                                time: timeController.text,
                                priority: TodoCubit.get(context).selectedPriority,
                              );
                              setState(() {
                                currentTask['title'] = titleController.text;
                                currentTask['details'] = detailsController.text;
                                currentTask['date'] = dateController.text;
                                currentTask['time'] = timeController.text;
                                currentTask['priority'] =
                                    TodoCubit.get(context).selectedPriority;
                              });
                              Navigator.pop(context);
                            } catch (e) {
                              print(e);
                            }
                          }
                        },
                        child: Text(
                          'Update Task',
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
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrioritySection(
      BuildContext context, TodoCubit todoCubit, StateSetter setState) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentPriority = todoCubit.selectedPriority.toLowerCase();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D2D2D) : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
            blurRadius: isDark ? 8 : 4,
            offset: const Offset(0, 2),
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
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          SizedBox(height: 12.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildPriorityOption(
                  context,
                  'Low',
                  _getPriorityColor('low'),
                  currentPriority == 'low',
                  () {
                    setState(() {
                      todoCubit.changePriority('low');
                    });
                  },
                ),
                SizedBox(width: 12.w),
                _buildPriorityOption(
                  context,
                  'Medium',
                  _getPriorityColor('medium'),
                  currentPriority == 'medium' || currentPriority == 'meduim',
                  () {
                    setState(() {
                      todoCubit.changePriority('medium');
                    });
                  },
                ),
                SizedBox(width: 12.w),
                _buildPriorityOption(
                  context,
                  'High',
                  _getPriorityColor('high'),
                  currentPriority == 'high',
                  () {
                    setState(() {
                      todoCubit.changePriority('high');
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityOption(
    BuildContext context,
    String label,
    Color color,
    bool isSelected,
    VoidCallback onPressed,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(isDark ? 0.2 : 0.1)
              : Colors.transparent,
          border: Border.all(
            color: isSelected
                ? color
                : Colors.grey.withOpacity(isDark ? 0.4 : 0.3),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.flag_rounded,
              size: 16.sp,
              color: isSelected
                  ? color
                  : Colors.grey.withOpacity(isDark ? 0.7 : 0.6),
            ),
            SizedBox(width: 4.w),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? color
                    : Colors.grey.withOpacity(isDark ? 0.7 : 0.6),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
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
              TodoCubit.get(context).deleteDatabase(currentTask['id']);
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
