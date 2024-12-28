import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/componants/shard_componant.dart';
import 'package:todo_app/cubit/cubit.dart';
import 'package:todo_app/cubit/states.dart';
import 'package:todo_app/screens/done_task_screen.dart';
import 'package:todo_app/screens/tasks_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:todo_app/widgets/custom_bottom_nav.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  final formKey = GlobalKey<FormState>();

  final titleController = TextEditingController();
  final timeController = TextEditingController();
  final dateController = TextEditingController();
  final detailsController = TextEditingController();

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      TodoCubit.get(context).changePriority('medium');
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TodoCubit, TodoStates>(
      listener: (context, state) {
        if (state is ChangeBottomSheetState) {
          if (!TodoCubit.get(context).isBottomSheetShown) {
            widget.titleController.text = '';
            widget.timeController.text = '';
            widget.dateController.text = '';
            widget.detailsController.text = '';
          }
        }
      },
      builder: (context, state) {
        TodoCubit todoCubit = TodoCubit.get(context);
        return ThemeSwitchingArea(
          child: Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            floatingActionButton:
                _buildFloatingActionButton(context, todoCubit),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            bottomNavigationBar: CustomBottomNavBar(
              currentIndex: todoCubit.currentIndex,
              onTap: (index) => todoCubit.changeIndex(index),
            ),
            body: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: todoCubit.currentIndex == 0
                  ? const TasksScreen()
                  : const DoneTaskScreen(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFloatingActionButton(BuildContext context, TodoCubit todoCubit) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return FloatingActionButton(
      backgroundColor: Colors.deepOrange,
      foregroundColor: Colors.white,
      elevation: isDark ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Icon(
        todoCubit.fabIcon,
        size: 24.sp,
      ),
      onPressed: () => _handleFabPressed(context, todoCubit),
    );
  }

  void _handleFabPressed(BuildContext context, TodoCubit todoCubit) {
    if (todoCubit.isBottomSheetShown) {
      _handleFormSubmission(context, todoCubit);
    } else {
      _showAddTaskBottomSheet(context, todoCubit);
    }
  }

  void _handleFormSubmission(BuildContext context, TodoCubit todoCubit) {
    if (widget.formKey.currentState!.validate()) {
      todoCubit.InsertDB(
        title: widget.titleController.text,
        time: widget.timeController.text,
        date: widget.dateController.text,
        details: widget.detailsController.text,
        priority: todoCubit.selectedPriority,
        category: todoCubit.selectedCategory,
      );
      Navigator.pop(context);
      todoCubit.changeBottomSheetSt(isShow: false, icon: Icons.edit);
    }
  }

  void _showAddTaskBottomSheet(BuildContext context, TodoCubit todoCubit) {
    todoCubit.changePriority('medium');
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SafeArea(
            bottom: false,
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.9,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF1A1A1A)
                    : Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(32.r),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle
                  Padding(
                    padding: EdgeInsets.only(top: 12.h),
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 20.h,
                      ),
                      child: Form(
                        key: widget.formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(12.r),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.deepOrange.shade300,
                                        Colors.deepOrange.shade500,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(16.r),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            Colors.deepOrange.withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.add_task_rounded,
                                    color: Colors.white,
                                    size: 24.r,
                                  ),
                                ),
                                SizedBox(width: 16.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Add New Task',
                                        style: TextStyle(
                                          fontSize: 24.sp,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        'Fill in the details below',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12.r),
                                    onTap: () {
                                      HapticFeedback.mediumImpact();
                                      Navigator.pop(context);
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(8.r),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.withOpacity(0.1),
                                        borderRadius:
                                            BorderRadius.circular(12.r),
                                      ),
                                      child: Icon(
                                        Icons.close_rounded,
                                        size: 24.r,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 24.h),
                            // Form Fields Container
                            Container(
                              padding: EdgeInsets.all(20.r),
                              decoration: BoxDecoration(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.grey[900]
                                    : Colors.grey[100],
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Column(
                                children: [
                                  _buildTitleField(context),
                                  SizedBox(height: 16.h),
                                  _buildDetailsField(context),
                                  SizedBox(height: 16.h),
                                  _buildTimeField(context, setState),
                                  SizedBox(height: 16.h),
                                  _buildDateField(context, setState),
                                ],
                              ),
                            ),
                            SizedBox(height: 24.h),
                            // Priority Section
                            _buildPrioritySection(context, todoCubit),
                            SizedBox(height: 16.h),
                            // Category Section
                            _buildCategorySection(context, todoCubit),
                            SizedBox(height: 24.h),
                            // Create Task Button
                            Container(
                              width: double.infinity,
                              height: 56.h,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.deepOrange.shade400,
                                    Colors.deepOrange.shade600,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.deepOrange.withOpacity(0.25),
                                    blurRadius: 12,
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
                                  onTap: () {
                                    HapticFeedback.mediumImpact();
                                    _handleFormSubmission(context, todoCubit);
                                  },
                                  child: Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 24.w),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.add_task_rounded,
                                          color: Colors.white,
                                          size: 24.r,
                                        ),
                                        SizedBox(width: 12.w),
                                        Text(
                                          'Create Task',
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
                            SizedBox(height: 24.h),
                          ],
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
    ).then((_) {
      todoCubit.changeBottomSheetSt(isShow: false, icon: Icons.edit);
      widget.titleController.clear();
      widget.timeController.clear();
      widget.dateController.clear();
      widget.detailsController.clear();
    });
    todoCubit.changeBottomSheetSt(isShow: true, icon: Icons.add);
  }

  Widget _buildTitleField(BuildContext context) {
    return defaultFormField(
      context: context,
      controller: widget.titleController,
      type: TextInputType.text,
      validate: (value) {
        if (value!.isEmpty) return 'Title must not be empty';
        return null;
      },
      label: 'Task Title',
      prefix: Icons.title,
    );
  }

  Widget _buildDetailsField(BuildContext context) {
    return defaultFormField(
      context: context,
      controller: widget.detailsController,
      type: TextInputType.multiline,
      maxLines: 3,
      validate: (value) => null,
      label: 'Task Details',
      prefix: Icons.description,
    );
  }

  Widget _buildTimeField(BuildContext context, StateSetter setState) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.grey[100],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => _selectTime(context, setState),
        child: defaultFormField(
          context: context,
          controller: widget.timeController,
          type: TextInputType.datetime,
          validate: (value) {
            if (value!.isEmpty) return 'Time must not be empty';
            return null;
          },
          label: 'Task Time',
          prefix: Icons.watch_later_outlined,
          enabled: false,
        ),
      ),
    );
  }

  Widget _buildDateField(BuildContext context, StateSetter setState) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.grey[100],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => _selectDate(context, setState),
        child: defaultFormField(
          context: context,
          controller: widget.dateController,
          type: TextInputType.datetime,
          validate: (value) {
            if (value!.isEmpty) return 'Date must not be empty';
            return null;
          },
          label: 'Task Date',
          prefix: Icons.calendar_today,
          enabled: false,
        ),
      ),
    );
  }

  Widget _buildPrioritySection(BuildContext context, TodoCubit cubit) {
    return StatefulBuilder(
      builder: (context, setState) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[900]
              : Colors.grey[50],
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withOpacity(0.1)
                : Colors.grey[200]!,
            width: 1,
          ),
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
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 16.h),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.deepOrange.withOpacity(0.2),
                          Colors.deepOrange.withOpacity(0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      Icons.flag_rounded,
                      color: Colors.deepOrange,
                      size: 20.w,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'Priority',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
              child: Row(
                children: [
                  _buildPriorityOption(
                    context,
                    'High',
                    cubit.selectedPriority == 'high',
                    () => setState(() {
                      cubit.changePriority('high');
                      HapticFeedback.selectionClick();
                    }),
                    Colors.red[400]!,
                    Icons.arrow_upward_rounded,
                  ),
                  SizedBox(width: 12.w),
                  _buildPriorityOption(
                    context,
                    'Medium',
                    cubit.selectedPriority == 'medium',
                    () => setState(() {
                      cubit.changePriority('medium');
                      HapticFeedback.selectionClick();
                    }),
                    Colors.orange[400]!,
                    Icons.remove_rounded,
                  ),
                  SizedBox(width: 12.w),
                  _buildPriorityOption(
                    context,
                    'Low',
                    cubit.selectedPriority == 'low',
                    () => setState(() {
                      cubit.changePriority('low');
                      HapticFeedback.selectionClick();
                    }),
                    Colors.green[400]!,
                    Icons.arrow_downward_rounded,
                  ),
                ],
              ),
            ),
          ],
        ),
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
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(8.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isSelected
                  ? [
                      color.withOpacity(isDark ? 0.3 : 0.2),
                      color.withOpacity(isDark ? 0.2 : 0.1),
                    ]
                  : [
                      (isDark ? Colors.white.withOpacity(0.05) : Colors.white),
                      (isDark
                          ? Colors.white.withOpacity(0.02)
                          : Colors.grey[50]!),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: isSelected ? color : Colors.grey.withOpacity(0.2),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withOpacity(isDark ? 0.2 : 0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Icon(
                  icon,
                  color: isSelected ? color : Colors.grey[600],
                  size: 16.w,
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? color : Colors.grey[700],
                ),
              ),
              if (isSelected) ...[
                SizedBox(width: 6.w),
                Icon(
                  Icons.check_circle_rounded,
                  color: color,
                  size: 14.w,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySection(BuildContext context, TodoCubit cubit) {
    return StatefulBuilder(
      builder: (context, setState) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[900]
              : Colors.grey[50],
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withOpacity(0.1)
                : Colors.grey[200]!,
            width: 1,
          ),
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
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 16.h),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.deepPurple.withOpacity(0.2),
                          Colors.deepPurple.withOpacity(0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      Icons.category_rounded,
                      color: Colors.deepPurple,
                      size: 20.w,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'Category',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
              child: Row(
                children: cubit.categories.map((category) {
                  return Padding(
                    padding: EdgeInsets.only(right: 12.w),
                    child: _buildCategoryOption(
                      context,
                      category['name'] as String,
                      category['icon'] as IconData,
                      category['color'] as Color,
                      cubit.selectedCategory == category['name'],
                      () => setState(() {
                        cubit.changeCategory(category['name'] as String);
                        HapticFeedback.selectionClick();
                      }),
                    ),
                  );
                }).toList(),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(8.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isSelected
                  ? [
                      color.withOpacity(isDark ? 0.3 : 0.2),
                      color.withOpacity(isDark ? 0.2 : 0.1),
                    ]
                  : [
                      (isDark ? Colors.white.withOpacity(0.05) : Colors.white),
                      (isDark
                          ? Colors.white.withOpacity(0.02)
                          : Colors.grey[50]!),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: isSelected ? color : Colors.grey.withOpacity(0.2),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withOpacity(isDark ? 0.2 : 0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Icon(
                  icon,
                  color: isSelected ? color : Colors.grey[600],
                  size: 16.w,
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                category,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? color : Colors.grey[700],
                ),
              ),
              if (isSelected) ...[
                SizedBox(width: 6.w),
                Icon(
                  Icons.check_circle_rounded,
                  color: color,
                  size: 14.w,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectTime(BuildContext context, StateSetter setState) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        widget.timeController.text = picked.format(context);
      });
    }
  }

  Future<void> _selectDate(BuildContext context, StateSetter setState) async {
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
        widget.dateController.text = DateFormat.yMMMd().format(picked);
      });
    }
  }
}
