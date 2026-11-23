import 'package:http/http.dart' as http;

import 'src/json_http_transport.dart';

/// Contract for Firebase Android Auth / validated desktop OIDC token acquisition.
/// No demo identity or service-account secret is accepted here.
abstract interface class IdTokenProvider {
  Future<String> freshFirebaseIdToken();
  Future<void> signOut();
}

/// Integration foundation only; the demo UI does NOT instantiate this adapter.
class LiveSchoolApi {
  LiveSchoolApi({
    required this.baseUrl,
    required this.tokens,
    http.Client? client,
  }) : _client = JsonHttpTransport(client: client) {
    if (baseUrl.scheme != 'https')
      throw ArgumentError('Live API requires HTTPS');
  }
  final Uri baseUrl;
  final IdTokenProvider tokens;
  final JsonHttpTransport _client;
  Future<Map<String, dynamic>> _request(
    String method,
    String path, [
    Map<String, dynamic>? body,
  ]) async {
    final token = await tokens.freshFirebaseIdToken().timeout(
      const Duration(seconds: 15),
    );
    return _client.request(
      method,
      baseUrl.resolve(path),
      headers: {'Authorization': 'Bearer $token'},
      body: body,
      timeout: const Duration(seconds: 15),
    );
  }

  Future<Map<String, dynamic>> me() => _request('GET', '/v1/me');
  Future<Map<String, dynamic>> assignments() =>
      _request('GET', '/v1/assignments');
  Future<Map<String, dynamic>> createAssignment({
    required String teacherUid,
    required String subjectId,
    required String classId,
    required String academicYearId,
  }) => _request('POST', '/v1/assignments', {
    'teacherUid': teacherUid,
    'subjectId': subjectId,
    'classId': classId,
    'academicYearId': academicYearId,
  });
  void close() => _client.close();
}
