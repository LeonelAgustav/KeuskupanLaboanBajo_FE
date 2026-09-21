import 'dart:convert';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme.dart';
import '../../../data/local/app_database.dart';
import '../cubit/jurnal_cubit.dart';

class JurnalFormScreen extends StatefulWidget {
  final List<Keuskupan> keuskupans;
  final JurnalCubit cubit;
  final JurnalPrefill? prefill;
  final Jurnal? jurnal; // untuk edit mode
  const JurnalFormScreen({super.key, required this.keuskupans, required this.cubit, this.prefill, this.jurnal});
  @override
  State<JurnalFormScreen> createState() => _JurnalFormScreenState();
}

/// Jenis transaksi di level jurnal (UI_DESIGN.md §3.2.2)
enum JenisTransaksi { pendapatan, pengeluaran }

class _DetilForm {
  int? akunId;
  int? parokiId;
  final nominalCtrl = TextEditingController();
  final ketCtrl = TextEditingController();
  JenisTransaksi jenis = JenisTransaksi.pendapatan; // default per detil
}

/// Data untuk tombol "Salin" dari detail jurnal (UI_DESIGN.md §7.3.12)
class JurnalPrefillDetil {
  final int akunId;
  final int parokiId;
  final double nominal;
  const JurnalPrefillDetil({required this.akunId, required this.parokiId, required this.nominal});
}

class JurnalPrefill {
  final int? keuskupanId;
  final String? deskripsi;
  final List<JurnalPrefillDetil> detils;
  const JurnalPrefill({this.keuskupanId, this.deskripsi, required this.detils});
}

String formatRibuan(double v) {
  final s = v.abs().toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  return '${v < 0 ? '-' : ''}$s';
}

/// Format angka jadi ribuan ber titik saat mengetik: 1000000 -> 1.000.000
class _RibuanFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return const TextEditingValue(text: '');
    final formatted = digits.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
    return TextEditingValue(text: formatted, selection: TextSelection.collapsed(offset: formatted.length));
  }
}

class _JurnalFormScreenState extends State<JurnalFormScreen> {
  final _formKey = GlobalKey<FormState>();
  static const _draftKey = 'jurnal_draft_v1';
  int? _keuskupanId;
  DateTime _tanggal = DateTime.now();
  final _deskripsiCtrl = TextEditingController();
  final _noBuktiCtrl = TextEditingController();
  bool _saving = false;
  List<Akun> _akuns = [];
  List<Paroki> _parokis = [];
  int? _userParokiId; // Jika login sebagai MEMBER, paroki otomatis ke-lock
  bool _loadingMaster = true;
  bool _applying = false;
  final List<_DetilForm> _detils = [];

  @override
  void initState() {
    super.initState();
    _deskripsiCtrl.addListener(_onAnyChange);
    _noBuktiCtrl.addListener(_onAnyChange);
    _addDetil(notify: false);
    _loadMaster();
  }

  void _addDetil({bool notify = true}) {
    final d = _DetilForm();
    if (_userParokiId != null && _userParokiId! > 0) {
      d.parokiId = _userParokiId;
    }
    d.nominalCtrl.addListener(_onAnyChange);
    _detils.add(d);
    if (notify) setState(() {});
  }

  void _onJenisChanged() {
    _onAnyChange();
  }

  void _removeDetil(int idx) {
    _detils.removeAt(idx);
    _onAnyChange();
  }

  /// Rebuild (untuk balanced check live) + auto-save draft
  void _onAnyChange() {
    if (!mounted || _applying) return;
    setState(() {});
    _saveDraft();
  }

  double _parseNomor(String t) => double.tryParse(t.replaceAll('.', '').trim()) ?? 0;

  bool get _isDirty =>
      _deskripsiCtrl.text.isNotEmpty ||
      _noBuktiCtrl.text.isNotEmpty ||
      _keuskupanId != null ||
      _detils.any((d) => d.akunId != null || d.parokiId != null || d.nominalCtrl.text.isNotEmpty);

