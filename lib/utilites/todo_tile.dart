import 'package:flutter/material.dart';

class ToDoTile extends StatelessWidget {
  final String taskName;
  final bool taskCompleted;
  final bool isPinned;
  final String? details;
  final Function(bool?)? onChanged;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final VoidCallback onPin;

  const ToDoTile({
    super.key,
    required this.taskName,
    required this.taskCompleted,
    required this.isPinned,
    this.details,
    this.onChanged,
    this.onDelete,
    this.onEdit,
    required this.onPin,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isRetro =
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
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Row(
            children: [
              Checkbox(value: taskCompleted, onChanged: onChanged),
              const SizedBox(width: 5),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
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
                    if (details != null && details!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          details!,
                          style: TextStyle(
                            fontSize: 13,
                            color: contrastColor.withAlpha(160),
                            height: 1.3,
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
                  if (value == 'edit' && onEdit != null) onEdit!();
                  if (value == 'delete' && onDelete != null) onDelete!();
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
                          isPinned ? 'Unpin' : 'Pin',
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
                          'Edit',
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
                          'Delete',
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
