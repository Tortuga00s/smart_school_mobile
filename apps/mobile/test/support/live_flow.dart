import 'package:http/http.dart' as http;
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:school_data/school_data.dart';
import 'package:smartschool_mobile/features/parent/parent_app.dart';
import 'package:smartschool_mobile/features/teacher/teacher_shell.dart';

const endpoint = String.fromEnvironment(
  'BROWSER_DEMO_API_URL',
  defaultValue: 'http://127.0.0.1:8080',
);
Future<void> ready(WidgetTester tester, bool Function() predicate) async {
  for (var i = 0; i < 100; i++) {
    await tester.pump();
    if (predicate()) return;
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
  }
  fail('Browser/backend did not reach the expected state');
}

Future<void> saved(WidgetTester tester, SchoolStore store) async {
  await ready(tester, () => !store.saving);
  await tester.pumpAndSettle();
  expect(store.connectionError, isNull);
}

void registerLiveFlowTests({
  required bool enabled,
  http.Client Function()? clientFactory,
}) {
  test('real HTTP GET POST PUT OPTIONS reach shared backend', () async {
    final s = SchoolStore();
    try {
      await s.connect(endpoint);
      expect(s.loaded, isTrue, reason: s.connectionError);
      final before = await s.request('GET', '/snapshot');
      final posted = await s.request('POST', '/snapshot', before);
      final updated = await s.request('PUT', '/snapshot', posted);
      expect(updated['revision'], before['revision'] + 2);
      expect(await s.request('OPTIONS', '/snapshot'), isEmpty);
      await expectLater(
        s.request('PUT', '/snapshot', before),
        throwsA(predicate((e) => e.toString().contains('409'))),
      );
    } finally {
      s.dispose();
    }
  }, skip: !enabled);

  testWidgets(
    'teacher to parent role switch, navigation, manual attendance, grades and inbox',
    (tester) => clientFactory == null
        ? _runUiFlow(tester)
        : http.runWithClient(() => _runUiFlow(tester), clientFactory),
    skip: !enabled,
  );
}

Future<void> _runUiFlow(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(1280, 900));
  await tester.pumpWidget(const SmartSchoolApp());
  await tester.tap(find.text('Buka Demo'));
  await ready(tester, () => find.byType(TeacherShell).evaluate().isNotEmpty);
  expect(tester.takeException(), isNull);
  var teacher = tester.widget<TeacherShell>(find.byType(TeacherShell)).data;
  expect(teacher.loaded, isTrue);
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
  await tester.tap(find.text('Mulai Mengajar').first);
  await tester.pumpAndSettle();
  await tester.tap(find.text('Konfirmasi'));
  await tester.pumpAndSettle();
  await saved(tester, teacher);
  expect(find.byType(TeacherAttendance), findsOneWidget);
  await tester.tap(find.byTooltip('Catat kehadiran').first);
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextField), 'Dikonfirmasi dari Chrome');
  await tester.tap(find.text('Simpan Manual'));
  await tester.pumpAndSettle();
  await saved(tester, teacher);
  expect(
    teacher.events.any(
      (e) =>
          e['studentId'] == 'ST01' &&
          e['sessionId'] == teacher.sessionId(teacher.schedule('SC01')),
    ),
    isTrue,
  );
  await tester.pageBack();
  await tester.pumpAndSettle();
  await tester.tap(
    find.descendant(
      of: find.byType(NavigationBar),
      matching: find.text('Nilai'),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('Ahmad Rizki').first);
  await tester.pumpAndSettle();
  final fields = find.descendant(
    of: find.byType(AlertDialog),
    matching: find.byType(TextFormField),
  );
  await tester.enterText(fields.at(0), '88');
  await tester.enterText(fields.at(1), '94');
  await tester.tap(find.text('Simpan Nilai'));
  await tester.pumpAndSettle();
  await saved(tester, teacher);
  await tester.tap(
    find.descendant(
      of: find.byType(NavigationBar),
      matching: find.text('Profil'),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('Keluar / Ganti Peran'));
  await tester.pumpAndSettle();
  expect(find.text('Buka Demo'), findsOneWidget);
  await tester.tap(find.text('Orang Tua'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Buka Demo'));
  await ready(tester, () => find.byType(ParentShell).evaluate().isNotEmpty);
  final parent = tester.widget<ParentShell>(find.byType(ParentShell)).data;
  expect(parent.grades['ST01_S01']!['uas'], 94);
  expect(
    parent.events.any(
      (e) => e['studentId'] == 'ST01' && e['status'] == 'HADIR',
    ),
    isTrue,
  );
  for (final name in ['Kehadiran', 'Jadwal', 'Akademik', 'Profil', 'Beranda']) {
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text(name),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  }
  await tester.tap(find.byTooltip('Pusat notifikasi'));
  await tester.pumpAndSettle();
  expect(find.text('Pusat Notifikasi'), findsOneWidget);
  await tester.tap(find.text('Tandai dibaca'));
  await tester.pumpAndSettle();
  expect(find.text('0 notifikasi belum dibaca'), findsOneWidget);
  await tester.pageBack();
  await tester.pumpAndSettle();
  await tester.tap(find.byType(DropdownButton<String>).first);
  await tester.pumpAndSettle();
  await tester.tap(find.text('Putra Wijaya').last);
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
  expect(find.text('Putra Wijaya'), findsWidgets);
  expect(
    tester
        .widget<DropdownButton<String>>(
          find.byType(DropdownButton<String>).first,
        )
        .value,
    'ST05',
  );
  await tester.runAsync(parent.refresh);
  await saved(tester, parent);
  await tester.tap(find.byTooltip('Ganti peran'));
  await tester.pumpAndSettle();
  expect(find.text('Buka Demo'), findsOneWidget);
  await tester.pumpWidget(const SizedBox());
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 100)),
  );
  await tester.pump(const Duration(seconds: 6));
  await tester.pumpAndSettle();
  await tester.binding.setSurfaceSize(null);
}
