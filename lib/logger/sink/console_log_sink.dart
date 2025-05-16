import 'dart:async';
import 'package:flutter/material.dart';
import 'package:crosscheck_sports/logger/record.dart';
import 'package:crosscheck_sports/logger/sink/log_sink.dart';

class ConsoleLogSink implements LogSink {
  @override
  void setLoggerData(String title) {}

  @override
  Future<void> send(LogRecord record, String formatted) async {
    Zone.root.run(() {
      debugPrint(formatted);
    });
  }

  @override
  Future<void> flush() async {}
}
