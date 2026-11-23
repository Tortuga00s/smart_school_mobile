import json
import tempfile
import threading
import unittest
import urllib.request
import urllib.error
from pathlib import Path
from server import make_server, allowed_origin

class CorsTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.temp = tempfile.TemporaryDirectory()
        cls.server = make_server(port=0, path=Path(cls.temp.name)/'state.json')
        cls.thread = threading.Thread(target=cls.server.serve_forever, daemon=True)
        cls.thread.start()
        cls.url = f'http://127.0.0.1:{cls.server.server_port}'
    @classmethod
    def tearDownClass(cls):
        cls.server.shutdown();cls.server.server_close();cls.temp.cleanup()
    def request(self, method, path='/snapshot', origin='http://localhost:7357', extra=None, body=None):
        headers={'Origin':origin, 'Content-Type':'application/json', 'X-Demo-Role':'admin','X-Demo-Uid':'admin.demo', **(extra or {})}
        req=urllib.request.Request(self.url+path,method=method,headers=headers,data=json.dumps(body).encode() if body else None)
        try:
            response=urllib.request.urlopen(req)
        except urllib.error.HTTPError as e:
            response=e
        with response:
            text=response.read()
            return response.status,response.headers, json.loads(text) if text else None
    def test_preflight_for_get_post_put_options(self):
        for method in ['GET','POST','PUT','OPTIONS']:
            with self.subTest(method=method):
                status,headers,_=self.request('OPTIONS',extra={'Access-Control-Request-Method':method,'Access-Control-Request-Headers':'content-type,x-demo-role,x-demo-uid'})
                self.assertEqual(status,204);self.assertEqual(headers['Access-Control-Allow-Origin'],'http://localhost:7357')
                self.assertIn(method,headers['Access-Control-Allow-Methods']);self.assertIsNone(headers.get('Access-Control-Allow-Credentials'))
    def test_get_put_post_keep_same_revision_and_role_rules(self):
        _,_,snapshot=self.request('GET')
        for method in ['PUT','POST']:
            status,headers,snapshot=self.request(method,body=snapshot)
            self.assertEqual(status,200);self.assertEqual(headers['Access-Control-Allow-Origin'],'http://localhost:7357')
    def test_cors_headers_on_json_error(self):
        status,headers,_=self.request('GET',extra={'X-Demo-Uid':'unknown'})
        self.assertEqual(status,403);self.assertEqual(headers['Access-Control-Allow-Origin'],'http://localhost:7357')
        status,headers,_=self.request('PUT',body={'revision':-1,'data':{}})
        self.assertEqual(status,409);self.assertEqual(headers['Access-Control-Allow-Origin'],'http://localhost:7357')
    def test_unknown_path_has_cors(self):
        status,headers,_=self.request('GET','/missing')
        self.assertEqual(status,404);self.assertIn('Origin',headers['Vary'])
        self.assertEqual(headers['Access-Control-Allow-Origin'],'http://localhost:7357')
    def test_reject_remote_origin_before_mutation(self):
        status,headers,_=self.request('POST',origin='https://example.test',body={'revision':1,'data':{}})
        self.assertEqual(status,403);self.assertIsNone(headers.get('Access-Control-Allow-Origin'))
    def test_reject_unexpected_preflight(self):
        for extra in [{'Access-Control-Request-Method':'DELETE'},{'Access-Control-Request-Headers':'x-secret'}]:
            self.assertEqual(self.request('OPTIONS',extra=extra)[0],403)
    def test_local_origin_validation(self):
        for origin in ['http://127.0.0.1:7357','http://localhost:5000','http://[::1]:7357']:
            self.assertTrue(allowed_origin(origin))
        for origin in ['null','https://localhost.evil.test','http://localhost@evil.test','http://localhost:bad','http://localhost/path','file://localhost']:
            self.assertFalse(allowed_origin(origin))

if __name__=='__main__':unittest.main()
