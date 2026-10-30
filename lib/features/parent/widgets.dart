import 'package:flutter/material.dart';
import 'models.dart';

class SchoolCard extends StatelessWidget {
  const SchoolCard({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.onTap});
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Material(color: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: const BorderSide(color: schoolBorder, width: 1.2)), clipBehavior: Clip.antiAlias,
      child: InkWell(onTap: onTap, child: Padding(padding: padding, child: child))),
  );
}

class GradientPanel extends StatelessWidget {
  const GradientPanel({super.key, required this.child, this.green = false, this.padding = const EdgeInsets.all(20)});
  final Widget child;
  final bool green;
  final EdgeInsets padding;
  @override
  Widget build(BuildContext context) => Container(width: double.infinity, padding: padding,
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: green ? const [Color(0xFF168B68), Color(0xFF24B585)] : const [schoolBlue, Color(0xFF328FDC)])),
    child: DefaultTextStyle.merge(style: const TextStyle(color: Colors.white), child: child));
}

class IconTile extends StatelessWidget {
  const IconTile(this.icon, {super.key, this.color = schoolBlue, this.solid = false});
  final IconData icon;
  final Color color;
  final bool solid;
  @override
  Widget build(BuildContext context) => Container(width: 46, height: 46,
    decoration: BoxDecoration(color: solid ? color : color.withAlpha(25), borderRadius: BorderRadius.circular(14)),
    child: Icon(icon, color: solid ? Colors.white : color, size: 26));
}

class StatusBadge extends StatelessWidget {
  const StatusBadge(this.status, {super.key});
  final String status;
  @override
  Widget build(BuildContext context) {
    final color = ['Hadir', 'Mengajar'].contains(status) ? schoolGreen : ['Berhalangan', 'Izin', 'Sakit', 'Belum tercatat'].contains(status) ? const Color(0xFFBE6B0A) : status == 'Tidak Hadir' ? Colors.red : schoolBlue;
    return Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: color.withAlpha(23), borderRadius: BorderRadius.circular(30)), child: Text(status, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)));
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key, this.action, this.onTap});
  final String title;
  final String? action;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(top: 20, bottom: 12), child: Row(children: [Expanded(child: Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700))), if (action != null) TextButton(onPressed: onTap, child: Text(action!))]));
}

class PageTitle extends StatelessWidget {
  const PageTitle(this.title, this.subtitle, {super.key});
  final String title, subtitle;
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.fromLTRB(20, 22, 20, 20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w700, letterSpacing: -.6)), const SizedBox(height: 5), Text(subtitle, style: const TextStyle(color: schoolMuted))]));
}

class StudentAvatar extends StatelessWidget {
  const StudentAvatar({super.key, this.radius = 30});
  final double radius;
  @override
  Widget build(BuildContext context) => CircleAvatar(radius: radius, backgroundColor: const Color(0xFFE2F0FF), child: Text('AR', style: TextStyle(fontSize: radius * .6, color: schoolBlue, fontWeight: FontWeight.w700)));
}

void showAttendance(BuildContext context, AttendanceEntry entry) {
  showModalBottomSheet<void>(context: context, isScrollControlled: true, showDragHandle: true, builder: (context) => SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(24, 4, 24, 28), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('Detail Kehadiran', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w700)), const SizedBox(height: 18),
    Row(children: [const StudentAvatar(), const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Ahmad Rizki', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)), Text(entry.subject)])), StatusBadge(entry.status)]),
    const Divider(height: 32), Text('Guru: ${entry.teacher}'), const SizedBox(height: 8), Text('${dateLabel(entry.date)} • ${clock(entry.date)} WIB'), const SizedBox(height: 8), Text('Metode: ${entry.method}'),
    const SizedBox(height: 20), Container(width: double.infinity, padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: schoolBackground, borderRadius: BorderRadius.circular(16)), child: const Column(children: [Icon(Icons.lock_outline, color: schoolMuted, size: 32), SizedBox(height: 10), Text('Foto bukti belum tersedia', style: TextStyle(fontWeight: FontWeight.w700)), SizedBox(height: 6), Text('Ini data contoh. Foto asli tampil setelah akun dan akses Firebase terhubung.', textAlign: TextAlign.center, style: TextStyle(color: schoolMuted))])),
    const SizedBox(height: 16), const Text('Catatan dihitung untuk sesi pelajaran ini.', style: TextStyle(color: schoolMuted)),
  ]))));
}
