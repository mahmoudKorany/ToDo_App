import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/componants/shard_componant.dart';
import 'package:todo_app/cubit/cubit.dart';
import 'package:todo_app/cubit/states.dart';
import 'package:todo_app/screens/done_task_screen.dart';
import 'package:todo_app/screens/tasks_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:todo_app/widgets/custom_bottom_nav.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final formkey = GlobalKey<FormState>();

  final titleController = TextEditingController();
  final timeController = TextEditingController();
  final dateController = TextEditingController();
  final detailsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TodoCubit, TodoStates>(
      listener: (context, state) {
        if (state is ChangeBottomSheetState) {
          if (!TodoCubit.get(context).isBottomSheetShown) {
            titleController.text = '';
            timeController.text = '';
            dateController.text = '';
            detailsController.text = '';
          }
        }
      },
      builder: (context, state) {
        TodoCubit todoCubit = TodoCubit.get(context);
        return ThemeSwitchingArea(
          child: Scaffold(
            key: scaffoldKey,
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
    if (formkey.currentState!.validate()) {
      todoCubit.InsertDB(
        title: titleController.text,
        time: timeController.text,
        date: dateController.text,
        details: detailsController.text,
        priority: todoCubit.selectedPriority,
      );
      Navigator.pop(context);
      todoCubit.changeBottomSheetSt(isShow: false, icon: Icons.edit);
    }
  }

  void _showAddTaskBottomSheet(BuildContext context, TodoCubit todoCubit) {
    scaffoldKey.currentState
        ?.showBottomSheet(
          (context) => StatefulBuilder(
            builder: (context, setState) =>
                _buildBottomSheetContent(context, setState, todoCubit),
          ),
          backgroundColor: Colors.transparent,
        )
        .closed
        .then((value) {
      todoCubit.changeBottomSheetSt(isShow: false, icon: Icons.edit);
      titleController.clear();
      timeController.clear();
      dateController.clear();
      detailsController.clear();
    });
    todoCubit.changeBottomSheetSt(isShow: true, icon: Icons.add);
  }

  Widget _buildBottomSheetContent(
      BuildContext context, StateSetter setState, TodoCubit todoCubit) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 20.h,
        left: 20.w,
        right: 20.w,
      ),
      child: Form(
        key: formkey,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBottomSheetHeader(),
                SizedBox(height: 20.h),
                _buildTitleField(context),
                SizedBox(height: 15.h),
                _buildDetailsField(context),
                SizedBox(height: 15.h),
                _buildTimeField(context, setState),
                SizedBox(height: 15.h),
                _buildDateField(context, setState),
                SizedBox(height: 15.h),
                _buildPrioritySection(context, todoCubit, setState),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSheetHeader() {
    return Column(
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
      ],
    );
  }

  Widget _buildTitleField(BuildContext context) {
    return defaultFormField(
      context: context,
      controller: titleController,
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
      controller: detailsController,
      type: TextInputType.multiline,
      maxLines: 3,
      validate: (value) => null,
      label: 'Task Details',
      prefix: Icons.description,
    );
  }

  Widget _buildTimeField(BuildContext context, StateSetter setState) {
    return InkWell(
      onTap: () => _selectTime(context, setState),
      child: defaultFormField(
        context: context,
        controller: timeController,
        type: TextInputType.datetime,
        validate: (value) {
          if (value!.isEmpty) return 'Time must not be empty';
          return null;
        },
        label: 'Task Time',
        prefix: Icons.watch_later_outlined,
        enabled: false,
      ),
    );
  }

  Widget _buildDateField(BuildContext context, StateSetter setState) {
    return InkWell(
      onTap: () => _selectDate(context, setState),
      child: defaultFormField(
        context: context,
        controller: dateController,
        type: TextInputType.datetime,
        validate: (value) {
          if (value!.isEmpty) return 'Date must not be empty';
          return null;
        },
        label: 'Task Date',
        prefix: Icons.calendar_today,
        enabled: false,
      ),
    );
  }

  Widget _buildPrioritySection(
      BuildContext context, TodoCubit todoCubit, StateSetter setState) {
    final Map<String, Color> priorityColors = {
      'Low': Colors.green,
      'Medium': Colors.orange,
      'High': Colors.red,
    };

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.r),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              buildPriorityButton(
                context,
                'Low',
                priorityColors['Low']!,
                todoCubit.selectedPriority == 'Low',
                () {
                  setState(() {
                    todoCubit.changePriority('Low');
                  });
                },
              ),
              buildPriorityButton(
                context,
                'Medium',
                priorityColors['Medium']!,
                todoCubit.selectedPriority == 'Medium',
                () {
                  setState(() {
                    todoCubit.changePriority('Medium');
                  });
                },
              ),
              buildPriorityButton(
                context,
                'High',
                priorityColors['High']!,
                todoCubit.selectedPriority == 'High',
                () {
                  setState(() {
                    todoCubit.changePriority('High');
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildPriorityButton(
    BuildContext context,
    String label,
    Color color,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          border: Border.all(
            color: isSelected ? color : Colors.grey.withOpacity(0.3),
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
              color: isSelected ? color : Colors.grey,
            ),
            SizedBox(width: 4.w),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Colors.grey,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
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
        timeController.text = picked.format(context);
      });
    }
  }

  Future<void> _selectDate(BuildContext context, StateSetter setState) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2025, 12, 31),
    );
    if (picked != null) {
      setState(() {
        dateController.text = DateFormat.yMMMd().format(picked);
      });
    }
  }
}
