import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo1/main.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _myBox = Hive.box('MyBox');

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = _myBox.get("IS_DARK_MODE") ?? false;
    bool isRetroTheme = _myBox.get("IS_RETRO_THEME") ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Dark Mode Toggle
            ListTile(
              title: const Text("Dark Mode"),
              trailing: Switch(
                value: isDarkMode,
                onChanged: (value) {
                  setState(() {
                    _myBox.put("IS_DARK_MODE", value);
                  });
                  MyApp.of(context)?.refresh();
                },
              ),
            ),

            // Retro Theme Toggle
            ListTile(
              title: const Text("Retro Theme"),
              trailing: Switch(
                value: isRetroTheme,
                onChanged: (value) {
                  setState(() {
                    _myBox.put("IS_RETRO_THEME", value);
                  });
                  MyApp.of(context)?.refresh();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
