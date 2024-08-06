import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smmic/pages/dashboard.dart';
import 'package:smmic/providers/devices_providers.dart';
import 'package:smmic/pages/login.dart';
import 'package:smmic/providers/theme_provider.dart';
import 'package:smmic/providers/auth_provider.dart';
import 'package:smmic/providers/user_data_provider.dart';
import 'package:smmic/utils/auth_utils.dart';
import 'package:smmic/utils/global_navigator.dart';
import 'package:smmic/utils/shared_prefs.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  GlobalNavigator().setupLocator();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<DeviceListOptionsNotifier>(create: (_) => DeviceListOptionsNotifier()),
        ChangeNotifierProvider<DeviceOptionsNotifier>(create: (_) => DeviceOptionsNotifier()),
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()..init()),
        ChangeNotifierProvider<UserDataProvider>(create: (_) => UserDataProvider()..init())
      ],
      child: const MyApp(),
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) => UiProvider()..init(),
      child: Consumer<UiProvider>(builder: (context, UiProvider notifier, child) {
        return MaterialApp(
          navigatorKey: locator<GlobalNavigator>().navigatorKey,
          debugShowCheckedModeBanner: false,
          themeMode: notifier.isDark ? ThemeMode.dark : ThemeMode.light,
          darkTheme: notifier.isDark ? notifier.darktheme : notifier.lightTheme,
          theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
          home: const AuthGate(),
        );
      }),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {

  Future<bool> _onStartupLogin() async {
    //TODO: uncomment after debug
    // await Future.delayed(const Duration(seconds: 2));
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (!sharedPreferences.containsKey('login')) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _onStartupLogin(),
      builder: (context, AsyncSnapshot<bool> loginOnStartup) {
        if (loginOnStartup.connectionState == ConnectionState.waiting) {
          //TODO: imlement loading screen
          return Container(
            color: Colors.white,
            child: const Center(child: CircularProgressIndicator()),
          );
        }
        if (loginOnStartup.hasError) {
          return const Center(
            child: Text('An unexpected error has occurred'),
          );
        }
        if (loginOnStartup.hasData) {
          if(loginOnStartup.data!){
            return const LoginPage();
          }
          return const DashBoard();
        }
        return const Center(
          child: Text('AuthPage._onStartupLogin has returned a null value'),
        );
      });
  }
}