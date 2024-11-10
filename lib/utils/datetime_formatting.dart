import 'package:intl/intl.dart';

class DateTimeFormatting {
  final String _dateFormat = 'yyyy-MM-dd';
  final String _timeFormat = 'h:mma';
  final String _dateTimeFormat = 'yyyy-MM-dd HH:mm';

  String formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  String formatTimeClearZero(DateTime dateTime) {
    if(DateFormat('HH:mm').format(dateTime)[0] == '0'){
      return DateFormat('HH:mm').format(dateTime).substring(1, DateFormat('HH:mm').format(dateTime).length);
    }
    return DateFormat('HH:mm:ss.SSS').format(dateTime);
  }

  String formatDate(DateTime dateTime) {
    return DateFormat(_dateFormat).format(dateTime);
  }
  
  DateTime fromJWTSeconds(num dateTime) {
    return DateTime.fromMillisecondsSinceEpoch(dateTime.toInt() * 1000);
  }
}
