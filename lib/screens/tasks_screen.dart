import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/componants/shard_componant.dart';
import 'package:todo_app/cubit/cubit.dart';
import 'package:todo_app/cubit/states.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
            padding: EdgeInsets.all(20.r),
            child: Column(
              children: [
                buildTasksScreen(context),
                SizedBox(height: 20.h),
                BlocConsumer<TodoCubit, TodoStates>(
                  listener: (context, state) {},
                  builder: (context, state) {
                    var todoCubit = TodoCubit.get(context);
                    var tasks = todoCubit.filteredTasks.isEmpty
                        ? todoCubit.tasks
                        : todoCubit.filteredTasks;

                    if (tasks.isNotEmpty) {
                      return Expanded(
                        child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.zero,
                          itemBuilder: (context, index) {
                            return Hero(
                              tag: 'task_${tasks[index].id}',
                              child: Material(
                                type: MaterialType.transparency,
                                child: buildTaskItem(
                                  tasks[index],
                                  context,
                                ),
                              ),
                            );
                          },
                          itemCount: tasks.length,
                        ),
                      );
                    }

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Opacity(
                          opacity: 0.9,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: CachedNetworkImage(
                                imageUrl:
                                    'https://cdn3d.iconscout.com/3d/premium/thumb/task-not-found-3d-illustration-download-in-png-blend-fbx-gltf-file-formats--checklist-no-tasklist-list-empty-states-pack-miscellaneous-illustrations-4009510.png',
                                width: 200,
                                height: 200,
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    const CircularProgressIndicator(),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                              ),
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
