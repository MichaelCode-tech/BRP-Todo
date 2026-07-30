import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo1/pags/homePage.dart';
import 'package:todo1/utilites/theme_manager.dart';

void main() async {
  // init the hive
  await Hive.initFlutter();

  // open a box
  await Hive.openBox('MyBox');

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => MyAppState();

  // Helper method to find the state and call refresh
  static MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<MyAppState>();
}

class MyAppState extends State<MyApp> {
  final _myBox = Hive.box('MyBox');

  void refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = _myBox.get("IS_DARK_MODE") ?? false;
    bool isRetroTheme = _myBox.get("IS_RETRO_THEME") ?? false;

    return MaterialApp(
      title: 'Todo',
      debugShowCheckedModeBanner: false,
      home: const Homepage(),
      theme: ThemeManager.getTheme(isDarkMode, isRetroTheme),
    );
  }
}
