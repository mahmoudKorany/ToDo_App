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

// ignore: must_be_immutable
class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);

  var scaffoldKey = GlobalKey<ScaffoldState>();
  var formkey = GlobalKey<FormState>();

  var titleController = TextEditingController();
  var timeController = TextEditingController();
  var dateController = TextEditingController();
  var detailsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TodoCubit, TodoStates>(
      listener: (context, state) {
        if (state is ChangeBottomSheetState) {
          // Reset controllers if bottom sheet is closed
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
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                if (todoCubit.isBottomSheetShown) {
                  if (formkey.currentState!.validate()) {
                    todoCubit.InsertDB(
                      title: titleController.text,
                      time: timeController.text,
                      date: dateController.text,
                      details: detailsController.text,
                      priority: todoCubit.selectedPriority,
                    );
                    Navigator.pop(context);
                    todoCubit.changeBottomSheetSt(
                      isShow: false,
                      icon: Icons.edit,
                    );
                  }
                } else {
                  scaffoldKey.currentState
                      ?.showBottomSheet(
                        (context) => StatefulBuilder(
                          builder: (context, setState) {
                            return Container(
                              decoration: BoxDecoration(
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20.r),
                                ),
                              ),
                              padding: EdgeInsets.only(
                                bottom:
                                    MediaQuery.of(context).viewInsets.bottom,
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
                                      maxHeight:
                                          MediaQuery.of(context).size.height *
                                              0.8,
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Center(
                                          child: Container(
                                            width: 40.w,
                                            height: 4.h,
                                            decoration: BoxDecoration(
                                              color: Colors.grey[300],
                                              borderRadius:
                                                  BorderRadius.circular(2.r),
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
                                                setState(() {
                                                  timeController.text =
                                                      value.format(context);
                                                });
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
                                              lastDate:
                                                  DateTime.parse('2025-12-31'),
                                            ).then((value) {
                                              if (value != null) {
                                                setState(() {
                                                  dateController.text =
                                                      DateFormat.yMMMd()
                                                          .format(value);
                                                });
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
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 16.w, vertical: 8.h),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(16.r),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.05),
                                                blurRadius: 10,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
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
                                                builder: (context, setState) =>
                                                    SingleChildScrollView(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  child: Row(
                                                    children: [
                                                      buildPriorityButton(
                                                        context,
                                                        'High',
                                                        Colors.red,
                                                        todoCubit
                                                                .selectedPriority ==
                                                            'high',
                                                        () {
                                                          todoCubit
                                                              .changePriority(
                                                                  'high');
                                                          setState(() {});
                                                        },
                                                      ),
                                                      SizedBox(width: 8.w),
                                                      buildPriorityButton(
                                                        context,
                                                        'Medium',
                                                        Colors.orange,
                                                        todoCubit
                                                                .selectedPriority ==
                                                            'medium',
                                                        () {
                                                          todoCubit
                                                              .changePriority(
                                                                  'medium');
                                                          setState(() {});
                                                        },
                                                      ),
                                                      SizedBox(width: 8.w),
                                                      buildPriorityButton(
                                                        context,
                                                        'Low',
                                                        Colors.green,
                                                        todoCubit
                                                                .selectedPriority ==
                                                            'low',
                                                        () {
                                                          todoCubit
                                                              .changePriority(
                                                                  'low');
                                                          setState(() {});
                                                        },
                                                      ),
                                                    ],
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
                            );
                          },
                        ),
                        backgroundColor: Colors.transparent,
                      )
                      .closed
                      .then((value) {
                    todoCubit.changeBottomSheetSt(
                      isShow: false,
                      icon: Icons.edit,
                    );
                  });
                  todoCubit.changeBottomSheetSt(
                    isShow: true,
                    icon: Icons.add,
                  );
                }
              },
              backgroundColor: Colors.deepOrange,
              child: Icon(
                todoCubit.fabIcon,
                color: Colors.white,
              ),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: todoCubit.currentIndex,
              onTap: (index) {
                todoCubit.changeIndex(index);
              },
              backgroundColor:
                  Theme.of(context).bottomNavigationBarTheme.backgroundColor,
              selectedItemColor: Colors.deepOrange,
              unselectedItemColor: Colors.grey[400],
              elevation: 8.0,
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.menu),
                  label: 'Tasks',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.check_circle_outline),
                  label: 'Done',
                ),
              ],
            ),
            body: todoCubit.currentIndex == 0
                ? const TasksScreen()
                : const DoneTaskScreen(),
          ),
        );
      },
    );
  }

  Widget buildPriorityButton(
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
              size: 16.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
