import 'package:flutter_test/flutter_test.dart';
import 'package:school_data/school_data.dart';

void main() {
  test(
    'session open is idempotent, assignment protected and independent per lesson',
    () {
      final s = SchoolStore();
      final sc = s.schedule('SC01');
      expect(() => s.openSession(sc, 'T02'), throwsStateError);
      s.openSession(sc, 'T01');
      final count = s.attendance.length;
      s.openSession(sc, 'T01');
      expect(s.attendance.length, count);
      s.openSession(s.schedule('SC02'), 'T02');
      final records = s.attendance
          .where((a) => a.studentId == 'ST01' && a.sessionCode.contains('_SC'))
          .toList();
      expect(records.length, 2);
      expect(records.every((a) => a.status == 'BELUM_ABSEN'), isTrue);
      s.dispose();
    },
  );
  test(
    'manual attendance updates inbox per lesson and duplicate status is idempotent',
    () {
      final s = SchoolStore();
      for (final pair in [('SC01', 'T01'), ('SC02', 'T02')]) {
        final sc = s.schedule(pair.$1);
        s.openSession(sc, pair.$2);
        final a = s.attendance.firstWhere(
          (a) => a.sessionCode == s.sessionId(sc) && a.studentId == 'ST01',
        );
        s.markAttendance(a, 'HADIR', 'Dicatat manual', pair.$2);
        s.markAttendance(a, 'HADIR', 'Retry', pair.$2);
      }
      expect(s.events.length, 2);
      expect(s.events.map((e) => e['sessionId']).toSet().length, 2);
      s.dispose();
    },
  );
  test('closing requires review; closed sessions reject attendance edits', () {
    final s = SchoolStore();
    final sc = s.schedule('SC01');
    s.openSession(sc, 'T01');
    expect(() => s.closeSession(sc, 'T01'), throwsStateError);
    final records = s.attendance
        .where((a) => a.sessionCode == s.sessionId(sc))
        .toList();
    for (final a in records) {
      s.markAttendance(a, 'IZIN', 'Konfirmasi wali', 'T01');
    }
    s.closeSession(sc, 'T01');
    expect(s.sessionStates[s.sessionId(sc)], 'CLOSED');
    expect(
      () => s.markAttendance(records.first, 'HADIR', 'Koreksi', 'T01'),
      throwsStateError,
    );
    s.dispose();
  });
  test(
    'serialization preserves state and schedule conflicts reject writes',
    () {
      final s = SchoolStore();
      final copy = SchoolStore()..load(s.toJson());
      expect(copy.students.length, s.students.length);
      expect(
        () => s.addSchedule('A03', 1, 430, 480, 'R. 209'),
        throwsStateError,
      );
      expect(
        () => s.addSchedule('A03', 1, 600, 500, 'R. 209'),
        throwsArgumentError,
      );
      s.dispose();
      copy.dispose();
    },
  );
  test('grade input rejects cross-class teacher and invalid values', () {
    final s = SchoolStore();
    expect(() => s.inputGrade('T02', 'ST01', 'S01', 80, 90), throwsStateError);
    expect(
      () => s.inputGrade('T01', 'ST01', 'S01', -1, 90),
      throwsArgumentError,
    );
    s.inputGrade('T01', 'ST01', 'S01', 80, 90);
    expect(s.grades['ST01_S01']!['uts'], 80);
    s.dispose();
  });
}
