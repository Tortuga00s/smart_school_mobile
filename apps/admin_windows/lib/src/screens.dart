import 'package:school_data/dialogs.dart';
// Keep original Material UI imports compatible with the uploaded project.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';

import 'app_state.dart';
import 'ui.dart';

class OverviewPage extends StatelessWidget {
  const OverviewPage({
    super.key,
    required this.store,
    required this.onNavigate,
  });
  final SchoolStore store;
  final ValueChanged<int> onNavigate;
  @override
  Widget build(BuildContext context) {
    final activeCount = store.teachers.where((t) => t.active).length;
    final studentCount = store.students.where((s) => s.active).length;
    final activeSessions = store.schedules
        .where((s) => s.status == 'ACTIVE')
        .length;
    final unresolved =
        store.attendance.where((a) => a.status == 'BELUM_ABSEN').length +
        store.leaveRequests.where((r) => r.status == 'PENDING').length;
    final metrics = [
      MetricCard(
        icon: Icons.school_rounded,
        title: 'Siswa aktif',
        value: '$studentCount',
        note: 'Terdaftar pada kelas aktif',
        tint: C.blue,
      ),
      MetricCard(
        icon: Icons.co_present_rounded,
        title: 'Guru aktif',
        value: '$activeCount',
        note: 'Memiliki akses akademik',
        tint: C.green,
      ),
      MetricCard(
        icon: Icons.calendar_month_rounded,
        title: 'Blok jadwal aktif',
        value: '$activeSessions',
        note: 'Contoh jadwal mingguan',
        tint: const Color(0xFF986AE3),
      ),
      MetricCard(
        icon: Icons.error_outline_rounded,
        title: 'Perlu ditinjau',
        value: '$unresolved',
        note: 'Status awal dan izin guru',
        tint: C.orange,
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageTitle(
          title: 'Dashboard Sekolah',
          subtitle:
              'Ringkasan akademik, sesi, dan hal yang memerlukan perhatian.',
        ),
        const DemoNotice(),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, c) {
            final cols = c.maxWidth > 1200 ? 4 : (c.maxWidth > 620 ? 2 : 1);
            final width = (c.maxWidth - (cols - 1) * 16) / cols;
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                for (final m in metrics) SizedBox(width: width, child: m),
              ],
            );
          },
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, c) {
            final wide = c.maxWidth >= 920;
            final left = _schedulePanel(context);
            final right = _attentionPanel(context);
            if (!wide) {
              return Column(
                children: [left, const SizedBox(height: 16), right],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 7, child: left),
                const SizedBox(width: 16),
                Expanded(flex: 4, child: right),
              ],
            );
          },
        ),
        const SizedBox(height: 20),
        _attendanceStats(),
        const SizedBox(height: 20),
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle('Akses cepat'),
              const SizedBox(height: 18),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _quickAction(
                    Icons.person_add_alt_1_rounded,
                    'Kelola Guru',
                    1,
                  ),
                  _quickAction(Icons.groups_rounded, 'Data Siswa & Wali', 2),
                  _quickAction(
                    Icons.assignment_ind_rounded,
                    'Penugasan Guru',
                    4,
                  ),
                  _quickAction(Icons.event_note_rounded, 'Jadwal Mengajar', 5),
                  _quickAction(
                    Icons.fact_check_rounded,
                    'Monitoring Absensi',
                    6,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _attendanceStats() {
    final total = store.attendance.length;
    final rows = [
      (
        'Hadir',
        store.attendance
            .where((a) => a.status == 'HADIR' || a.status == 'MANUAL_HADIR')
            .length,
        C.green,
      ),
      (
        'Terlambat',
        store.attendance.where((a) => a.status == 'TERLAMBAT').length,
        C.orange,
      ),
      (
        'Izin / Sakit',
        store.attendance
            .where((a) => a.status == 'IZIN' || a.status == 'SAKIT')
            .length,
        C.blue,
      ),
      (
        'Belum dicatat',
        store.attendance.where((a) => a.status == 'BELUM_ABSEN').length,
        C.red,
      ),
    ];
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(
            'Distribusi status absensi',
            trailing: TextButton(
              onPressed: () => onNavigate(6),
              child: const Text('Periksa Absensi'),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Gambaran dari 5 catatan fiktif, bukan statistik kehadiran sekolah.',
            style: TextStyle(fontSize: 11, color: C.muted),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, c) {
              final cols = c.maxWidth > 900 ? 4 : (c.maxWidth > 520 ? 2 : 1);
              final width = (c.maxWidth - (cols - 1) * 16) / cols;
              return Wrap(
                spacing: 16,
                runSpacing: 15,
                children: [
                  for (final r in rows)
                    SizedBox(
                      width: width,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  r.$1,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              Text(
                                '${r.$2}/$total',
                                style: const TextStyle(
                                  color: C.muted,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 9),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: LinearProgressIndicator(
                              value: total == 0 ? 0 : r.$2 / total,
                              minHeight: 9,
                              color: r.$3,
                              backgroundColor: C.light,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _quickAction(IconData icon, String label, int index) =>
      OutlinedButton.icon(
        onPressed: () => onNavigate(index),
        icon: Icon(icon, size: 17),
        label: Text(label),
      );
  Widget _schedulePanel(BuildContext context) {
    final list = store.schedules.where((s) => s.status == 'ACTIVE').toList()
      ..sort(
        (a, b) => a.weekday == b.weekday
            ? a.startMinute.compareTo(b.startMinute)
            : a.weekday.compareTo(b.weekday),
      );
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(
            'Jadwal pelajaran',
            trailing: TextButton(
              onPressed: () => onNavigate(5),
              child: const Text('Lihat Semua'),
            ),
          ),
          const SizedBox(height: 8),
          for (final sc in list.take(4))
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: C.pale,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.menu_book_rounded, color: C.blue),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          store.subjectName(
                            store.assignment(sc.assignmentId).subjectId,
                          ),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${store.className(store.assignment(sc.assignmentId).classId)} · ${store.teacherName(sc.substituteTeacherId ?? store.assignment(sc.assignmentId).teacherId)}',
                          style: const TextStyle(fontSize: 11, color: C.muted),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        store.dayName(sc.weekday),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${store.timeOf(sc.startMinute)}–${store.timeOf(sc.endMinute)}',
                        style: const TextStyle(fontSize: 11, color: C.muted),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          const Divider(color: C.line),
          const Text(
            'Catatan: ini jadwal mingguan demo, bukan hasil sesi hari ini dari server.',
            style: TextStyle(fontSize: 11, color: C.muted),
          ),
        ],
      ),
    );
  }

  Widget _attentionPanel(BuildContext context) {
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(
            'Butuh perhatian',
            trailing: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.notifications_active_outlined,
                color: C.orange,
                size: 18,
              ),
            ),
          ),
          const SizedBox(height: 18),
          _notice(
            Icons.access_time_rounded,
            'Absensi belum tercatat',
            '${store.attendance.where((a) => a.status == 'BELUM_ABSEN').length} siswa pada data demo',
            () => onNavigate(6),
            C.orange,
          ),
          const Divider(color: C.line, height: 25),
          _notice(
            Icons.event_busy_rounded,
            'Permohonan berhalangan',
            '${store.leaveRequests.where((r) => r.status == 'PENDING').length} laporan menunggu review',
            () => onNavigate(7),
            C.blue,
          ),
          const Divider(color: C.line, height: 25),
          _notice(
            Icons.verified_user_outlined,
            'Persetujuan biometrik',
            '${store.consents.where((x) => x.status != 'DISETUJUI').length} siswa belum disetujui/dicabut',
            () => onNavigate(8),
            C.red,
          ),
          const SizedBox(height: 15),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: C.pale,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Sesi NOT_STARTED tidak boleh otomatis membuat status siswa Tidak Hadir.',
              style: TextStyle(fontSize: 11, color: C.navy),
            ),
          ),
        ],
      ),
    );
  }

  Widget _notice(
    IconData icon,
    String title,
    String caption,
    VoidCallback onClick,
    Color tint,
  ) => InkWell(
    onTap: onClick,
    borderRadius: BorderRadius.circular(10),
    child: Row(
      children: [
        Icon(icon, color: tint, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                caption,
                style: const TextStyle(color: C.muted, fontSize: 11),
              ),
            ],
          ),
        ),
        const Icon(Icons.chevron_right, size: 18, color: C.muted),
      ],
    ),
  );
}

