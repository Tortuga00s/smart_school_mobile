import '../../../packages/school_data/test/load_fonts.dart';
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_school_admin/src/admin_app.dart';
import 'package:smart_school_admin/src/app_state.dart';
import 'package:smart_school_admin/src/ui.dart';

void main() {
  testWidgets('admin navigation and add teacher form remain interactive', (
    tester,
  ) async {
    await tester.runAsync(loadTestFonts);
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    final data = SchoolStore();
    await tester.pumpWidget(
      MaterialApp(
        theme: smartTheme().copyWith(
          textTheme: smartTheme().textTheme.apply(
            fontFamily: 'SmartSchoolTest',
          ),
        ),
        home: AdminShell(store: data, onExit: () {}),
      ),
    );
    await tester.tap(find.text('Manajemen Guru').first);
    await tester.pumpAndSettle();
    expect(find.text('Ahmad Hidayat'), findsWidgets);
    await tester.tap(find.text('Tambah Guru'));
    await tester.pumpAndSettle();
    final fields = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(TextField),
    );
    expect(fields, findsWidgets);
    await tester.enterText(fields.at(0), 'Guru Baru');
    await tester.enterText(fields.at(1), 'guru@example.test');
    await tester.enterText(fields.at(2), 'Matematika');
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();
    expect(data.teachers.any((t) => t.name == 'Guru Baru'), isTrue);
    expect(tester.takeException(), isNull);
    for (final label in [
      'Siswa & Wali',
      'Mapel & Kelas',
      'Penugasan Guru',
      'Jadwal Mengajar',
      'Monitoring Absensi',
      'Izin & Pengganti',
      'Persetujuan Wajah',
      'Pengaturan & Audit',
      'Dashboard',
    ]) {
      await tester.tap(find.text(label).first);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
    if (const bool.fromEnvironment('CAPTURE_VISUALS')) {
      await expectLater(
        find.byType(AdminShell),
        matchesGoldenFile('../../../docs/screenshots/admin-dashboard.png'),
      );
    }
    await tester.pumpWidget(const SizedBox());
    data.dispose();
    await tester.binding.setSurfaceSize(null);
  });
}
