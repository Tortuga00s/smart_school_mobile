import 'package:flutter/foundation.dart';

import 'dart:async';

import 'package:http/http.dart' as http;

import 'json_http_transport.dart';

// Data seed fiktif; runtime menggunakan demo API bersama, bukan Firebase produksi.
// Jangan gunakan sebagai penyimpanan data sekolah atau autentikasi produksi.
import 'models.dart';

class SchoolStore extends ChangeNotifier {
  SchoolStore({http.Client? client})
    : _http = JsonHttpTransport(client: client);
  final List<Teacher> teachers = [
    Teacher('T01', 'Ahmad Hidayat', 'ahmad@example.test', 'Matematika'),
    Teacher('T02', 'Siti Rahmawati', 'siti@example.test', 'IPA'),
    Teacher('T03', 'Budi Santoso', 'budi@example.test', 'Bahasa Indonesia'),
    Teacher('T04', 'Dina Permata', 'dina@example.test', 'Bahasa Inggris'),
    Teacher('T05', 'Rizal Pratama', 'rizal@example.test', 'IPS'),
  ];
  final List<Guardian> guardians = [
    Guardian('G01', 'Rina Andini', '081200000001', 'rina@example.test'),
    Guardian('G02', 'Dedi Saputra', '081200000002', 'dedi@example.test'),
    Guardian('G03', 'Maya Putri', '081200000003', 'maya@example.test'),
    Guardian('G04', 'Fajar Nugroho', '081200000004', 'fajar@example.test'),
  ];
  final List<SchoolClass> classes = [
    SchoolClass('C01', '8A', 'R. 201'),
    SchoolClass('C02', '8B', 'R. 202'),
    SchoolClass('C03', '9A', 'R. 301'),
  ];
  final List<Subject> subjects = [
    Subject('S01', 'Matematika', 'MTK'),
    Subject('S02', 'IPA', 'IPA'),
    Subject('S03', 'Bahasa Indonesia', 'BIN'),
    Subject('S04', 'Bahasa Inggris', 'BIG'),
    Subject('S05', 'IPS', 'IPS'),
  ];
  final List<Student> students = [
    Student('ST01', 'Ahmad Rizki', '2026001', 'C01', 'G01'),
    Student('ST02', 'Nadia Putri', '2026002', 'C01', 'G02'),
    Student('ST03', 'Raka Pratama', '2026003', 'C01', 'G03'),
    Student('ST04', 'Alya Safira', '2026004', 'C02', 'G04'),
    Student('ST05', 'Putra Wijaya', '2026005', 'C02', 'G01'),
    Student('ST06', 'Laras Anjani', '2026006', 'C03', 'G02'),
  ];
  final List<Assignment> assignments = [
    Assignment('A01', 'T01', 'S01', 'C01', '2026/2027'),
    Assignment('A02', 'T01', 'S01', 'C02', '2026/2027'),
    Assignment('A03', 'T02', 'S02', 'C01', '2026/2027'),
    Assignment('A04', 'T03', 'S03', 'C02', '2026/2027'),
    Assignment('A05', 'T04', 'S04', 'C03', '2026/2027'),
  ];
  final List<LessonSchedule> schedules = [
    LessonSchedule('SC01', 'A01', 1, 420, 510, 'R. 201'),
    LessonSchedule('SC02', 'A03', 1, 510, 600, 'R. 201'),
    LessonSchedule('SC03', 'A02', 1, 600, 690, 'R. 202'),
    LessonSchedule('SC04', 'A04', 2, 420, 510, 'R. 202'),
    LessonSchedule('SC05', 'A05', 3, 510, 600, 'R. 301'),
  ];
  final List<Attendance> attendance = [
    Attendance(
      'AT01',
      'ST01',
      'S01',
      'C01',
      'SESI-MTK-8A-01',
      'HADIR',
      'WAJAH',
      '07:15',
    ),
    Attendance(
      'AT02',
      'ST02',
      'S01',
      'C01',
      'SESI-MTK-8A-01',
      'TERLAMBAT',
      'MANUAL',
      '07:32',
    ),
    Attendance(
      'AT03',
      'ST03',
      'S01',
      'C01',
      'SESI-MTK-8A-01',
      'BELUM_ABSEN',
      '-',
      '-',
    ),
    Attendance(
      'AT04',
      'ST04',
      'S03',
      'C02',
      'SESI-BIN-8B-01',
      'IZIN',
      'MANUAL',
      '07:06',
    ),
    Attendance(
      'AT05',
      'ST05',
      'S03',
      'C02',
      'SESI-BIN-8B-01',
      'HADIR',
      'WAJAH',
      '07:10',
    ),
  ];
  final List<LeaveRequest> leaveRequests = [
    LeaveRequest('LV01', 'T02', 'SC02', 'Pemeriksaan kesehatan'),
    LeaveRequest('LV02', 'T04', 'SC05', 'Kegiatan dinas sekolah'),
  ];
  final List<Consent> consents = [
    Consent('ST01', 'G01', 'DISETUJUI', '01 Nov 2026'),
    Consent('ST02', 'G02', 'DISETUJUI', '01 Nov 2026'),
    Consent('ST03', 'G03', 'BELUM_ADA', '-'),
    Consent('ST04', 'G04', 'DICABUT', '10 Nov 2026'),
    Consent('ST05', 'G01', 'DISETUJUI', '01 Nov 2026'),
    Consent('ST06', 'G02', 'BELUM_ADA', '-'),
  ];
  final List<AuditItem> audits = [
    AuditItem(
      '16 Nov 2026 · 07:32',
      'admin.demo',
      'Status sesi',
      'Contoh riwayat perubahan data demo',
    ),
    AuditItem(
      '16 Nov 2026 · 07:15',
      'guru.demo',
      'Absensi',
      'Contoh absensi siswa per sesi Matematika 8A',
    ),
  ];

