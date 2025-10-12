import 'package:intl/intl.dart';

class DateTimeUtils {
  static formatToHHmm(DateTime dt) {
    final DateFormat formatter = DateFormat('HH:mm');
    return formatter.format(dt.toLocal());
  }

  /// Calculate the hhmm seconds of the given datetime
  static datetimeToSeconds(DateTime dt) {
    return dt.hour * 3600 + dt.minute * 60;
  }
}
