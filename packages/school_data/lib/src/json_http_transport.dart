import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiResponseException implements Exception {
  const ApiResponseException(this.statusCode, this.body);
  final int statusCode;
  final String body;
  @override
  String toString() => 'API $statusCode: $body';
}

/// Client() selects BrowserClient on Web and IOClient on native platforms.
/// Never set Host, Origin or Content-Length: the browser owns these headers.
class JsonHttpTransport {
  JsonHttpTransport({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;
  Future<Map<String, dynamic>> request(
    String method,
    Uri uri, {
    Map<String, String> headers = const {},
    Object? body,
    Duration timeout = const Duration(seconds: 15),
  }) async {
    final request = http.Request(method, uri);
    request.headers.addAll({'Accept': 'application/json', ...headers});
    if (body != null) {
      request.headers['Content-Type'] = 'application/json; charset=utf-8';
      request.bodyBytes = utf8.encode(jsonEncode(body));
    }
    final response = await _client
        .send(request)
        .then(http.Response.fromStream)
        .timeout(timeout);
    final text = utf8.decode(response.bodyBytes);
    if (response.statusCode >= 400) {
      throw ApiResponseException(response.statusCode, text);
    }
    if (text.isEmpty)
      return <String, dynamic>{}; // OPTIONS 204, if explicitly used
    return Map<String, dynamic>.from(jsonDecode(text));
  }

  void close() => _client.close();
}