  String schoolName = 'SMP Smart School';
  String academicYear = '2026/2027';
  int deadlineMinutes = 15;
  int retentionDays = 60;
  final List<String> holidays = ['25 Des 2026'];
  int _serial = 100;
  String nextId(String prefix) => '$prefix${_serial++}';

  Teacher teacher(String id) => teachers.firstWhere((t) => t.id == id);
  Subject subject(String id) => subjects.firstWhere((s) => s.id == id);
  SchoolClass schoolClass(String id) => classes.firstWhere((c) => c.id == id);
  Student student(String id) => students.firstWhere((s) => s.id == id);
  Guardian guardian(String id) => guardians.firstWhere((g) => g.id == id);
  Assignment assignment(String id) => assignments.firstWhere((a) => a.id == id);
  LessonSchedule schedule(String id) => schedules.firstWhere((s) => s.id == id);

  String className(String id) => schoolClass(id).name;
  String subjectName(String id) => subject(id).name;
  String teacherName(String id) => teacher(id).name;
  String timeOf(int minutes) =>
      '${(minutes ~/ 60).toString().padLeft(2, '0')}:${(minutes % 60).toString().padLeft(2, '0')}';
  String dayName(int d) => const [
    '',
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ][d];

  void record(String action, String detail) {
    final d = DateTime.now();
    audits.insert(
      0,
      AuditItem(
        '${d.day}/${d.month}/${d.year} ${timeOf(d.hour * 60 + d.minute)}',
        'admin.demo',
        action,
        detail,
      ),
    );
    notifyListeners();
    unawaited(save());
  }

  void addTeacher(String name, String email, String specialty) {
    teachers.add(Teacher(nextId('T'), name, email, specialty));
    record('Tambah guru', name);
  }

  void editTeacher(
    Teacher teacher,
    String name,
    String email,
    String specialty,
  ) {
    teacher.name = name;
    teacher.email = email;
    teacher.specialty = specialty;
    record('Perbarui guru', '${teacher.id}: $name');
  }

  void toggleTeacher(Teacher teacher) {
    teacher.active = !teacher.active;
    record(
      'Status guru',
      '${teacher.name}: ${teacher.active ? 'aktif' : 'nonaktif'}',
    );
  }

