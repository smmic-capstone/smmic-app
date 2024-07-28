import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smmic/providers/devices_providers.dart';
import 'package:smmic/pages/devices.dart';
import 'package:smmic/pages/login.dart';

void main() {
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
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Devices()//LoginPage(),
    );
  }
}