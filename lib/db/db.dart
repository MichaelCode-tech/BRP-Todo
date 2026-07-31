import 'package:hive_flutter/hive_flutter.dart';

class ToDoDB {
  List toDoList = [];
  bool isDarkMode = false;
  bool isRetroTheme = false;

  // Lazily access the Hive box so tests (which don't open Hive) won't
  // throw during construction.
  Box? get _myBox => Hive.isBoxOpen('MyBox') ? Hive.box('MyBox') : null;

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
    final rawData = _myBox?.get("TODOLIST");
    if (rawData is List) {
      toDoList = List.from(rawData);
    } else {
      toDoList = [];
    }

    // Migrate old data if necessary (ensure 3 fields per task)
    for (int i = 0; i < toDoList.length; i++) {
      if (toDoList[i] is! List || toDoList[i].length < 2) {
        // Fallback for corrupted items
        toDoList[i] = ["Invalid Task", false, false];
        continue;
      }
      if (toDoList[i].length < 3) {
        toDoList[i] = [toDoList[i][0], toDoList[i][1], false];
      }
    }

    isDarkMode = _myBox?.get("IS_DARK_MODE") ?? false;
    isRetroTheme = _myBox?.get("IS_RETRO_THEME") ?? false;
  }

  // update the database
  void updateDatabase() {
    if (_myBox != null) {
      _myBox!.put("TODOLIST", toDoList);
      _myBox!.put("IS_DARK_MODE", isDarkMode);
      _myBox!.put("IS_RETRO_THEME", isRetroTheme);
    }
  }
}
