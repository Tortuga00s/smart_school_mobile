import copy
import json
import tempfile
import threading
import unittest
import urllib.request
import urllib.error
from pathlib import Path
from server import make_server, merge, view

class DemoApiTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.temp = tempfile.TemporaryDirectory()
        cls.path = Path(cls.temp.name) / 'state.json'
        cls.server = make_server(port=0, path=cls.path)
        cls.thread = threading.Thread(target=cls.server.serve_forever, daemon=True)
        cls.thread.start()
        cls.url = f'http://127.0.0.1:{cls.server.server_port}'
    @classmethod
    def tearDownClass(cls):
        cls.server.shutdown(); cls.server.server_close(); cls.temp.cleanup()
    def setUp(self):
        self.server.state = {'revision': 1, 'data': json.loads((Path(__file__).parent / 'seed.json').read_text())}
    def req(self, method, role='admin', uid='admin.demo', body=None):
        req = urllib.request.Request(self.url+'/snapshot', method=method, headers={'Content-Type':'application/json','X-Demo-Role':role,'X-Demo-Uid':uid}, data=json.dumps(body).encode() if body is not None else None)
        try:
            with urllib.request.urlopen(req) as res: return res.status, json.load(res)
        except urllib.error.HTTPError as e: return e.code, json.load(e)
    def test_admin_write_persists_and_stale_writer_gets_conflict(self):
        _, current = self.req('GET')
        current['data']['schoolName']='Sekolah Demo Updated'
        self.assertEqual(self.req('PUT',body=current)[0],200)
        self.assertEqual(self.req('PUT',body=current)[0],409)
        self.assertEqual(json.loads(self.path.read_text())['data']['schoolName'],'Sekolah Demo Updated')
    def test_identity_is_required(self):
        self.assertEqual(self.req('GET','teacher','admin.demo')[0],403)
    def test_parent_only_gets_linked_students(self):
        _, current=self.req('GET','parent','G01')
        self.assertEqual({s['id'] for s in current['data']['students']},{'ST01','ST05'})
        self.assertTrue(all(a['studentId'] in {'ST01','ST05'} for a in current['data']['attendance']))
        self.assertEqual(len(current['data']['guardians']),1)
    def test_teacher_cannot_change_master_data(self):
        _, current=self.req('GET','teacher','T01');current['data']['teachers'][0]['name']='Spoofed'
        self.assertEqual(self.req('PUT','teacher','T01',current)[0],403)
    def test_parent_cannot_change_attendance(self):
        _, current=self.req('GET','parent','G01');current['data']['attendance'][0]['status']='IZIN'
        self.assertEqual(self.req('PUT','parent','G01',current)[0],403)
    def test_teacher_cannot_submit_wrong_session(self):
        _, current=self.req('GET','teacher','T01')
        current['data']['attendance'].append({'id':'2026-11-16_SC02_ST01','studentId':'ST01','subjectId':'S02','classId':'C01','sessionCode':'2026-11-16_SC02','status':'HADIR','method':'MANUAL','time':'08:31'})
        self.assertEqual(self.req('PUT','teacher','T01',current)[0],403)
    def test_shared_flow_manual_attendance_to_parent_and_admin(self):
        _, current=self.req('GET','teacher','T01')
        session='2026-11-16_SC01'
        current['data']['sessionStates'][session]='OPEN'
        for sid in ['ST01','ST02','ST03']:
            current['data']['attendance'].append({'id':f'{session}_{sid}','studentId':sid,'subjectId':'S01','classId':'C01','sessionCode':session,'status':'BELUM_ABSEN','method':'-','time':'-'})
        status, current=self.req('PUT','teacher','T01',current);self.assertEqual(status,200)
        record=next(a for a in current['data']['attendance'] if a['id']==session+'_ST01')
        record.update(status='HADIR',method='MANUAL',time='07:15')
        status, current=self.req('PUT','teacher','T01',current);self.assertEqual(status,200)
        _, parent=self.req('GET','parent','G01')
        events=[e for e in parent['data']['events'] if e['sessionId']==session]
        self.assertEqual(len(events),1);self.assertEqual(events[0]['delivery'],'DEMO_INBOX_ONLY')
        # Same snapshot/status retry after a fresh read must not duplicate events.
        self.assertEqual(self.req('PUT','teacher','T01',current)[0],200)
        _, admin=self.req('GET')
        self.assertEqual(len([e for e in admin['data']['events'] if e['sessionId']==session]),1)
        self.assertEqual(next(a for a in admin['data']['attendance'] if a['id']==record['id'])['status'],'HADIR')
    def test_parent_profile_cannot_relink_child(self):
        _, current=self.req('GET','parent','G01');current['data']['students'][0]['guardianId']='G02'
        self.assertEqual(self.req('PUT','parent','G01',current)[0],403)
    def test_closed_session_rejects_teacher_change(self):
        self.server.state['data']['sessionStates']['2026-11-16_SC01']='CLOSED'
        _, current=self.req('GET','teacher','T01')
        current['data']['sessionStates']['2026-11-16_SC01']='OPEN'
        self.assertEqual(self.req('PUT','teacher','T01',current)[0],403)

if __name__ == '__main__': unittest.main()
