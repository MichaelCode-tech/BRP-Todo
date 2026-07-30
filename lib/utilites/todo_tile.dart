import 'package:flutter/material.dart';

class ToDoTile extends StatelessWidget {
  final String taskName;
  final bool taskCompleted;
  final bool isPinned;
  final Function(bool?)? onChanged;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onPin;

  const ToDoTile({
    super.key,
    required this.taskName,
    required this.taskCompleted,
    required this.isPinned,
    required this.onChanged,
    required this.onDelete,
    required this.onEdit,
    required this.onPin,
  });

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    bool isRetro =
        Theme.of(context).appBarTheme.titleTextStyle?.fontFamily == 'Courier';
    final Color primaryColor = Theme.of(context).primaryColor;
    final Color contrastColor = isDark ? Colors.white : Colors.black;
    final Color surfaceColor = Theme.of(context).colorScheme.surface;

    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 15.0),
      child: Container(
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: isRetro ? BorderRadius.zero : BorderRadius.circular(12),
          border: Border.all(
            color: isPinned ? primaryColor : contrastColor.withAlpha(20),
            width: isPinned ? 2 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          child: Row(
            children: [
              Checkbox(value: taskCompleted, onChanged: onChanged),
              const SizedBox(width: 5),
              Expanded(
                child: Row(
                  children: [
                    if (isPinned)
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Icon(
                          Icons.push_pin,
                          size: 16,
                          color: primaryColor,
                        ),
                      ),
                    Expanded(
                      child: Text(
                        taskName,
                        style: TextStyle(
                          fontSize: 18,
                          height: 1.3,
                          decoration: taskCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          color: taskCompleted
                              ? contrastColor.withAlpha(130)
                              : contrastColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  color: contrastColor.withAlpha(150),
                ),
                color: surfaceColor,
                elevation: isRetro ? 0 : 8,
                shape: isRetro
                    ? Border.all(color: contrastColor)
                    : RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: contrastColor.withAlpha(20)),
                      ),
                onSelected: (value) {
                  if (value == 'pin') onPin();
                  if (value == 'edit') onEdit();
                  if (value == 'delete') onDelete();
                },
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem<String>(
                    value: 'pin',
                    child: Row(
                      children: [
                        Icon(
                          isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                          size: 18,
                          color: primaryColor,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          isPinned ? "Unpin" : "Pin",
                          style: isRetro
                              ? const TextStyle(fontFamily: 'Courier')
                              : null,
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 18, color: contrastColor),
                        const SizedBox(width: 10),
                        Text(
                          "Edit",
                          style: isRetro
                              ? const TextStyle(fontFamily: 'Courier')
                              : null,
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 18, color: contrastColor),
                        const SizedBox(width: 10),
                        Text(
                          "Delete",
                          style: isRetro
                              ? const TextStyle(fontFamily: 'Courier')
                              : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
