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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GlobalNavigator().setupLocator();
  runApp(const RegisterMultiProviders());
}

class RegisterMultiProviders extends StatelessWidget {
  const RegisterMultiProviders({super.key});
  @override
  Widget build(BuildContext context) {
    _logs.warning(message: 'RegisterMultiProviders() running');
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<DeviceListOptionsNotifier>(create: (_) => DeviceListOptionsNotifier()),
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
        ChangeNotifierProvider<UserDataProvider>(create: (_) => UserDataProvider()),
        ChangeNotifierProvider<UiProvider>(create: (_) => UiProvider()),
        ChangeNotifierProvider<DevicesProvider>(create: (_) => DevicesProvider()),
        ChangeNotifierProvider<MqttProvider>(create: (_) => MqttProvider()),
        ChangeNotifierProvider<ConnectionProvider>(create: (_) => ConnectionProvider())
      ],
      builder: (context, child) {
        return SMMICApp(context: context);
      },
    );
  }
}

class SMMICApp extends StatelessWidget {
  const SMMICApp({super.key, required this.context});

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: locator<GlobalNavigator>().navigatorKey,
      debugShowCheckedModeBanner: false,
      themeMode: context.watch<UiProvider>()
          .isDark
          ? ThemeMode.dark
          : ThemeMode.light,
      darkTheme: context.watch<UiProvider>()
          .isDark
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

  Future<void> _loadFirstOrderProviders({
    required BuildContext context,
    required List<Function> initFunctions}) async {

    for (Function func in initFunctions) {
      if (func is Future<dynamic> Function()) {
        await func();
      }  else if (func is Future<dynamic> Function(BuildContext)) {
        if (context.mounted) {
          await func(context);
        }
      } else {
        func();
      }
      //await Future.delayed(const Duration(seconds: 1));
    }
    //await Future.delayed(const Duration(seconds: 2));
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
                future: _loadFirstOrderProviders(
                    context: context,
                    initFunctions: [
                      context.read<ConnectionProvider>().init,
                      context.read<AuthProvider>().init,
                      context.read<UserDataProvider>().init,
                    ]
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // TODO   add loading screen
                    return const Center(child: CircularProgressIndicator());
                  }


                  context.read<MqttProvider>().registerContext(context: context);

                  context.read<DevicesProvider>().init(
                      connectivity: context.read<ConnectionProvider>().connectionStatus,
                      context: context
                  );

                  _apiRequest.initSeReadingsWSChannel(
                      route: _apiRoutes.seReadingsWs,
                      context: context
                  );

                  _apiRequest.initSeAlertsWSChannel(
                      route: _apiRoutes.seAlertsWs,
                      context: context
                  );

                  return const Stack(
                    children: [
                      BottomNavBar(initialIndexPage: 0),
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
