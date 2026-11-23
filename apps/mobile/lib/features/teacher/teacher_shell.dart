import 'package:school_data/dialogs.dart';
// Keep original Material UI imports compatible with the uploaded project.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:school_data/school_data.dart';

import '../parent/models.dart';
import '../parent/widgets.dart';

class TeacherShell extends StatefulWidget {
  const TeacherShell({
    super.key,
    required this.data,
    required this.uid,
    required this.onExit,
  });
  final SchoolStore data;
  final String uid;
  final VoidCallback onExit;
  @override
  State<TeacherShell> createState() => _TeacherShellState();
}

class _TeacherShellState extends State<TeacherShell> {
  int tab = 0;
  SchoolStore get s => widget.data;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: s,
    builder: (context, _) => Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: tab,
          children: [dashboard(), schedule(), grades(), profile()],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (v) => setState(() => tab = v),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            label: 'Jadwal',
          ),
          NavigationDestination(
            icon: Icon(Icons.fact_check_outlined),
            label: 'Nilai',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Profil',
          ),
        ],
      ),
    ),
  );
  Widget header(String title, String subtitle) => GradientPanel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.school_outlined, color: Colors.white, size: 36),
        const SizedBox(height: 20),
        Text(
          title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(subtitle, style: const TextStyle(color: Colors.white70)),
      ],
    ),
  );
  Widget dashboard() {
    final list = s.teacherSchedules(widget.uid);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        header(
          'Selamat Pagi, ${s.teacherName(widget.uid)}',
          'Jadwal dan kehadiran per mata pelajaran',
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: SchoolCard(child: Text('${list.length} jadwal mingguan')),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SchoolCard(
                child: Text(
                  '${s.sessionStates.values.where((v) => v == "OPEN").length} sesi aktif demo',
                ),
              ),
            ),
          ],
        ),
        const SectionTitle('Jadwal Mengajar'),
        if (list.isEmpty)
          const SchoolCard(child: Text('Belum ada jadwal yang ditugaskan.')),
        for (final sc in list) lesson(sc),
      ],
    );
  }

  Widget lesson(LessonSchedule sc) {
    final a = s.assignment(sc.assignmentId);
    final state = s.sessionStates[s.sessionId(sc)] ?? 'BELUM_DIMULAI';
    return SchoolCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${s.dayName(sc.weekday)} • ${s.timeOf(sc.startMinute)}–${s.timeOf(sc.endMinute)}',
            style: const TextStyle(
              color: schoolBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            s.subjectName(a.subjectId),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            'Kelas ${s.className(a.classId)} • ${sc.room}',
            style: const TextStyle(color: schoolMuted),
          ),
          const SizedBox(height: 8),
          Text(state.replaceAll('_', ' ')),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            children: [
              FilledButton(
                onPressed: state == 'CLOSED' ? null : () => open(sc),
                child: Text(
                  state == 'OPEN' ? 'Lanjutkan Absensi' : 'Mulai Mengajar',
                ),
              ),
              OutlinedButton(
                onPressed: () => leave(sc),
                child: const Text('Berhalangan'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> open(LessonSchedule sc) async {
    if (s.sessionStates[s.sessionId(sc)] == null) {
      final a = s.assignment(sc.assignmentId);
      final ok = await settledDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Konfirmasi Mengajar'),
          content: Text(
            '${s.subjectName(a.subjectId)} • ${s.className(a.classId)}\n${s.timeOf(sc.startMinute)}–${s.timeOf(sc.endMinute)}\nTenggat usulan: ${s.deadlineMinutes} menit.\n\nDemo membuka sesi tanggal hari ini; tidak menegakkan jam kalender sekolah.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Konfirmasi'),
            ),
          ],
        ),
      );
      if (ok != true || !mounted) return;
      s.openSession(sc, widget.uid);
    }
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) =>
            TeacherAttendance(data: s, uid: widget.uid, scheduleId: sc.id),
      ),
    );
  }

  Future<void> leave(LessonSchedule sc) async {
    final reason = TextEditingController();
    final ok = await settledDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Lapor Berhalangan'),
        content: TextField(
          controller: reason,
          maxLines: 3,
          decoration: const InputDecoration(labelText: 'Alasan'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              if (reason.text.trim().isNotEmpty) Navigator.pop(ctx, true);
            },
            child: const Text('Kirim ke admin demo'),
          ),
        ],
      ),
    );
    if (ok == true) {
      s.leaveRequests.add(
        LeaveRequest(s.nextId('LV'), widget.uid, sc.id, reason.text.trim()),
      );
      s.record('Laporan berhalangan', '${widget.uid} · ${sc.id}');
    }
    reason.dispose();
  }

  Widget schedule() => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      const PageTitle(
        'Jadwal Pelajaran',
        'Hanya penugasan Anda • jadwal mingguan demo',
      ),
      for (final sc in s.teacherSchedules(widget.uid)) lesson(sc),
    ],
  );
  Widget grades() => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      const PageTitle('Nilai Siswa', 'UTS dan UAS • nilai 0–100'),
      for (final a in s.assignments.where(
        (a) => a.teacherId == widget.uid && a.active,
      )) ...[
        SectionTitle(
          '${s.subjectName(a.subjectId)} • ${s.className(a.classId)}',
        ),
        for (final st in s.students.where(
          (st) => st.classId == a.classId && st.active,
        ))
          SchoolCard(
            onTap: () => editGrade(st, a),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(st.name),
              subtitle: Text(
                s.grades.containsKey('${st.id}_${a.subjectId}')
                    ? 'UTS ${s.grades['${st.id}_${a.subjectId}']!['uts']} • UAS ${s.grades['${st.id}_${a.subjectId}']!['uas']}'
                    : 'Belum diisi',
              ),
              trailing: const Icon(Icons.edit_outlined),
            ),
          ),
      ],
    ],
  );
  Future<void> editGrade(Student st, Assignment a) async {
    final current = s.grades['${st.id}_${a.subjectId}'];
    final uts = TextEditingController(text: current?['uts']?.toString());
    final uas = TextEditingController(text: current?['uas']?.toString());
    final form = GlobalKey<FormState>();
    await settledDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Input Nilai • ${st.name}'),
        content: Form(
          key: form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final item in [(uts, 'UTS'), (uas, 'UAS')])
                TextFormField(
                  controller: item.$1,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: item.$2),
                  validator: (v) {
                    final n = int.tryParse(v ?? '');
                    return n == null || n < 0 || n > 100
                        ? 'Masukkan nilai 0–100'
                        : null;
                  },
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              if (form.currentState!.validate()) {
                s.inputGrade(
                  widget.uid,
                  st.id,
                  a.subjectId,
                  int.parse(uts.text),
                  int.parse(uas.text),
                );
                Navigator.pop(ctx);
              }
            },
            child: const Text('Simpan Nilai'),
          ),
        ],
      ),
    );
    uts.dispose();
    uas.dispose();
  }

  Widget profile() => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      header(
        s.teacherName(widget.uid),
        'Guru • ${s.teacher(widget.uid).specialty}',
      ),
      const SizedBox(height: 20),
      SchoolCard(child: Text(s.teacher(widget.uid).email)),
      const SchoolCard(
        child: Text(
          'Mode demo lokal. Perubahan jadwal dan data akademik utama dikelola admin Windows.',
        ),
      ),
      OutlinedButton.icon(
        onPressed: widget.onExit,
        icon: const Icon(Icons.logout),
        label: const Text('Keluar / Ganti Peran'),
      ),
    ],
  );
}

