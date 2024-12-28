import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/cubit/states.dart';
import 'package:todo_app/models/task_model.dart';
import 'package:todo_app/services/notification_service.dart';

class TodoCubit extends Cubit<TodoStates> {
  TodoCubit() : super(TodoInitialState()) {
    selectedPriority = 'medium';
    selectedCategory = 'Personal';
  }

  static TodoCubit get(context) => BlocProvider.of(context);

  int currentIndex = 0;

  List<String> titles = ['Tasks', 'Done Tasks'];

  void changeIndex(int index) {
    currentIndex = index;
    emit(ChangeBottomNavState());
  }

  Database? database;
  List<TaskModel> allTasks = [];
  List<TaskModel> tasks = [];
  List<TaskModel> doneTasks = [];
  List<TaskModel> filteredTasks = [];

  void CreateDB() {
    openDatabase('todo.db', version: 4, onCreate: (db, version) {
      print('Database Created');
      db
          .execute(
              'CREATE TABLE tasks (id INTEGER PRIMARY KEY, title TEXT, date TEXT, time TEXT, status TEXT, details TEXT, priority TEXT, category TEXT)')
          .then((_) => print('Table Created'))
          .catchError((error) {
        print('Error creating table: ${error.toString()}');
      });
    }, onUpgrade: (db, oldVersion, newVersion) async {
      if (oldVersion < 2) {
        await db.execute('ALTER TABLE tasks ADD COLUMN details TEXT');
      }
      if (oldVersion < 3) {
        await db.execute(
            'ALTER TABLE tasks ADD COLUMN priority TEXT DEFAULT "medium"');
      }
      if (oldVersion < 4) {
        await db.execute(
            'ALTER TABLE tasks ADD COLUMN category TEXT DEFAULT "personal"');
      }
    }, onOpen: (db) {
      print('Database Opened');
      database = db;
      getDataFromDB(db);
    }).then((value) {
      database = value;
      emit(CreateDatabaseState());
    });
  }

  Future<void> InsertDB({
    required String title,
    required String time,
    required String date,
    String? details,
    required String priority,
    required String category,
  }) async {
    try {
      await database!.transaction((txn) async {
        await txn.rawInsert(
          'INSERT INTO tasks(title, time, date, status, details, priority, category) VALUES("$title", "$time", "$date", "new", "$details", "$priority", "$category")',
        );
      });
      await getDataFromDB(database);
      emit(InsertDatabaseState());

      try {
        print('Parsing time: $time');
        print('Parsing date: $date');

        final timeComponents = time.split(' ');
        final timePart = timeComponents[0];
        final period = timeComponents[1].toUpperCase();

        final hourMinute = timePart.split(':');
        var hour = int.parse(hourMinute[0]);
        final minute = int.parse(hourMinute[1]);

        if (period == 'PM' && hour != 12) {
          hour += 12;
        } else if (period == 'AM' && hour == 12) {
          hour = 0;
        }

        final dateComponents = date.split(' ');
        final month = _getMonthNumber(dateComponents[0]);
        final day = int.parse(dateComponents[1].replaceAll(',', ''));
        final year = int.parse(dateComponents[2]);

        final scheduleTime = DateTime(year, month, day, hour, minute);

        print('Scheduling notification for: $scheduleTime');

        if (scheduleTime.isAfter(DateTime.now())) {
          NotificationService.createTaskNotification(
            title: 'Task Reminder',
            body: title,
            scheduleTime: scheduleTime,
          );
        }
      } catch (e) {
        print('Error scheduling notification: $e');
      }
    } catch (error) {
      print('Error when Inserting New Record ${error.toString()}');
    }
  }

  int _getMonthNumber(String monthName) {
    final months = {
      'Jan': 1,
      'Feb': 2,
      'Mar': 3,
      'Apr': 4,
      'May': 5,
      'Jun': 6,
      'Jul': 7,
      'Aug': 8,
      'Sep': 9,
      'Oct': 10,
      'Nov': 11,
      'Dec': 12
    };
    return months[monthName] ?? 1; // Default to January if month not found
  }

  Future<void> getDataFromDB(Database? database) async {
    allTasks = [];
    tasks = [];
    doneTasks = [];
    emit(GetDatabaseState());

    database!.rawQuery('SELECT * FROM tasks ORDER BY id DESC').then((value) {
      for (var element in value) {
        if (element['status'] == 'done') {
          doneTasks.add(TaskModel.fromJson(element));
        } else {
          tasks.add(TaskModel.fromJson(element));
          allTasks.add(TaskModel.fromJson(
              element)); // Only store active tasks in allTasks
        }
      }
      emit(GetDatabaseState());
    });
  }

