import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smmic/components/bottomnavbar/bottom_nav_bar.dart';
import 'package:smmic/pages/dashboard.dart';
import 'package:smmic/providers/device_settings_provider.dart';
import 'package:smmic/pages/login.dart';
import 'package:smmic/providers/theme_provider.dart';
import 'package:smmic/providers/auth_provider.dart';
import 'package:smmic/providers/user_data_provider.dart';
import 'package:smmic/services/auth_services.dart';
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

  // utils
  final SharedPrefsUtils _sharedPrefsUtils = SharedPrefsUtils();

  // providers
  final AuthProvider _authProvider = AuthProvider();
  final UserDataProvider _userDataProvider = UserDataProvider();

  Future<bool> _authCheck() async {
    _logs.info2(message: 'executing _authCheck()');

    String? login = await _sharedPrefsUtils.getLogin();
    if (login == null){
      _logs.info(message: 'did not find login key from SharedPreferences, returning LoginPage()');
      return false;
    }

    await Future.delayed(const Duration(seconds:  3));
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _authCheck(),
        builder: (context, AsyncSnapshot<bool> authCheckSnapshot) {
          if(authCheckSnapshot.connectionState == ConnectionState.waiting){
            return Container(
              color: Colors.white,
              child: const Center(child: CircularProgressIndicator()),
            );
          }
          if(authCheckSnapshot.hasError){
            return const Center(
              child: Text('An unexpected error has occurred'),
            );
          }
          if (authCheckSnapshot.hasData) {
            bool authCheck = authCheckSnapshot.data!;
            if (!authCheck){
              return const LoginPage();
            }
            // initiate user data when logged in
            context.read<UserDataProvider>().init();
            return const MyBottomNav(indexPage: 0);
          }
          return const Center(
            child: Text('AuthPage._authCheck has returned a null value'),
          );
        }
    );
  }
}