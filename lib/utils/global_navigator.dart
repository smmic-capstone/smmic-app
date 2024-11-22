import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:smmic/pages/login.dart';
import 'package:smmic/utils/logs.dart';
import 'package:smmic/utils/shared_prefs.dart';

GetIt locator = GetIt.instance;

class GlobalNavigator {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final SharedPrefsUtils _sharedPrefsUtils = SharedPrefsUtils();
  final Logs _logs = Logs(tag: 'GlobalNavigator()');

  Future<dynamic> navigateToLogin() {
    return navigatorKey.currentState!.pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const LoginPage()), (route) => false);
  }

  void setupLocator() {
    locator.registerLazySingleton(() => GlobalNavigator());
  }

  void forceLoginDialog({required String origin}) {
    _logs.error(message: '$origin called forceLoginDialog()');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
          barrierDismissible: false,
          context: navigatorKey.currentContext!,
          builder: (context) {
            return AlertDialog(
              title: const Text('Invalid Session'),
              content: const Text('Your session is either invalid or has expired. Please login to continue'),
              actions: [
                TextButton(
                    onPressed: () {
                      _sharedPrefsUtils.clearTokens();
                      _toLogin();
                    },
                    child: Text('OK')
                )
              ],
            );
          }
      );
    });
  }

  void _toLogin() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushAndRemoveUntil(navigatorKey.currentContext!, MaterialPageRoute(builder: (context) => const LoginPage()), (route) => false);
    });
  }
}