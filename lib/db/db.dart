import 'package:hive_flutter/hive_flutter.dart';

class ToDoDB {
  List toDoList = [];
  bool isDarkMode = false;
  bool isRetroTheme = false;

  // reference our box
  final _myBox = Hive.box('MyBox');

  // run this method if this is the 1st time ever opening this app
  void createInitialData() {
    toDoList = [
      ["Make Tutorial", false, false], // [name, completed, pinned]
      ["Do Exercise", false, false],
    ];
    isDarkMode = false;
    isRetroTheme = false;
  }

  // load the data from database
  void loadData() {
    toDoList = _myBox.get("TODOLIST") ?? [];
    
    // Migrate old data if necessary (ensure 3 fields per task)
    for (int i = 0; i < toDoList.length; i++) {
      if (toDoList[i].length < 3) {
        toDoList[i] = [toDoList[i][0], toDoList[i][1], false];
      }
    }

    isDarkMode = _myBox.get("IS_DARK_MODE") ?? false;
    isRetroTheme = _myBox.get("IS_RETRO_THEME") ?? false;
  }

  // update the database
  void updateDatabase() {
    _myBox.put("TODOLIST", toDoList);
    _myBox.put("IS_DARK_MODE", isDarkMode);
    _myBox.put("IS_RETRO_THEME", isRetroTheme);
  }
}