  void addGuardian(String name, String phone, String email) {
    guardians.add(Guardian(nextId('G'), name, phone, email));
    record('Tambah wali', name);
  }

  void editGuardian(
    Guardian guardian,
    String name,
    String phone,
    String email,
  ) {
    guardian.name = name;
    guardian.phone = phone;
    guardian.email = email;
    record('Perbarui wali', '${guardian.id}: $name');
  }

  void addStudent(String name, String nis, String classId, String guardianId) {
    students.add(Student(nextId('ST'), name, nis, classId, guardianId));
    consents.add(Consent(students.last.id, guardianId, 'BELUM_ADA', '-'));
    record('Tambah siswa', '$name ($nis)');
  }

  void editStudent(Student student, String name, String nis, String classId) {
    student.name = name;
    student.nis = nis;
    student.classId = classId;
    record(
      'Perbarui siswa',
      '${student.id}: $name, $nis, ${className(classId)}',
    );
  }

  void toggleStudent(Student student) {
    student.active = !student.active;
    record(
      'Status siswa',
      '${student.name}: ${student.active ? 'aktif' : 'nonaktif'}',
    );
  }

  void addSubject(String name, String code) {
    subjects.add(Subject(nextId('S'), name, code));
    record('Tambah mapel', '$name ($code)');
  }

  void editSubject(Subject subject, String name, String code) {
    subject.name = name;
    subject.code = code;
    record('Perbarui pelajaran', '${subject.id}: $name ($code)');
  }

  void editClass(SchoolClass schoolClass, String name, String room) {
    schoolClass.name = name;
    schoolClass.room = room;
    record('Perbarui kelas', '${schoolClass.id}: $name ($room)');
  }

  void addClass(String name, String room) {
    classes.add(SchoolClass(nextId('C'), name, room));
    record('Tambah kelas', '$name · $room');
  }

  bool hasAssignment(String tid, String sid, String cid) => assignments.any(
    (a) =>
        a.active &&
        a.teacherId == tid &&
        a.subjectId == sid &&
        a.classId == cid &&
        a.academicYear == academicYear,
  );
  void addAssignment(String tid, String sid, String cid) {
    if (hasAssignment(tid, sid, cid))
      throw StateError('Penugasan aktif sudah ada');
    assignments.add(Assignment(nextId('A'), tid, sid, cid, academicYear));
    record(
      'Penugasan guru',
      '${teacherName(tid)} · ${subjectName(sid)} · ${className(cid)}',
    );
  }

  void toggleAssignment(Assignment a) {
    a.active = !a.active;
    record('Status penugasan', '${a.id}: ${a.active ? 'aktif' : 'nonaktif'}');
  }

  // Bentrok kelas, guru aktual, ataupun ruang. Rentang [mulai, selesai).
  String? scheduleConflict(
    String aid,
    int day,
    int start,
    int end,
    String room, {
    String? ignoreId,
  }) {
    final candidate = assignment(aid);
    for (final sc in schedules) {
      if (sc.id == ignoreId || sc.status == 'CANCELLED' || sc.weekday != day)
        continue;
      if (!(start < sc.endMinute && sc.startMinute < end)) continue;
      final other = assignment(sc.assignmentId);
      if (other.classId == candidate.classId)
        return 'Bentrok kelas ${className(candidate.classId)} dengan ${sc.id}.';
      if ((sc.substituteTeacherId ?? other.teacherId) == candidate.teacherId)
        return 'Guru memiliki jadwal lain (${sc.id}).';
      if (room.toLowerCase().trim() == sc.room.toLowerCase().trim())
        return 'Ruangan $room digunakan (${sc.id}).';
    }
    return null;
  }

  void addSchedule(String aid, int day, int start, int end, String room) {
    if (start < 0 ||
        end > 1440 ||
        start >= end ||
        day < 1 ||
        day > 7 ||
        room.trim().isEmpty)
      throw ArgumentError('Rentang jadwal tidak valid');
    final conflict = scheduleConflict(aid, day, start, end, room);
    if (conflict != null) throw StateError(conflict);
    schedules.add(LessonSchedule(nextId('SC'), aid, day, start, end, room));
    record(
      'Jadwal aktif',
      '${assignment(aid).id} · ${dayName(day)} ${timeOf(start)}–${timeOf(end)}',
    );
  }

