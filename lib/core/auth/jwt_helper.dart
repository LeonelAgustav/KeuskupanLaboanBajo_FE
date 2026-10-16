import 'dart:convert';

// ponytail: decode JWT offline tanpa verify signature, cukup cek exp
// pakai base64Url, tidak perlu package tambahan
class JwtHelper {
  static Map<String, dynamic> decodePayload(String token) {
    final parts = token.split('.');
    if (parts.length != 3) throw FormatException('JWT harus 3 bagian');
    final payload = parts[1];
    final normalized = base64Url.normalize(payload);
    final decoded = utf8.decode(base64Url.decode(normalized));
    return jsonDecode(decoded) as Map<String, dynamic>;
  }

  static DateTime? getExpiry(String token) {
    try {
      final payload = decodePayload(token);
      final exp = payload['exp'];
      if (exp == null) return null;
      return DateTime.fromMillisecondsSinceEpoch((exp as int) * 1000);
    } catch (_) {
      return null;
    }
  }

  static bool isExpired(String token, {Duration leeway = Duration.zero}) {
    final exp = getExpiry(token);
    if (exp == null) return true;
    return DateTime.now().add(leeway).isAfter(exp);
  }

  static bool isValid(String token) {
    try {
      decodePayload(token);
      return !isExpired(token);
    } catch (_) {
      return false;
    }
  }

  static int? getParokiId(String token) {
    try {
      final payload = decodePayload(token);
      final pid = payload['paroki_id'];
      if (pid == null) return null;
      if (pid is int) return pid;
      if (pid is String) return int.tryParse(pid);
      return null;
    } catch (_) {
      return null;
    }
  }

  // helper buat test: bikin fake JWT (header.payload.signature) tanpa sign
  static String generateFakeJwt({required int expUnixSeconds, Map<String, dynamic>? extra}) {
    final header = base64Url.encode(utf8.encode(jsonEncode({"alg": "HS256", "typ": "JWT"}))).replaceAll('=', '');
    final payloadMap = {"sub": "test-user", "exp": expUnixSeconds, ...?extra};
    final payload = base64Url.encode(utf8.encode(jsonEncode(payloadMap))).replaceAll('=', '');
    const fakeSig = "fake_signature";
    return "$header.$payload.$fakeSig";
  }
}
