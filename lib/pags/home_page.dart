import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo1/db/db.dart';
import 'package:todo1/pags/settings_page.dart';
import 'package:todo1/utilites/todo_tile.dart';
import 'package:todo1/utilites/dialog_box.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  // Don't access Hive boxes during field initialization — tests may pump
  // widgets without opening boxes. Access the box lazily in initState
  // only when it's open.
  Box? _myBox;
  ToDoDB db = ToDoDB();

  @override
  void initState() {
    super.initState();
    if (Hive.isBoxOpen('MyBox')) {
      _myBox = Hive.box('MyBox');
      if (_myBox!.get("TODOLIST") == null) {
        db.createInitialData();
      } else {
        db.loadData();
      }
    } else {
      // No box available (tests or early startup). Keep DB with defaults;
      // avoid calling Hive until the box is opened in `main()`.
    }
  }

  final _controller = TextEditingController();

  void checkBoxChanged(bool? value, int index, bool isCompletedList) {
    setState(() {
      List targetList = isCompletedList ? completedTasks : uncompletedTasks;
      var task = targetList[index];
      int originalIndex = db.toDoList.indexOf(task);
      db.toDoList[originalIndex][1] = !db.toDoList[originalIndex][1];
    });
    db.updateDatabase();
  }

  void saveNewTask() {
    String taskText = _controller.text.trim();
    if (taskText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Task cannot be empty!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    setState(() {
      db.toDoList.add([taskText, false, false]);
      _controller.clear();
    });
    Navigator.of(context).pop();
    db.updateDatabase();
  }

  void createNewTask() {
    _controller.clear();
    showDialog(
      context: context,
      builder: (context) {
        return DialogbBox(
          controller: _controller,
          onSave: saveNewTask,
          onCancel: () => Navigator.of(context).pop(),
        );
      },
    );
  }

  void editTask(int index, bool isCompletedList) {
    List targetList = isCompletedList ? completedTasks : uncompletedTasks;
    var task = targetList[index];
    int originalIndex = db.toDoList.indexOf(task);
    _controller.text = db.toDoList[originalIndex][0];

    showDialog(
      context: context,
      builder: (context) {
        return DialogbBox(
          controller: _controller,
          onSave: () {
            String updatedText = _controller.text.trim();
            if (updatedText.isNotEmpty) {
              setState(() {
                db.toDoList[originalIndex][0] = updatedText;
              });
              db.updateDatabase();
              Navigator.of(context).pop();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Task cannot be empty!")),
              );
            }
          },
          onCancel: () => Navigator.of(context).pop(),
        );
      },
    );
  }

  void deleteTask(int index, bool isCompletedList) {
    setState(() {
      List targetList = isCompletedList ? completedTasks : uncompletedTasks;
      var task = targetList[index];
      db.toDoList.remove(task);
    });
    db.updateDatabase();
  }

  void togglePin(int index, bool isCompletedList) {
    setState(() {
      List targetList = isCompletedList ? completedTasks : uncompletedTasks;
      var task = targetList[index];
      int originalIndex = db.toDoList.indexOf(task);
      db.toDoList[originalIndex][2] = !db.toDoList[originalIndex][2];
    });
    db.updateDatabase();
  }

  List get uncompletedTasks {
    var tasks = db.toDoList.where((task) => task[1] == false).toList();
    tasks.sort(
      (a, b) => (b[2] as bool ? 1 : 0).compareTo(a[2] as bool ? 1 : 0),
    );
    return tasks;
  }

  List get completedTasks {
    var tasks = db.toDoList.where((task) => task[1] == true).toList();
    tasks.sort(
      (a, b) => (b[2] as bool ? 1 : 0).compareTo(a[2] as bool ? 1 : 0),
    );
    return tasks;
  }

  Widget _buildTaskItem(
    List taskList,
    int index,
    bool isCompletedList,
    double scale,
  ) {
    final taskName = taskList[index][0] as String;
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
      onDismissed: (_) => deleteTask(index, isCompletedList),
      child: ToDoTile(
        taskName: taskName,
        taskCompleted: taskList[index][1],
        isPinned: taskList[index][2],
        onChanged: (value) => checkBoxChanged(value, index, isCompletedList),
        onDelete: () => deleteTask(index, isCompletedList),
        onEdit: () => editTask(index, isCompletedList),
        onPin: () => togglePin(index, isCompletedList),
      ),
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
        title: Text('Todo', style: TextStyle(color: primaryColor)),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsPage()),
            ),
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: createNewTask,
        child: const Icon(Icons.add),
      ),
      body: Center(
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
                              // Tint dark logos in dark mode so they remain visible
                              color: isDark ? Colors.white : null,
                              colorBlendMode: isDark ? BlendMode.srcIn : null,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    width: 48 * scale,
                                    height: 48 * scale,
                                    decoration: BoxDecoration(
                                      color: primaryColor.withAlpha(40),
                                      borderRadius: BorderRadius.circular(12),
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
                                "Welcome to MicCode App",
                                style: TextStyle(
                                  fontSize: 14 * scale,
                                  color: contrastColor.withAlpha(180),
                                ),
                              ),
                              Text(
                                "Todo",
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
                          'Tap + to add your first todo item and keep your day on track.',
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
                      "In Progress",
                      style: TextStyle(
                        fontSize: 20 * scale,
                        fontWeight: FontWeight.bold,
                        color: contrastColor,
                      ),
                    ),
                  ),
                ),
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  return _buildTaskItem(uncompletedTasks, index, false, scale);
                }, childCount: uncompletedTasks.length),
              ),
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
                      "Completed",
                      style: TextStyle(
                        fontSize: 20 * scale,
                        fontWeight: FontWeight.bold,
                        color: contrastColor,
                      ),
                    ),
                  ),
                ),
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  return _buildTaskItem(completedTasks, index, true, scale);
                }, childCount: completedTasks.length),
              ),
              SliverToBoxAdapter(child: SizedBox(height: 100 * scale)),
            ],
          ),
        ),
      ),
    );
  }
}
