import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smmic/components/bottomnavbar/bottom_nav_bar.dart';
import 'package:smmic/constants/api.dart';
import 'package:smmic/providers/connections_provider.dart';
import 'package:smmic/providers/device_settings_provider.dart';
import 'package:smmic/pages/login.dart';
import 'package:smmic/providers/devices_provider.dart';
import 'package:smmic/providers/mqtt_provider.dart';
import 'package:smmic/providers/theme_provider.dart';
import 'package:smmic/providers/auth_provider.dart';
import 'package:smmic/providers/user_data_provider.dart';
import 'package:smmic/utils/api.dart';
import 'package:smmic/utils/global_navigator.dart';
import 'package:smmic/utils/logs.dart';
import 'package:smmic/utils/shared_prefs.dart';

final Logs _logs = Logs(tag: 'Main.dart');

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  GlobalNavigator().setupLocator();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<DeviceListOptionsNotifier>(create: (_) => DeviceListOptionsNotifier()),
      ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
      ChangeNotifierProvider<UserDataProvider>(create: (_) => UserDataProvider()),
      ChangeNotifierProvider<UiProvider>(create: (_) => UiProvider()),
      ChangeNotifierProvider<DevicesProvider>(create: (_) => DevicesProvider()),
      ChangeNotifierProvider<MqttProvider>(create: (_) => MqttProvider()),
      ChangeNotifierProvider<ConnectionProvider>(create: (_) => ConnectionProvider())
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: locator<GlobalNavigator>().navigatorKey,
      debugShowCheckedModeBanner: false,
      themeMode:
          context.watch<UiProvider>().isDark ? ThemeMode.dark : ThemeMode.light,
      darkTheme: context.watch<UiProvider>().isDark
          ? context.watch<UiProvider>().darkTheme
          : context.watch<UiProvider>().lightTheme,
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
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
  // utils, dependencies
  final SharedPrefsUtils _sharedPrefsUtils = SharedPrefsUtils();
  final ApiRequest _apiRequest = ApiRequest();
  final ApiRoutes _apiRoutes = ApiRoutes();

  Future<bool> _authCheck() async {
    _logs.info2(message: 'executing _authCheck()');

    String? login = await _sharedPrefsUtils.getLogin();
    if (login == null) {
      _logs.info(message:'did not find login key from SharedPreferences, returning LoginPage()');
      return false;
    }

    //await Future.delayed(const Duration(seconds:  3));
    return true;
  }

  Future<void> _loadProviders({
    required BuildContext context,
  }) async {
    // initiate user data when logged in
    context.read<ConnectionProvider>().init();
    context.read<UserDataProvider>().init();
    context.read<AuthProvider>().init();
    context.read<MqttProvider>().registerContext(context: context);
    await Future.delayed(const Duration(seconds: 2));
    return;
  }

  @override
  Widget build(BuildContext context) {

    return FutureBuilder(
        future: _authCheck(),
        builder: (context, AsyncSnapshot<bool> authCheckSnapshot) {
          if (authCheckSnapshot.connectionState == ConnectionState.waiting) {
            return Container(
              color: Colors.white,
              child: const Center(child: CircularProgressIndicator()),
            );
          }

          if (authCheckSnapshot.hasError) {
            return const Center(
              child: Text('An unexpected error has occurred'),
            );
          }

          if (authCheckSnapshot.hasData) {
            bool authCheck = authCheckSnapshot.data!;
            if (!authCheck) {
              return const LoginPage();
            }

            return FutureBuilder(
                future: _loadProviders(context: context),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // TODO   add loading screen
                    return const Center(child: CircularProgressIndicator());
                  }

                  context.read<DevicesProvider>().init(
                      connectivity: context.read<ConnectionProvider>().connectionStatus
                  );

                  _apiRequest.connectSeReadingsChannel(
                      route: _apiRoutes.seReadingsWs,
                      context: context
                  );
                  _apiRequest.connectAlertsChannel(
                      route: _apiRoutes.seAlertsWs,
                      context: context
                  );

                  return const Stack(
                    children: [
                      MyBottomNav(indexPage: 0),
                    ],
                  );
                });
          }
          return const Center(
            child: Text('AuthPage._authCheck has returned a null value'),
          );
        });
  }
}
