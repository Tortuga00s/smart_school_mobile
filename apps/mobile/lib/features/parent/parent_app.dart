// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
// Keep original Material UI imports compatible with the uploaded project.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';

import 'demo_store.dart';
import 'models.dart';
import 'widgets.dart';
import 'password_page.dart';
import '../../role_app.dart';

import 'package:school_data/school_data.dart' as shared;

ThemeData smartSchoolMobileTheme() => ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: schoolBackground,
  colorScheme: ColorScheme.fromSeed(seedColor: schoolBlue),
  textTheme: ThemeData.light().textTheme.apply(
    bodyColor: schoolInk,
    displayColor: schoolInk,
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: schoolBackground,
    foregroundColor: schoolInk,
    surfaceTintColor: Colors.transparent,
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: schoolBlue,
      foregroundColor: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    contentPadding: EdgeInsets.all(18),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: schoolBorder),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: schoolBorder),
    ),
  ),
);

class SmartSchoolApp extends StatelessWidget {
  const SmartSchoolApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Smart School',
    debugShowCheckedModeBanner: false,
    theme: smartSchoolMobileTheme(),
    home: RoleGateway(),
  );
}

class ParentShell extends StatefulWidget {
  const ParentShell({super.key, required this.data, required this.onExit});
  final shared.SchoolStore data;
  final VoidCallback onExit;
  @override
  State<ParentShell> createState() => _ParentShellState();
}

class _ParentShellState extends State<ParentShell> {
  late final store = ParentDemoStore(widget.data);
  int tab = 0;
  bool signedOut = false;
  @override
  void dispose() {
    store.dispose();
    super.dispose();
  }

