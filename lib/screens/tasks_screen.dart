import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/componants/shard_componant.dart';
import 'package:todo_app/cubit/cubit.dart';
import 'package:todo_app/cubit/states.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(10.r),
            child: Column(
              children: [
                buildTasksScreen(context),
                SizedBox(height: 20.h),
                BlocConsumer<TodoCubit, TodoStates>(
                  listener: (context, state) {},
                  builder: (context, state) {
                    var tasks = TodoCubit.get(context).filteredTasks.isEmpty
                        ? TodoCubit.get(context).tasks
                        : TodoCubit.get(context).filteredTasks;

                    if (tasks.isNotEmpty) {
                      return Expanded(
                        child: ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.zero,
                          itemBuilder: (context, index) => Hero(
                            tag: 'task_${tasks[index]['id']}',
                            child: Material(
                              type: MaterialType.transparency,
                              child: buildTaskItem(
                                tasks[index],
                                context,
                              ),
                            ),
                          ),
                          separatorBuilder: (context, index) =>
                              SizedBox(height: 0.h),
                          itemCount: tasks.length,
                        ),
                      );
                    }

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 150.h,
                          width: 150.w,
                          child: Opacity(
                            opacity: 0.6,
                            child: Image.network(
                              'https://cdn3d.iconscout.com/3d/premium/thumb/task-not-found-3d-illustration-download-in-png-blend-fbx-gltf-file-formats--checklist-no-tasklist-list-empty-states-pack-miscellaneous-illustrations-4009510.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Text(
                          'No Tasks Yet!',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
