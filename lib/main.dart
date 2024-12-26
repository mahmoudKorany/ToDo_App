import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_app/cubit/cubit.dart';
import 'package:todo_app/cubit/search/search_cubit.dart';
import 'package:todo_app/layout/home_layout.dart';
import 'package:todo_app/screens/splash_screen.dart';
import 'package:todo_app/screens/search_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:todo_app/services/notification_service.dart';

//import 'componants/bloc_observer_class.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //Bloc.observer = MyBlocObserver();

  final prefs = await SharedPreferences.getInstance();
  final showOnboarding = prefs.getBool('showOnboarding') ?? true;
  bool isDark = prefs.getBool('isDark') ?? false;
  ThemeData initTheme = isDark ? darkTheme : lightTheme;

  await NotificationService.initializeNotification();

  runApp(MyApp(showOnboarding: showOnboarding, initTheme: initTheme));
}

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primarySwatch: Colors.deepOrange,
  scaffoldBackgroundColor: const Color(0xFF1E1E1E),
  colorScheme: const ColorScheme.dark(
    primary: Colors.deepOrange,
    secondary: Colors.deepOrangeAccent,
    surface: Color(0xFF2C2C2C),
    background: Color(0xFF1E1E1E),
    error: Colors.redAccent,
  ),
  appBarTheme: const AppBarTheme(
    titleSpacing: 20.0,
    iconTheme: IconThemeData(
      color: Colors.white,
    ),
    backgroundColor: Colors.deepOrange,
    elevation: 0.0,
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20.0,
      fontWeight: FontWeight.bold,
    ),
  ),
  cardTheme: CardTheme(
    color: const Color(0xFF2C2C2C),
    elevation: 4.0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16.0),
    ),
    margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    type: BottomNavigationBarType.fixed,
    selectedItemColor: Colors.deepOrange,
    unselectedItemColor: Colors.grey,
    elevation: 8.0,
    backgroundColor: Color(0xFF2C2C2C),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Colors.deepOrange,
    foregroundColor: Colors.white,
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(color: Colors.white),
    displayMedium: TextStyle(color: Colors.white),
    displaySmall: TextStyle(color: Colors.white),
    headlineMedium: TextStyle(color: Colors.white),
    headlineSmall: TextStyle(color: Colors.white),
    titleLarge: TextStyle(color: Colors.white),
    titleMedium: TextStyle(color: Colors.white),
    titleSmall: TextStyle(color: Colors.white),
    bodyLarge: TextStyle(color: Colors.white),
    bodyMedium: TextStyle(color: Colors.white),
  ),
);

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primarySwatch: Colors.deepOrange,
  scaffoldBackgroundColor: Colors.white,
  colorScheme: const ColorScheme.light(
    primary: Colors.deepOrange,
    secondary: Colors.deepOrangeAccent,
    surface: Colors.white,
    background: Colors.white,
    error: Colors.redAccent,
  ),
  appBarTheme: const AppBarTheme(
    titleSpacing: 20.0,
    iconTheme: IconThemeData(
      color: Colors.white,
    ),
    backgroundColor: Colors.deepOrange,
    elevation: 0.0,
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20.0,
      fontWeight: FontWeight.bold,
    ),
  ),
  cardTheme: CardTheme(
    color: Colors.white,
    elevation: 4.0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16.0),
    ),
    margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    type: BottomNavigationBarType.fixed,
    selectedItemColor: Colors.deepOrange,
    unselectedItemColor: Colors.grey,
    elevation: 8.0,
    backgroundColor: Colors.white,
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Colors.deepOrange,
    foregroundColor: Colors.white,
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(color: Colors.black),
    displayMedium: TextStyle(color: Colors.black),
    displaySmall: TextStyle(color: Colors.black),
    headlineMedium: TextStyle(color: Colors.black),
    headlineSmall: TextStyle(color: Colors.black),
    titleLarge: TextStyle(color: Colors.black),
    titleMedium: TextStyle(color: Colors.black),
    titleSmall: TextStyle(color: Colors.black),
    bodyLarge: TextStyle(color: Colors.black),
    bodyMedium: TextStyle(color: Colors.black),
  ),
);

class MyApp extends StatelessWidget {
  final bool showOnboarding;
  // ignore: prefer_typing_uninitialized_variables
  final ThemeData initTheme;
  const MyApp(
      {super.key, required this.showOnboarding, required this.initTheme});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return ThemeProvider(
          initTheme: initTheme,
          builder: (_, myTheme) {
            return MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (context) => TodoCubit()..CreateDB(),
                ),
                BlocProvider(
                  create: (context) => SearchCubit(
                    allTasks: TodoCubit.get(context).tasks,
                  ),
                ),
              ],
              child: MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'Todo App',
                theme: myTheme,
                home: const SplashScreen(),
                routes: {
                  '/search': (context) => BlocProvider(
                        create: (context) => SearchCubit(
                          allTasks: TodoCubit.get(context).tasks,
                        ),
                        child: const SearchScreen(),
                      ),
                },
              ),
            );
          },
        );
      },
    );
  }
}
