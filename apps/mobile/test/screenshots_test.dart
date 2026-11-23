@TestOn('vm')
library;

import '../../../packages/school_data/test/load_fonts.dart';
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:school_data/school_data.dart';
import 'package:smartschool_mobile/features/parent/parent_app.dart';
import 'package:smartschool_mobile/features/teacher/teacher_shell.dart';

void main() {
  testWidgets('phone layouts at 390x844 render without overflow', (
    tester,
  ) async {
    await tester.runAsync(loadTestFonts);
    await tester.binding.setSurfaceSize(const Size(390, 844));
    final data = SchoolStore();
    data.grades['ST01_S01'] = {'uts': 85, 'uas': 90};
    await tester.pumpWidget(
      MaterialApp(
        theme: smartSchoolMobileTheme().copyWith(
          textTheme: smartSchoolMobileTheme().textTheme.apply(
            fontFamily: 'SmartSchoolTest',
          ),
        ),
        home: TeacherShell(data: data, uid: 'T01', onExit: () {}),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    if (const bool.fromEnvironment('CAPTURE_VISUALS')) {
      await expectLater(
        find.byType(TeacherShell),
        matchesGoldenFile('../../../docs/screenshots/teacher-dashboard.png'),
      );
    }
    await tester.tap(find.text('Mulai Mengajar').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Konfirmasi'));
    await tester.pumpAndSettle();
    expect(find.text('Daftar Kehadiran'), findsOneWidget);
    expect(tester.takeException(), isNull);
    if (const bool.fromEnvironment('CAPTURE_VISUALS')) {
      await expectLater(
        find.byType(TeacherAttendance),
        matchesGoldenFile('../../../docs/screenshots/teacher-attendance.png'),
      );
    }
    await tester.tap(find.byTooltip('Catat kehadiran').first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Konfirmasi di kelas');
    await tester.tap(find.text('Simpan Manual'));
    await tester.pumpAndSettle();
    expect(data.events.length, 1);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    await tester.pumpWidget(
      MaterialApp(
        theme: smartSchoolMobileTheme().copyWith(
          textTheme: smartSchoolMobileTheme().textTheme.apply(
            fontFamily: 'SmartSchoolTest',
          ),
        ),
        home: ParentShell(data: data, onExit: () {}),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    if (const bool.fromEnvironment('CAPTURE_VISUALS')) {
      await expectLater(
        find.byType(ParentShell),
        matchesGoldenFile('../../../docs/screenshots/parent-dashboard.png'),
      );
    }
    for (final name in ['Kehadiran', 'Jadwal', 'Akademik', 'Profil']) {
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text(name),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
    await tester.pumpWidget(const SizedBox());
    data.dispose();
    await tester.binding.setSurfaceSize(null);
  });
}
