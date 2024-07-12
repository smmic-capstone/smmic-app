import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatetimeFormatting {
  String _dateFormat = 'yyyy-MM-dd';
  String _timeFormat = 'h:mma';
  String _dateTimeFormat = 'yyyy-MM-dd HH:mm';

  String formatTime(DateTime dateTime) {
    return DateFormat.jm().format(dateTime);
  }
}
