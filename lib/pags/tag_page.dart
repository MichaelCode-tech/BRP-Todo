import 'package:flutter/material.dart';
import 'package:todo1/db/db.dart';
import 'package:todo1/utilites/todo_tile.dart';

class TagPage extends StatelessWidget {
  final ToDoDB db;

  const TagPage({super.key, required this.db});

  @override
  Widget build(BuildContext context) {
    final tags = db.allTags;
    return Scaffold(
      appBar: AppBar(title: const Text('Tags')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: tags.isEmpty
            ? const Center(
                child: Text(
                  'No tags yet. Add tags when creating tasks to track progress by category.',
                  textAlign: TextAlign.center,
                ),
              )
            : ListView.builder(
                itemCount: tags.length,
                itemBuilder: (context, index) {
                  final tag = tags[index];
                  final total = db.tagTaskCount(tag);
                  final completed = db.tagCompletedCount(tag);
                  final monthlyTarget = db.getTagTarget(tag);
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(tag),
                      subtitle: Text(
                        monthlyTarget > 0
                            ? 'Completed $completed of $total tasks • Target $monthlyTarget/month'
                            : 'Completed $completed of $total tasks',
                      ),
                      trailing: const Icon(Icons.keyboard_arrow_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                TagDetailPage(tag: tag, db: db),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }
}

enum TagFilter { both, completed, uncompleted }

class TagDetailPage extends StatefulWidget {
  final String tag;
  final ToDoDB db;

  const TagDetailPage({super.key, required this.tag, required this.db});

  @override
  State<TagDetailPage> createState() => _TagDetailPageState();
}

class _TagDetailPageState extends State<TagDetailPage> {
  TagFilter _filter = TagFilter.both;

  List get _tagTasks {
    return widget.db.getTasksForTag(widget.tag);
  }

  List get _filteredTasks {
    return _tagTasks.where((task) {
      final completed = task[1] as bool;
      if (_filter == TagFilter.completed) return completed;
      if (_filter == TagFilter.uncompleted) return !completed;
      return true;
    }).toList();
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

  void _setTarget() async {
    final controller = TextEditingController(
      text: widget.db.getTagTarget(widget.tag).toString(),
    );
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Set Monthly Target'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Target count',
              hintText: 'Enter a monthly completion goal',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      final value = int.tryParse(controller.text.trim()) ?? 0;
      widget.db.setTagTarget(widget.tag, value);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = widget.db.tagCompletedCount(widget.tag);
    final totalCount = widget.db.tagTaskCount(widget.tag);
    final target = widget.db.getTagTarget(widget.tag);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tag),
        actions: [
          IconButton(
            tooltip: 'Set monthly target',
            icon: const Icon(Icons.settings),
            onPressed: _setTarget,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.tag,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text('Total tasks: $totalCount'),
                        Text('Completed: $completedCount'),
                        Text(
                          'Monthly target: ${target > 0 ? target : 'Not set'}',
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: _setTarget,
                      child: const Text('Edit target'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildFilterChip('All', TagFilter.both),
                const SizedBox(width: 8),
                _buildFilterChip('Checked', TagFilter.completed),
                const SizedBox(width: 8),
                _buildFilterChip('Unchecked', TagFilter.uncompleted),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _filteredTasks.isEmpty
                  ? const Center(
                      child: Text(
                        'No tasks match this filter. Create or update tasks with this tag to track progress.',
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredTasks.length,
                      itemBuilder: (context, index) {
                        final task = _filteredTasks[index];
                        final details = _formatTimeRange(task);
                        return ToDoTile(
                          taskName: task[0] as String,
                          details: details,
                          taskCompleted: task[1] as bool,
                          isPinned: task[2] as bool,
                          onChanged: (value) {
                            final originalIndex = widget.db.toDoList.indexOf(
                              task,
                            );
                            widget.db.toggleTaskCompletion(
                              originalIndex,
                              value ?? false,
                            );
                            setState(() {});
                          },
                          onDelete: () {
                            setState(() {
                              widget.db.toDoList.remove(task);
                            });
                            widget.db.updateDatabase();
                          },
                          onEdit: () {},
                          onPin: () {
                            setState(() {
                              final originalIndex = widget.db.toDoList.indexOf(
                                task,
                              );
                              if (originalIndex >= 0) {
                                widget.db.toDoList[originalIndex][2] =
                                    !(widget.db.toDoList[originalIndex][2]
                                        as bool);
                              }
                            });
                            widget.db.updateDatabase();
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, TagFilter filterType) {
    final selected = _filter == filterType;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) {
        setState(() {
          _filter = filterType;
        });
      },
    );
  }
}
