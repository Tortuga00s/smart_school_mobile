// Keep original Material UI imports compatible with the uploaded project.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:school_data/school_data.dart';
import 'package:smartschool_mobile/features/parent/parent_app.dart';
import 'package:smartschool_mobile/features/parent/demo_store.dart';
import 'package:smartschool_mobile/features/teacher/teacher_shell.dart';

void main() {
  test(
    'parent adapter uses shared attendance and grades rather than static counts',
    () {
      final data = SchoolStore();
      data.grades['ST01_S01'] = {'uts': 85, 'uas': 90};
      final store = ParentDemoStore(data);
      expect(store.attendance.length, 1);
      expect(store.presentPercent, 100);
      expect(store.average, 87.5);
      data.updateAttendance(data.attendance.first, 'IZIN', 'Koreksi demo');
      expect(store.attendance.first.status, 'Izin');
      expect(store.presentPercent, 0);
      expect(store.unread, 1);
      store.markAllRead();
      expect(store.unread, 0);
      store.dispose();
      data.dispose();
    },
  );
  testWidgets('mobile entry offers teacher and parent, never admin', (
    tester,
  ) async {
    await tester.pumpWidget(const SmartSchoolApp());
    expect(find.text('Guru'), findsOneWidget);
    expect(find.text('Orang Tua'), findsOneWidget);
    expect(find.text('Buka Demo'), findsOneWidget);
    expect(find.text('Admin'), findsNothing);
    await tester.tap(find.text('Orang Tua'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Wali demo:'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('existing parent bottom navigation works on shared data', (
    tester,
  ) async {
    final data = SchoolStore();
    await tester.pumpWidget(
      MaterialApp(
        home: ParentShell(data: data, onExit: () {}),
      ),
    );
    for (final p in {
      'Kehadiran': 'Rekap Kehadiran',
      'Jadwal': 'Jadwal Pelajaran',
      'Akademik': 'Nilai Akademik',
      'Profil': 'Edit Profil',
    }.entries) {
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text(p.key),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(p.value), findsWidgets);
      expect(tester.takeException(), isNull);
    }
    await tester.pumpWidget(const SizedBox());
    data.dispose();
  });
  testWidgets('teacher dashboard and tabs use only assigned schedules', (
    tester,
  ) async {
    final data = SchoolStore();
    await tester.pumpWidget(
      MaterialApp(
        home: TeacherShell(data: data, uid: 'T01', onExit: () {}),
      ),
    );
    expect(find.text('Matematika'), findsWidgets);
    expect(find.text('IPA'), findsNothing);
    for (final name in ['Jadwal', 'Nilai', 'Profil', 'Beranda']) {
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
  });
}
