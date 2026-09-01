import 'package:flutter_test/flutter_test.dart';
import 'package:keuskupanlaboanbajo_fe/core/auth/jwt_helper.dart';

void main() {
  group('JWT offline - cek exp tanpa hit server', () {
    test('token valid 1 jam ke depan -> tidak expired', () {
      final exp = (DateTime.now().millisecondsSinceEpoch ~/ 1000) + 3600;
      final token = JwtHelper.generateFakeJwt(expUnixSeconds: exp);
      expect(JwtHelper.isExpired(token), false);
      expect(JwtHelper.isValid(token), true);
      expect(JwtHelper.getExpiry(token)!.isAfter(DateTime.now()), true);
    });

    test('token expired 1 jam lalu -> expired', () {
      final exp = (DateTime.now().millisecondsSinceEpoch ~/ 1000) - 3600;
      final token = JwtHelper.generateFakeJwt(expUnixSeconds: exp);
      expect(JwtHelper.isExpired(token), true);
      expect(JwtHelper.isValid(token), false);
    });

    test('token tanpa exp -> dianggap expired', () {
      final header = "eyJhbGciOiJIUzI1NiJ9";
      final payload = "eyJzdWIiOiIxMjMifQ"; // {"sub":"123"} tanpa exp
      final token = "$header.$payload.fake";
      expect(JwtHelper.isExpired(token), true);
      expect(JwtHelper.getExpiry(token), isNull);
    });

    test('token malformed -> isValid false', () {
      expect(JwtHelper.isValid("bukan.jwt"), false);
      expect(JwtHelper.isValid("a.b.c.d"), false);
    });

    test('leeway: token exp 5 detik lagi + leeway 10 detik -> anggap expired', () {
      final exp = (DateTime.now().millisecondsSinceEpoch ~/ 1000) + 5;
      final token = JwtHelper.generateFakeJwt(expUnixSeconds: exp);
      expect(JwtHelper.isExpired(token), false);
      expect(JwtHelper.isExpired(token, leeway: const Duration(seconds: 10)), true);
    });

    test('offline login flow: simpan token, cek offline tanpa internet', () {
      // simulasi login online -> dapat token 7 hari (refresh_token)
      final refreshExp = (DateTime.now().millisecondsSinceEpoch ~/ 1000) + 7 * 24 * 3600;
      final refreshToken = JwtHelper.generateFakeJwt(expUnixSeconds: refreshExp, extra: {"type": "refresh"});

      // offline: cek token lokal tanpa hit BE
      final canAccessOffline = JwtHelper.isValid(refreshToken);
      expect(canAccessOffline, true);

      // kalau access_token 15 menit sudah habis, tapi refresh masih valid -> bisa silent refresh nanti saat online
      final accessExp = (DateTime.now().millisecondsSinceEpoch ~/ 1000) - 60; // expired 1 menit lalu
      final accessToken = JwtHelper.generateFakeJwt(expUnixSeconds: accessExp);
      expect(JwtHelper.isValid(accessToken), false);
      expect(JwtHelper.isValid(refreshToken), true);
    });
  });
}