  // ── Draft auto-save (SharedPreferences, key dibuang setelah simpan) ──
  Future<void> _saveDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_draftKey, jsonEncode({
      'keuskupanId': _keuskupanId,
      'tanggal': _tanggal.toIso8601String(),
      'deskripsi': _deskripsiCtrl.text,
      'noBukti': _noBuktiCtrl.text,
      'detils': [
        for (final d in _detils)
          {'akunId': d.akunId, 'parokiId': d.parokiId, 'nominal': d.nominalCtrl.text, 'jenis': d.jenis.name}
      ],
    }));
  }

  Future<void> _restoreDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_draftKey);
      if (raw == null) return;
      final map = jsonDecode(raw) as Map<String, dynamic>;
      _keuskupanId = map['keuskupanId'] as int?;
      _tanggal = DateTime.tryParse(map['tanggal'] as String? ?? '') ?? DateTime.now();
      _deskripsiCtrl.text = map['deskripsi'] as String? ?? '';
      _noBuktiCtrl.text = map['noBukti'] as String? ?? '';
      final detils = (map['detils'] as List?) ?? const [];
      _detils.clear();
      if (detils.isEmpty) {
        _addDetil(notify: false);
      } else {
        for (final d in detils) {
          final m = d as Map<String, dynamic>;
          _addDetil(notify: false);
          final f = _detils.last;
          f.akunId = m['akunId'] as int?;
          f.parokiId = m['parokiId'] as int?;
          f.nominalCtrl.text = m['nominal'] as String? ?? '';
          f.jenis = JenisTransaksi.values.byName(m['jenis'] as String? ?? 'pendapatan');
        }
      }
    } catch (_) {
      // draft korup: abaikan, mulai kosong
    }
  }

  Future<void> _clearDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_draftKey);
  }

  // No bukti otomatis: JB/2026/09/001 (UI_DESIGN.md §7.3.13), tetap bisa diedit
  Future<String> _generateNoBukti() async {
    final t = _tanggal;
    final start = DateTime(t.year, t.month).toIso8601String().substring(0, 10);
    final next = DateTime(t.year, t.month + 1).toIso8601String().substring(0, 10);
    final row = await widget.cubit.db.customSelect(
      'SELECT COUNT(*) as c FROM jurnals WHERE deleted_at IS NULL AND tanggal >= ? AND tanggal < ?',
      variables: [Variable.withString(start), Variable.withString(next)],
    ).getSingle();
    final n = (row.data['c'] as int) + 1;
    return 'JB/${t.year}/${t.month.toString().padLeft(2, '0')}/${n.toString().padLeft(3, '0')}';
  }

  Future<void> _loadMaster() async {
    // Jika edit mode, load jurnal data first
    if (widget.jurnal != null) {
      _applying = true;
      final j = widget.jurnal!;
      _keuskupanId = j.keuskupanId;
      _tanggal = j.tanggal;
      _deskripsiCtrl.text = j.deskripsi ?? '';
      _noBuktiCtrl.text = j.noBukti ?? '';
      
      // Load detils
      final detils = await widget.cubit.jurnalRepo.getDetils(j.id);
      _detils.clear();
      for (final d in detils) {
        _addDetil(notify: false);
        final f = _detils.last;
        f.akunId = d.akunId;
        f.parokiId = d.parokiId;
        final isPendapatan = (d.kredit ?? 0) > 0;
        f.jenis = isPendapatan ? JenisTransaksi.pendapatan : JenisTransaksi.pengeluaran;
        f.nominalCtrl.text = (isPendapatan ? (d.kredit ?? 0) : (d.debit ?? 0)) > 0 ? formatRibuan(isPendapatan ? (d.kredit ?? 0) : (d.debit ?? 0)) : '';
      }
    } else if (widget.prefill != null) {
      // Salin dari jurnal lain: prefill menang, draft lama tidak disentuh
      _applying = true;
      final p = widget.prefill!;
      _keuskupanId = p.keuskupanId ?? _keuskupanId;
      _deskripsiCtrl.text = p.deskripsi ?? '';
      _noBuktiCtrl.text = await _generateNoBukti();
      _detils.clear();
      for (final d in p.detils) {
        _addDetil(notify: false);
        final f = _detils.last;
        f.akunId = d.akunId;
        f.parokiId = d.parokiId;
        // prefill detil pakai nominal, default jenis pendapatan
        f.jenis = JenisTransaksi.pendapatan;
        f.nominalCtrl.text = d.nominal > 0 ? formatRibuan(d.nominal) : '';
      }
    } else {
      await _restoreDraft(); // draft di-restore sebelum build pertama form
      if (_noBuktiCtrl.text.isEmpty) _noBuktiCtrl.text = await _generateNoBukti();
    }
    _applying = false;
    final akuns = await widget.cubit.getAkuns();
    var parokis = await widget.cubit.getParokis();
    
    // Check if MEMBER, filter parokis and prefill detil
    final userPid = await widget.cubit.tokenStorage.getCurrentParokiId();
    if (userPid != null && userPid > 0) {
      _userParokiId = userPid;
      parokis = parokis.where((p) => p.id == userPid).toList();
      for (final d in _detils) {
        d.parokiId = userPid;
      }
    }

    setState(() {
      _akuns = akuns;
      _parokis = parokis;
      _loadingMaster = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final totalPendapatan = _detils
        .where((d) => d.jenis == JenisTransaksi.pendapatan)
        .fold<double>(0, (s, d) => s + _parseNomor(d.nominalCtrl.text));
    final totalPengeluaran = _detils
        .where((d) => d.jenis == JenisTransaksi.pengeluaran)
        .fold<double>(0, (s, d) => s + _parseNomor(d.nominalCtrl.text));
    final totalNominal = totalPendapatan + totalPengeluaran;
    final adaNominal = totalNominal > 0;
    final seimbang = totalPendapatan == totalPengeluaran && adaNominal;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (!_isDirty) {
          if (mounted) Navigator.pop(context, false);
          return;
        }
        final buang = await showDialog<bool>(
          context: context,
          builder: (dCtx) => AlertDialog(
            title: const Text('Buang perubahan?'),
            content: const Text('Perubahan sudah tersimpan sebagai draft lokal. Draft dibuang?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dCtx, false), child: const Text('Batal')),
              TextButton(onPressed: () => Navigator.pop(dCtx, true), child: const Text('Buang', style: TextStyle(color: Colors.red))),
            ],
          ),
        );
        if (buang == true && mounted) {
          await _clearDraft();
          if (mounted) Navigator.pop(context, false);
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(widget.jurnal != null ? 'Edit Jurnal' : 'Buat Jurnal Offline')),
        body: _loadingMaster
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (widget.keuskupans.isEmpty)
                      Card(
                        color: orangeKhas.withValues(alpha: 0.1),
                        child: const Padding(
                          padding: EdgeInsets.all(12),
                          child: Text('Belum ada Keuskupan. Tambahkan lewat menu Master dulu.'),
                        ),
                      ),
                    DropdownButtonFormField<int>(
                      initialValue: _keuskupanId,
                      decoration: const InputDecoration(labelText: 'Keuskupan *', border: OutlineInputBorder()),
                      items: widget.keuskupans.map((k) => DropdownMenuItem(value: k.id, child: Text(k.nama))).toList(),
                      onChanged: (v) {
                        _keuskupanId = v;
                        _onAnyChange();
                      },
                      validator: (v) => v == null ? 'Wajib pilih' : null,
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('Tanggal: ${_tanggal.toString().substring(0, 10)}'),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final d = await showDatePicker(context: context, initialDate: _tanggal, firstDate: DateTime(2020), lastDate: DateTime(2030));
                        if (d != null) {
                          _tanggal = d;
                          _onAnyChange();
                        }
                      },
                    ),
                    // Quick chips tanggal
                    Wrap(
                      spacing: 8,
                      children: [
                        ActionChip(
                          label: const Text('Hari ini'),
                          onPressed: () {
                            _tanggal = DateTime.now();
                            _onAnyChange();
                          },
                        ),
                        ActionChip(
                          label: const Text('Kemarin'),
                          onPressed: () {
                            _tanggal = DateTime.now().subtract(const Duration(days: 1));
                            _onAnyChange();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _deskripsiCtrl,
                      decoration: const InputDecoration(labelText: 'Deskripsi', border: OutlineInputBorder()),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _noBuktiCtrl,
                      decoration: const InputDecoration(labelText: 'No Bukti (unik)', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('Detil Jurnal *', style: TextStyle(fontWeight: FontWeight.bold)),
                        const Spacer(),
                        IconButton(icon: const Icon(Icons.add_circle, color: ungu), onPressed: () => _addDetil()),
                      ],
                    ),
                    const Text('Minimal 1 detil, pilih jenis & isi nominal per baris', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    const SizedBox(height: 8),
                    ..._detils.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final d = entry.value;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            children: [
                              Row(children: [
                                Text('Detil ${idx + 1}', style: const TextStyle(fontWeight: FontWeight.w600)),
                                const Spacer(),
                                if (_detils.length > 1) IconButton(icon: const Icon(Icons.delete, color: Colors.red, size: 20), onPressed: () => _removeDetil(idx)),
                              ]),
                              DropdownButtonFormField<int>(
                                initialValue: d.akunId,
                                decoration: const InputDecoration(labelText: 'Akun *', border: OutlineInputBorder(), isDense: true),
                                items: _akuns.map((a) => DropdownMenuItem(value: a.id, child: Text('${a.kode} - ${a.nama}'))).toList(),
                                onChanged: (v) {
                                  d.akunId = v;
                                  _onAnyChange();
                                },
                                validator: (v) => v == null ? 'Wajib' : null,
                              ),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<int>(
                                initialValue: d.parokiId,
                                decoration: const InputDecoration(labelText: 'Paroki *', border: OutlineInputBorder(), isDense: true),
                                items: _parokis.map((p) => DropdownMenuItem(value: p.id, child: Text(p.nama))).toList(),
                                onChanged: _userParokiId != null ? null : (v) {
                                  d.parokiId = v;
                                  _onAnyChange();
                                },
                                validator: (v) => v == null ? 'Wajib' : null,
                              ),
                              const SizedBox(height: 8),
                              // Per-detil jenis transaksi
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: SegmentedButton<JenisTransaksi>(
                                  segments: const [
                                    ButtonSegment(
                                      value: JenisTransaksi.pendapatan,
                                      label: Text('Pendapatan', style: TextStyle(fontSize: 12)),
                                      icon: Icon(Icons.arrow_upward, size: 14),
                                    ),
                                    ButtonSegment(
                                      value: JenisTransaksi.pengeluaran,
                                      label: Text('Pengeluaran', style: TextStyle(fontSize: 12)),
                                      icon: Icon(Icons.arrow_downward, size: 14),
                                    ),
                                  ],
                                  selected: {d.jenis},
                                onSelectionChanged: (s) {
                                  d.jenis = s.first;
                                  _onJenisChanged();
                                },
                              )),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: d.nominalCtrl,
                                decoration: InputDecoration(
                                  labelText: d.jenis == JenisTransaksi.pendapatan ? 'Jumlah Pendapatan' : 'Jumlah Pengeluaran',
                                  border: const OutlineInputBorder(),
                                  isDense: true,
                                  prefixText: 'Rp ',
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: [_RibuanFormatter()],
                                validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
                              ),
                            ],
                          ),
                        ),
                      );
                    }),

                    if (_akuns.isEmpty || _parokis.isEmpty)
                      Card(
                        color: orangeKhas.withValues(alpha: 0.1),
                        child: const Padding(
                          padding: EdgeInsets.all(8),
                          child: Text('Belum ada Akun/Paroki. Isi lewat menu Master dulu.', style: TextStyle(fontSize: 12)),
                        ),
                      ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(backgroundColor: kreditHijau, foregroundColor: Colors.white, minimumSize: const Size.fromHeight(48)),
                      icon: _saving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.save),
                      label: Text(_saving ? 'Menyimpan...' : (widget.jurnal != null ? 'Perbarui' : 'Simpan Offline')),
                      onPressed: _saving ? null : _save,
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  String _ribuan(double v) => formatRibuan(v);

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_detils.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Minimal 1 detil')));
      return;
    }
    for (final d in _detils) {
      if (d.akunId == null || d.parokiId == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lengkapi Akun & Paroki di semua detil')));
        return;
      }
      if (_parseNomor(d.nominalCtrl.text) == 0) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Isi Jumlah di semua detil')));
        return;
      }
    }
    setState(() => _saving = true);
    try {
      final detilsComp = _detils
          .map((d) {
            final nominal = _parseNomor(d.nominalCtrl.text);
            final isPendapatan = d.jenis == JenisTransaksi.pendapatan;
            return DetilJurnalsCompanion.insert(
              jurnalId: '',
              akunId: d.akunId!,
              parokiId: d.parokiId!,
              debit: Value(isPendapatan ? 0 : nominal),
              kredit: Value(isPendapatan ? nominal : 0),
              keterangan: const Value.absent(),
            );
          })
          .toList();
      
      if (widget.jurnal != null) {
        // Edit mode
        await widget.cubit.updateJurnal(
          id: widget.jurnal!.id,
          keuskupanId: _keuskupanId!,
          tanggal: _tanggal,
          deskripsi: _deskripsiCtrl.text.isEmpty ? null : _deskripsiCtrl.text,
          noBukti: _noBuktiCtrl.text.isEmpty ? null : _noBuktiCtrl.text,
          detils: detilsComp,
        );
        await _clearDraft();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Jurnal diperbarui ✓ (pending sync)'), backgroundColor: Colors.green));
      } else {
        // Create mode
        await widget.cubit.createJurnal(
          keuskupanId: _keuskupanId!,
          tanggal: _tanggal,
          deskripsi: _deskripsiCtrl.text.isEmpty ? null : _deskripsiCtrl.text,
          noBukti: _noBuktiCtrl.text.isEmpty ? null : _noBuktiCtrl.text,
          detils: detilsComp,
        );
        await _clearDraft();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Jurnal disimpan lokal ✓ (pending sync)'), backgroundColor: Colors.green));
      }
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _deskripsiCtrl.dispose();
    _noBuktiCtrl.dispose();
    for (final d in _detils) {
      d.nominalCtrl.dispose();
      d.ketCtrl.dispose();
    }
    super.dispose();
  }
}
