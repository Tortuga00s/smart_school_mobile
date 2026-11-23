@TestOn('vm')
library;

import 'package:http/io_client.dart';

import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'support/live_flow.dart';

class RealNativeHttp extends HttpOverrides {}

void main() {
  HttpOverrides? previous;
  setUp(() {
    previous = HttpOverrides.current;
    HttpOverrides.global = RealNativeHttp();
  });
  tearDown(() {
    HttpOverrides.global = previous;
  });
  registerLiveFlowTests(
    enabled: const bool.fromEnvironment('RUN_LIVE_FLOW'),
    clientFactory: () => IOClient(RealNativeHttp().createHttpClient(null)),
  );
}
