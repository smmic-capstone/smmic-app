import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smmic/providers/devices_providers.dart';
import 'package:smmic/pages/devices.dart';
import 'package:smmic/pages/login.dart';
import 'package:smmic/provide/provide.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<DeviceListOptionsNotifier>(create: (_) => DeviceListOptionsNotifier()),
        ChangeNotifierProvider<DeviceOptionsNotifier>(create: (_) => DeviceOptionsNotifier())
      ],
      child: MyApp(),
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) => UiProvider()..init(),
      child:
          Consumer<UiProvider>(builder: (context, UiProvider notifier, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: notifier.isDark ? ThemeMode.dark : ThemeMode.light,
          darkTheme: notifier.isDark ? notifier.darktheme : notifier.lightTheme,
          theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
          home: const Devices(),
        );
      }),
    );
  }
}