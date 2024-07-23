import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smmic/provide/provide.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Consumer<UiProvider>(builder: (context, notifier, child) {
        return Column(
          children: [
            ListTile(
              leading: const Icon(Icons.dark_mode),
              title: const Text('Dard Mode'),
              trailing: Switch(
                  value: notifier.isDark,
                  onChanged: (value) => notifier.changTheme()),
            ),
          ],
        );
      }),
    );
  }
}
