// Shared DTOs used by both Flutter applications.
class Teacher {
  Teacher(this.id, this.name, this.email, this.specialty, {this.active = true});
  final String id;
  String name;
  String email;
  String specialty;
  bool active;
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'specialty': specialty,
    'active': active,
  };
  factory Teacher.fromJson(Map<String, dynamic> j) => Teacher(
    j['id'] as String,
    j['name'] as String,
    j['email'] as String,
    j['specialty'] as String,
    active: j['active'] as bool,
  );
}

class Student {
  Student(
    this.id,
    this.name,
    this.nis,
    this.classId,
    this.guardianId, {
    this.active = true,
  });
  final String id;
  String name;
  String nis;
  String classId;
  String guardianId;
  bool active;
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'nis': nis,
    'classId': classId,
    'guardianId': guardianId,
    'active': active,
  };
  factory Student.fromJson(Map<String, dynamic> j) => Student(
    j['id'] as String,
    j['name'] as String,
    j['nis'] as String,
    j['classId'] as String,
    j['guardianId'] as String,
    active: j['active'] as bool,
  );
}

class Guardian {
  Guardian(this.id, this.name, this.phone, this.email);
  final String id;
  String name;
  String phone;
  String email;
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'email': email,
  };
  factory Guardian.fromJson(Map<String, dynamic> j) => Guardian(
    j['id'] as String,
    j['name'] as String,
    j['phone'] as String,
    j['email'] as String,
  );
}

class SchoolClass {
  SchoolClass(this.id, this.name, this.room);
  final String id;
  String name;
  String room;
  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'room': room};
  factory SchoolClass.fromJson(Map<String, dynamic> j) =>
      SchoolClass(j['id'] as String, j['name'] as String, j['room'] as String);
}

class Subject {
  Subject(this.id, this.name, this.code);
  final String id;
  String name;
  String code;
  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'code': code};
  factory Subject.fromJson(Map<String, dynamic> j) =>
      Subject(j['id'] as String, j['name'] as String, j['code'] as String);
}

class Assignment {
  Assignment(
    this.id,
    this.teacherId,
    this.subjectId,
    this.classId,
    this.academicYear, {
    this.active = true,
  });
  final String id;
  String teacherId;
  String subjectId;
  String classId;
  String academicYear;
  bool active;
  Map<String, dynamic> toJson() => {
    'id': id,
    'teacherId': teacherId,
    'subjectId': subjectId,
    'classId': classId,
    'academicYear': academicYear,
    'active': active,
  };
  factory Assignment.fromJson(Map<String, dynamic> j) => Assignment(
    j['id'] as String,
    j['teacherId'] as String,
    j['subjectId'] as String,
    j['classId'] as String,
    j['academicYear'] as String,
    active: j['active'] as bool,
  );
}

class LessonSchedule {
  LessonSchedule(
    this.id,
    this.assignmentId,
    this.weekday,
    this.startMinute,
    this.endMinute,
    this.room, {
    this.status = 'ACTIVE',
    this.substituteTeacherId,
  });
  final String id;
  String assignmentId;
  int weekday;
  int startMinute;
  int endMinute;
  String room;
  String status;
  String? substituteTeacherId;
  Map<String, dynamic> toJson() => {
    'id': id,
    'assignmentId': assignmentId,
    'weekday': weekday,
    'startMinute': startMinute,
    'endMinute': endMinute,
    'room': room,
    'status': status,
    'substituteTeacherId': substituteTeacherId,
  };
  factory LessonSchedule.fromJson(Map<String, dynamic> j) => LessonSchedule(
    j['id'] as String,
    j['assignmentId'] as String,
    j['weekday'] as int,
    j['startMinute'] as int,
    j['endMinute'] as int,
    j['room'] as String,
    status: j['status'] as String,
    substituteTeacherId: j['substituteTeacherId'] as String?,
  );
}

class Attendance {
  Attendance(
    this.id,
    this.studentId,
    this.subjectId,
    this.classId,
    this.sessionCode,
    this.status,
    this.method,
    this.time,
  );
  final String id;
  String studentId;
  String subjectId;
  String classId;
  String sessionCode;
  String status;
  String method;
  String time;
  Map<String, dynamic> toJson() => {
    'id': id,
    'studentId': studentId,
    'subjectId': subjectId,
    'classId': classId,
    'sessionCode': sessionCode,
    'status': status,
    'method': method,
    'time': time,
  };
  factory Attendance.fromJson(Map<String, dynamic> j) => Attendance(
    j['id'] as String,
    j['studentId'] as String,
    j['subjectId'] as String,
    j['classId'] as String,
    j['sessionCode'] as String,
    j['status'] as String,
    j['method'] as String,
    j['time'] as String,
  );
}

class LeaveRequest {
  LeaveRequest(
    this.id,
    this.teacherId,
    this.scheduleId,
    this.reason, {
    this.status = 'PENDING',
  });
  final String id;
  String teacherId;
  String scheduleId;
  String reason;
  String status;
  Map<String, dynamic> toJson() => {
    'id': id,
    'teacherId': teacherId,
    'scheduleId': scheduleId,
    'reason': reason,
    'status': status,
  };
  factory LeaveRequest.fromJson(Map<String, dynamic> j) => LeaveRequest(
    j['id'] as String,
    j['teacherId'] as String,
    j['scheduleId'] as String,
    j['reason'] as String,
    status: j['status'] as String,
  );
}

class Consent {
  Consent(this.studentId, this.guardianId, this.status, this.updatedAt);
  final String studentId;
  String guardianId;
  String status;
  String updatedAt;
  Map<String, dynamic> toJson() => {
    'studentId': studentId,
    'guardianId': guardianId,
    'status': status,
    'updatedAt': updatedAt,
  };
  factory Consent.fromJson(Map<String, dynamic> j) => Consent(
    j['studentId'] as String,
    j['guardianId'] as String,
    j['status'] as String,
    j['updatedAt'] as String,
  );
}

class AuditItem {
  AuditItem(this.when, this.actor, this.action, this.details);
  final String when;
  String actor;
  String action;
  String details;
  Map<String, dynamic> toJson() => {
    'when': when,
    'actor': actor,
    'action': action,
    'details': details,
  };
  factory AuditItem.fromJson(Map<String, dynamic> j) => AuditItem(
    j['when'] as String,
    j['actor'] as String,
    j['action'] as String,
    j['details'] as String,
  );
}
