"""LOCAL DEMO ONLY: fictional data, spoofable demo identities, never expose publicly.
No Firebase/FCM, no photos, no passwords. Shared snapshot with optimistic revisions.
"""
import argparse
import copy
import json
import os
import threading
from datetime import datetime, timezone
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import urlsplit

HERE = Path(__file__).resolve().parent
LOCK = threading.Lock()
IDENTITIES = {'admin': {'admin.demo'}, 'teacher': {'T01', 'T02'}, 'parent': {'G01'}}

def allowed_students(data, role, uid):
    if role == 'admin':
        return {s['id'] for s in data['students']}
    if role == 'parent':
        return {s['id'] for s in data['students'] if s['guardianId'] == uid}
    aids = {a['id'] for a in data['assignments'] if a['active'] and a['teacherId'] == uid}
    aids |= {s['assignmentId'] for s in data['schedules'] if s.get('substituteTeacherId') == uid}
    cids = {a['classId'] for a in data['assignments'] if a['id'] in aids}
    return {s['id'] for s in data['students'] if s['classId'] in cids}

def teacher_schedule_ids(data, uid):
    assignments = {a['id']: a for a in data['assignments']}
    return {s['id'] for s in data['schedules'] if s['status'] != 'CANCELLED'
            and assignments[s['assignmentId']]['active']
            and (s.get('substituteTeacherId') or assignments[s['assignmentId']]['teacherId']) == uid}

def view(data, role, uid):
    out = copy.deepcopy(data)
    if role == 'admin':
        return out
    ids = allowed_students(data, role, uid)
    for key in ['students', 'attendance', 'consents']:
        out[key] = [x for x in out[key] if (x['id'] if key == 'students' else x['studentId']) in ids]
    out['guardians'] = [x for x in out['guardians'] if role == 'parent' and x['id'] == uid]
    out['events'] = [x for x in out['events'] if x['studentId'] in ids]
    out['grades'] = {k: v for k, v in out['grades'].items() if k.split('_')[0] in ids}
    out['audits'] = []
    out['leaveRequests'] = [x for x in out['leaveRequests'] if x['teacherId'] == uid] if role == 'teacher' else []
    if role == 'teacher':
        schedule_ids = teacher_schedule_ids(data, uid)
        out['sessionStates'] = {k: v for k, v in out['sessionStates'].items() if k.split('_')[-1] in schedule_ids}
    return out

