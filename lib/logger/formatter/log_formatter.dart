import 'package:crosscheck_sports/logger/record.dart';

abstract class LogFormatter {
  String format(LogRecord record);
}
