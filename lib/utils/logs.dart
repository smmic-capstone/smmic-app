// FUNCTIONS THAT LOG THE EVENTS AND ONGOING FUNCTIONS TO TRACE POSSIBLE BUGS FOR EASIER DEBUGGING
import 'package:ansicolor/ansicolor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Provides logging functions of different levels (`error`, `info`, `warning`, `critical`) Useful for logging processes that execute
///
/// Provide a tag as context of the log (i.e. Service, Utility, Widgets), `message` should provide context of the log
class Logs {

  /// Provides logging functions of different levels (`error`, `info`, `warning`, `critical`) Useful for logging processes that execute
  ///
  /// Provide a tag as context of the log (i.e. Service, Utility, Widgets), `message` should provide context of the log
  Logs({required this.tag});

  final String tag;
  final AnsiPen _pen = AnsiPen();

  void _writer({required String message, required AnsiPen pen}) {
    assert(() {
      if(kDebugMode){
        ansiColorDisabled = false;
        print(pen('$tag ---> $message'));
      }
      return true;
    }());
  }

  void critical({String message = 'Critical'}){
    _pen..white(bold: true)..rgb(r:1.0, g:0.0, b:0.0, bg: true);
    _writer(message: message, pen: _pen);
  }

  void error({String message = 'Error'}){
    _pen..reset()..red();
    _writer(message: message, pen: _pen);
  }

  void info({String? message}){
    _pen..reset()..xterm(039);
    _writer(message: message ?? 'Information', pen: _pen);
  }

  void warning({String message = 'Warning'}){
    _pen..reset()..xterm(202);
    _writer(message: message, pen: _pen);
  }
}