  void cancelSchedule(LessonSchedule sc, String reason) {
    sc.status = 'CANCELLED';
    record(
      'Jadwal dibatalkan',
      '${sc.id} · alasan: $reason. Demo: tidak mengirim FCM.',
    );
  }

  void substitute(LessonSchedule sc, String teacherId, String reason) {
    sc.substituteTeacherId = teacherId;
    record('Guru pengganti', '${sc.id} · ${teacherName(teacherId)} · $reason');
  }

  void updateAttendance(Attendance a, String status, String reason) {
    final before = a.status;
    a.status = status;
    a.method = 'KOREKSI_ADMIN';
    addEvent(a);
    record(
      'Koreksi absensi',
      '${student(a.studentId).name} · ${a.sessionCode} · $before → $status · $reason',
    );
  }

  void decideLeave(LeaveRequest request, String status) {
    request.status = status;
    record(
      'Izin guru',
      '${teacherName(request.teacherId)} · $status · ${request.reason}',
    );
  }

  void setConsent(Consent c, String status, String reason) {
    final before = c.status;
    c.status = status;
    c.updatedAt =
        '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}';
    record(
      'Persetujuan biometrik',
      '${student(c.studentId).name} · $before → $status · $reason (demo tanpa template biometrik)',
    );
  }

  void updateSettings(String name, int deadline, int retention) {
    schoolName = name;
    deadlineMinutes = deadline;
    retentionDays = retention;
    record(
      'Pengaturan sekolah',
      'Nama sekolah, deadline: $deadline menit, retensi: $retention hari (demo).',
    );
  }

  void addHoliday(String date) {
    holidays.add(date);
    record('Tambah kalender libur', date);
  }

  final Map<String, String> sessionStates = {};
  final List<Map<String, dynamic>> events = [];
  final Map<String, Map<String, int>> grades = {};
  String? connectionError;
  bool saving = false;
  int revision = 0;
  Timer? _poll;
  String? _url;
  String demoRole = 'admin';
  String demoUid = 'admin.demo';
  bool loaded = false;
  bool _disposed = false;
  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  final JsonHttpTransport _http;
  Future<dynamic> request(String method, String path, [Object? body]) {
    if (_url == null) throw StateError('Alamat API demo belum diatur');
    return _http.request(
      method,
      Uri.parse('$_url$path'),
      headers: {'X-Demo-Role': demoRole, 'X-Demo-Uid': demoUid},
      body: body,
      timeout: const Duration(seconds: 5),
    );
  }

  Future<void> connect(String url) async {
    _url = url;
    try {
      await refresh();
      _poll ??= Timer.periodic(const Duration(seconds: 2), (_) {
        if (!saving) refresh();
      });
    } catch (e) {
      connectionError = 'Backend demo tidak terhubung: $e';
    }
    notifyListeners();
  }

  Future<void> refresh() async {
    try {
      final data = await request('GET', '/snapshot');
      if (!saving && data['revision'] >= revision) {
        if (!loaded || revision != data['revision']) {
          load(data['data']);
          revision = data['revision'];
          loaded = true;
        }
        connectionError = null;
        notifyListeners();
      }
    } catch (e) {
      connectionError = '$e';
      notifyListeners();
    }
  }

  Future<void> save() async {
    if (_url == null) return; // unit test / seed export only
    if (saving) return;
    saving = true;
    try {
      final data = await request('PUT', '/snapshot', {
        'revision': revision,
        'data': toJson(),
      });
      revision = data['revision'];
      if (data['data'] != null) load(Map<String, dynamic>.from(data['data']));
      connectionError = null;
    } catch (e) {
      connectionError = 'Perubahan gagal disimpan; data dimuat ulang. $e';
      saving = false;
      final message = connectionError;
      loaded = false;
      await refresh();
      connectionError = message;
    } finally {
      saving = false;
      notifyListeners();
    }
  }

