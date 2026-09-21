import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'jwt_helper.dart';

// ponytail: 1 class untuk access+refresh, sync pakai refresh offline
abstract class TokenStorageI {
  Future<void> saveTokens({required String accessToken, required String refreshToken});
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<bool> hasValidAccessToken();
  Future<bool> hasValidRefreshToken();
  Future<void> clear();
  Future<int?> getCurrentUserId(); // dari JWT payload
  Future<int?> getCurrentParokiId(); // dari JWT payload
}

class TokenStorage implements TokenStorageI {
  final FlutterSecureStorage _s;
  TokenStorage([FlutterSecureStorage? s]) : _s = s ?? const FlutterSecureStorage();

  static const _kAccess = 'access_token';
  static const _kRefresh = 'refresh_token';

  @override
  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    await _s.write(key: _kAccess, value: accessToken);
    await _s.write(key: _kRefresh, value: refreshToken);
  }

  @override
  Future<String?> getAccessToken() => _s.read(key: _kAccess);

  @override
  Future<String?> getRefreshToken() => _s.read(key: _kRefresh);

  @override
  Future<bool> hasValidAccessToken() async {
    final t = await getAccessToken();
    return t != null && JwtHelper.isValid(t);
  }

  @override
  Future<bool> hasValidRefreshToken() async {
    final t = await getRefreshToken();
    return t != null && JwtHelper.isValid(t);
  }

  @override
  Future<void> clear() async {
    await _s.delete(key: _kAccess);
    await _s.delete(key: _kRefresh);
  }

  @override
  Future<int?> getCurrentUserId() async {
    final t = await getAccessToken() ?? await getRefreshToken();
    if (t == null) return null;
    try {
      final payload = JwtHelper.decodePayload(t);
      final userId = payload['user_id'] ?? payload['sub'];
      return userId is int ? userId : int.tryParse(userId.toString());
    } catch (_) {
      return null;
    }
  }

  @override
  Future<int?> getCurrentParokiId() async {
    final t = await getAccessToken() ?? await getRefreshToken();
    if (t == null) return null;
    return JwtHelper.getParokiId(t);
  }
}

// untuk unit test tanpa platform channel
class InMemoryTokenStorage implements TokenStorageI {
  String? _access;
  String? _refresh;
  @override
  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    _access = accessToken;
    _refresh = refreshToken;
  }

  @override
  Future<String?> getAccessToken() async => _access;
  @override
  Future<String?> getRefreshToken() async => _refresh;
  @override
  Future<bool> hasValidAccessToken() async => _access != null && JwtHelper.isValid(_access!);
  @override
  Future<bool> hasValidRefreshToken() async => _refresh != null && JwtHelper.isValid(_refresh!);
  @override
  Future<void> clear() async {
    _access = null;
    _refresh = null;
  }
  @override
  Future<int?> getCurrentUserId() async {
    final t = _access ?? _refresh;
    if (t == null) return null;
    try {
      final payload = JwtHelper.decodePayload(t);
      final userId = payload['user_id'] ?? payload['sub'];
      return userId is int ? userId : int.tryParse(userId.toString());
    } catch (_) {
      return null;
    }
  }

  @override
  Future<int?> getCurrentParokiId() async {
    final t = _access ?? _refresh;
    if (t == null) return null;
    return JwtHelper.getParokiId(t);
  }
}
