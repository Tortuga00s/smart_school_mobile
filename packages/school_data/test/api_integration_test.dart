@TestOn('vm')
library;

import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:school_data/school_data.dart';

class RealHttp extends HttpOverrides {}

Future<void> settle(SchoolStore s) async {
  for (var i = 0; s.saving && i < 500; i++) {
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  expect(s.saving, isFalse);
  expect(s.connectionError, isNull);
}

void main() {
  test(
    'real demo API shares admin changes, teacher attendance and parent inbox',
    () async {
      await HttpOverrides.runWithHttpOverrides(() async {
        final dir = await Directory.systemTemp.createTemp('smartschool-test-');
        final socket = await ServerSocket.bind('127.0.0.1', 0);
        final port = socket.port;
        await socket.close();
        final command = Platform.isWindows ? 'py' : 'python3';
        final process = await Process.start(command, [
          if (Platform.isWindows) '-3',
          '../../services/demo_api/server.py',
          '--port',
          '$port',
          '--state',
          '${dir.path}/state.json',
        ]);
        process.stdout.drain<void>();
        process.stderr.drain<void>();
        final admin = SchoolStore();
        final teacher = SchoolStore()
          ..demoRole = 'teacher'
          ..demoUid = 'T01';
        final parent = SchoolStore()
          ..demoRole = 'parent'
          ..demoUid = 'G01';
        try {
          for (var i = 0; i < 100 && !admin.loaded; i++) {
            await admin.connect('http://127.0.0.1:$port');
            if (!admin.loaded)
              await Future<void>.delayed(const Duration(milliseconds: 20));
          }
          expect(admin.loaded, isTrue);
          await teacher.connect('http://127.0.0.1:$port');
          await parent.connect('http://127.0.0.1:$port');
          admin.editStudent(
            admin.student('ST01'),
            'Ahmad Demo Terbaru',
            '2026001',
            'C01',
          );
          await settle(admin);
          await teacher.refresh();
          await parent.refresh();
          expect(teacher.student('ST01').name, 'Ahmad Demo Terbaru');
          expect(parent.student('ST01').name, 'Ahmad Demo Terbaru');
          final sc = teacher.schedule('SC01');
          teacher.openSession(sc, 'T01');
          await settle(teacher);
          final attendance = teacher.attendance.firstWhere(
            (a) =>
                a.sessionCode == teacher.sessionId(sc) && a.studentId == 'ST01',
          );
          teacher.markAttendance(
            attendance,
            'HADIR',
            'Dikonfirmasi guru di kelas',
            'T01',
          );
          await settle(teacher);
          await parent.refresh();
          await admin.refresh();
          expect(
            parent.events.any(
              (e) =>
                  e['sessionId'] == attendance.sessionCode &&
                  e['studentId'] == 'ST01',
            ),
            isTrue,
          );
          expect(
            admin.attendance.firstWhere((a) => a.id == attendance.id).status,
            'HADIR',
          );
        } finally {
          admin.dispose();
          teacher.dispose();
          parent.dispose();
          process.kill();
          await process.exitCode;
          await dir.delete(recursive: true);
        }
      }, RealHttp());
    },
    timeout: const Timeout(Duration(seconds: 30)),
  );
}
