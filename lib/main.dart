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
import 'package:smmic/utils/logs.dart';
import 'package:smmic/utils/shared_prefs.dart';

final Logs _logs = Logs(tag: 'Main.dart');

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  GlobalNavigator().setupLocator();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<DeviceListOptionsNotifier>(create: (_) => DeviceListOptionsNotifier()),
        ChangeNotifierProvider<DeviceOptionsNotifier>(create: (_) => DeviceOptionsNotifier()),
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()..init()),
        ChangeNotifierProvider<UserDataProvider>(create: (_) => UserDataProvider()),
        ChangeNotifierProvider<UiProvider>(create: (_) => UiProvider()..init())
      ],
      child: const MyApp(),
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: locator<GlobalNavigator>().navigatorKey,
      debugShowCheckedModeBanner: false,
      themeMode: context.watch<UiProvider>().isDark ? ThemeMode.dark : ThemeMode.light,
      darkTheme: context.watch<UiProvider>().isDark ? context.watch<UiProvider>().darktheme : context.watch<UiProvider>().lightTheme,
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
      home: const AuthGate(),
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
          //TODO: implement loading screen
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
          // initiate user data when logged in
          _logs.info(message: 'AuthPage() => UserDataProvider.init()');
          context.read<UserDataProvider>().init();
          return const DashBoard();
        }
        return const Center(
          child: Text('AuthPage._onStartupLogin has returned a null value'),
        );
      });
  }
}