def merge(data, incoming, role, uid):
    before = view(data, role, uid)
    if set(incoming) != set(before):
        raise ValueError('Schema snapshot tidak cocok')
    changed = {k for k in before if incoming[k] != before[k]}
    permitted = set(before) if role == 'admin' else ({'attendance', 'sessionStates', 'events', 'audits', 'grades', 'leaveRequests', 'serial'} if role == 'teacher' else {'guardians', 'audits'})
    if changed - permitted:
        raise PermissionError('Operasi administratif ditolak')
    result = copy.deepcopy(data)
    if role == 'admin':
        result = copy.deepcopy(incoming)
    elif role == 'parent':
        if len(incoming['guardians']) != 1 or incoming['guardians'][0]['id'] != uid:
            raise PermissionError('Profil wali tidak valid')
        original = next(g for g in before['guardians'] if g['id'] == uid)
        updated = incoming['guardians'][0]
        if set(updated) != set(original) or updated['phone'] != original['phone'] or not updated['name'].strip() or '@' not in updated['email']:
            raise ValueError('Hanya nama dan email profil yang dapat diubah')
        result['guardians'] = [updated if g['id'] == uid else g for g in data['guardians']]
    else:
        ids = allowed_students(data, role, uid)
        schedules = teacher_schedule_ids(data, uid)
        def valid_session(session):
            return session.split('_')[-1] in schedules and len(session.split('_')) == 2
        old = {a['id']: a for a in before['attendance']}
        new = {a['id']: a for a in incoming['attendance']}
        if not old.keys() <= new.keys() or len(new) != len(incoming['attendance']):
            raise ValueError('Absensi tidak dapat dihapus / duplikat')
        for key, a in new.items():
            if a == old.get(key):
                continue
            scid = a['sessionCode'].split('_')[-1]
            if a['studentId'] not in ids or not valid_session(a['sessionCode']) or a['id'] != a['sessionCode'] + '_' + a['studentId']:
                raise PermissionError('Siswa atau sesi bukan penugasan guru')
            sc = next(s for s in data['schedules'] if s['id'] == scid)
            assignment = next(x for x in data['assignments'] if x['id'] == sc['assignmentId'])
            student = next(x for x in data['students'] if x['id'] == a['studentId'])
            if a['classId'] != assignment['classId'] or student['classId'] != a['classId'] or a['subjectId'] != assignment['subjectId']:
                raise PermissionError('Relasi sesi tidak valid')
            if data['sessionStates'].get(a['sessionCode']) == 'CLOSED':
                raise PermissionError('Sesi sudah ditutup')
            if a['status'] not in {'BELUM_ABSEN', 'HADIR', 'TERLAMBAT', 'IZIN', 'SAKIT', 'TIDAK_HADIR'} or a['method'] not in {'-', 'MANUAL'}:
                raise ValueError('Status/metode demo tidak valid')
        for session, state in incoming['sessionStates'].items():
            if state == before['sessionStates'].get(session):
                continue
            if not valid_session(session) or state not in {'OPEN', 'CLOSED'} or before['sessionStates'].get(session) == 'CLOSED':
                raise PermissionError('Perubahan sesi ditolak')
            if state == 'CLOSED' and any(a['sessionCode'] == session and a['status'] == 'BELUM_ABSEN' for a in new.values()):
                raise ValueError('Siswa belum ditinjau')
        if not before['sessionStates'].keys() <= incoming['sessionStates'].keys():
            raise ValueError('Sesi tidak dapat dihapus')
        result['attendance'] = [a for a in data['attendance'] if a['studentId'] not in ids] + list(new.values())
        result['sessionStates'].update(incoming['sessionStates'])
        for key, grade in incoming['grades'].items():
            if grade == before['grades'].get(key):
                continue
            sid, subject = key.split('_')
            st = next(x for x in data['students'] if x['id'] == sid)
            if not any(a['active'] and a['teacherId'] == uid and a['classId'] == st['classId'] and a['subjectId'] == subject for a in data['assignments']):
                raise PermissionError('Nilai bukan penugasan guru')
            if set(grade) != {'uts', 'uas'} or any(type(n) is not int or not 0 <= n <= 100 for n in grade.values()):
                raise ValueError('Nilai 0–100')
            result['grades'][key] = grade
        old_leaves = {x['id']: x for x in before['leaveRequests']}
        new_leaves = {x['id']: x for x in incoming['leaveRequests']}
        if not old_leaves.keys() <= new_leaves.keys():
            raise ValueError('Laporan tidak dapat dihapus')
        for key, item in new_leaves.items():
            if key in old_leaves:
                if item != old_leaves[key]:
                    raise PermissionError('Hanya admin menyetujui laporan')
            elif item['teacherId'] != uid or item['scheduleId'] not in schedules or item['status'] != 'PENDING' or not item['reason'].strip():
                raise PermissionError('Laporan tidak valid')
            else:
                result['leaveRequests'].append(item)
        result['serial'] = max(data['serial'], incoming['serial'])
    # Server derives attendance inbox events, never trusts client-supplied notifications.
    previous = {a['id']: a for a in data['attendance']}
    result['events'] = copy.deepcopy(data['events'])
    for a in result['attendance']:
        prior = previous.get(a['id'])
        if (prior or {}).get('status') == a['status'] or a['status'] == 'BELUM_ABSEN':
            continue
        revision = len([e for e in result['events'] if e['attendanceId'] == a['id']]) + 1
        student = next(s for s in result['students'] if s['id'] == a['studentId'])
        subject = next(s for s in result['subjects'] if s['id'] == a['subjectId'])
        result['events'].insert(0, {'id': f"{a['id']}_{revision}", 'attendanceId': a['id'], 'studentId': a['studentId'], 'guardianId': student['guardianId'], 'sessionId': a['sessionCode'], 'subject': subject['name'], 'status': a['status'], 'time': datetime.now(timezone.utc).isoformat(), 'delivery': 'DEMO_INBOX_ONLY', 'read': False})
    if changed:
        result['audits'] = copy.deepcopy(data['audits'])
        result['audits'].insert(0, {'when': datetime.now(timezone.utc).isoformat(), 'actor': f'{role}:{uid}', 'action': 'Demo API mutation', 'details': json.dumps({'changed': sorted(changed), 'clientNote': (incoming['audits'][0]['details'] if incoming['audits'] else ''), 'attendanceBefore': data['attendance'] if 'attendance' in changed else [], 'attendanceAfter': result['attendance'] if 'attendance' in changed else []})})
    return result

# Local Flutter origins may use an ephemeral dev/test port. No wildcard or cookies.
CORS_METHODS = {'GET', 'POST', 'PUT', 'OPTIONS'}
CORS_HEADERS = {'accept', 'content-type', 'authorization', 'x-demo-role', 'x-demo-uid'}
def allowed_origin(origin):
    try:
        url = urlsplit(origin)
        return (url.scheme in {'http', 'https'}
                and url.hostname in {'localhost', '127.0.0.1', '::1'}
                and not url.username and not url.password
                and not url.path and not url.query and not url.fragment
                and (url.port is None or 0 < url.port < 65536))
    except ValueError:
        return False

