import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo1/pags/home_page.dart';
import 'package:todo1/utilites/theme_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
  void refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = false;
    bool isRetroTheme = false;

    // Guard against box not being open (e.g. in tests)
    if (Hive.isBoxOpen('MyBox')) {
      final box = Hive.box('MyBox');
      isDarkMode = box.get("IS_DARK_MODE") ?? false;
      isRetroTheme = box.get("IS_RETRO_THEME") ?? false;
    }

    return MaterialApp(
      title: 'Todo',
      debugShowCheckedModeBanner: false,
      home: const Homepage(),
      theme: ThemeManager.getTheme(isDarkMode, isRetroTheme),
    );
  }
}
