import 'package:flutter/material.dart';

class Mybutton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const Mybutton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    bool isRetro = Theme.of(context).appBarTheme.titleTextStyle?.fontFamily == 'Courier';
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color contrastColor = isDark ? Colors.white : Colors.black;

    return MaterialButton(
      onPressed: onPressed,
      color: text == "Save" ? Theme.of(context).primaryColor : Colors.transparent,
      elevation: 0,
      highlightElevation: 0,
      shape: isRetro
          ? const RoundedRectangleBorder()
          : RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: text == "Save" ? BorderSide.none : BorderSide(color: contrastColor.withAlpha(50)),
            ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: isRetro ? 'Courier' : null,
          fontWeight: FontWeight.bold,
          color: text == "Save" 
              ? (isDark ? Colors.black : Colors.white) 
              : contrastColor,
        ),
      ),
    );
  }
}
