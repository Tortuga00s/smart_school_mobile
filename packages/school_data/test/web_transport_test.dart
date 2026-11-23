import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:school_data/demo_endpoint.dart';
import 'package:school_data/live_api.dart';
import 'package:school_data/src/json_http_transport.dart';

class TestTokens implements IdTokenProvider {
  @override
  Future<String> freshFirebaseIdToken() async => 'test-id-token';
  @override
  Future<void> signOut() async {}
}

void main() {
  test('Chrome default wins over Android user-agent platform', () {
    expect(
      demoApiUrl(isWeb: true, platform: TargetPlatform.android, override: ''),
      'http://127.0.0.1:8080',
    );
  });
  test('Android native retains emulator address', () {
    expect(
      demoApiUrl(isWeb: false, platform: TargetPlatform.android, override: ''),
      'http://10.0.2.2:8080',
    );
  });
  test('Windows native uses localhost and explicit address wins', () {
    expect(
      demoApiUrl(isWeb: false, platform: TargetPlatform.windows, override: ''),
      'http://127.0.0.1:8080',
    );
    expect(
      demoApiUrl(isWeb: true, override: ' http://192.168.1.8:8080 '),
      'http://192.168.1.8:8080',
    );
  });
  for (final method in ['GET', 'POST', 'PUT', 'OPTIONS']) {
    test(
      '$method uses portable http client with UTF8 and demo headers',
      () async {
        final transport = JsonHttpTransport(
          client: MockClient((request) async {
            expect(request.method, method);
            expect(request.headers['X-Demo-Role'], 'teacher');
            if (method == 'POST' || method == 'PUT')
              expect(jsonDecode(request.body)['name'], 'Siti — Guru');
            expect(request.headers.containsKey('Origin'), isFalse);
            return http.Response.bytes(
              utf8.encode('{"name":"Ahmad — hadir"}'),
              200,
            );
          }),
        );
        final result = await transport.request(
          method,
          Uri.parse('http://localhost/snapshot'),
          headers: {'X-Demo-Role': 'teacher'},
          body: method == 'POST' || method == 'PUT'
              ? {'name': 'Siti — Guru'}
              : null,
        );
        expect(result['name'], 'Ahmad — hadir');
        transport.close();
      },
    );
  }
  test('non-JSON errors preserve status and empty 204 is accepted', () async {
    final failed = JsonHttpTransport(
      client: MockClient((_) async => http.Response('Forbidden', 403)),
    );
    await expectLater(
      failed.request('GET', Uri.parse('http://localhost')),
      throwsA(
        isA<ApiResponseException>().having((e) => e.statusCode, 'status', 403),
      ),
    );
    failed.close();
    final empty = JsonHttpTransport(
      client: MockClient((_) async => http.Response('', 204)),
    );
    expect(
      await empty.request('OPTIONS', Uri.parse('http://localhost')),
      isEmpty,
    );
    empty.close();
  });
  test('full response timeout is retained', () async {
    final client = JsonHttpTransport(
      client: MockClient((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 30));
        return http.Response('{}', 200);
      }),
    );
    await expectLater(
      client.request(
        'GET',
        Uri.parse('http://localhost'),
        timeout: const Duration(milliseconds: 1),
      ),
      throwsA(isA<TimeoutException>()),
    );
    client.close();
  });
  test(
    'live adapter preserves Bearer token and POST body without dart io',
    () async {
      final api = LiveSchoolApi(
        baseUrl: Uri.parse('https://example.test'),
        tokens: TestTokens(),
        client: MockClient((req) async {
          expect(req.method, 'POST');
          expect(req.headers['Authorization'], 'Bearer test-id-token');
          expect(jsonDecode(req.body)['classId'], 'C01');
          return http.Response('{"id":"A_NEW"}', 201);
        }),
      );
      expect(
        (await api.createAssignment(
          teacherUid: 'T01',
          subjectId: 'S01',
          classId: 'C01',
          academicYearId: '2026',
        ))['id'],
        'A_NEW',
      );
      api.close();
      expect(
        () => LiveSchoolApi(
          baseUrl: Uri.parse('http://localhost'),
          tokens: TestTokens(),
        ),
        throwsArgumentError,
      );
    },
  );
}
