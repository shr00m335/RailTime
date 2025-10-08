import 'package:intl/intl.dart';

class DateTimeUtils {
  static formatToHHmm(DateTime dt) {
    final DateFormat formatter = DateFormat('HH:mm');
    return formatter.format(dt.toLocal());
  }
}
