import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/cubit/states.dart';
import 'package:todo_app/services/notification_service.dart';

class TodoCubit extends Cubit<TodoStates> {
  //TodoCubit(super.initialState);

  TodoCubit() : super(TodoInitialState());

  static TodoCubit get(context) => BlocProvider.of(context);

  int currentIndex = 0;

  List<String> titles = ['Tasks', 'Done Tasks'];

  void changeIndex(int index) {
    currentIndex = index;
    emit(ChangeBottomNavState());
  }

  Database? database;
  List<Map<String, dynamic>> tasks = [];
  List<Map<String, dynamic>> doneTasks = [];

  void CreateDB() {
    openDatabase('todo.db', version: 3, onCreate: (db, version) {
      print('Database Created');
      db
          .execute(
              'CREATE TABLE tasks (id INTEGER PRIMARY KEY, title TEXT, date TEXT, time TEXT, status TEXT, details TEXT, priority TEXT)')
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
  }) async {
    try {
      await database!.transaction((txn) async {
        await txn.rawInsert(
          'INSERT INTO tasks(title, time, date, status, details, priority) VALUES("$title", "$time", "$date", "new", "$details", "$priority")',
        );
      });
      // Refresh tasks list after insertion
      await getDataFromDB(database);
      emit(InsertDatabaseState());
      // Schedule notification
      try {
        print('Parsing time: $time'); // Debug time
        print('Parsing date: $date'); // Debug date

        // Parse time
        final timeComponents = time.split(' ');
        final timePart = timeComponents[0];
        final period = timeComponents[1].toUpperCase(); // AM/PM

        final hourMinute = timePart.split(':');
        var hour = int.parse(hourMinute[0]);
        final minute = int.parse(hourMinute[1]);

        // Convert to 24-hour format if needed
        if (period == 'PM' && hour != 12) {
          hour += 12;
        } else if (period == 'AM' && hour == 12) {
          hour = 0;
        }

        // Parse date (e.g., "Dec 25, 2024")
        final dateComponents = date.split(' ');
        final month =
            _getMonthNumber(dateComponents[0]); // Convert month name to number
        final day = int.parse(
            dateComponents[1].replaceAll(',', '')); // Remove comma and parse
        final year = int.parse(dateComponents[2]);

        final scheduleTime = DateTime(
          year,
          month,
          day,
          hour,
          minute,
        );

        print('Scheduling notification for: $scheduleTime');

        if (scheduleTime.isAfter(DateTime.now())) {
          NotificationService.createTaskNotification(
            title: 'Task Reminder',
            body: title,
            scheduleTime: scheduleTime,
          )
              .then((_) => print('Notification scheduled successfully'))
              .catchError((e) => print('Error scheduling notification: $e'));
        } else {
          print('Task time is in the past, not scheduling notification');
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
    await database?.rawQuery('SELECT * FROM tasks').then((value) {
      tasks = [];
      doneTasks = [];
      for (var element in value) {
        if (element['status'] == 'new')
          tasks.add(element);
        else
          doneTasks.add(element);
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

  void changeBottomSheetSt({required bool isShow, required IconData icon}) {
    isBottomSheetShown = isShow;
    fabIcon = icon;
    if (isShow) {
      selectedPriority = 'Medium'; // Set default priority when bottom sheet opens
    }
    emit(ChangeBottomSheetState());
  }

  void changePriority(String priority) {
    selectedPriority = priority;
    emit(ChangePriorityState());
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
    String? status,
  }) async {
    try {
      await database!.rawUpdate(
        'UPDATE tasks SET title = ?, details = ?, date = ?, time = ?, priority = ?, status = ? WHERE id = ?',
        [title, details, date, time, priority, status ?? 'new', id],
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

  List<Map<String, dynamic>> filteredTasks = [];

  void filterTasksByPriority(String priority) {
    emit(FilterTasksLoadingState());
    try {
      if (priority.toLowerCase() == 'all') {
        filteredTasks = List.from(tasks);
      } else {
        filteredTasks = tasks
            .where((task) =>
                task['priority']?.toString().toLowerCase() ==
                priority.toLowerCase())
            .toList();
      }
      emit(FilterTasksSuccessState());
    } catch (error) {
      emit(FilterTasksErrorState());
    }
  }

  Future<void> deleteAllTasks() async {
    await database!.rawDelete('DELETE FROM tasks').then((value) {
      getDataFromDB(database);
      emit(DeleteAllTasksState());
    });
  }
}
