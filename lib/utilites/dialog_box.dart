import 'package:flutter/material.dart';
import 'package:todo1/utilites/mybutton.dart';

class TaskDialogBox extends StatefulWidget {
  final String initialTitle;
  final String initialStartTime;
  final String initialEndTime;
  final List<String> initialTags;
  final void Function(
    String title,
    String startTime,
    String endTime,
    List<String> tags,
  )
  onSave;
  final VoidCallback onCancel;

  const TaskDialogBox({
    super.key,
    this.initialTitle = '',
    this.initialStartTime = '',
    this.initialEndTime = '',
    this.initialTags = const [],
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<TaskDialogBox> createState() => _TaskDialogBoxState();
}

class _TaskDialogBoxState extends State<TaskDialogBox> {
  late final TextEditingController _titleController;
  late final TextEditingController _tagsController;
  String _startTime = '';
  String _endTime = '';

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _tagsController = TextEditingController(
      text: widget.initialTags.join(', '),
    );
    _startTime = widget.initialStartTime;
    _endTime = widget.initialEndTime;
  }

  Future<void> _pickTime(bool isStart) async {
    final initial = TimeOfDay.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart
          ? (widget.initialStartTime.isNotEmpty
                ? _parseTime(widget.initialStartTime)
                : initial)
          : (widget.initialEndTime.isNotEmpty
                ? _parseTime(widget.initialEndTime)
                : initial),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked.format(context);
        } else {
          _endTime = picked.format(context);
        }
      });
    }
  }

  TimeOfDay _parseTime(String value) {
    final parts = value.split(':');
    if (parts.length == 2) {
      final hour = int.tryParse(parts[0]) ?? 0;
      final minute = int.tryParse(parts[1]) ?? 0;
      return TimeOfDay(hour: hour, minute: minute);
    }
    return TimeOfDay.now();
  }

  void _save() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task title cannot be empty.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    final tags = _tagsController.text
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toSet()
        .toList();
    widget.onSave(title, _startTime, _endTime, tags);
  }

  @override
  Widget build(BuildContext context) {
    final isRetro =
        Theme.of(context).appBarTheme.titleTextStyle?.fontFamily == 'Courier';
    final surfaceColor = Theme.of(context).colorScheme.surface;

    return AlertDialog(
      title: const Text('New Task'),
      backgroundColor: surfaceColor,
      surfaceTintColor: Colors.transparent,
      shape: isRetro
          ? const RoundedRectangleBorder()
          : RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              autofocus: true,
              style: isRetro ? const TextStyle(fontFamily: 'Courier') : null,
              decoration: InputDecoration(
                enabledBorder: isRetro
                    ? const OutlineInputBorder(borderRadius: BorderRadius.zero)
                    : const OutlineInputBorder(),
                focusedBorder: isRetro
                    ? OutlineInputBorder(
                        borderRadius: BorderRadius.zero,
                        borderSide: BorderSide(
                          color: Theme.of(context).primaryColor,
                          width: 2,
                        ),
                      )
                    : OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).primaryColor,
                          width: 2,
                        ),
                      ),
                labelText: 'Task title',
                hintText: 'Enter a new task',
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _pickTime(true),
                    child: Text(
                      _startTime.isEmpty ? 'Start time' : 'From $_startTime',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _pickTime(false),
                    child: Text(_endTime.isEmpty ? 'End time' : 'To $_endTime'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _tagsController,
              style: isRetro ? const TextStyle(fontFamily: 'Courier') : null,
              decoration: InputDecoration(
                enabledBorder: isRetro
                    ? const OutlineInputBorder(borderRadius: BorderRadius.zero)
                    : const OutlineInputBorder(),
                focusedBorder: isRetro
                    ? OutlineInputBorder(
                        borderRadius: BorderRadius.zero,
                        borderSide: BorderSide(
                          color: Theme.of(context).primaryColor,
                          width: 2,
                        ),
                      )
                    : OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).primaryColor,
                          width: 2,
                        ),
                      ),
                labelText: 'Tags',
                hintText: 'Gym, Work, Religion',
              ),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Use comma-separated tags to group your tasks.',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(
                    context,
                  ).textTheme.bodySmall?.color?.withAlpha(180),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Mybutton(text: 'Cancel', onPressed: widget.onCancel),
                const SizedBox(width: 8),
                Mybutton(text: 'Save', onPressed: _save),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
