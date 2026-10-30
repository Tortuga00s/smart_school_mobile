import 'package:flutter/material.dart';
import 'models.dart';

/// In-memory demo only. Replace with authenticated repository streams when
/// Firebase is configured. No passwords, face templates, or student photos stored.
class ParentDemoStore extends ChangeNotifier {
  String guardianName = 'Budi Pratama';
  String guardianEmail = 'budi.pratama@email.com';
  final today = DateTime(2026, 10, 5);
  final List<AttendanceEntry> attendance = [];
  final List<SchoolNotice> notices = [];
  static const grades = [
    Grade('Matematika', 85, 90, schoolBlue),
    Grade('IPA', 88, 92, schoolGreen),
    Grade('Bahasa Indonesia', 82, 87, schoolOrange),
    Grade('Bahasa Inggris', 86, 88, schoolPurple),
    Grade('IPS', 84, 89, schoolGreen),
    Grade('Pendidikan Pancasila', 88, 90, schoolOrange),
  ];

  ParentDemoStore() {
    // 44 lesson sessions: 40 present, 2 excused, 1 sick, 1 absent.
    for (var i = 0; i < 44; i++) {
      final status = i == 40 || i == 41 ? 'Izin' : i == 42 ? 'Sakit' : i == 43 ? 'Tidak Hadir' : 'Hadir';
      final day = i < 2 ? today : today.subtract(Duration(days: 1 + (i - 2) ~/ 12));
      attendance.add(AttendanceEntry(
        grades[i % grades.length].subject,
        ['Pak Ahmad', 'Bu Siti', 'Pak Budi', 'Bu Rina', 'Pak Dedi', 'Bu Ayu'][i % 6],
        DateTime(day.year, day.month, day.day, i == 0 ? 7 : i == 1 ? 8 : 10, i == 0 ? 15 : i == 1 ? 45 : 20),
        status,
      ));
    }
    notices.addAll([
      SchoolNotice('Kehadiran Siswa', 'Ahmad Rizki telah hadir pada mata pelajaran Matematika pukul 07.15 WIB.', '07.16', Icons.check_rounded, schoolGreen, attendance: attendance[0]),
      SchoolNotice('Informasi Pembelajaran', 'Pak Budi berhalangan mengajar Bahasa Indonesia pukul 10.15–11.45. Jadwal menunggu pembaruan sekolah.', '06.50', Icons.info_outline_rounded, schoolOrange),
      SchoolNotice('Nilai Diperbarui', 'Nilai UAS mata pelajaran IPA telah diperbarui menjadi 92.', '16.20', Icons.bookmark_border_rounded, schoolBlue, read: true, yesterday: true),
    ]);
  }

  int get unread => notices.where((n) => !n.read).length;
  double get average => grades.fold<double>(0, (sum, g) => sum + g.average) / grades.length;
  List<AttendanceEntry> filtered(int period, String subject) => attendance.where((a) {
    final start = period == 0 ? today : period == 1 ? today.subtract(Duration(days: today.weekday - 1)) : DateTime(today.year, today.month);
    return !a.date.isBefore(start) && a.date.isBefore(today.add(const Duration(days: 1))) && (subject == 'Semua mapel' || a.subject == subject);
  }).toList();
  List<Lesson> lessons(int day) {
    if (day == 0) {
      return const [
        Lesson('07.00 - 08.30', 'Matematika', 'Pak Ahmad', 'Mengajar', schoolBlue),
        Lesson('08.30 - 10.00', 'IPA', 'Bu Siti', 'Mengajar', schoolGreen),
        Lesson('10.15 - 11.45', 'Bahasa Indonesia', 'Pak Budi', 'Berhalangan', schoolOrange),
        Lesson('12.30 - 14.00', 'Bahasa Inggris', 'Bu Rina', 'Terjadwal', schoolPurple),
      ];
    }
    return [
      Lesson('07.00 - 08.30', grades[day % 6].subject, ['Pak Ahmad', 'Bu Siti', 'Pak Budi', 'Bu Rina', 'Pak Dedi'][day], 'Terjadwal', grades[day % 6].color),
      const Lesson('08.30 - 10.00', 'Pendidikan Pancasila', 'Bu Ayu', 'Terjadwal', schoolGreen),
      const Lesson('10.15 - 11.45', 'IPS', 'Pak Dedi', 'Terjadwal', schoolOrange),
    ];
  }
  void readNotice(SchoolNotice n) { n.read = true; notifyListeners(); }
  void markAllRead() { for (final n in notices) { n.read = true; } notifyListeners(); }
  void updateProfile(String name, String email) { guardianName = name.trim(); guardianEmail = email.trim(); notifyListeners(); }
}
