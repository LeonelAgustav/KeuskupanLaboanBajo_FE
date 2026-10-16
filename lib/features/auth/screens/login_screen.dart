import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../core/auth/token_storage.dart';
import '../../../core/theme.dart';

/// Layar login (UI_DESIGN.md §3.5).
/// Satu tombol "Masuk": login pertama butuh internet; setelah itu sesi diingat
/// 1 tahun (token BE), sehingga buka app berikutnya tanpa login lagi.
class LoginScreen extends StatefulWidget {
  final VoidCallback onSuccess;
  final TokenStorageI tokens;
  final String baseUrl;
  const LoginScreen({super.key, required this.onSuccess, required this.tokens, required this.baseUrl});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  Future<void> _login() async {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;
    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Email dan password wajib diisi');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await http
          .post(
            Uri.parse('${widget.baseUrl}/api/v1/auth/login'),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 15));
      if (!mounted) return;
      if (res.statusCode == 200) {
        final map = jsonDecode(res.body) as Map<String, dynamic>;
        final data = (map['data'] as Map<String, dynamic>?) ?? map;
        final access = (data['accessToken'] ?? data['access_token'] ?? data['token']) as String?;
        final refresh = (data['refreshToken'] ?? data['refresh_token']) as String?;
        if (access == null || access.isEmpty) {
          setState(() => _error = 'Format respons server tidak dikenal (tanpa token)');
        } else {
          await widget.tokens.saveTokens(accessToken: access, refreshToken: refresh ?? access);
          widget.onSuccess();
        }
      } else if (res.statusCode == 401 || res.statusCode == 403) {
        setState(() => _error = 'Email atau nama atau password salah');
      } else {
        setState(() => _error = 'Login gagal (HTTP ${res.statusCode})');
      }
    } catch (e) {
      if (!mounted) return;
      debugPrint('Login error: $e');
      final hasSession = await widget.tokens.hasValidRefreshToken();
      if (hasSession) {
        // sudah pernah login di HP ini: langsung masuk, jangan bingungkan awam
        widget.onSuccess();
      } else {
        setState(() => _error = 'Tidak ada koneksi internet. Login pertama harus dilakukan saat ada internet.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(24),
            children: [
              // Logo lingkaran gradient ungu→emas
              Center(
                child: SizedBox(
                  width: 96,
                  height: 96,
                  child: Image.asset('assets/icons/logo_1024.png', fit: BoxFit.contain),
                ),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text('Jurnal Keuangan Keuskupan', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: darkText)),
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(labelText: 'Email / Username', border: OutlineInputBorder(), prefixIcon: Icon(Icons.person_outline)),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _passwordCtrl,
                        obscureText: _obscure,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                            onPressed: () => setState(() => _obscure = !_obscure),
                          ),
                        ),
                        onSubmitted: (_) => _login(),
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                        onPressed: _loading ? null : _login,
                        child: _loading
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text('Masuk', style: TextStyle(fontSize: 16)),
                      ),
                      const SizedBox(height: 8),
                      if (_error != null) ...[
                        const SizedBox(height: 12),
                        Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13), textAlign: TextAlign.center),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
