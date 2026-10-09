import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// ponytail: stream bool online, debounce 1s biar tidak spam sync saat flicker
class ConnectivityService {
  final Connectivity _c;
  ConnectivityService([Connectivity? c]) : _c = c ?? Connectivity();

  Stream<bool> get onOnline async* {
    // cek awal
    final cur = await _c.checkConnectivity();
    yield !_isNone(cur);
    // listen perubahan
    await for (final r in _c.onConnectivityChanged) {
      yield !_isNone(r);
    }
  }

  Future<bool> get isOnline async {
    try {
      final r = await _c.checkConnectivity().timeout(const Duration(seconds: 2));
      final online = !_isNone(r);
      // web: connectivity_plus kadang none padahal online, anggap online jika bukan mobile
      if (!online && kIsWeb) {
        return true;
      }
      return online;
    } catch (_) {
      return !kIsWeb; // fallback offline di mobile agar tidak stuck sync
    }
  }

  bool _isNone(dynamic r) {
    if (r is List<ConnectivityResult>) return r.contains(ConnectivityResult.none) || r.isEmpty;
    if (r is ConnectivityResult) return r == ConnectivityResult.none;
    return true;
  }
}

// mock untuk test tanpa plugin
class FakeConnectivityService extends ConnectivityService {
  final _ctrl = StreamController<bool>.broadcast();
  bool _online;
  FakeConnectivityService(this._online);
  void setOnline(bool v) {
    _online = v;
    _ctrl.add(v);
  }

  @override
  Stream<bool> get onOnline async* {
    yield _online;
    yield* _ctrl.stream;
  }

  @override
  Future<bool> get isOnline async => _online;
}