  List<LessonSchedule> teacherSchedules(String uid) =>
      (!teacher(uid).active ? <LessonSchedule>[] : schedules)
          .where(
            (sc) =>
                sc.status != 'CANCELLED' &&
                assignment(sc.assignmentId).active &&
                (sc.substituteTeacherId ??
                        assignment(sc.assignmentId).teacherId) ==
                    uid,
          )
          .toList();
  String sessionId(LessonSchedule sc) =>
      '${DateTime.now().toIso8601String().substring(0, 10)}_${sc.id}';
  void openSession(LessonSchedule sc, String teacherUid) {
    if (!teacherSchedules(teacherUid).contains(sc))
      throw StateError('Akses sesi ditolak');
    final id = sessionId(sc);
    if (sessionStates.containsKey(id)) return;
    sessionStates[id] = 'OPEN';
    final a = assignment(sc.assignmentId);
    for (final st in students.where(
      (s) => s.classId == a.classId && s.active,
    )) {
      attendance.add(
        Attendance(
          '${id}_${st.id}',
          st.id,
          a.subjectId,
          a.classId,
          id,
          'BELUM_ABSEN',
          '-',
          '-',
        ),
      );
    }
    record('Buka sesi', '$teacherUid · $id');
  }

  void markAttendance(
    Attendance a,
    String status,
    String reason,
    String teacherUid,
  ) {
    if (!{
      'HADIR',
      'TERLAMBAT',
      'IZIN',
      'SAKIT',
      'TIDAK_HADIR',
    }.contains(status))
      throw ArgumentError('Status tidak valid');
    final sc = schedules.firstWhere((sc) => sessionId(sc) == a.sessionCode);
    if (!teacherSchedules(teacherUid).contains(sc) ||
        sessionStates[a.sessionCode] != 'OPEN')
      throw StateError('Sesi tidak aktif / akses ditolak');
    if (reason.trim().isEmpty) throw ArgumentError('Alasan wajib');
    final before = a.status;
    if (before == status) return;
    a.status = status;
    a.method = 'MANUAL';
    a.time = timeOf(DateTime.now().hour * 60 + DateTime.now().minute);
    addEvent(a);
    record(
      'Absensi manual',
      '$teacherUid · ${a.id} · $before → $status · $reason',
    );
  }

  void addEvent(Attendance a) {
    final revision = events.where((e) => e['attendanceId'] == a.id).length + 1;
    events.insert(0, {
      'id': '${a.id}_$revision',
      'attendanceId': a.id,
      'studentId': a.studentId,
      'guardianId': student(a.studentId).guardianId,
      'sessionId': a.sessionCode,
      'subject': subjectName(a.subjectId),
      'status': a.status,
      'time': DateTime.now().toIso8601String(),
      'delivery': 'DEMO_INBOX_ONLY',
      'read': false,
    });
  }

  void closeSession(LessonSchedule sc, String uid) {
    if (!teacherSchedules(uid).contains(sc)) throw StateError('Akses ditolak');
    final id = sessionId(sc);
    if (attendance.any((a) => a.sessionCode == id && a.status == 'BELUM_ABSEN'))
      throw StateError('Tinjau seluruh siswa sebelum menutup sesi');
    sessionStates[id] = 'CLOSED';
    record('Tutup sesi', '$uid · $id');
  }

  void inputGrade(String uid, String sid, String subjectId, int uts, int uas) {
    final st = student(sid);
    if (!assignments.any(
      (a) =>
          a.active &&
          a.teacherId == uid &&
          a.classId == st.classId &&
          a.subjectId == subjectId,
    ))
      throw StateError('Akses nilai ditolak');
    if (uts < 0 || uts > 100 || uas < 0 || uas > 100)
      throw ArgumentError('Nilai 0–100');
    grades['${sid}_$subjectId'] = {'uts': uts, 'uas': uas};
    record('Input nilai', '$uid · $sid · $subjectId');
  }

