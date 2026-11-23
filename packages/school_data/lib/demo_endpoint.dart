import 'package:flutter/foundation.dart';

/// Check Web first: Chrome on an Android host must still use browser localhost.
/// Explicit --dart-define overrides the defaults on every platform.
String demoApiUrl({bool? isWeb, TargetPlatform? platform, String? override}) {
  final configured = override ?? const String.fromEnvironment('DEMO_API_URL');
  if (configured.trim().isNotEmpty) return configured.trim();
  if (isWeb ?? kIsWeb) return 'http://127.0.0.1:8080';
  return (platform ?? defaultTargetPlatform) == TargetPlatform.android
      ? 'http://10.0.2.2:8080'
      : 'http://127.0.0.1:8080';
}