class TeachersPage extends StatefulWidget {
  const TeachersPage({super.key, required this.store});
  final SchoolStore store;
  @override
  State<TeachersPage> createState() => _TeachersPageState();
}

class _TeachersPageState extends State<TeachersPage> {
  String search = '';
  @override
  Widget build(BuildContext context) {
    final data = widget.store.teachers
        .where(
          (t) => '${t.name} ${t.email} ${t.specialty}'.toLowerCase().contains(
            search.toLowerCase(),
          ),
        )
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageTitle(
          title: 'Manajemen Guru',
          subtitle: 'Kelola akun guru, bidang ajar, dan status keaktifan.',
          action: primaryButton('Tambah Guru', _add),
        ),
        Panel(
          child: Column(
            children: [
              TextField(
                onChanged: (v) => setState(() => search = v),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Cari nama, email, atau bidang ajar...',
                ),
              ),
              const SizedBox(height: 18),
              SmartTable(
                columns: const [
                  'GURU',
                  'EMAIL',
                  'BIDANG AJAR',
                  'STATUS',
                  'TINDAKAN',
                ],
                rows: [
                  for (final t in data)
                    [
                      cell(t.name, strong: true),
                      cell(t.email),
                      cell(t.specialty),
                      AppBadge(t.active ? 'AKTIF' : 'NONAKTIF'),
                      Wrap(
                        spacing: 4,
                        children: [
                          TextButton(
                            onPressed: () => _edit(t),
                            child: const Text('Ubah'),
                          ),
                          TextButton(
                            onPressed: () async {
                              if (await confirm(
                                context,
                                'Ubah status guru?',
                                'Status ${t.name} akan diubah di data demo.',
                              )) {
                                widget.store.toggleTeacher(t);
                              }
                            },
                            child: Text(t.active ? 'Nonaktifkan' : 'Aktifkan'),
                          ),
                        ],
                      ),
                    ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _edit(Teacher t) async {
    final name = TextEditingController(text: t.name),
        email = TextEditingController(text: t.email),
        subject = TextEditingController(text: t.specialty);
    await settledDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ubah Guru'),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              field(name, 'Nama lengkap'),
              const SizedBox(height: 12),
              field(email, 'Email'),
              const SizedBox(height: 12),
              field(subject, 'Bidang ajar'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (name.text.trim().isEmpty ||
                  !email.text.contains('@') ||
                  subject.text.trim().isEmpty) {
                inform(context, 'Lengkapi data guru.', error: true);
                return;
              }
              widget.store.editTeacher(
                t,
                name.text.trim(),
                email.text.trim(),
                subject.text.trim(),
              );
              Navigator.pop(ctx);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    name.dispose();
    email.dispose();
    subject.dispose();
  }

  Future<void> _add() async {
    final name = TextEditingController(),
        email = TextEditingController(),
        subject = TextEditingController();
    await settledDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tambah Guru'),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              field(name, 'Nama lengkap'),
              const SizedBox(height: 12),
              field(email, 'Email'),
              const SizedBox(height: 12),
              field(subject, 'Bidang ajar'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (name.text.trim().isEmpty ||
                  !email.text.contains('@') ||
                  subject.text.trim().isEmpty) {
                inform(
                  context,
                  'Lengkapi nama, email, dan bidang ajar.',
                  error: true,
                );
                return;
              }
              widget.store.addTeacher(
                name.text.trim(),
                email.text.trim(),
                subject.text.trim(),
              );
              Navigator.pop(ctx);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    name.dispose();
    email.dispose();
    subject.dispose();
  }
}

class StudentsPage extends StatefulWidget {
  const StudentsPage({super.key, required this.store});
  final SchoolStore store;
  @override
  State<StudentsPage> createState() => _StudentsPageState();
}

class _StudentsPageState extends State<StudentsPage> {
  String search = '';
  int tab = 0;
  @override
  Widget build(BuildContext context) {
    final students = widget.store.students
        .where(
          (s) => '${s.name} ${s.nis} ${widget.store.className(s.classId)}'
              .toLowerCase()
              .contains(search.toLowerCase()),
        )
        .toList();
    final guardians = widget.store.guardians
        .where(
          (g) => '${g.name} ${g.phone} ${g.email}'.toLowerCase().contains(
            search.toLowerCase(),
          ),
        )
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageTitle(
          title: 'Siswa & Orang Tua',
          subtitle: 'Daftar siswa, wali, serta relasi anak–wali.',
          action: primaryButton(
            tab == 0 ? 'Tambah Siswa' : 'Tambah Wali',
            tab == 0 ? _addStudent : _addGuardian,
          ),
        ),
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SegmentedButton<int>(
                segments: const [
                  ButtonSegment(
                    value: 0,
                    label: Text('Siswa'),
                    icon: Icon(Icons.school),
                  ),
                  ButtonSegment(
                    value: 1,
                    label: Text('Orang Tua'),
                    icon: Icon(Icons.family_restroom),
                  ),
                ],
                selected: {tab},
                onSelectionChanged: (v) => setState(() {
                  tab = v.first;
                  search = '';
                }),
              ),
              const SizedBox(height: 14),
              TextField(
                onChanged: (v) => setState(() => search = v),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: tab == 0
                      ? 'Cari nama, NIS, atau kelas...'
                      : 'Cari nama, telepon, atau email...',
                ),
              ),
              const SizedBox(height: 16),
              if (tab == 0)
                SmartTable(
                  columns: const [
                    'SISWA',
                    'NIS',
                    'KELAS',
                    'WALI TERTAUT',
                    'STATUS',
                    'AKSI',
                  ],
                  rows: [
                    for (final s in students)
                      [
                        cell(s.name, strong: true),
                        cell(s.nis),
                        cell(widget.store.className(s.classId)),
                        cell(widget.store.guardian(s.guardianId).name),
                        AppBadge(s.active ? 'AKTIF' : 'NONAKTIF'),
                        Wrap(
                          spacing: 4,
                          children: [
                            TextButton(
                              onPressed: () => _editStudent(s),
                              child: const Text('Ubah'),
                            ),
                            TextButton(
                              onPressed: () => widget.store.toggleStudent(s),
                              child: Text(
                                s.active ? 'Nonaktifkan' : 'Aktifkan',
                              ),
                            ),
                          ],
                        ),
                      ],
                  ],
                ),
              if (tab == 1)
                SmartTable(
                  columns: const [
                    'WALI',
                    'NO. TELEPON',
                    'EMAIL',
                    'ANAK TERTAUT',
                    'AKSI',
                  ],
                  rows: [
                    for (final g in guardians)
                      [
                        cell(g.name, strong: true),
                        cell(g.phone),
                        cell(g.email),
                        cell(
                          widget.store.students
                              .where((s) => s.guardianId == g.id)
                              .map((s) => s.name)
                              .join(', '),
                        ),
                        TextButton(
                          onPressed: () => _editGuardian(g),
                          child: const Text('Ubah'),
                        ),
                      ],
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _editStudent(Student student) async {
    final name = TextEditingController(text: student.name),
        nis = TextEditingController(text: student.nis);
    String cid = student.classId;
    await settledDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, update) => AlertDialog(
          title: const Text('Ubah Data Siswa'),
          content: SizedBox(
            width: 440,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                field(name, 'Nama lengkap'),
                const SizedBox(height: 12),
                field(nis, 'NIS'),
                const SizedBox(height: 12),
                dropdown(
                  'Kelas',
                  cid,
                  options(widget.store.classes.map((c) => (c.id, c.name))),
                  (v) => update(() => cid = v ?? cid),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Relasi anak–wali tidak diubah dari dialog demo ini. Perubahan relasi harus diverifikasi secara terpisah.',
                  style: TextStyle(fontSize: 11, color: C.muted),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (name.text.trim().isEmpty ||
                    nis.text.trim().isEmpty ||
                    widget.store.students.any(
                      (s) => s.id != student.id && s.nis == nis.text.trim(),
                    )) {
                  inform(
                    context,
                    'Nama/NIS wajib diisi dan unik.',
                    error: true,
                  );
                  return;
                }
                widget.store.editStudent(
                  student,
                  name.text.trim(),
                  nis.text.trim(),
                  cid,
                );
                Navigator.pop(ctx);
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
    name.dispose();
    nis.dispose();
  }

  Future<void> _editGuardian(Guardian guardian) async {
    final name = TextEditingController(text: guardian.name),
        phone = TextEditingController(text: guardian.phone),
        email = TextEditingController(text: guardian.email);
    await settledDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ubah Wali'),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              field(name, 'Nama wali'),
              const SizedBox(height: 12),
              field(phone, 'No. telepon'),
              const SizedBox(height: 12),
              field(email, 'Email'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (name.text.trim().isEmpty ||
                  phone.text.trim().isEmpty ||
                  !email.text.contains('@')) {
                inform(context, 'Lengkapi data wali.', error: true);
                return;
              }
              widget.store.editGuardian(
                guardian,
                name.text.trim(),
                phone.text.trim(),
                email.text.trim(),
              );
              Navigator.pop(ctx);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    name.dispose();
    phone.dispose();
    email.dispose();
  }

  Future<void> _addStudent() async {
    final name = TextEditingController(), nis = TextEditingController();
    String cid = widget.store.classes.first.id,
        gid = widget.store.guardians.first.id;
    await settledDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, update) => AlertDialog(
          title: const Text('Tambah Siswa'),
          content: SizedBox(
            width: 440,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                field(name, 'Nama lengkap'),
                const SizedBox(height: 12),
                field(nis, 'NIS'),
                const SizedBox(height: 12),
                dropdown(
                  'Kelas',
                  cid,
                  options(widget.store.classes.map((c) => (c.id, c.name))),
                  (v) => update(() => cid = v ?? cid),
                ),
                const SizedBox(height: 12),
                dropdown(
                  'Orang tua / wali',
                  gid,
                  options(widget.store.guardians.map((g) => (g.id, g.name))),
                  (v) => update(() => gid = v ?? gid),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (name.text.trim().isEmpty ||
                    nis.text.trim().isEmpty ||
                    widget.store.students.any(
                      (s) => s.nis == nis.text.trim(),
                    )) {
                  inform(
                    context,
                    'Nama/NIS wajib diisi dan NIS harus unik.',
                    error: true,
                  );
                  return;
                }
                widget.store.addStudent(
                  name.text.trim(),
                  nis.text.trim(),
                  cid,
                  gid,
                );
                Navigator.pop(ctx);
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
    name.dispose();
    nis.dispose();
  }

  Future<void> _addGuardian() async {
    final name = TextEditingController(),
        phone = TextEditingController(),
        email = TextEditingController();
    await settledDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tambah Wali'),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              field(name, 'Nama wali'),
              const SizedBox(height: 12),
              field(phone, 'Telepon'),
              const SizedBox(height: 12),
              field(email, 'Email'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (name.text.trim().isEmpty ||
                  phone.text.trim().isEmpty ||
                  !email.text.contains('@')) {
                inform(context, 'Lengkapi semua data wali.', error: true);
                return;
              }
              widget.store.addGuardian(
                name.text.trim(),
                phone.text.trim(),
                email.text.trim(),
              );
              Navigator.pop(ctx);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    name.dispose();
    phone.dispose();
    email.dispose();
  }
}

class SubjectsClassesPage extends StatefulWidget {
  const SubjectsClassesPage({super.key, required this.store});
  final SchoolStore store;
  @override
  State<SubjectsClassesPage> createState() => _SubjectsClassesPageState();
}

class _SubjectsClassesPageState extends State<SubjectsClassesPage> {
  int tab = 0;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      PageTitle(
        title: 'Mata Pelajaran & Kelas',
        subtitle: 'Master mata pelajaran, rombongan belajar, dan tahun ajaran.',
        action: primaryButton(
          tab == 0 ? 'Tambah Mata Pelajaran' : 'Tambah Kelas',
          _add,
        ),
      ),
      Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  color: C.blue,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Text(
                  'Tahun ajaran aktif: ${widget.store.academicYear}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 22),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 0, label: Text('Mata Pelajaran')),
                ButtonSegment(value: 1, label: Text('Kelas')),
              ],
              selected: {tab},
              onSelectionChanged: (v) => setState(() => tab = v.first),
            ),
            const SizedBox(height: 14),
            if (tab == 0)
              SmartTable(
                columns: const [
                  'KODE',
                  'MATA PELAJARAN',
                  'PENUGASAN AKTIF',
                  'AKSI',
                ],
                rows: [
                  for (final s in widget.store.subjects)
                    [
                      cell(s.code, strong: true),
                      cell(s.name),
                      cell(
                        '${widget.store.assignments.where((a) => a.active && a.subjectId == s.id).length}',
                      ),
                      TextButton(
                        onPressed: () => _editSubject(s),
                        child: const Text('Ubah'),
                      ),
                    ],
                ],
              ),
            if (tab == 1)
              SmartTable(
                columns: const [
                  'KELAS',
                  'RUANG',
                  'JUMLAH SISWA',
                  'STATUS',
                  'AKSI',
                ],
                rows: [
                  for (final c in widget.store.classes)
                    [
                      cell(c.name, strong: true),
                      cell(c.room),
                      cell(
                        '${widget.store.students.where((s) => s.classId == c.id && s.active).length}',
                      ),
                      const AppBadge('AKTIF'),
                      TextButton(
                        onPressed: () => _editClass(c),
                        child: const Text('Ubah'),
                      ),
                    ],
                ],
              ),
          ],
        ),
      ),
    ],
  );
  Future<void> _editSubject(Subject subject) async {
    final name = TextEditingController(text: subject.name),
        code = TextEditingController(text: subject.code);
    await settledDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ubah Mata Pelajaran'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              field(name, 'Nama mata pelajaran'),
              const SizedBox(height: 12),
              field(code, 'Kode mata pelajaran'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (name.text.trim().isEmpty || code.text.trim().isEmpty) {
                inform(context, 'Lengkapi semua kolom.', error: true);
                return;
              }
              widget.store.editSubject(
                subject,
                name.text.trim(),
                code.text.trim().toUpperCase(),
              );
              Navigator.pop(ctx);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    name.dispose();
    code.dispose();
  }

  Future<void> _editClass(SchoolClass schoolClass) async {
    final name = TextEditingController(text: schoolClass.name),
        room = TextEditingController(text: schoolClass.room);
    await settledDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ubah Kelas'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              field(name, 'Nama kelas'),
              const SizedBox(height: 12),
              field(room, 'Ruang default'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (name.text.trim().isEmpty || room.text.trim().isEmpty) {
                inform(context, 'Lengkapi semua kolom.', error: true);
                return;
              }
              widget.store.editClass(
                schoolClass,
                name.text.trim(),
                room.text.trim(),
              );
              Navigator.pop(ctx);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    name.dispose();
    room.dispose();
  }

  Future<void> _add() async {
    final name = TextEditingController(), extra = TextEditingController();
    await settledDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tab == 0 ? 'Tambah Mata Pelajaran' : 'Tambah Kelas'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              field(name, tab == 0 ? 'Nama mata pelajaran' : 'Nama kelas'),
              const SizedBox(height: 12),
              field(extra, tab == 0 ? 'Kode pelajaran' : 'Ruangan'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (name.text.trim().isEmpty || extra.text.trim().isEmpty) {
                inform(context, 'Lengkapi semua bidang.', error: true);
                return;
              }
              if (tab == 0) {
                widget.store.addSubject(
                  name.text.trim(),
                  extra.text.trim().toUpperCase(),
                );
              } else {
                widget.store.addClass(name.text.trim(), extra.text.trim());
              }
              Navigator.pop(ctx);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    name.dispose();
    extra.dispose();
  }
}

class AssignmentsPage extends StatelessWidget {
  const AssignmentsPage({super.key, required this.store});
  final SchoolStore store;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      PageTitle(
        title: 'Penugasan Guru',
        subtitle:
            'Hubungkan guru, mata pelajaran, kelas, dan tahun ajaran; satu guru boleh memiliki banyak penugasan.',
        action: primaryButton('Buat Penugasan', () => _add(context)),
      ),
      Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Penugasan hanya dapat disusun oleh admin. Perubahan hak akses harus divalidasi ulang oleh API di lingkungan produksi.',
              style: TextStyle(fontSize: 12, color: C.muted),
            ),
            const SizedBox(height: 16),
            SmartTable(
              columns: const [
                'GURU',
                'PELAJARAN',
                'KELAS',
                'TAHUN AJARAN',
                'STATUS',
                'AKSI',
              ],
              rows: [
                for (final a in store.assignments)
                  [
                    cell(store.teacherName(a.teacherId), strong: true),
                    cell(store.subjectName(a.subjectId)),
                    cell(store.className(a.classId)),
                    cell(a.academicYear),
                    AppBadge(a.active ? 'AKTIF' : 'NONAKTIF'),
                    TextButton(
                      onPressed: () async {
                        if (a.active &&
                            store.schedules.any(
                              (s) =>
                                  s.assignmentId == a.id &&
                                  s.status == 'ACTIVE',
                            )) {
                          inform(
                            context,
                            'Nonaktifkan jadwal terkait lebih dulu.',
                            error: true,
                          );
                          return;
                        }
                        if (await confirm(
                          context,
                          'Perbarui penugasan?',
                          'Status penugasan ${a.id} akan diubah dalam demo.',
                        )) {
                          store.toggleAssignment(a);
                        }
                      },
                      child: Text(a.active ? 'Nonaktifkan' : 'Aktifkan'),
                    ),
                  ],
              ],
            ),
          ],
        ),
      ),
    ],
  );
  Future<void> _add(BuildContext context) async {
    if (store.teachers.where((t) => t.active).isEmpty ||
        store.subjects.isEmpty ||
        store.classes.isEmpty) {
      return;
    }
    String tid = store.teachers.firstWhere((t) => t.active).id;
    String sid = store.subjects.first.id;
    String cid = store.classes.first.id;
    await settledDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, update) => AlertDialog(
          title: const Text('Penugasan Baru'),
          content: SizedBox(
            width: 445,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                dropdown(
                  'Guru',
                  tid,
                  options(
                    store.teachers
                        .where((t) => t.active)
                        .map((t) => (t.id, t.name)),
                  ),
                  (v) => update(() => tid = v ?? tid),
                ),
                const SizedBox(height: 13),
                dropdown(
                  'Mata pelajaran',
                  sid,
                  options(store.subjects.map((s) => (s.id, s.name))),
                  (v) => update(() => sid = v ?? sid),
                ),
                const SizedBox(height: 13),
                dropdown(
                  'Kelas',
                  cid,
                  options(store.classes.map((c) => (c.id, c.name))),
                  (v) => update(() => cid = v ?? cid),
                ),
                const SizedBox(height: 13),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: C.pale,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Text(
                    'Tahun ajaran: ${store.academicYear}',
                    style: const TextStyle(fontSize: 12, color: C.navy),
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
            ElevatedButton(
              onPressed: () {
                if (store.hasAssignment(tid, sid, cid)) {
                  inform(
                    context,
                    'Penugasan aktif identik sudah ada.',
                    error: true,
                  );
                  return;
                }
                store.addAssignment(tid, sid, cid);
                Navigator.pop(ctx);
              },
              child: const Text('Aktifkan'),
            ),
          ],
        ),
      ),
    );
  }
}

class SchedulesPage extends StatefulWidget {
  const SchedulesPage({super.key, required this.store});
  final SchoolStore store;
  @override
  State<SchedulesPage> createState() => _SchedulesPageState();
}

class _SchedulesPageState extends State<SchedulesPage> {
  int day = 0;
  @override
  Widget build(BuildContext context) {
    final list =
        widget.store.schedules
            .where((s) => day == 0 || s.weekday == day)
            .toList()
          ..sort(
            (a, b) => a.weekday == b.weekday
                ? a.startMinute.compareTo(b.startMinute)
                : a.weekday.compareTo(b.weekday),
          );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageTitle(
          title: 'Jadwal Mengajar',
          subtitle:
              'Jadwal blok pelajaran dengan validasi konflik kelas, guru, dan ruang.',
          action: primaryButton('Tambah Jadwal', _add),
        ),
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (int i = 0; i <= 5; i++)
                    ChoiceChip(
                      label: Text(
                        i == 0 ? 'Semua Hari' : widget.store.dayName(i),
                      ),
                      selected: day == i,
                      onSelected: (_) => setState(() => day = i),
                    ),
                ],
              ),
              const SizedBox(height: 18),
              SmartTable(
                columns: const [
                  'HARI & JAM',
                  'PELAJARAN / KELAS',
                  'GURU',
                  'RUANG',
                  'STATUS',
                  'AKSI',
                ],
                rows: [
                  for (final s in list)
                    [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          cell(widget.store.dayName(s.weekday), strong: true),
                          const SizedBox(height: 4),
                          cell(
                            '${widget.store.timeOf(s.startMinute)}–${widget.store.timeOf(s.endMinute)}',
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          cell(
                            widget.store.subjectName(
                              widget.store.assignment(s.assignmentId).subjectId,
                            ),
                            strong: true,
                          ),
                          const SizedBox(height: 4),
                          cell(
                            'Kelas ${widget.store.className(widget.store.assignment(s.assignmentId).classId)}',
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          cell(
                            widget.store.teacherName(
                              s.substituteTeacherId ??
                                  widget.store
                                      .assignment(s.assignmentId)
                                      .teacherId,
                            ),
                          ),
                          if (s.substituteTeacherId != null)
                            cell('Pengganti', color: C.orange),
                        ],
                      ),
                      cell(s.room),
                      AppBadge(s.status),
                      s.status == 'CANCELLED'
                          ? cell('Dibatalkan')
                          : TextButton(
                              onPressed: () => _cancel(s),
                              child: const Text('Batalkan'),
                            ),
                    ],
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Satu blok 07:00–08:30 = satu sesi. Blok pelajaran terpisah wajib absensi dan notifikasi baru.',
                style: TextStyle(fontSize: 11, color: C.muted),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _add() async {
    final active = widget.store.assignments
        .where((a) => a.active && widget.store.teacher(a.teacherId).active)
        .toList();
    if (active.isEmpty) {
      inform(context, 'Buat penugasan aktif terlebih dahulu.', error: true);
      return;
    }
    String aid = active.first.id;
    int weekday = 1;
    final start = TextEditingController(text: '07:00'),
        end = TextEditingController(text: '08:30'),
        room = TextEditingController(
          text: widget.store.schoolClass(active.first.classId).room,
        );
    int? toMinute(String value) {
      final match = RegExp(
        r'^([01]\d|2[0-3]):([0-5]\d)$',
      ).firstMatch(value.trim());
      if (match == null) return null;
      return int.parse(match.group(1)!) * 60 + int.parse(match.group(2)!);
    }

    await settledDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, update) => AlertDialog(
          title: const Text('Buat Jadwal Mengajar'),
          content: SizedBox(
            width: 470,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  dropdown(
                    'Penugasan',
                    aid,
                    options(
                      active.map(
                        (a) => (
                          a.id,
                          '${widget.store.subjectName(a.subjectId)} · ${widget.store.className(a.classId)} · ${widget.store.teacherName(a.teacherId)}',
                        ),
                      ),
                    ),
                    (v) => update(() {
                      aid = v ?? aid;
                      room.text = widget.store
                          .schoolClass(widget.store.assignment(aid).classId)
                          .room;
                    }),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    initialValue: weekday,
                    decoration: const InputDecoration(labelText: 'Hari'),
                    items: [
                      for (int i = 1; i <= 6; i++)
                        DropdownMenuItem(
                          value: i,
                          child: Text(widget.store.dayName(i)),
                        ),
                    ],
                    onChanged: (v) => update(() => weekday = v ?? weekday),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: field(start, 'Mulai (HH:mm)')),
                      const SizedBox(width: 10),
                      Expanded(child: field(end, 'Selesai (HH:mm)')),
                    ],
                  ),
                  const SizedBox(height: 12),
                  field(room, 'Ruang'),
                  const SizedBox(height: 14),
                  const Text(
                    'Jadwal beririsan tidak dapat dibuat untuk kelas, guru, atau ruang yang sama.',
                    style: TextStyle(color: C.muted, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                final from = toMinute(start.text), until = toMinute(end.text);
                if (from == null ||
                    until == null ||
                    from >= until ||
                    room.text.trim().isEmpty) {
                  inform(
                    context,
                    'Gunakan format HH:mm dan pastikan jam selesai setelah mulai.',
                    error: true,
                  );
                  return;
                }
                final conflict = widget.store.scheduleConflict(
                  aid,
                  weekday,
                  from,
                  until,
                  room.text.trim(),
                );
                if (conflict != null) {
                  inform(context, conflict, error: true);
                  return;
                }
                widget.store.addSchedule(
                  aid,
                  weekday,
                  from,
                  until,
                  room.text.trim(),
                );
                Navigator.pop(ctx);
              },
              child: const Text('Simpan Jadwal'),
            ),
          ],
        ),
      ),
    );
    start.dispose();
    end.dispose();
    room.dispose();
  }

  Future<void> _cancel(LessonSchedule s) async {
    final reason = TextEditingController();
    await settledDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Batalkan Jadwal'),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Pada sistem produksi pembatalan sesi harus diaudit dan mengirim pembaruan yang sesuai.',
              ),
              const SizedBox(height: 14),
              field(reason, 'Alasan pembatalan'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (reason.text.trim().isEmpty) {
                inform(context, 'Alasan harus diisi.', error: true);
                return;
              }
              widget.store.cancelSchedule(s, reason.text.trim());
              Navigator.pop(ctx);
            },
            child: const Text('Batalkan Jadwal'),
          ),
        ],
      ),
    );
    reason.dispose();
  }
}

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key, required this.store});
  final SchoolStore store;
  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  String search = '';
  String status = 'SEMUA';
  final statuses = const [
    'SEMUA',
    'HADIR',
    'TERLAMBAT',
    'MANUAL_HADIR',
    'IZIN',
    'SAKIT',
    'TIDAK_HADIR',
    'BELUM_ABSEN',
    'BELUM_TERCATAT_HADIR',
    'BELUM_DIVERIFIKASI',
  ];
  @override
  Widget build(BuildContext context) {
    final records = widget.store.attendance.where((a) {
      final haystack =
          '${widget.store.student(a.studentId).name} ${a.sessionCode} ${widget.store.subjectName(a.subjectId)} ${widget.store.className(a.classId)}'
              .toLowerCase();
      return haystack.contains(search.toLowerCase()) &&
          (status == 'SEMUA' || a.status == status);
    }).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageTitle(
          title: 'Monitoring & Koreksi',
          subtitle:
              'Kehadiran per siswa per sesi, bukan rekap hanya sekali per hari.',
        ),
        const DemoNotice(),
        const SizedBox(height: 16),
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LayoutBuilder(
                builder: (context, c) => Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    SizedBox(
                      width: c.maxWidth > 500 ? 345 : c.maxWidth,
                      child: TextField(
                        onChanged: (v) => setState(() => search = v),
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          hintText: 'Cari siswa, sesi, mapel...',
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 235,
                      child: dropdown(
                        'Filter status',
                        status,
                        options(
                          statuses.map((s) => (s, s.replaceAll('_', ' '))),
                        ),
                        (v) => setState(() => status = v ?? status),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SmartTable(
                columns: const [
                  'SISWA',
                  'MAPEL / KELAS',
                  'ID SESI',
                  'STATUS',
                  'METODE',
                  'PUKUL',
                  'AKSI',
                ],
                rows: [
                  for (final a in records)
                    [
                      cell(
                        widget.store.student(a.studentId).name,
                        strong: true,
                      ),
                      cell(
                        '${widget.store.subjectName(a.subjectId)} · ${widget.store.className(a.classId)}',
                      ),
                      cell(a.sessionCode),
                      AppBadge(a.status),
                      cell(a.method),
                      cell(a.time),
                      TextButton(
                        onPressed: () => _correct(a),
                        child: const Text('Koreksi'),
                      ),
                    ],
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'BELUM_ABSEN / BELUM_TERCATAT_HADIR tidak sama dengan TIDAK_HADIR final. Koreksi wajib beralasan.',
                style: TextStyle(color: C.muted, fontSize: 11),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _correct(Attendance a) async {
    String selected = a.status;
    final reason = TextEditingController();
    final choices = statuses.where((s) => s != 'SEMUA').toList();
    await settledDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, update) => AlertDialog(
          title: const Text('Koreksi Absensi'),
          content: SizedBox(
            width: 455,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.store.student(a.studentId).name} · ${a.sessionCode}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 14),
                dropdown(
                  'Status baru',
                  selected,
                  options(choices.map((s) => (s, s.replaceAll('_', ' ')))),
                  (v) => update(() => selected = v ?? selected),
                ),
                const SizedBox(height: 12),
                field(reason, 'Alasan koreksi', lines: 3),
                const SizedBox(height: 12),
                const Text(
                  'Di produksi tindakan ini wajib diperiksa oleh backend (RBAC, versi, audit dan notifikasi koreksi).',
                  style: TextStyle(fontSize: 11, color: C.muted),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (selected == a.status || reason.text.trim().isEmpty) {
                  inform(
                    context,
                    'Pilih status berbeda dan isi alasan.',
                    error: true,
                  );
                  return;
                }
                widget.store.updateAttendance(a, selected, reason.text.trim());
                Navigator.pop(ctx);
              },
              child: const Text('Simpan Koreksi'),
            ),
          ],
        ),
      ),
    );
    reason.dispose();
  }
}

