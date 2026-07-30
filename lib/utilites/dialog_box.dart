import 'package:flutter/material.dart';
import 'package:todo1/utilites/mybutton.dart';

class DialogbBox extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  const DialogbBox({
    super.key,
    required this.controller,
    required this.onSave,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    bool isRetro =
        Theme.of(context).appBarTheme.titleTextStyle?.fontFamily == 'Courier';
    final Color surfaceColor = Theme.of(context).colorScheme.surface;

    return AlertDialog(
      title: const Text('New Task'),
      backgroundColor: surfaceColor,
      surfaceTintColor: Colors.transparent,
      shape: isRetro
          ? const RoundedRectangleBorder()
          : RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      content: SizedBox(
        height: 140,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextField(
              controller: controller,
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
                hintText: "Add a new task",
                hintStyle: isRetro
                    ? const TextStyle(fontFamily: 'Courier')
                    : null,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Mybutton(text: "Cancel", onPressed: onCancel),
                const SizedBox(width: 8),
                Mybutton(text: "Save", onPressed: onSave),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
