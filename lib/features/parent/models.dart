import 'package:flutter/material.dart';

const schoolBlue = Color(0xFF1765C5);
const schoolGreen = Color(0xFF16A176);
const schoolOrange = Color(0xFFF39327);
const schoolPurple = Color(0xFF7A63CD);
const schoolInk = Color(0xFF1C293B);
const schoolMuted = Color(0xFF7487A2);
const schoolBackground = Color(0xFFF4F8FF);
const schoolBorder = Color(0xFFE1E9F4);

class AttendanceEntry {
  const AttendanceEntry(this.subject, this.teacher, this.date, this.status,
      {this.method = 'Verifikasi wajah', this.proofAsset});
  final String subject, teacher, status, method;
  final DateTime date;
  // Only authenticated, authorized backend data should supply real proof photos.
  final String? proofAsset;
}

class Lesson {
  const Lesson(this.time, this.subject, this.teacher, this.status, this.color);
  final String time, subject, teacher, status;
  final Color color;
}

class Grade {
  const Grade(this.subject, this.uts, this.uas, this.color);
  final String subject;
  final int uts, uas;
  final Color color;
  double get average => (uts + uas) / 2;
}

class SchoolNotice {
  SchoolNotice(this.title, this.message, this.time, this.icon, this.color,
      {this.read = false, this.yesterday = false, this.attendance});
  final String title, message, time;
  final IconData icon;
  final Color color;
  final bool yesterday;
  final AttendanceEntry? attendance;
  bool read;
}

String decimal(num value) => value.toStringAsFixed(1).replaceAll('.', ',');
String clock(DateTime value) => '${value.hour.toString().padLeft(2, '0')}.${value.minute.toString().padLeft(2, '0')}';
String dateLabel(DateTime value) {
  const days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
  const months = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
  return '${days[value.weekday - 1]}, ${value.day} ${months[value.month - 1]} ${value.year}';
}