class TeacherAttendance extends StatelessWidget {
  const TeacherAttendance({
    super.key,
    required this.data,
    required this.uid,
    required this.scheduleId,
  });
  final SchoolStore data;
  final String uid, scheduleId;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: data,
    builder: (context, _) {
      final sc = data.schedule(scheduleId);
      final id = data.sessionId(sc);
      final rows = data.attendance.where((a) => a.sessionCode == id).toList();
      return Scaffold(
        appBar: AppBar(title: const Text('Daftar Kehadiran')),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  GradientPanel(
                    child: Text(
                      '${data.subjectName(data.assignment(sc.assignmentId).subjectId)} • ${data.className(data.assignment(sc.assignmentId).classId)}\n$id\n${data.sessionStates[id]}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Absensi manual demo. Kamera, pencocokan wajah, bukti foto, dan push FCM belum aktif.',
                  ),
                  const SizedBox(height: 16),
                  for (final a in rows)
                    SchoolCard(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(data.student(a.studentId).name),
                        subtitle: Text(a.status.replaceAll('_', ' ')),
                        trailing: IconButton(
                          tooltip: 'Catat kehadiran',
                          onPressed:
                              data.sessionStates[id] == 'OPEN' && !data.saving
                              ? () => mark(context, a)
                              : null,
                          icon: const Icon(Icons.edit_outlined),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: data.sessionStates[id] == 'OPEN' && !data.saving
                      ? () async {
                          if (rows.any((a) => a.status == 'BELUM_ABSEN')) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Tinjau status seluruh siswa dahulu.',
                                ),
                              ),
                            );
                            return;
                          }
                          final ok = await settledDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Selesaikan Absensi?'),
                              content: const Text(
                                'Pastikan seluruh status sudah ditinjau. Sesi demo akan ditutup.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('Batal'),
                                ),
                                FilledButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text('Selesaikan'),
                                ),
                              ],
                            ),
                          );
                          if (ok == true) {
                            data.closeSession(sc, uid);
                            if (context.mounted) Navigator.pop(context);
                          }
                        }
                      : null,
                  child: const Text('Selesaikan Absensi'),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
  Future<void> mark(BuildContext context, Attendance a) async {
    String status = 'HADIR';
    final reason = TextEditingController();
    await settledDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, update) => AlertDialog(
          title: Text(data.student(a.studentId).name),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: status,
                  items: ['HADIR', 'TERLAMBAT', 'IZIN', 'SAKIT', 'TIDAK_HADIR']
                      .map(
                        (v) => DropdownMenuItem(
                          value: v,
                          child: Text(v.replaceAll('_', ' ')),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => update(() => status = v!),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: reason,
                  decoration: const InputDecoration(
                    labelText: 'Alasan / catatan wajib',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                if (reason.text.trim().isEmpty) return;
                data.markAttendance(a, status, reason.text.trim(), uid);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Perubahan dicatat • sinkronisasi demo diproses. Tidak mengirim FCM.',
                    ),
                  ),
                );
              },
              child: const Text('Simpan Manual'),
            ),
          ],
        ),
      ),
    );
    reason.dispose();
  }
}
