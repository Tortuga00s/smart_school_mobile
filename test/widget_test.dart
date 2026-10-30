import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smartschool_mobile/features/parent/parent_app.dart';
import 'package:smartschool_mobile/features/parent/demo_store.dart';

void main() {
  test('Statistics count lesson sessions and notices can be marked read', () {
    final store = ParentDemoStore();
    final entries = store.filtered(2, 'Semua mapel');
    expect(entries.length, 44);
    expect(entries.where((a) => a.status == 'Hadir').length, 40);
    expect(store.filtered(0, 'Semua mapel').length, 2);
    expect(store.unread, 2);
    store.markAllRead();
    expect(store.unread, 0);
    store.dispose();
  });

  testWidgets('Bottom navigation opens attendance, schedule, grades and profile', (tester) async {
    await tester.pumpWidget(const SmartSchoolApp());
    for (final page in {'Kehadiran': 'Rekap Kehadiran', 'Jadwal': 'Jadwal Pelajaran', 'Akademik': 'Nilai Akademik', 'Profil': 'Edit Profil'}.entries) {
      await tester.tap(find.descendant(of: find.byType(NavigationBar), matching: find.text(page.key)));
      await tester.pumpAndSettle();
      expect(find.text(page.value), findsWidgets);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('Notification inbox updates unread count', (tester) async {
    await tester.pumpWidget(const SmartSchoolApp());
    await tester.tap(find.byTooltip('Pusat notifikasi'));
    await tester.pumpAndSettle();
    expect(find.text('2 notifikasi belum dibaca'), findsOneWidget);
    await tester.tap(find.text('Tandai dibaca'));
    await tester.pumpAndSettle();
    expect(find.text('0 notifikasi belum dibaca'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