  void navigate(int value) => setState(() => tab = value);
  void notifications() => Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => NotificationsPage(store: store)),
  );
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: store,
    builder: (context, _) {
      if (signedOut) {
        return Scaffold(
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.school_outlined, size: 64, color: schoolBlue),
                    SizedBox(height: 20),
                    Text(
                      'Smart School',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Pratinjau wali murid telah ditutup.',
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24),
                    FilledButton(
                      onPressed: () => setState(() {
                        signedOut = false;
                        tab = 0;
                      }),
                      child: Text('Buka kembali demo'),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Login akun asli belum terhubung Firebase.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: schoolMuted),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
      return Scaffold(
        appBar: AppBar(
          toolbarHeight: 54,
          title: DropdownButton<String>(
            isExpanded: true,
            value: store.selectedStudentId,
            items: store.children
                .map(
                  (st) => DropdownMenuItem(value: st.id, child: Text(st.name)),
                )
                .toList(),
            onChanged: (v) {
              if (v != null) store.selectChild(v);
            },
          ),
          actions: [
            IconButton(
              tooltip: 'Ganti peran',
              onPressed: widget.onExit,
              icon: Icon(Icons.logout),
            ),
          ],
        ),
        body: SafeArea(
          bottom: false,
          child: IndexedStack(
            index: tab,
            children: [
              HomePage(
                store: store,
                onNavigate: navigate,
                onNotifications: notifications,
              ),
              AttendancePage(store: store),
              SchedulePage(store: store),
              GradesPage(store: store),
              ProfilePage(store: store, onLogout: widget.onExit),
            ],
          ),
        ),
        bottomNavigationBar: NavigationBar(
          height: 74,
          backgroundColor: Colors.white,
          indicatorColor: Color(0xFFE7F1FF),
          selectedIndex: tab,
          onDestinationSelected: navigate,
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home, color: schoolBlue),
              label: 'Beranda',
            ),
            NavigationDestination(
              icon: Icon(Icons.check_rounded),
              label: 'Kehadiran',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_today_outlined),
              label: 'Jadwal',
            ),
            NavigationDestination(
              icon: Icon(Icons.menu_book_outlined),
              label: 'Akademik',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              label: 'Profil',
            ),
          ],
        ),
      );
    },
  );
}

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    required this.store,
    required this.onNavigate,
    required this.onNotifications,
  });
  final ParentDemoStore store;
  final ValueChanged<int> onNavigate;
  final VoidCallback onNotifications;
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(20, 22, 20, 44),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1057A6), Color(0xFF2389DF)],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconTile(Icons.school_outlined),
                  Badge(
                    isLabelVisible: store.unread > 0,
                    label: Text('${store.unread}'),
                    child: IconButton(
                      tooltip: 'Pusat notifikasi',
                      onPressed: onNotifications,
                      icon: Icon(
                        Icons.notifications_none_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 26),
              Text(
                'Selamat Datang, Bapak/Ibu',
                style: TextStyle(
                  fontSize: 26,
                  height: 1.25,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Pantau perkembangan belajar buah hati Anda.',
                style: TextStyle(color: Color(0xFFC6E2FF), fontSize: 15),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Transform.translate(
                offset: Offset(0, -14),
                child: SchoolCard(
                  child: Row(
                    children: [
                      StudentAvatar(),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PUTRA ANDA',
                              style: TextStyle(
                                color: schoolBlue,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              store.childName,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 19,
                              ),
                            ),
                            Text(
                              store.childDetails,
                              style: TextStyle(
                                color: schoolMuted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      StatusBadge(
                        store.attendance.isEmpty
                            ? 'Belum Ada'
                            : store.attendance.first.status,
                      ),
                    ],
                  ),
                ),
              ),
              Text(
                'Ringkasan Akademik',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 4),
              Text(
                'Semester Ganjil 2026/2027',
                style: TextStyle(color: schoolMuted),
              ),
              SizedBox(height: 18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _summary(
                      Icons.check,
                      '${store.presentPercent}%',
                      'Rekap Kehadiran',
                      '${store.presentCount} dari ${store.attendance.length} sesi',
                      false,
                      () => onNavigate(1),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _summary(
                      Icons.bookmark_border,
                      decimal(store.average),
                      'Rata-rata Nilai',
                      store.grades.isEmpty
                          ? 'Nilai belum diisi'
                          : 'Rata-rata UTS dan UAS',
                      true,
                      () => onNavigate(3),
                    ),
                  ),
                ],
              ),
              SectionTitle(
                'Jadwal Anak',
                action: 'Jadwal',
                onTap: () => onNavigate(2),
              ),
              SchoolCard(
                onTap: () => onNavigate(2),
                child: Row(
                  children: [
                    Text(
                      store.lessons(0).isEmpty
                          ? '—'
                          : store.lessons(0).first.time.split(' - ').first,
                      style: TextStyle(
                        color: schoolBlue,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            store.lessons(0).isEmpty
                                ? 'Belum ada jadwal'
                                : store.lessons(0).first.subject,
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          SizedBox(height: 4),
                          Text(
                            store.lessons(0).isEmpty
                                ? 'Hubungi sekolah'
                                : store.lessons(0).first.teacher,
                            style: TextStyle(color: schoolMuted, fontSize: 12),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Jadwal mingguan demo',
                            style: TextStyle(color: schoolOrange, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SectionTitle(
                'Kehadiran Terbaru',
                action: 'Lihat semua',
                onTap: () => onNavigate(1),
              ),
              SchoolCard(
                onTap: () => store.attendance.isEmpty
                    ? null
                    : showAttendance(context, store.attendance[0]),
                child: Row(
                  children: [
                    IconTile(Icons.menu_book_outlined, solid: true),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            store.attendance.isEmpty
                                ? 'Belum ada kehadiran'
                                : store.attendance.first.subject,
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            store.attendance.isEmpty
                                ? 'Belum ada sesi dicatat'
                                : '${store.attendance.first.teacher} • ${store.attendance.first.method}',
                            style: TextStyle(color: schoolMuted, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    StatusBadge(
                      store.attendance.isEmpty
                          ? 'Belum Ada'
                          : store.attendance.first.status,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 12),
                child: Text(
                  'Mode demo lokal • Data fiktif, tanpa push online',
                  style: TextStyle(color: schoolMuted, fontSize: 11),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
  Widget _summary(
    IconData icon,
    String value,
    String label,
    String subtitle,
    bool green,
    VoidCallback onTap,
  ) => Semantics(
    button: true,
    label: label,
    child: GestureDetector(
      onTap: onTap,
      child: GradientPanel(
        green: green,
        padding: EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.white),
                Spacer(),
                Icon(Icons.chevron_right, color: Colors.white70),
              ],
            ),
            SizedBox(height: 20),
            Text(
              value,
              style: TextStyle(fontSize: 31, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
            SizedBox(height: 6),
            Text(
              subtitle,
              style: TextStyle(color: Colors.white70, fontSize: 10),
            ),
          ],
        ),
      ),
    ),
  );
}

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key, required this.store});
  final ParentDemoStore store;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: store,
    builder: (context, _) => Scaffold(
      appBar: AppBar(
        title: Text('Pusat Notifikasi'),
        actions: [
          TextButton(
            onPressed: store.unread == 0 ? null : store.markAllRead,
            child: Text('Tandai dibaca'),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          Text(
            '${store.unread} notifikasi belum dibaca',
            style: TextStyle(color: schoolMuted),
          ),
          SizedBox(height: 22),
          for (final yesterday in [false, true]) ...[
            Padding(
              padding: EdgeInsets.only(bottom: 12, top: 8),
              child: Text(
                yesterday ? 'KEMARIN' : 'HARI INI',
                style: TextStyle(
                  color: schoolMuted,
                  letterSpacing: 1.1,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            for (final notice in store.notices.where(
              (n) => n.yesterday == yesterday,
            ))
              SchoolCard(
                onTap: () {
                  store.readNotice(notice);
                  if (notice.attendance != null) {
                    showAttendance(context, notice.attendance!);
                  } else {
                    showDialog<void>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text(notice.title),
                        content: Text(notice.message),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: Text('Tutup'),
                          ),
                        ],
                      ),
                    );
                  }
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconTile(notice.icon, color: notice.color),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  notice.title,
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                              ),
                              if (!notice.read)
                                Icon(
                                  Icons.circle,
                                  size: 7,
                                  color: Colors.lightBlue,
                                ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            notice.message,
                            style: TextStyle(
                              color: schoolMuted,
                              height: 1.6,
                              fontSize: 13,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            notice.time,
                            style: TextStyle(color: schoolMuted, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    ),
  );
}

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key, required this.store});
  final ParentDemoStore store;
  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  int period = 2;
  String subject = 'Semua mapel';
  @override
  Widget build(BuildContext context) {
    final entries = widget.store.filtered(period, subject);
    final present = entries
        .where((a) => a.status == 'Hadir' || a.status == 'Terlambat')
        .length;
    final percent = entries.isEmpty
        ? 0
        : (present / entries.length * 100).round();
    return ListView(
      padding: EdgeInsets.only(bottom: 24),
      children: [
        PageTitle(
          'Rekap Kehadiran',
          '${widget.store.childName} • ${widget.store.childDetails}',
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GradientPanel(
                child: Row(
                  children: [
                    SizedBox(
                      width: 78,
                      height: 78,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox.expand(
                            child: CircularProgressIndicator(
                              value: entries.isEmpty
                                  ? 0
                                  : present / entries.length,
                              strokeWidth: 6,
                              backgroundColor: Colors.white24,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '$percent%',
                            style: TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TINGKAT KEHADIRAN',
                            style: TextStyle(
                              fontSize: 11,
                              letterSpacing: 1,
                              color: Colors.white70,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            entries.isEmpty
                                ? 'Belum ada data'
                                : percent >= 90
                                ? 'Sangat Baik'
                                : percent >= 75
                                ? 'Baik'
                                : 'Perlu Perhatian',
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            '$present dari ${entries.length} sesi',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 14),
              Row(
                children: [
                  for (final status in [
                    'Hadir',
                    'Izin',
                    'Sakit',
                    'Tidak Hadir',
                  ])
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 3),
                        child: SchoolCard(
                          padding: EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 3,
                          ),
                          child: Column(
                            children: [
                              Text(
                                '${entries.where((a) => a.status == status).length}',
                                style: TextStyle(
                                  fontSize: 25,
                                  color: schoolBlue,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                status == 'Tidak Hadir' ? 'Alpa' : status,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: schoolMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 6),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<int>(
                  showSelectedIcon: false,
                  segments: [
                    ButtonSegment(value: 0, label: Text('Hari ini')),
                    ButtonSegment(value: 1, label: Text('Minggu ini')),
                    ButtonSegment(value: 2, label: Text('Bulan ini')),
                  ],
                  selected: {period},
                  onSelectionChanged: (s) => setState(() => period = s.first),
                ),
              ),
              SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: subject,
                decoration: InputDecoration(labelText: 'Mata pelajaran'),
                items:
                    [
                          'Semua mapel',
                          ...widget.store.data.subjects.map((g) => g.name),
                        ]
                        .map(
                          (s) => DropdownMenuItem(
                            value: s,
                            child: Text(s, style: TextStyle(fontSize: 13)),
                          ),
                        )
                        .toList(),
                onChanged: (s) => setState(() => subject = s!),
              ),
              SectionTitle('Riwayat Kehadiran'),
              if (entries.isEmpty)
                SchoolCard(child: Text('Belum ada kehadiran pada filter ini.')),
              for (final entry in entries)
                SchoolCard(
                  onTap: () => showAttendance(context, entry),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 42,
                        decoration: BoxDecoration(
                          color: entry.status == 'Hadir'
                              ? schoolGreen
                              : schoolOrange,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.subject,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              '${dateLabel(entry.date)} • ${clock(entry.date)} WIB',
                              style: TextStyle(
                                fontSize: 11,
                                color: schoolMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 6),
                      StatusBadge(entry.status),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key, required this.store});
  final ParentDemoStore store;
  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  int selected = 0;
  @override
  Widget build(BuildContext context) => ListView(
    padding: EdgeInsets.only(bottom: 24),
    children: [
      PageTitle(
        'Jadwal Pelajaran',
        '${widget.store.childDetails} • Jadwal mingguan demo',
      ),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Row(
              children: [
                for (var i = 0; i < 5; i++)
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 3),
                      child: Material(
                        color: selected == i ? schoolBlue : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: schoolBorder),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () => setState(() => selected = i),
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Column(
                              children: [
                                Text(
                                  ['Sen', 'Sel', 'Rab', 'Kam', 'Jum'][i],
                                  style: TextStyle(
                                    color: selected == i
                                        ? Colors.white
                                        : schoolMuted,
                                    fontSize: 12,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  '${i + 1}',
                                  style: TextStyle(
                                    color: selected == i
                                        ? Colors.white
                                        : schoolMuted,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 24),
            for (final lesson in widget.store.lessons(selected))
              Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 65,
                      child: Padding(
                        padding: EdgeInsets.only(top: 18),
                        child: Text(
                          lesson.time.replaceAll(' - ', '\n'),
                          style: TextStyle(
                            fontSize: 11,
                            height: 1.8,
                            color: schoolMuted,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: SchoolCard(
                        child: Row(
                          children: [
                            Container(
                              width: 5,
                              height: 44,
                              decoration: BoxDecoration(
                                color: lesson.color,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    lesson.subject,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    lesson.teacher,
                                    style: TextStyle(
                                      color: schoolMuted,
                                      fontSize: 12,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  StatusBadge(lesson.status),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    ],
  );
}

class GradesPage extends StatefulWidget {
  const GradesPage({super.key, required this.store});
  final ParentDemoStore store;
  @override
  State<GradesPage> createState() => _GradesPageState();
}

class _GradesPageState extends State<GradesPage> {
  String semester = 'Semester Ganjil 2026/2027';
  @override
  Widget build(BuildContext context) => ListView(
    padding: EdgeInsets.only(bottom: 24),
    children: [
      PageTitle(
        'Nilai Akademik',
        '${widget.store.childName} • ${widget.store.childDetails}',
      ),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              initialValue: semester,
              isExpanded: true,
              decoration: InputDecoration(labelText: 'Periode Akademik'),
              items: ['Semester Ganjil 2026/2027', 'Semester Genap 2026/2027']
                  .map(
                    (s) => DropdownMenuItem(
                      value: s,
                      child: Text(
                        s,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (s) => setState(() => semester = s!),
            ),
            SizedBox(height: 16),
            if (semester.contains('Genap') || widget.store.grades.isEmpty)
              SchoolCard(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('Nilai pada periode ini belum tersedia.'),
                ),
              )
            else ...[
              GradientPanel(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rata-rata nilai',
                            style: TextStyle(color: Colors.white70),
                          ),
                          SizedBox(height: 6),
                          Text(
                            decimal(widget.store.average),
                            style: TextStyle(
                              fontSize: 39,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 13,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        'A',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Text('Sangat Baik', style: TextStyle(fontSize: 10)),
                  ],
                ),
              ),
              SectionTitle(
                'Nilai per Mata Pelajaran',
                action: '${widget.store.grades.length} mapel',
              ),
              for (final g in widget.store.grades)
                SchoolCard(
                  child: Row(
                    children: [
                      IconTile(
                        Icons.menu_book_outlined,
                        color: g.color,
                        solid: true,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              g.subject,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Nilai akhir ${decimal(g.average)}',
                              style: TextStyle(
                                color: schoolMuted,
                                fontSize: 11,
                              ),
                            ),
                            SizedBox(height: 9),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: LinearProgressIndicator(
                                value: g.average / 100,
                                color: Color(0xFF3BA6F8),
                                backgroundColor: schoolBorder,
                                minHeight: 3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 10),
                      _score('UTS', g.uts),
                      SizedBox(width: 5),
                      _score('UAS', g.uas),
                    ],
                  ),
                ),
              Text(
                'Nilai akhir demo = (UTS + UAS) ÷ 2. Bobot resmi mengikuti kebijakan sekolah.',
                style: TextStyle(color: schoolMuted, fontSize: 11),
              ),
            ],
          ],
        ),
      ),
    ],
  );
  Widget _score(String label, int value) => Container(
    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    decoration: BoxDecoration(
      color: schoolBackground,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      children: [
        Text(label, style: TextStyle(fontSize: 9, color: schoolMuted)),
        Text(
          '$value',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ],
    ),
  );
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key, required this.store, required this.onLogout});
  final ParentDemoStore store;
  final VoidCallback onLogout;
  @override
  Widget build(BuildContext context) => ListView(
    padding: EdgeInsets.only(bottom: 24),
    children: [
      GradientPanel(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Profil',
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700),
                  ),
                ),
                IconButton(
                  tooltip: 'Edit profil',
                  onPressed: () => editProfile(context),
                  icon: Icon(Icons.edit_outlined, color: Colors.white),
                ),
              ],
            ),
            SizedBox(height: 15),
            CircleAvatar(
              radius: 43,
              backgroundColor: Colors.white24,
              child: Text(
                store.guardianName
                    .trim()
                    .split(RegExp(r'\s+'))
                    .take(2)
                    .map((s) => s[0])
                    .join()
                    .toUpperCase(),
                style: TextStyle(
                  fontSize: 27,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            SizedBox(height: 14),
            Text(
              store.guardianName,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 23, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 5),
            Text(
              'Wali Murid • ${store.childName}',
              style: TextStyle(color: Colors.white70),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
      Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            SchoolCard(
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.person_outline, color: schoolBlue),
                    title: Text(
                      'Nama',
                      style: TextStyle(color: schoolMuted, fontSize: 11),
                    ),
                    subtitle: Text(
                      store.guardianName,
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Divider(color: schoolBorder),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.mail_outline, color: schoolBlue),
                    title: Text(
                      'Email',
                      style: TextStyle(color: schoolMuted, fontSize: 11),
                    ),
                    subtitle: Text(
                      store.guardianEmail,
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 4),
            GradientPanel(
              child: Row(
                children: [
                  StudentAvatar(radius: 26),
                  SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ANAK TERHUBUNG',
                          style: TextStyle(fontSize: 10, color: Colors.white70),
                        ),
                        SizedBox(height: 5),
                        Text(
                          store.childName,
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          store.childDetails,
                          style: TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            SchoolCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _menu(
                    Icons.edit_outlined,
                    'Edit Profil',
                    () => editProfile(context),
                  ),
                  Divider(height: 1, color: schoolBorder),
                  _menu(
                    Icons.lock_outline,
                    'Ubah Kata Sandi',
                    () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(builder: (_) => PasswordPage()),
                    ),
                  ),
                  Divider(height: 1, color: schoolBorder),
                  _menu(Icons.logout, 'Keluar', () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text('Keluar dari demo?'),
                        content: Text(
                          'Perubahan profil disimpan di backend demo lokal.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: Text('Batal'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: Text('Keluar'),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      onLogout();
                    }
                  }, red: true),
                ],
              ),
            ),
            Text(
              'Profil demo disimpan pada backend lokal bersama.',
              style: TextStyle(fontSize: 11, color: schoolMuted),
            ),
          ],
        ),
      ),
    ],
  );
  Widget _menu(
    IconData icon,
    String label,
    VoidCallback onTap, {
    bool red = false,
  }) => ListTile(
    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 5),
    leading: IconTile(icon, color: red ? Colors.red : schoolBlue),
    title: Text(
      label,
      style: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 14,
        color: red ? Colors.red : schoolInk,
      ),
    ),
    trailing: Icon(Icons.chevron_right, color: schoolMuted),
    onTap: onTap,
  );
  Future<void> editProfile(BuildContext context) => showDialog<void>(
    context: context,
    builder: (_) => _EditProfileDialog(store: store),
  );
}

class _EditProfileDialog extends StatefulWidget {
  const _EditProfileDialog({required this.store});
  final ParentDemoStore store;
  @override
  State<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<_EditProfileDialog> {
  late final name = TextEditingController(text: widget.store.guardianName);
  late final email = TextEditingController(text: widget.store.guardianEmail);
  final form = GlobalKey<FormState>();
  @override
  void dispose() {
    name.dispose();
    email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text('Edit Profil'),
    content: SingleChildScrollView(
      child: Form(
        key: form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: name,
              maxLength: 80,
              decoration: InputDecoration(labelText: 'Nama'),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Nama wajib diisi' : null,
            ),
            SizedBox(height: 14),
            TextFormField(
              controller: email,
              maxLength: 120,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(labelText: 'Email'),
              validator: (v) =>
                  v == null ||
                      !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(v.trim())
                  ? 'Email tidak valid'
                  : null,
            ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: Text('Batal')),
      FilledButton(
        onPressed: () {
          if (form.currentState!.validate()) {
            widget.store.updateProfile(name.text, email.text);
            Navigator.pop(context);
          }
        },
        child: Text('Simpan'),
      ),
    ],
  );
}