  void deleteDatabase(int id) async {
    try {
      // Cancel the notification for this task
      await NotificationService.cancelNotification(id);

      // Delete from database
      await database?.rawDelete('DELETE FROM tasks WHERE id = ?', [id]);
      getDataFromDB(database);
      emit(DeleteDatabaseState());
    } catch (e) {
      print('Error deleting task and notification: $e');
      emit(DeleteDatabaseErrorState());
    }
  }

  bool isBottomSheetShown = false;
  IconData fabIcon = Icons.edit;
  String selectedPriority = 'medium';
  String selectedCategory = 'Personal';
  bool noTasksFound = false;

  final List<Map<String, dynamic>> categories = [
    {
      'name': 'Personal',
      'icon': Icons.person_outline_rounded,
      'color': const Color(0xFF9C27B0), // Rich Purple
    },
    {
      'name': 'Work',
      'icon': Icons.work_outline_rounded,
      'color': const Color(0xFF1E88E5), // Professional Blue
    },
    {
      'name': 'Shopping',
      'icon': Icons.shopping_bag_outlined,
      'color': const Color(0xFFFF6D00), // Vibrant Orange
    },
    {
      'name': 'Health',
      'icon': Icons.favorite_border_rounded,
      'color': const Color(0xFFD81B60), // Deep Pink
    },
    {
      'name': 'Education',
      'icon': Icons.school_outlined,
      'color': const Color(0xFF9C27B0), // Rich Purple
    },
    {
      'name': 'Social',
      'icon': Icons.people,
      'color': const Color(0xFF00897B), // Deep Teal
    },
    {
      'name': 'Other',
      'icon': Icons.more_horiz,
      'color': const Color(0xFF546E7A), // Blue Grey
    },
  ];

  void changeBottomSheetSt({
    required bool isShow,
    required IconData icon,
  }) {
    isBottomSheetShown = isShow;
    fabIcon = icon;
    emit(ChangeBottomSheetState());
  }

  void changePriority(String priority) {
    selectedPriority = priority;
    emit(ChangeBottomSheetState());
  }

  void changeCategory(String category) {
    selectedCategory = category;
    emit(ChangeBottomSheetState());
  }

  void filterTasksByPriority(String priority) {
    emit(FilterTasksLoadingState());
    try {
      if (priority.toLowerCase() == 'all') {
        tasks = List.from(allTasks);
        noTasksFound = false;
      } else {
        var filteredList = allTasks
            .where(
                (task) => task.priority.toLowerCase() == priority.toLowerCase())
            .toList();

        if (filteredList.isEmpty) {
          noTasksFound = true;
          tasks = List.from(allTasks); // Return to all tasks
          emit(FilterTasksSuccessState());
          Future.delayed(const Duration(seconds: 2), () {
            noTasksFound = false;
            emit(FilterTasksSuccessState());
          });
        } else {
          noTasksFound = false;
          tasks = filteredList;
        }
      }
      emit(FilterTasksSuccessState());
    } catch (error) {
      print('Error filtering tasks: $error');
      emit(FilterTasksErrorState());
    }
  }

  Future<void> updateData({
    required String status,
    required int id,
  }) async {
    await database!.rawUpdate('UPDATE tasks SET status = ? WHERE id = ?',
        [status, id]).then((value) async {
      await getDataFromDB(database);
    });
    emit(UpdateDatabaseState());
  }

  Future<void> updateTask({
    required int id,
    required String title,
    required String details,
    required String date,
    required String time,
    required String priority,
    required String category,
    String? status,
  }) async {
    try {
      await database!.rawUpdate(
        'UPDATE tasks SET title = ?, details = ?, date = ?, time = ?, priority = ?, category = ?, status = ? WHERE id = ?',
        [title, details, date, time, priority, category, status ?? 'new', id],
      );
      getDataFromDB(database);
      emit(UpdateTaskSuccessState());
    } catch (error) {
      print('Error updating task: $error');
      emit(UpdateTaskErrorState());
    }
  }

  Future<void> updateTaskStatus({
    required int id,
    required String status,
  }) async {
    emit(UpdateTaskLoadingState());
    try {
      await database!.rawUpdate(
        'UPDATE tasks SET status = ? WHERE id = ?',
        [status, id],
      );
      getDataFromDB(database);
      emit(UpdateTaskSuccessState());
    } catch (error) {
      emit(UpdateTaskErrorState());
    }
  }

  Future<void> deleteAllTasks() async {
    await database!.rawDelete('DELETE FROM tasks').then((value) {
      getDataFromDB(database);
      emit(DeleteAllTasksState());
    });
  }
}
