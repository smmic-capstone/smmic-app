import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatetimeFormatting {
  String _dateFormat = 'yyyy-MM-dd';
  String _timeFormat = 'h:mma';
  String _dateTimeFormat = 'yyyy-MM-dd HH:mm';

  String formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  String formatTimeClearZero(DateTime dateTime) {
    if(DateFormat('HH:mm').format(dateTime)[0] == '0'){
      return DateFormat('HH:mm').format(dateTime).substring(1, DateFormat('HH:mm').format(dateTime).length);
    };
    return DateFormat('HH:mm').format(dateTime);
  }

  String formatDate(DateTime dateTime) {
    return DateFormat(_dateFormat).format(dateTime);
  }
}
