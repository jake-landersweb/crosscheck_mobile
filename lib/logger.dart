import 'package:crosscheck_sports/client/env.dart';
import 'package:crosscheck_sports/logger/formatter/json_log_formatter.dart';
import 'package:crosscheck_sports/logger/formatter/logfmt_log_formatter.dart';
import 'package:crosscheck_sports/logger/level.dart';
import 'package:crosscheck_sports/logger/logger.dart';
import 'package:crosscheck_sports/logger/sink/console_log_sink.dart';
import 'package:crosscheck_sports/logger/sink/otel_log_sink.dart';
import 'package:flutter/foundation.dart';

var logger = Logger(
  OTEL_INSTRUMENTATION_NAME,
  formatter: kDebugMode ? LogFMTLogFormatter() : JSONLogFormatter(),
  level: kDebugMode ? LogLevel.debug : LogLevel.info,
  sinks: [
    ConsoleLogSink(),
    if (!kDebugMode)
      OtelLogSink(
        endpoint: "$OTEL_BACKEND_HOST/v1/logs",
        apiKey: OTEL_BACKEND_API_KEY,
        flushDuration: Duration(seconds: 5),
      ),
  ],
  attributes: {
    "sessionId": OTEL_SESSION_ID, // add a session id for the app session
  },
);
