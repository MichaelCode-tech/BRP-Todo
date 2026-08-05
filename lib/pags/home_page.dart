import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo1/db/db.dart';
import 'package:todo1/pags/monthly_tracker_page.dart';
import 'package:todo1/pags/settings_page.dart';
import 'package:todo1/pags/tag_page.dart';
import 'package:todo1/utilites/dialog_box.dart';
import 'package:todo1/utilites/todo_tile.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  Box? _myBox;
  ToDoDB db = ToDoDB();

  @override
  void initState() {
    super.initState();
    if (Hive.isBoxOpen('MyBox')) {
      _myBox = Hive.box('MyBox');
      if (_myBox!.get('TODOLIST') == null) {
        db.createInitialData();
      } else {
        db.loadData();
      }
    }
  }

  final _controller = TextEditingController();
  bool _showCompletedTasks = false;
  bool _showUncompletedTasks = false;
  int _bottomNavIndex = 0;
  static const int _toggleThreshold = 5;

  int _timeToMinutes(String time) {
    final parts = time.split(':');
    if (parts.length != 2) return 9999;
    final hour = int.tryParse(parts[0]) ?? 99;
    final minute = int.tryParse(parts[1]) ?? 99;
    return hour * 60 + minute;
  }

  int _compareTasksByTime(List a, List b) {
    final aTime = _timeToMinutes(a[3] as String);
    final bTime = _timeToMinutes(b[3] as String);
    if (aTime == bTime) return 0;
    if (aTime == 9999) return 1;
    if (bTime == 9999) return -1;
    return aTime.compareTo(bTime);
  }

  int _completedAtEpoch(List task) {
    if (task.length > 6 &&
        task[6] is String &&
        (task[6] as String).isNotEmpty) {
      final parsed = DateTime.tryParse(task[6] as String);
      return parsed?.millisecondsSinceEpoch ?? 0;
    }
    return 0;
  }

  String _formatTimeRange(List task) {
    final start = task[3] as String;
    final end = task[4] as String;
    if (start.isNotEmpty && end.isNotEmpty) {
      return 'Time: $start – $end';
    }
    if (start.isNotEmpty) {
      return 'Starts at $start';
    }
    if (end.isNotEmpty) {
      return 'Until $end';
    }
    return '';
  }

  String _formatTagLabel(List task) {
    final tags = task[5] as List;
    if (tags.isEmpty) return '';
    return 'Tags: ${tags.join(', ')}';
  }

  void _toggleTaskCompletion(bool? value, int index, bool isCompletedList) {
    final targetList = isCompletedList ? completedTasks : uncompletedTasks;
    final task = targetList[index];
    final originalIndex = db.toDoList.indexOf(task);
    if (originalIndex >= 0) {
      db.toggleTaskCompletion(originalIndex, value ?? false);
      setState(() {});
    }
  }

  void _saveTask(
    String title,
    String startTime,
    String endTime,
    List<String> tags,
  ) {
    setState(() {
      db.toDoList.add([
        title,
        false,
        false,
        startTime,
        endTime,
        tags,
        '',
        DateTime.now().toIso8601String(),
      ]);
    });
    Navigator.of(context).pop();
    db.updateDatabase();
  }

  void _editTask(int index, bool isCompletedList) {
    final targetList = isCompletedList ? completedTasks : uncompletedTasks;
    final task = targetList[index];
    final originalIndex = db.toDoList.indexOf(task);
    _controller.text = db.toDoList[originalIndex][0] as String;
    showDialog(
      context: context,
      builder: (context) {
        return TaskDialogBox(
          initialTitle: db.toDoList[originalIndex][0] as String,
          initialStartTime: db.toDoList[originalIndex][3] as String,
          initialEndTime: db.toDoList[originalIndex][4] as String,
          initialTags: List<String>.from(db.toDoList[originalIndex][5] as List),
          onSave: (title, startTime, endTime, tags) {
            final updatedText = title.trim();
            if (updatedText.isNotEmpty) {
              setState(() {
                db.toDoList[originalIndex][0] = updatedText;
                db.toDoList[originalIndex][3] = startTime;
                db.toDoList[originalIndex][4] = endTime;
                db.toDoList[originalIndex][5] = tags;
              });
              db.updateDatabase();
              Navigator.of(context).pop();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Task title cannot be empty.')),
              );
            }
          },
          onCancel: () => Navigator.of(context).pop(),
        );
      },
    );
  }

  void _deleteTask(int index, bool isCompletedList) {
    setState(() {
      final targetList = isCompletedList ? completedTasks : uncompletedTasks;
      final task = targetList[index];
      db.toDoList.remove(task);
    });
    db.updateDatabase();
  }

  void _togglePin(int index, bool isCompletedList) {
    setState(() {
      final targetList = isCompletedList ? completedTasks : uncompletedTasks;
      final task = targetList[index];
      final originalIndex = db.toDoList.indexOf(task);
      if (originalIndex >= 0) {
        db.toDoList[originalIndex][2] =
            !(db.toDoList[originalIndex][2] as bool);
      }
    });
    db.updateDatabase();
  }

  List get uncompletedTasks {
    final tasks = db.toDoList.where((task) => task[1] == false).toList();
    tasks.sort((a, b) {
      if ((b[2] as bool) != (a[2] as bool)) {
        return (b[2] as bool ? 1 : 0).compareTo(a[2] as bool ? 1 : 0);
      }
      return _compareTasksByTime(a, b);
    });
    return tasks;
  }

  List get completedTasks {
    final tasks = db.toDoList.where((task) => task[1] == true).toList();
    tasks.sort((a, b) {
      if ((b[2] as bool) != (a[2] as bool)) {
        return (b[2] as bool ? 1 : 0).compareTo(a[2] as bool ? 1 : 0);
      }
      return _completedAtEpoch(b).compareTo(_completedAtEpoch(a));
    });
    return tasks;
  }

  Widget _buildTaskItem(
    List taskList,
    int index,
    bool isCompletedList,
    double scale,
  ) {
    final task = taskList[index];
    final taskName = task[0] as String;
    final details = [
      _formatTimeRange(task),
      _formatTagLabel(task),
    ].where((text) => text.isNotEmpty).join(' • ');
    final taskKey =
        '${isCompletedList ? 'completed' : 'todo'}-$index-$taskName';

    return Dismissible(
      key: Key(taskKey),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20 * scale),
        child: Icon(Icons.delete, color: Colors.white, size: 20 * scale),
      ),
      onDismissed: (_) => _deleteTask(index, isCompletedList),
      child: ToDoTile(
        taskName: taskName,
        details: details,
        taskCompleted: task[1] as bool,
        isPinned: task[2] as bool,
        onChanged: (value) =>
            _toggleTaskCompletion(value, index, isCompletedList),
        onDelete: () => _deleteTask(index, isCompletedList),
        onEdit: () => _editTask(index, isCompletedList),
        onPin: () => _togglePin(index, isCompletedList),
      ),
    );
  }

  void _showNewTaskDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return TaskDialogBox(
          dialogTitle: 'New Task',
          initialTitle: 'Task ${db.toDoList.length + 1}',
          initialStartTime: '09:00',
          initialEndTime: '10:00',
          initialTags: const ['Gym'],
          onSave: _saveTask,
          onCancel: () => Navigator.of(context).pop(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color contrastColor = isDark ? Colors.white : Colors.black;
    final Color primaryColor = Theme.of(context).primaryColor;
    final bool hasTasks = db.toDoList.isNotEmpty;

    final double screenWidth = MediaQuery.of(context).size.width;
    final double scale = screenWidth > 1200
        ? 1.35
        : screenWidth > 800
        ? 1.15
        : screenWidth > 600
        ? 1.05
        : 1.0;
    const double maxContentWidth = 900;

    return Scaffold(
      appBar: AppBar(
        title: Text('Todo Tracker', style: TextStyle(color: primaryColor)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showNewTaskDialog,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                tooltip: 'Tasks',
                icon: Icon(
                  Icons.checklist_rtl,
                  color: _bottomNavIndex == 0
                      ? primaryColor
                      : contrastColor.withAlpha(160),
                ),
                onPressed: () {
                  setState(() {
                    _bottomNavIndex = 0;
                  });
                },
              ),
              Row(
                children: [
                  IconButton(
                    tooltip: 'Tags',
                    icon: Icon(
                      Icons.label_outline,
                      color: _bottomNavIndex == 1
                          ? primaryColor
                          : contrastColor.withAlpha(160),
                    ),
                    onPressed: () {
                      setState(() {
                        _bottomNavIndex = 1;
                      });
                    },
                  ),
                  IconButton(
                    tooltip: 'Tracker',
                    icon: Icon(
                      Icons.insights,
                      color: _bottomNavIndex == 2
                          ? primaryColor
                          : contrastColor.withAlpha(160),
                    ),
                    onPressed: () {
                      setState(() {
                        _bottomNavIndex = 2;
                      });
                    },
                  ),
                ],
              ),
              IconButton(
                tooltip: 'Settings',
                icon: Icon(Icons.settings, color: contrastColor.withAlpha(160)),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                ),
              ),
            ],
          ),
        ),
      ),
      body: IndexedStack(
        index: _bottomNavIndex,
        children: [
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxContentWidth),
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(25.0 * scale),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.asset(
                                  'lib/assets/images/logo.png',
                                  width: 48 * scale,
                                  height: 48 * scale,
                                  fit: BoxFit.cover,
                                  color: isDark ? Colors.white : null,
                                  colorBlendMode: isDark
                                      ? BlendMode.srcIn
                                      : null,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                        width: 48 * scale,
                                        height: 48 * scale,
                                        decoration: BoxDecoration(
                                          color: primaryColor.withAlpha(40),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.apps,
                                          color: contrastColor,
                                          size: 20 * scale,
                                        ),
                                      ),
                                ),
                              ),
                              SizedBox(width: 12 * scale),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Plan your day and track progress by tag.',
                                    style: TextStyle(
                                      fontSize: 14 * scale,
                                      color: contrastColor.withAlpha(180),
                                    ),
                                  ),
                                  Text(
                                    'Todo Tracker',
                                    style: TextStyle(
                                      fontSize: 28 * scale,
                                      fontWeight: FontWeight.bold,
                                      color: primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (!hasTasks)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40.0 * scale),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.task_alt,
                              size: 88 * scale,
                              color: primaryColor.withAlpha(180),
                            ),
                            SizedBox(height: 20 * scale),
                            Text(
                              'No tasks yet',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 22 * scale,
                                fontWeight: FontWeight.w600,
                                color: contrastColor,
                              ),
                            ),
                            SizedBox(height: 12 * scale),
                            Text(
                              'Tap + to add your first task, set time windows, assign tags, and start tracking monthly progress.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16 * scale,
                                color: contrastColor.withAlpha(160),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (uncompletedTasks.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 25.0 * scale,
                          vertical: 14 * scale,
                        ),
                        child: Text(
                          'In Progress',
                          style: TextStyle(
                            fontSize: 20 * scale,
                            fontWeight: FontWeight.bold,
                            color: contrastColor,
                          ),
                        ),
                      ),
                    ),
                  if (uncompletedTasks.length > _toggleThreshold)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 25.0 * scale,
                          vertical: 8.0 * scale,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${uncompletedTasks.length} active tasks',
                              style: TextStyle(
                                fontSize: 16 * scale,
                                color: contrastColor.withAlpha(200),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  _showUncompletedTasks =
                                      !_showUncompletedTasks;
                                });
                              },
                              icon: Icon(
                                _showUncompletedTasks
                                    ? Icons.expand_less
                                    : Icons.expand_more,
                                color: primaryColor,
                              ),
                              label: Text(
                                _showUncompletedTasks
                                    ? 'Hide list'
                                    : 'Show list',
                                style: TextStyle(color: primaryColor),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (uncompletedTasks.length <= _toggleThreshold ||
                      _showUncompletedTasks)
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        return _buildTaskItem(
                          uncompletedTasks,
                          index,
                          false,
                          scale,
                        );
                      }, childCount: uncompletedTasks.length),
                    ),
                  if (uncompletedTasks.length > _toggleThreshold &&
                      !_showUncompletedTasks)
                    SliverToBoxAdapter(child: SizedBox(height: 12 * scale)),
                  if (completedTasks.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: 25.0 * scale,
                          right: 25 * scale,
                          top: 40 * scale,
                          bottom: 10 * scale,
                        ),
                        child: Text(
                          'Completed',
                          style: TextStyle(
                            fontSize: 20 * scale,
                            fontWeight: FontWeight.bold,
                            color: contrastColor,
                          ),
                        ),
                      ),
                    ),
                  if (completedTasks.length > _toggleThreshold)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 25.0 * scale,
                          vertical: 8.0 * scale,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${completedTasks.length} completed tasks',
                              style: TextStyle(
                                fontSize: 16 * scale,
                                color: contrastColor.withAlpha(200),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  _showCompletedTasks = !_showCompletedTasks;
                                });
                              },
                              icon: Icon(
                                _showCompletedTasks
                                    ? Icons.expand_less
                                    : Icons.expand_more,
                                color: primaryColor,
                              ),
                              label: Text(
                                _showCompletedTasks ? 'Hide list' : 'Show list',
                                style: TextStyle(color: primaryColor),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (completedTasks.length <= _toggleThreshold ||
                      _showCompletedTasks)
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        return _buildTaskItem(
                          completedTasks,
                          index,
                          true,
                          scale,
                        );
                      }, childCount: completedTasks.length),
                    ),
                  if (completedTasks.length > _toggleThreshold &&
                      !_showCompletedTasks)
                    SliverToBoxAdapter(child: SizedBox(height: 12 * scale)),
                  SliverToBoxAdapter(child: SizedBox(height: 100 * scale)),
                ],
              ),
            ),
          ),
          Center(child: TagPage(db: db)),
          Center(child: MonthlyTrackerPage(db: db)),
        ],
      ),
    );
  }
}