class LeavesPage extends StatelessWidget {
  const LeavesPage({super.key, required this.store});
  final SchoolStore store;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const PageTitle(
        title: 'Izin & Guru Pengganti',
        subtitle:
            'Tinjau guru berhalangan, tunjuk pengganti, dan tangani sesi yang batal.',
      ),
      Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle('Laporan guru berhalangan'),
            const SizedBox(height: 10),
            SmartTable(
              columns: const ['GURU', 'JADWAL', 'ALASAN', 'STATUS', 'AKSI'],
              rows: [
                for (final r in store.leaveRequests)
                  [
                    cell(store.teacherName(r.teacherId), strong: true),
                    cell(
                      '${store.dayName(store.schedule(r.scheduleId).weekday)} · ${store.timeOf(store.schedule(r.scheduleId).startMinute)}',
                    ),
                    cell(r.reason),
                    AppBadge(r.status),
                    r.status == 'PENDING'
                        ? Wrap(
                            spacing: 3,
                            children: [
                              TextButton(
                                onPressed: () =>
                                    store.decideLeave(r, 'DISETUJUI'),
                                child: const Text('Setujui'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    store.decideLeave(r, 'DITOLAK'),
                                child: const Text('Tolak'),
                              ),
                            ],
                          )
                        : cell('Ditinjau'),
                  ],
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle('Penetapan guru pengganti'),
            const SizedBox(height: 10),
            const Text(
              'Penetapan sementara dalam mode demo. Guru utama dan guru aktual harus disimpan terpisah di tiap sesi produksi.',
              style: TextStyle(fontSize: 12, color: C.muted),
            ),
            const SizedBox(height: 12),
            SmartTable(
              columns: const [
                'JADWAL',
                'GURU UTAMA',
                'GURU AKTUAL',
                'STATUS',
                'AKSI',
              ],
              rows: [
                for (final sc in store.schedules.where(
                  (s) => s.status == 'ACTIVE',
                ))
                  [
                    cell(
                      '${store.subjectName(store.assignment(sc.assignmentId).subjectId)} · ${store.className(store.assignment(sc.assignmentId).classId)}',
                      strong: true,
                    ),
                    cell(
                      store.teacherName(
                        store.assignment(sc.assignmentId).teacherId,
                      ),
                    ),
                    cell(
                      sc.substituteTeacherId == null
                          ? '-'
                          : store.teacherName(sc.substituteTeacherId!),
                    ),
                    AppBadge(
                      sc.substituteTeacherId == null ? 'REGULER' : 'PENGGANTI',
                    ),
                    TextButton(
                      onPressed: () => _substitute(context, sc),
                      child: const Text('Atur pengganti'),
                    ),
                  ],
              ],
            ),
          ],
        ),
      ),
    ],
  );
  Future<void> _substitute(BuildContext context, LessonSchedule sc) async {
    final assigned = store.assignment(sc.assignmentId);
    final candidates = store.teachers
        .where((t) => t.active && t.id != assigned.teacherId)
        .toList();
    if (candidates.isEmpty) {
      inform(context, 'Belum ada kandidat guru pengganti.', error: true);
      return;
    }
    String tid = candidates.first.id;
    final reason = TextEditingController();
    await settledDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, update) => AlertDialog(
          title: const Text('Tetapkan Guru Pengganti'),
          content: SizedBox(
            width: 450,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${store.subjectName(assigned.subjectId)} · Kelas ${store.className(assigned.classId)}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                dropdown(
                  'Pilih pengganti',
                  tid,
                  options(candidates.map((t) => (t.id, t.name))),
                  (v) => update(() => tid = v ?? tid),
                ),
                const SizedBox(height: 12),
                field(reason, 'Alasan penugasan'),
                const SizedBox(height: 12),
                const Text(
                  'Penggantian per sesi tidak mengubah guru utama di penugasan.',
                  style: TextStyle(fontSize: 11, color: C.muted),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (reason.text.trim().isEmpty) {
                  inform(context, 'Alasan harus diisi.', error: true);
                  return;
                }
                // Cek jadwal guru pengganti tanpa mengubah assignment utama.
                final conflict = store.schedules.any(
                  (other) =>
                      other.id != sc.id &&
                      other.status == 'ACTIVE' &&
                      other.weekday == sc.weekday &&
                      sc.startMinute < other.endMinute &&
                      other.startMinute < sc.endMinute &&
                      (other.substituteTeacherId ??
                              store.assignment(other.assignmentId).teacherId) ==
                          tid,
                );
                if (conflict) {
                  inform(
                    context,
                    'Guru pengganti bentrok dengan jadwal lain.',
                    error: true,
                  );
                  return;
                }
                store.substitute(sc, tid, reason.text.trim());
                Navigator.pop(ctx);
              },
              child: const Text('Tetapkan'),
            ),
          ],
        ),
      ),
    );
    reason.dispose();
  }
}

