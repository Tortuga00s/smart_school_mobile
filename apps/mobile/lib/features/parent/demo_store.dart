// Keep original Material UI imports compatible with the uploaded project.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:school_data/school_data.dart' as shared;

import 'models.dart';

class ParentDemoStore extends ChangeNotifier {
  ParentDemoStore(this.data) {
    data.addListener(_changed);
  }
  final shared.SchoolStore data;
  String selectedStudentId = 'ST01';
  shared.Student get child => data.student(selectedStudentId);
  List<shared.Student> get children =>
      data.students.where((s) => s.guardianId == 'G01' && s.active).toList();
  String get childName => child.name;
  String get childDetails =>
      'Kelas ${data.className(child.classId)} • NIS ${child.nis}';
  void selectChild(String id) {
    selectedStudentId = id;
    notifyListeners();
  }

  String get guardianName => data.guardian('G01').name;
  String get guardianEmail => data.guardian('G01').email;
  DateTime get today =>
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  void _changed() => notifyListeners();
  String status(String s) =>
      const {
        'HADIR': 'Hadir',
        'TERLAMBAT': 'Terlambat',
        'IZIN': 'Izin',
        'SAKIT': 'Sakit',
        'TIDAK_HADIR': 'Tidak Hadir',
        'BELUM_ABSEN': 'Belum Absen',
      }[s] ??
      s;
  List<AttendanceEntry> get attendance => data.attendance
      .where((a) => a.studentId == selectedStudentId)
      .map(
        (a) => AttendanceEntry(
          data.subjectName(a.subjectId),
          _teacher(a.subjectId),
          _time(a),
          status(a.status),
          method: a.method == 'MANUAL'
              ? 'Manual — tanpa foto'
              : 'Data seed demo — tanpa foto',
        ),
      )
      .toList()
      .reversed
      .toList();
  DateTime _time(shared.Attendance a) {
    final day = a.sessionCode.contains('_SC')
        ? DateTime.tryParse(a.sessionCode.split('_').first) ?? today
        : today;
    final parts = a.time.split(':');
    return DateTime(
      day.year,
      day.month,
      day.day,
      parts.length == 2 ? int.tryParse(parts[0]) ?? 0 : 0,
      parts.length == 2 ? int.tryParse(parts[1]) ?? 0 : 0,
    );
  }

  String _teacher(String subjectId) {
    final matches = data.assignments.where(
      (a) => a.subjectId == subjectId && a.classId == child.classId,
    );
    return matches.isEmpty
        ? 'Sekolah'
        : data.teacherName(matches.first.teacherId);
  }

  final Set<String> _read = {};
  List<SchoolNotice> get notices => data.events
      .where(
        (e) => e['studentId'] == selectedStudentId && e['guardianId'] == 'G01',
      )
      .map(
        (e) => SchoolNotice(
          '${e['subject']} • ${status(e['status'])}',
          '$childName: ${status(e['status'])}. Sesi ${e['sessionId']}. Inbox demo; FCM belum dikirim.',
          e['time'],
          Icons.notifications_outlined,
          schoolBlue,
          read: _read.contains(e['id']),
          attendance: AttendanceEntry(
            e['subject'],
            'Sekolah',
            DateTime.parse(e['time']),
            status(e['status']),
            method: 'MANUAL — tanpa foto',
          ),
        ),
      )
      .toList();
  int get unread => notices.where((n) => !n.read).length;
  int get presentCount => attendance
      .where((a) => a.status == 'Hadir' || a.status == 'Terlambat')
      .length;
  int get presentPercent =>
      attendance.isEmpty ? 0 : (presentCount / attendance.length * 100).round();
  List<Grade> get grades => data.subjects
      .where((s) => data.grades.containsKey('${selectedStudentId}_${s.id}'))
      .map((s) {
        final g = data.grades['${selectedStudentId}_${s.id}']!;
        return Grade(s.name, g['uts']!, g['uas']!, schoolBlue);
      })
      .toList();
  double get average => grades.isEmpty
      ? 0
      : grades.fold<double>(0, (v, g) => v + g.average) / grades.length;
  List<AttendanceEntry> filtered(int period, String subject) {
    final start = period == 0
        ? today
        : period == 1
        ? today.subtract(Duration(days: today.weekday - 1))
        : DateTime(today.year, today.month);
    return attendance
        .where(
          (a) =>
              !a.date.isBefore(start) &&
              (subject == 'Semua mapel' || a.subject == subject),
        )
        .toList();
  }

  List<Lesson> lessons(int day) => data.schedules
      .where(
        (s) =>
            s.weekday == day + 1 &&
            data.assignment(s.assignmentId).classId == child.classId,
      )
      .map((s) {
        final a = data.assignment(s.assignmentId);
        return Lesson(
          '${data.timeOf(s.startMinute)} - ${data.timeOf(s.endMinute)}',
          data.subjectName(a.subjectId),
          data.teacherName(s.substituteTeacherId ?? a.teacherId),
          s.status == 'CANCELLED' ? 'Dibatalkan' : 'Terjadwal',
          schoolBlue,
        );
      })
      .toList();
  void readNotice(SchoolNotice n) {
    final e = data.events.where(
      (e) => e['time'] == n.time && e['studentId'] == selectedStudentId,
    );
    for (final x in e) {
      _read.add(x['id']);
    }
    notifyListeners();
  }

  void markAllRead() {
    for (final e in data.events) {
      _read.add(e['id']);
    }
    notifyListeners();
  }

  void updateProfile(String name, String email) {
    final g = data.guardian('G01');
    data.editGuardian(g, name.trim(), g.phone, email.trim());
  }

  @override
  void dispose() {
    data.removeListener(_changed);
    super.dispose();
  }
}