class Handler(BaseHTTPRequestHandler):
    server_version = 'SmartSchoolDemo/2'
    def cors_headers(self):
        origin = self.headers.get('Origin')
        self.send_header('Vary', 'Origin, Access-Control-Request-Method, Access-Control-Request-Headers')
        if origin and allowed_origin(origin):
            self.send_header('Access-Control-Allow-Origin', origin)
            self.send_header('Access-Control-Allow-Methods', 'GET, POST, PUT, OPTIONS')
            self.send_header('Access-Control-Allow-Headers', 'Accept, Content-Type, Authorization, X-Demo-Role, X-Demo-Uid')
            self.send_header('Access-Control-Max-Age', '600')
    def check_origin(self):
        origin = self.headers.get('Origin')
        if origin and not allowed_origin(origin):
            self.respond(403, {'error': 'Origin is not a permitted local Flutter origin'})
            return False
        return True
    def do_OPTIONS(self):
        if not self.check_origin():
            return
        if self.path not in {'/health', '/snapshot'}:
            return self.respond(404, {'error': 'Not found'})
        method = self.headers.get('Access-Control-Request-Method', 'GET').upper()
        headers = {h.strip().lower() for h in self.headers.get('Access-Control-Request-Headers', '').split(',') if h.strip()}
        if method not in CORS_METHODS or headers - CORS_HEADERS:
            return self.respond(403, {'error': 'Preflight method/headers not allowed'})
        self.send_response(204)
        self.cors_headers()
        self.send_header('Content-Length', '0')
        self.end_headers()

    def respond(self, status, body):
        payload = json.dumps(body).encode()
        self.send_response(status)
        self.cors_headers()
        self.send_header('Content-Type', 'application/json')
        self.send_header('Content-Length', str(len(payload)))
        self.end_headers()
        self.wfile.write(payload)
    def identity(self):
        role, uid = self.headers.get('X-Demo-Role'), self.headers.get('X-Demo-Uid')
        if uid not in IDENTITIES.get(role, set()):
            raise PermissionError('Identitas demo tidak valid; bukan autentikasi produksi')
        return role, uid
    def do_GET(self):
        if not self.check_origin():
            return
        if self.path == '/health':
            return self.respond(200, {'mode': 'DEMO_LOCAL_ONLY', 'firebase': False, 'fcm': False})
        if self.path != '/snapshot':
            return self.respond(404, {'error': 'Not found'})
        try:
            role, uid = self.identity()
            with LOCK:
                self.respond(200, {'revision': self.server.state['revision'], 'data': view(self.server.state['data'], role, uid)})
        except PermissionError as e:
            self.respond(403, {'error': str(e)})
    def do_POST(self):
        # Alias for the same revision-checked snapshot mutation; no role bypass.
        self.write_snapshot()
    def do_PUT(self):
        self.write_snapshot()
    def write_snapshot(self):
        if not self.check_origin():
            return
        if self.path != '/snapshot':
            return self.respond(404, {'error': 'Not found'})
        try:
            role, uid = self.identity()
            length = int(self.headers.get('Content-Length', 0))
            if not 0 < length <= 2_000_000:
                return self.respond(413, {'error': 'Ukuran snapshot ditolak'})
            payload = json.loads(self.rfile.read(length))
            with LOCK:
                if payload['revision'] != self.server.state['revision']:
                    return self.respond(409, {'error': 'Konflik revisi. Muat ulang dan ulangi perubahan.'})
                data = merge(self.server.state['data'], payload['data'], role, uid)
                updated = {'revision': self.server.state['revision'] + 1, 'data': data}
                temp = self.server.path.with_suffix('.tmp')
                temp.write_text(json.dumps(updated, indent=2), encoding='utf-8')
                os.replace(temp, self.server.path)
                self.server.state = updated
                self.respond(200, {'revision': updated['revision'], 'data': view(data, role, uid)})
        except PermissionError as e:
            self.respond(403, {'error': str(e)})
        except (ValueError, KeyError, TypeError, StopIteration) as e:
            self.respond(400, {'error': str(e)})

def make_server(host='127.0.0.1', port=8080, path=None):
    path = Path(path or HERE / 'demo-state.json')
    state = json.loads(path.read_text(encoding='utf-8')) if path.exists() else {'revision': 1, 'data': json.loads((HERE / 'seed.json').read_text(encoding='utf-8'))}
    server = ThreadingHTTPServer((host, port), Handler)
    server.state, server.path = state, path
    return server

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--host', default='127.0.0.1')
    parser.add_argument('--port', type=int, default=8080)
    parser.add_argument('--state', help='Path penyimpanan demo opsional')
    args = parser.parse_args()
    print(f'DEMO LOCAL ONLY http://{args.host}:{args.port} — data fiktif, tanpa Firebase/FCM', flush=True)
    make_server(args.host, args.port, args.state).serve_forever()
