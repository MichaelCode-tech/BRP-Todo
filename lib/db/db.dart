import 'package:hive_flutter/hive_flutter.dart';

class ToDoDB {
  List toDoList = [];
  bool isDarkMode = false;
  bool isRetroTheme = false;
  Map<String, int> tagTargets = {};

  // Lazily access the Hive box so tests (which don't open Hive) won't
  // throw during construction.
  Box? get _myBox => Hive.isBoxOpen('MyBox') ? Hive.box('MyBox') : null;

  // run this method if this is the 1st time ever opening this app
  void createInitialData() {
    toDoList = [
      [
        "Make Tutorial",
        false,
        false,
        "",
        "",
        <String>[],
        "",
        DateTime.now().toIso8601String(),
      ],
      [
        "Do Exercise",
        false,
        false,
        "",
        "",
        <String>[],
        "",
        DateTime.now().toIso8601String(),
      ],
    ];
    tagTargets = {};
    isDarkMode = false;
    isRetroTheme = false;
  }

  // load the data from database
  void loadData() {
    final rawData = _myBox?.get("TODOLIST");
    if (rawData is List) {
      toDoList = List.from(rawData.map(_normalizeTask));
    } else {
      toDoList = [];
    }

    final rawTagTargets = _myBox?.get("TAG_TARGETS");
    if (rawTagTargets is Map) {
      tagTargets = rawTagTargets.map((key, value) {
        return MapEntry(
          key.toString(),
          value is int ? value : int.tryParse(value.toString()) ?? 0,
        );
      });
    } else {
      tagTargets = {};
    }

    isDarkMode = _myBox?.get("IS_DARK_MODE") ?? false;
    isRetroTheme = _myBox?.get("IS_RETRO_THEME") ?? false;
  }

  List _normalizeTask(dynamic rawTask) {
    if (rawTask is! List) {
      return [
        "Invalid Task",
        false,
        false,
        "",
        "",
        <String>[],
        "",
        DateTime.now().toIso8601String(),
      ];
    }

    final task = List.from(rawTask);
    final title = task.isNotEmpty && task[0] is String
        ? task[0] as String
        : "Untitled Task";
    final completed = task.length > 1 && task[1] is bool
        ? task[1] as bool
        : false;
    final pinned = task.length > 2 && task[2] is bool ? task[2] as bool : false;
    final startTime = task.length > 3 && task[3] is String
        ? task[3] as String
        : "";
    final endTime = task.length > 4 && task[4] is String
        ? task[4] as String
        : "";
    final tags = task.length > 5 && task[5] is List
        ? List<String>.from((task[5] as List).map((tag) => tag.toString()))
        : <String>[];
    final completedAt = task.length > 6 && task[6] is String
        ? task[6] as String
        : "";
    final createdAt = task.length > 7 && task[7] is String
        ? task[7] as String
        : DateTime.now().toIso8601String();

    return [
      title,
      completed,
      pinned,
      startTime,
      endTime,
      tags,
      completedAt,
      createdAt,
    ];
  }

  List<String> get allTags {
    final Set<String> tags = {};
    for (var task in toDoList) {
      if (task is List && task.length > 5 && task[5] is List) {
        tags.addAll(
          List<String>.from((task[5] as List).map((tag) => tag.toString())),
        );
      }
    }
    final result = tags.toList();
    result.sort();
    return result;
  }

  int getTagTarget(String tag) {
    return tagTargets[tag] ?? 0;
  }

  void setTagTarget(String tag, int target) {
    tagTargets[tag] = target;
    updateDatabase();
  }

  List getTasksForTag(String tag) {
    return toDoList.where((task) {
      return task is List && task.length > 5 && (task[5] as List).contains(tag);
    }).toList();
  }

  int tagTaskCount(String tag) {
    return getTasksForTag(tag).length;
  }

  int tagCompletedCount(String tag) {
    return getTasksForTag(tag).where((task) => task[1] == true).length;
  }

  int completedThisMonthForTag(String tag) {
    final now = DateTime.now();
    return getTasksForTag(tag).where((task) {
      if (task.length <= 6 || task[1] != true) return false;
      final completedAt = task[6] as String;
      if (completedAt.isEmpty) return false;
      final parsed = DateTime.tryParse(completedAt);
      return parsed != null &&
          parsed.year == now.year &&
          parsed.month == now.month;
    }).length;
  }

  int plannedThisMonthForTag(String tag) {
    final target = getTagTarget(tag);
    if (target > 0) {
      return target;
    }

    final now = DateTime.now();
    return getTasksForTag(tag).where((task) {
      if (task.length <= 7) return false;
      final createdAt = task[7] as String;
      final parsed = DateTime.tryParse(createdAt);
      return parsed != null &&
          parsed.year == now.year &&
          parsed.month == now.month;
    }).length;
  }

  void toggleTaskCompletion(int index, bool completed) {
    if (index >= 0 && index < toDoList.length) {
      toDoList[index][1] = completed;
      toDoList[index][6] = completed ? DateTime.now().toIso8601String() : "";
      updateDatabase();
    }
  }

  void updateDatabase() {
    if (_myBox != null) {
      _myBox!.put("TODOLIST", toDoList);
      _myBox!.put("TAG_TARGETS", tagTargets);
      _myBox!.put("IS_DARK_MODE", isDarkMode);
      _myBox!.put("IS_RETRO_THEME", isRetroTheme);
    }
  }
}
