import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smmic/pages/dashboard.dart';
import 'package:smmic/providers/devices_providers.dart';
import 'package:smmic/pages/login.dart';
import 'package:smmic/providers/theme_provider.dart';
import 'package:smmic/providers/auth_provider.dart';
import 'package:smmic/utils/auth_utils.dart';
import 'package:smmic/utils/shared_prefs.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<DeviceListOptionsNotifier>(create: (_) => DeviceListOptionsNotifier()),
        ChangeNotifierProvider<DeviceOptionsNotifier>(create: (_) => DeviceOptionsNotifier()),
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),

      ],
      child: const MyApp(),
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<AuthProvider>().init();
    return ChangeNotifierProvider(
      create: (BuildContext context) => UiProvider()..init(),
      child:
          Consumer<UiProvider>(builder: (context, UiProvider notifier, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: notifier.isDark ? ThemeMode.dark : ThemeMode.light,
          darkTheme: notifier.isDark ? notifier.darktheme : notifier.lightTheme,
          theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
          home: context.watch<AuthProvider>().accessStatus == TokenStatus.valid ? const DashBoard() : const LoginPage(),
        );
      }),
    );
  }
}

// class AuthCheck extends StatefulWidget {
//   const AuthCheck({super.key});
//
//   @override
//   State<AuthCheck> createState() => _AuthCheckState();
// }
//
// class _AuthCheckState extends State<AuthCheck>{
//   final AuthUtils _authUtils = AuthUtils();
//   final SharedPrefsUtils _sharedPrefsUtils = SharedPrefsUtils();
//
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<Map<String, dynamic>?>(future: _authUtils.getFromSharedPrefsAndVerify(), builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>?> tokenStatus){
//       if (tokenStatus.connectionState == ConnectionState.waiting){
//         return const Center(child: CircularProgressIndicator());
//       }
//       if (tokenStatus.hasError) {
//         return const Center(child: Text('error'));
//       }
//       TokenStatus? _status = tokenStatus.data;
//
//       if(_status == null || _status == TokenStatus.expired || _status == TokenStatus.invalid){
//         ///TODO: implement check if refresh is valid an unexpired and just do refresh for access token
//         return const LoginPage();
//       } else if (_status == TokenStatus.valid) {
//         context.read<AuthProvider>().createAccess(token: token)
//         return const DashBoard();
//       }
//
//       throw Exception('uh oh');
//     });
//   }
//
//
// }