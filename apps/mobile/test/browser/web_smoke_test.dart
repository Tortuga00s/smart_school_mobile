@TestOn('browser')
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import '../support/live_flow.dart';

void main() => registerLiveFlowTests(enabled: kIsWeb);