  @override
  void dispose() {
    _disposed = true;
    _poll?.cancel();
    _http.close();
    super.dispose();
  }

  Map<String, dynamic> toJson() => {
    'teachers': teachers.map((e) => e.toJson()).toList(),
    'students': students.map((e) => e.toJson()).toList(),
    'guardians': guardians.map((e) => e.toJson()).toList(),
    'classes': classes.map((e) => e.toJson()).toList(),
    'subjects': subjects.map((e) => e.toJson()).toList(),
    'assignments': assignments.map((e) => e.toJson()).toList(),
    'schedules': schedules.map((e) => e.toJson()).toList(),
    'attendance': attendance.map((e) => e.toJson()).toList(),
    'leaveRequests': leaveRequests.map((e) => e.toJson()).toList(),
    'consents': consents.map((e) => e.toJson()).toList(),
    'audits': audits.map((e) => e.toJson()).toList(),
    'schoolName': schoolName,
    'academicYear': academicYear,
    'deadlineMinutes': deadlineMinutes,
    'retentionDays': retentionDays,
    'holidays': holidays,
    'serial': _serial,
    'sessionStates': sessionStates,
    'events': events,
    'grades': grades,
  };
  void load(Map<String, dynamic> j) {
    teachers
      ..clear()
      ..addAll(
        (j['teachers'] as List).map(
          (e) => Teacher.fromJson(Map<String, dynamic>.from(e)),
        ),
      );
    students
      ..clear()
      ..addAll(
        (j['students'] as List).map(
          (e) => Student.fromJson(Map<String, dynamic>.from(e)),
        ),
      );
    guardians
      ..clear()
      ..addAll(
        (j['guardians'] as List).map(
          (e) => Guardian.fromJson(Map<String, dynamic>.from(e)),
        ),
      );
    classes
      ..clear()
      ..addAll(
        (j['classes'] as List).map(
          (e) => SchoolClass.fromJson(Map<String, dynamic>.from(e)),
        ),
      );
    subjects
      ..clear()
      ..addAll(
        (j['subjects'] as List).map(
          (e) => Subject.fromJson(Map<String, dynamic>.from(e)),
        ),
      );
    assignments
      ..clear()
      ..addAll(
        (j['assignments'] as List).map(
          (e) => Assignment.fromJson(Map<String, dynamic>.from(e)),
        ),
      );
    schedules
      ..clear()
      ..addAll(
        (j['schedules'] as List).map(
          (e) => LessonSchedule.fromJson(Map<String, dynamic>.from(e)),
        ),
      );
    attendance
      ..clear()
      ..addAll(
        (j['attendance'] as List).map(
          (e) => Attendance.fromJson(Map<String, dynamic>.from(e)),
        ),
      );
    leaveRequests
      ..clear()
      ..addAll(
        (j['leaveRequests'] as List).map(
          (e) => LeaveRequest.fromJson(Map<String, dynamic>.from(e)),
        ),
      );
    consents
      ..clear()
      ..addAll(
        (j['consents'] as List).map(
          (e) => Consent.fromJson(Map<String, dynamic>.from(e)),
        ),
      );
    audits
      ..clear()
      ..addAll(
        (j['audits'] as List).map(
          (e) => AuditItem.fromJson(Map<String, dynamic>.from(e)),
        ),
      );

    schoolName = j['schoolName'];
    academicYear = j['academicYear'];
    deadlineMinutes = j['deadlineMinutes'];
    retentionDays = j['retentionDays'];
    _serial = j['serial'];
    holidays
      ..clear()
      ..addAll(List<String>.from(j['holidays']));
    sessionStates
      ..clear()
      ..addAll(Map<String, String>.from(j['sessionStates'] ?? {}));
    events
      ..clear()
      ..addAll(
        (j['events'] as List? ?? []).map((e) => Map<String, dynamic>.from(e)),
      );
    grades.clear();
    (j['grades'] as Map? ?? {}).forEach(
      (k, v) => grades[k] = Map<String, int>.from(v),
    );
  }
}
