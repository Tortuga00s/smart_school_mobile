import 'package:flutter_test/flutter_test.dart';
import 'package:smart_school_admin/src/app_state.dart';

void main() {
  test('penugasan satu guru dapat mencakup lebih dari satu kelas', () {
    final s = SchoolStore();
    expect(s.assignments.where((a) => a.teacherId == 'T01').length, 2);
  });

  test('jadwal bentrok kelas ditolak secara logika', () {
    final s = SchoolStore();
    final conflict = s.scheduleConflict('A03', 1, 430, 480, 'R. 209');
    expect(conflict, contains('Bentrok kelas'));
  });

  test('jadwal yang bersisian tidak dianggap bentrok', () {
    final s = SchoolStore();
    final conflict = s.scheduleConflict(
      'A03',
      1,
      510,
      600,
      'R. 201',
      ignoreId: 'SC02',
    );
    expect(conflict, isNull);
  });

  test('koreksi absensi menambahkan log audit tanpa menghapus riwayat', () {
    final s = SchoolStore();
    final before = s.audits.length;
    final a = s.attendance.first;
    s.updateAttendance(a, 'IZIN', 'Dikoreksi setelah konfirmasi');
    expect(a.status, 'IZIN');
    expect(s.audits.length, before + 1);
    expect(s.audits.first.details, contains('HADIR → IZIN'));
  });

  test(
    'pencabutan consent mempertahankan jalur manual sebagai kebijakan UI',
    () {
      final s = SchoolStore();
      final c = s.consents.first;
      s.setConsent(c, 'DICABUT', 'Permintaan orang tua');
      expect(c.status, 'DICABUT');
      expect(s.audits.first.action, 'Persetujuan biometrik');
    },
  );
}