class ConsentsPage extends StatelessWidget {
  const ConsentsPage({super.key, required this.store});
  final SchoolStore store;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const PageTitle(
        title: 'Persetujuan Data Wajah',
        subtitle:
            'Status izin biometrik, pencabutan persetujuan, dan opsi nonbiometrik.',
      ),
      const DemoNotice(),
      const SizedBox(height: 15),
      Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF4E6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lock_outline, color: C.orange),
                  SizedBox(width: 11),
                  Expanded(
                    child: Text(
                      'Halaman demo hanya menampilkan status persetujuan. Tidak menyimpan foto, template wajah, atau data biometrik. Pendaftaran, pemberian izin, dan penghapusan nyata wajib ditangani backend/staf dengan kewenangan khusus serta bukti persetujuan sah.',
                      style: TextStyle(fontSize: 12, color: C.dark),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SmartTable(
              columns: const [
                'SISWA',
                'WALI',
                'STATUS PERSETUJUAN',
                'PEMBARUAN',
                'ALTERNATIF',
                'AKSI DEMO',
              ],
              rows: [
                for (final c in store.consents)
                  [
                    cell(store.student(c.studentId).name, strong: true),
                    cell(store.guardian(c.guardianId).name),
                    AppBadge(c.status),
                    cell(c.updatedAt),
                    const AppBadge('MANUAL'),
                    c.status == 'DISETUJUI'
                        ? TextButton(
                            onPressed: () => _revoke(context, c),
                            child: const Text('Simulasikan pencabutan'),
                          )
                        : cell('Tidak ada aksi'),
                  ],
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Status BELUM_ADA / DICABUT berarti jalur manual harus tetap tersedia. Tidak ada skor akurasi biometrik yang dinyatakan.',
              style: TextStyle(color: C.muted, fontSize: 11),
            ),
          ],
        ),
      ),
    ],
  );
  Future<void> _revoke(BuildContext context, Consent c) async {
    final reason = TextEditingController();
    await settledDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Simulasi pencabutan izin'),
        content: SizedBox(
          width: 430,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Siswa: ${store.student(c.studentId).name}'),
              const SizedBox(height: 13),
              field(reason, 'Alasan / referensi permintaan'),
              const SizedBox(height: 10),
              const Text(
                'Tidak mengubah data Firebase maupun file biometrik.',
                style: TextStyle(color: C.muted, fontSize: 11),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (reason.text.trim().isEmpty) {
                inform(context, 'Alasan wajib diisi.', error: true);
                return;
              }
              store.setConsent(c, 'DICABUT', reason.text.trim());
              Navigator.pop(ctx);
            },
            child: const Text('Simulasikan'),
          ),
        ],
      ),
    );
    reason.dispose();
  }
}

