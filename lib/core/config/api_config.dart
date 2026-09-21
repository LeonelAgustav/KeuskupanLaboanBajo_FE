import 'package:flutter/foundation.dart' show kIsWeb;

String resolveApiUrl() {
  const env = String.fromEnvironment('API_URL');
  if (env.isNotEmpty) return env;
  return kIsWeb ? 'http://localhost:8080' : 'http://10.39.59.170:8080';
}
