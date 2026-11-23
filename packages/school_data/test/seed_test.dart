@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';
import 'package:school_data/school_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('canonical demo seed roundtrips its domain state', () {
    final s = SchoolStore();
    s.grades['ST01_S01'] = {'uts': 85, 'uas': 90};
    s.addEvent(s.attendance.first);
    final encoded = const JsonEncoder.withIndent('  ').convert(s.toJson());
    final copy = SchoolStore()..load(jsonDecode(encoded));
    expect(copy.students.length, s.students.length);
    expect(copy.events.single['studentId'], 'ST01');
    expect(copy.grades['ST01_S01']!['uas'], 90);
    if (const bool.fromEnvironment('EXPORT_SEED'))
      File('../../services/demo_api/seed.json').writeAsStringSync(encoded);
    copy.dispose();
    s.dispose();
  });
}
