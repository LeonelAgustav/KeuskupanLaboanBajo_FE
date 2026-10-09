import 'package:flutter/foundation.dart' show kIsWeb;

String resolveApiUrl() {
  const env = String.fromEnvironment('API_URL');
  if (env.isNotEmpty) return env;
  // fallback dev local HP+laptop satu WiFi; production harus via --dart-define=API_URL=https://...
  return kIsWeb ? 'http://localhost:8080' : 'http://10.39.50.129:8080';
}
