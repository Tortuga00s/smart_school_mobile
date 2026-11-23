import 'package:school_data/demo_connection.dart';
// Keep original Material UI imports compatible with the uploaded project.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';

import 'app_state.dart';
import 'screens.dart';
import 'ui.dart';

class SmartSchoolAdminApp extends StatefulWidget {
  const SmartSchoolAdminApp({super.key});
  @override
  State<SmartSchoolAdminApp> createState() => _SmartSchoolAdminAppState();
}

class _SmartSchoolAdminAppState extends State<SmartSchoolAdminApp> {
  final store = SchoolStore();
  // Mulai langsung di dashboard agar review UI tidak memerlukan kredensial.
  // Logout memperlihatkan halaman login pratinjau yang TIDAK mengautentikasi.
  bool previewOpen = false;
  @override
  void dispose() {
    store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Smart School — Admin Windows (Demo)',
    debugShowCheckedModeBanner: false,
    theme: smartTheme(),
    home: DemoConnection(
      store: store,
      child: previewOpen
          ? AdminShell(
              store: store,
              onExit: () => setState(() => previewOpen = false),
            )
          : DemoLogin(onPreview: () => setState(() => previewOpen = true)),
    ),
  );
}

class AdminShell extends StatefulWidget {
  const AdminShell({super.key, required this.store, required this.onExit});
  final SchoolStore store;
  final VoidCallback onExit;
  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _NavItem {
  const _NavItem(this.label, this.icon, this.section);
  final String label;
  final IconData icon;
  final String section;
}

const _nav = <_NavItem>[
  _NavItem('Dashboard', Icons.dashboard_rounded, 'UMUM'),
  _NavItem('Manajemen Guru', Icons.co_present_rounded, 'DATA AKADEMIK'),
  _NavItem('Siswa & Wali', Icons.groups_rounded, 'DATA AKADEMIK'),
  _NavItem('Mapel & Kelas', Icons.auto_stories_rounded, 'DATA AKADEMIK'),
  _NavItem('Penugasan Guru', Icons.assignment_ind_rounded, 'OPERASIONAL'),
  _NavItem('Jadwal Mengajar', Icons.calendar_month_rounded, 'OPERASIONAL'),
  _NavItem('Monitoring Absensi', Icons.fact_check_rounded, 'OPERASIONAL'),
  _NavItem('Izin & Pengganti', Icons.event_busy_rounded, 'OPERASIONAL'),
  _NavItem('Persetujuan Wajah', Icons.verified_user_rounded, 'KEAMANAN'),
  _NavItem('Pengaturan & Audit', Icons.settings_rounded, 'KEAMANAN'),
];

class _AdminShellState extends State<AdminShell> {
  int selected = 0;
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.store,
    builder: (context, _) => LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 1000;
        return Scaffold(
          backgroundColor: C.light,
          drawer: compact
              ? Drawer(width: 270, child: _sidebar(mobile: true))
              : null,
          body: Row(
            children: [
              if (!compact) SizedBox(width: 260, child: _sidebar()),
              Expanded(
                child: Column(
                  children: [
                    _topbar(compact),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          compact ? 18 : 30,
                          28,
                          compact ? 18 : 30,
                          36,
                        ),
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1540),
                            child: _page(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    ),
  );

  Widget _page() {
    switch (selected) {
      case 0:
        return OverviewPage(
          store: widget.store,
          onNavigate: (i) => setState(() => selected = i),
        );
      case 1:
        return TeachersPage(store: widget.store);
      case 2:
        return StudentsPage(store: widget.store);
      case 3:
        return SubjectsClassesPage(store: widget.store);
      case 4:
        return AssignmentsPage(store: widget.store);
      case 5:
        return SchedulesPage(store: widget.store);
      case 6:
        return AttendancePage(store: widget.store);
      case 7:
        return LeavesPage(store: widget.store);
      case 8:
        return ConsentsPage(store: widget.store);
      case 9:
        return SettingsAuditPage(store: widget.store);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _sidebar({bool mobile = false}) => Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF123B76), Color(0xFF0E294E)],
      ),
    ),
    child: SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(23, 28, 16, 25),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .16),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.school_rounded,
                    color: Colors.white,
                    size: 27,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Smart School',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'ADMIN CONSOLE',
                        style: TextStyle(
                          color: Color(0xFFA7C7EE),
                          letterSpacing: 1.5,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                for (int i = 0; i < _nav.length; i++) ...[
                  if (i == 0 || _nav[i].section != _nav[i - 1].section)
                    Padding(
                      padding: EdgeInsets.fromLTRB(14, i == 0 ? 4 : 17, 10, 8),
                      child: Text(
                        _nav[i].section,
                        style: const TextStyle(
                          color: Color(0xFF8DAED6),
                          fontSize: 10,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  _sidebarLink(i, mobile),
                ],
              ],
            ),
          ),
          const Divider(color: Color(0xFF355378), height: 16),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 23),
            child: Column(
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 19,
                      backgroundColor: Color(0xFF2D74BC),
                      child: Icon(Icons.person_rounded, color: Colors.white),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Admin Demo',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Pratinjau tanpa login',
                            style: TextStyle(
                              color: Color(0xFFA7C7EE),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Keluar dari pratinjau',
                      onPressed: widget.onExit,
                      icon: const Icon(
                        Icons.logout_rounded,
                        color: Colors.white70,
                        size: 19,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
  Widget _sidebarLink(int index, bool mobile) {
    final isActive = selected == index;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: isActive ? const Color(0xFF226CBD) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {
            setState(() => selected = index);
            if (mobile) Navigator.of(context).maybePop();
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
            child: Row(
              children: [
                Icon(
                  _nav[index].icon,
                  color: isActive ? Colors.white : const Color(0xFFA9C2E0),
                  size: 20,
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Text(
                    _nav[index].label,
                    style: TextStyle(
                      color: isActive ? Colors.white : const Color(0xFFC1D4EA),
                      fontSize: 12,
                      fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                ),
                if (isActive)
                  Container(
                    height: 16,
                    width: 3,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _topbar(bool compact) {
    final now = DateTime.now();
    final date =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
    return Container(
      height: 79,
      padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 30),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: C.line)),
      ),
      child: Row(
        children: [
          if (compact)
            Builder(
              builder: (ctx) => IconButton(
                onPressed: () => Scaffold.of(ctx).openDrawer(),
                icon: const Icon(Icons.menu_rounded),
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _nav[selected].label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${widget.store.schoolName}  /  ${widget.store.academicYear}',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: C.muted, fontSize: 11),
                ),
              ],
            ),
          ),
          if (!compact) ...[
            const Icon(Icons.calendar_today_outlined, color: C.muted, size: 16),
            const SizedBox(width: 8),
            Text(date, style: const TextStyle(color: C.muted, fontSize: 12)),
            const SizedBox(width: 18),
          ],
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4E6),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Text(
              '●  DEMO',
              style: TextStyle(
                color: Color(0xFFA87423),
                fontWeight: FontWeight.w800,
                fontSize: 10,
              ),
            ),
          ),
          const SizedBox(width: 13),
          const CircleAvatar(
            radius: 18,
            backgroundColor: C.pale,
            child: Icon(Icons.person, color: C.blue, size: 19),
          ),
        ],
      ),
    );
  }
}

class DemoLogin extends StatelessWidget {
  const DemoLogin({super.key, required this.onPreview});
  final VoidCallback onPreview;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: Panel(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.school_rounded, size: 48, color: C.blue),
                const SizedBox(height: 14),
                const Text(
                  'Smart School',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
                ),
                const Text(
                  'Admin Windows',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: C.muted, fontSize: 13),
                ),
                const SizedBox(height: 25),
                const Text(
                  'W-01 · Login Admin',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Autentikasi akun belum terhubung pada versi ini. Tombol di bawah hanya membuka tampilan pratinjau dan bukan proses login.',
                  style: TextStyle(color: C.muted, fontSize: 12),
                ),
                const SizedBox(height: 19),
                const DemoNotice(),
                const SizedBox(height: 22),
                ElevatedButton.icon(
                  onPressed: onPreview,
                  icon: const Icon(Icons.visibility_outlined),
                  label: const Text('Buka Pratinjau Dashboard'),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Implementasi produksi: OIDC/Firebase Authentication + HTTPS API dengan verifikasi role di server.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: C.muted, fontSize: 11),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
