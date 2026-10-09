import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';

/// SQLCipher DB key management.
/// - Pertama run: generate 32 bytes acak -> simpan di flutter_secure_storage.
/// - Subsequent: load dari secure storage.
abstract class DbKeyServiceI {
  Future<String> getKey();
}

class DbKeyService implements DbKeyServiceI {
  final FlutterSecureStorage _storage;
  DbKeyService([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  static const _kKey = 'db_encryption_key';

  @override
  Future<String> getKey() async {
    final existing = await _storage.read(key: _kKey);
    if (existing != null && existing.isNotEmpty) return existing;

    // Generate 32 random bytes -> base64
    final rnd = Random.secure();
    final bytes = Uint8List.fromList(List.generate(32, (_) => rnd.nextInt(256)));
    final key = base64Encode(bytes);
    await _storage.write(key: _kKey, value: key);
    return key;
  }

  // helper: derive key dari password user (opsional, jika ingin user-provided)
  static String deriveKeyFromPassword(String password, String salt) {
    final bytes = utf8.encode('$password:$salt');
    final digest = sha256.convert(bytes);
    return base64Encode(digest.bytes);
  }
}

// for test without platform channel
class InMemoryDbKeyService implements DbKeyServiceI {
  String? _key;
  @override
  Future<String> getKey() async {
    if (_key != null) return _key!;
    final rnd = Random.secure();
    final bytes = Uint8List.fromList(List.generate(32, (_) => rnd.nextInt(256)));
    _key = base64Encode(bytes);
    return _key!;
  }
}