class SettingsAuditPage extends StatefulWidget {
  const SettingsAuditPage({super.key, required this.store});
  final SchoolStore store;
  @override
  State<SettingsAuditPage> createState() => _SettingsAuditPageState();
}

class _SettingsAuditPageState extends State<SettingsAuditPage> {
  int tab = 0;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const PageTitle(
        title: 'Pengaturan & Audit',
        subtitle:
            'Pengaturan sesi dan retensi, kalender sekolah, serta jejak tindakan admin.',
      ),
      Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(
                  value: 0,
                  label: Text('Pengaturan'),
                  icon: Icon(Icons.tune),
                ),
                ButtonSegment(
                  value: 1,
                  label: Text('Riwayat Audit'),
                  icon: Icon(Icons.history),
                ),
              ],
              selected: {tab},
              onSelectionChanged: (v) => setState(() => tab = v.first),
            ),
            const SizedBox(height: 20),
            if (tab == 0) _settings(context) else _audit(),
          ],
        ),
      ),
    ],
  );
  Widget _settings(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const DemoNotice(),
      const SizedBox(height: 17),
      const Text(
        'Kebijakan sekolah (nilai awal usulan dari PRD)',
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: 12),
      Text('Nama sekolah: ${widget.store.schoolName}'),
      const SizedBox(height: 8),
      Text(
        'Tenggat absensi: +${widget.store.deadlineMinutes} menit dari awal sesi',
      ),
      const SizedBox(height: 8),
      Text(
        'Retensi bukti foto: ${widget.store.retentionDays} hari (usulan demo, bukan kebijakan produksi)',
      ),
      const SizedBox(height: 16),
      primaryButton(
        'Ubah Pengaturan',
        () => _editSettings(context),
        icon: Icons.edit_outlined,
      ),
      const Divider(color: C.line, height: 34),
      const Text(
        'Kalender pengecualian / libur',
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: 10),
      for (final h in widget.store.holidays)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              const Icon(Icons.event_busy_outlined, color: C.orange, size: 18),
              const SizedBox(width: 10),
              Text(h),
            ],
          ),
        ),
      const SizedBox(height: 13),
      OutlinedButton.icon(
        onPressed: () => _addHoliday(context),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Pengecualian Demo'),
      ),
    ],
  );
  Widget _audit() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Jejak perubahan demo dari backend lokal bersama; audit keamanan produksi belum diterapkan.',
        style: TextStyle(fontSize: 12, color: C.muted),
      ),
      const SizedBox(height: 15),
      SmartTable(
        columns: const ['WAKTU', 'AKTOR', 'AKSI', 'RINCIAN'],
        rows: [
          for (final a in widget.store.audits)
            [
              cell(a.when),
              cell(a.actor),
              cell(a.action, strong: true),
              cell(a.details),
            ],
        ],
      ),
    ],
  );
  Future<void> _editSettings(BuildContext context) async {
    final name = TextEditingController(text: widget.store.schoolName),
        deadline = TextEditingController(
          text: '${widget.store.deadlineMinutes}',
        ),
        retention = TextEditingController(
          text: '${widget.store.retentionDays}',
        );
    await settledDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Pengaturan Sekolah'),
        content: SizedBox(
          width: 440,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              field(name, 'Nama sekolah'),
              const SizedBox(height: 12),
              field(deadline, 'Tenggat absensi (menit)'),
              const SizedBox(height: 12),
              field(retention, 'Retensi foto usulan (hari)'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final d = int.tryParse(deadline.text),
                  r = int.tryParse(retention.text);
              if (name.text.trim().isEmpty ||
                  d == null ||
                  d < 1 ||
                  d > 240 ||
                  r == null ||
                  r < 1 ||
                  r > 365) {
                inform(
                  context,
                  'Tenggat 1–240 menit; retensi 1–365 hari.',
                  error: true,
                );
                return;
              }
              widget.store.updateSettings(name.text.trim(), d, r);
              Navigator.pop(ctx);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    name.dispose();
    deadline.dispose();
    retention.dispose();
  }

  Future<void> _addHoliday(BuildContext context) async {
    final date = TextEditingController();
    await settledDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tambahkan Tanggal Libur Demo'),
        content: SizedBox(
          width: 420,
          child: field(date, 'Tanggal (mis. 01 Jan 2027)'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (date.text.trim().isEmpty) {
                inform(context, 'Tanggal harus diisi.', error: true);
                return;
              }
              widget.store.addHoliday(date.text.trim());
              Navigator.pop(ctx);
            },
            child: const Text('Tambahkan'),
          ),
        ],
      ),
    );
    date.dispose();
  }
}
