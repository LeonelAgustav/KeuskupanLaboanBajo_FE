import 'dart:convert';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme.dart';
import '../../../core/widgets/akun_picker.dart';
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

/// Satu baris input double-entry: debit vs kredit + nominal (UI_DESIGN.md §3.2.2)
class _DetilForm {
  int? akunDebitId;
  int? akunKreditId;
  final nominalCtrl = TextEditingController();
  final ketCtrl = TextEditingController();
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
  static const _draftKey = 'jurnal_draft_v2'; // v1 pakai skema jenis/akunId, tidak kompatibel
  int? _keuskupanId;
  DateTime _tanggal = DateTime.now();
  final _deskripsiCtrl = TextEditingController();
  final _noBuktiCtrl = TextEditingController();
  String _jenisPembatasan = 'Tanpa Pembatasan';
  bool _saving = false;
  List<Akun> _akuns = [];
  List<Paroki> _parokis = [];
  int? _userParokiId; // Jika login sebagai MEMBER, paroki otomatis ke-lock
  int? _parokiId; // paroki level-jurnal (DB wajib non-null per detil)
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
    d.nominalCtrl.addListener(_onAnyChange);
    d.ketCtrl.addListener(_onAnyChange);
    _detils.add(d);
    if (notify) setState(() {});
  }

  /// Rebuild (untuk balanced check live) + auto-save draft
  void _onAnyChange() {
    if (!mounted || _applying) return;
    setState(() {});
    _saveDraft();
  }

  /// Akun picker: bottom sheet lazy ListView (ganti DropdownMenu yang lag saat search).
  Widget _akunField({
    required Key key,
    required String label,
    required int? selectedId,
    required void Function(int? id) onSelected,
    required String? Function() validator,
  }) {
    final selected = _akuns.where((a) => a.id == selectedId).toList();
    return AkunPickerButton(
      key: key,
      akuns: _akuns,
      selected: selected.isEmpty ? null : selected.first,
      label: label,
      errorText: validator(),
      onChanged: (a) {
        onSelected(a.id);
        _onAnyChange();
      },
    );
  }

  double _parseNomor(String t) => double.tryParse(t.replaceAll('.', '').trim()) ?? 0;

  bool get _isDirty =>
      _deskripsiCtrl.text.isNotEmpty ||
      _noBuktiCtrl.text.isNotEmpty ||
      _keuskupanId != null ||
      _parokiId != null ||
      _detils.any((d) => d.akunDebitId != null || d.akunKreditId != null || d.nominalCtrl.text.isNotEmpty || d.ketCtrl.text.isNotEmpty);

  // ── Draft auto-save (SharedPreferences, key dibuang setelah simpan) ──
  Future<void> _saveDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_draftKey, jsonEncode({
      'keuskupanId': _keuskupanId,
      'parokiId': _parokiId,
      'tanggal': _tanggal.toIso8601String(),
      'deskripsi': _deskripsiCtrl.text,
      'noBukti': _noBuktiCtrl.text,
      'jenisPembatasan': _jenisPembatasan,
      'detils': [
        for (final d in _detils)
          {
            'akunDebitId': d.akunDebitId,
            'akunKreditId': d.akunKreditId,
            'nominal': d.nominalCtrl.text,
            'keterangan': d.ketCtrl.text,
          }
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
      _parokiId = map['parokiId'] as int?;
      _tanggal = DateTime.tryParse(map['tanggal'] as String? ?? '') ?? DateTime.now();
      _deskripsiCtrl.text = map['deskripsi'] as String? ?? '';
      _noBuktiCtrl.text = map['noBukti'] as String? ?? '';
      _jenisPembatasan = map['jenisPembatasan'] as String? ?? 'Tanpa Pembatasan';
      final detils = (map['detils'] as List?) ?? const [];
      _detils.clear();
      if (detils.isEmpty) {
        _addDetil(notify: false);
      } else {
        for (final d in detils) {
          final m = d as Map<String, dynamic>;
          _addDetil(notify: false);
          final f = _detils.last;
          f.akunDebitId = m['akunDebitId'] as int?;
          f.akunKreditId = m['akunKreditId'] as int?;
          f.nominalCtrl.text = m['nominal'] as String? ?? '';
          f.ketCtrl.text = m['keterangan'] as String? ?? '';
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
      _jenisPembatasan = j.jenisPembatasan;
      
      final detils = await widget.cubit.jurnalRepo.getDetils(j.id);
      if (detils.isNotEmpty) _parokiId = detils.first.parokiId;
      _detils.clear();
      for (var i = 0; i < detils.length;) {
        final a = detils[i];
        if (a.jumlah != null || (a.akunDebitId != null && a.akunKreditId != null)) {
          _addDetil(notify: false);
          final f = _detils.last;
          f.akunDebitId = a.akunDebitId;
          f.akunKreditId = a.akunKreditId;
          f.nominalCtrl.text = a.jumlah != null && a.jumlah! > 0 ? formatRibuan(a.jumlah!) : '';
          f.ketCtrl.text = a.keterangan ?? '';
          i++;
          continue;
        }
        final b = i + 1 < detils.length ? detils[i + 1] : null;
        final aDebit = (a.debit ?? 0) > 0;
        final deb = aDebit ? a : b;
        final kre = aDebit ? b : a;
        _addDetil(notify: false);
        final f = _detils.last;
        f.akunDebitId = deb?.akunId;
        f.akunKreditId = kre?.akunId;
        final nominal = aDebit ? (a.debit ?? 0) : (a.kredit ?? 0);
        f.nominalCtrl.text = nominal > 0 ? formatRibuan(nominal) : '';
        f.ketCtrl.text = a.keterangan ?? '';
        i += 2;
      }
      if (_detils.isEmpty) _addDetil(notify: false);
    } else if (widget.prefill != null) {
      // Salin dari jurnal lain: prefill menang, draft lama tidak disentuh
      _applying = true;
      final p = widget.prefill!;
      _keuskupanId = p.keuskupanId ?? _keuskupanId;
      _deskripsiCtrl.text = p.deskripsi ?? '';
      _noBuktiCtrl.text = await _generateNoBukti();
      if (p.detils.isNotEmpty) _parokiId = p.detils.first.parokiId;
      _detils.clear();
      // shortcut: prefill tak bawa sisi debit/kredit, asumsi urutan simpan (debit, kredit); ubah JurnalPrefillDetil bila perlu akurat
      for (var i = 0; i < p.detils.length; i += 2) {
        _addDetil(notify: false);
        final f = _detils.last;
        f.akunDebitId = p.detils[i].akunId;
        f.akunKreditId = i + 1 < p.detils.length ? p.detils[i + 1].akunId : null;
        final nominal = p.detils[i].nominal;
        f.nominalCtrl.text = nominal > 0 ? formatRibuan(nominal) : '';
      }
      if (_detils.isEmpty) _addDetil(notify: false);
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
      _parokiId = userPid;
      // MEMBER: keuskupan dikunci -> auto-set dari paroki
      if (parokis.isNotEmpty) _keuskupanId = parokis.first.keuskupanId;
    }

    setState(() {
      _akuns = akuns;
      _parokis = parokis;
      _loadingMaster = false;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                      isExpanded: true,
                      initialValue: _keuskupanId,
                      decoration: InputDecoration(
                        labelText: 'Keuskupan *',
                        border: const OutlineInputBorder(),
                        helperText: _userParokiId != null ? 'Keuskupan terkunci untuk akun MEMBER' : null,
                        helperStyle: const TextStyle(fontSize: 11, color: orangeKhas),
                      ),
                      items: widget.keuskupans.map((k) => DropdownMenuItem(value: k.id, child: Text(k.nama))).toList(),
                      onChanged: _userParokiId != null ? null : (v) {
                        _keuskupanId = v;
                        _onAnyChange();
                      },
                      validator: (v) => v == null ? 'Wajib pilih' : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      isExpanded: true,
                      initialValue: _parokiId,
                      decoration: InputDecoration(
                        labelText: 'Paroki *',
                        border: const OutlineInputBorder(),
                        helperText: _userParokiId != null ? 'Paroki terkunci untuk akun MEMBER' : null,
                        helperStyle: const TextStyle(fontSize: 11, color: orangeKhas),
                      ),
                      items: _parokis.map((p) => DropdownMenuItem(value: p.id, child: Text(p.nama))).toList(),
                      onChanged: _userParokiId != null ? null : (v) {
                        _parokiId = v;
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

                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _deskripsiCtrl,
                      decoration: const InputDecoration(labelText: 'Keterangan Transaksi', border: OutlineInputBorder()),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _jenisPembatasan,
                      decoration: const InputDecoration(labelText: 'Jenis Pembatasan *', border: OutlineInputBorder()),
                      items: const [
                        DropdownMenuItem(value: 'Tanpa Pembatasan', child: Text('Tanpa Pembatasan dari Pemberi Sumber Daya')),
                        DropdownMenuItem(value: 'Dengan Pembatasan', child: Text('Dengan Pembatasan dari Pemberi Sumber Daya')),
                      ],
                      onChanged: (v) {
                        _jenisPembatasan = v ?? 'Tanpa Pembatasan';
                        _onAnyChange();
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _noBuktiCtrl,
                      decoration: const InputDecoration(labelText: 'No Bukti (unik)', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    const Text('Detil Jurnal *', style: TextStyle(fontWeight: FontWeight.bold)),
                    const Text('Akun Debit & Kredit harus berbeda', style: TextStyle(fontSize: 11, color: Colors.grey)),
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
                              _akunField(
                                key: ValueKey('deb-$idx-${d.akunDebitId}'),
                                label: 'Akun Debit *',
                                selectedId: d.akunDebitId,
                                onSelected: (id) => d.akunDebitId = id,
                                validator: () => d.akunDebitId == null ? 'Wajib' : null,
                              ),
                              const SizedBox(height: 8),
                              _akunField(
                                key: ValueKey('kre-$idx-${d.akunKreditId}'),
                                label: 'Akun Kredit *',
                                selectedId: d.akunKreditId,
                                onSelected: (id) => d.akunKreditId = id,
                                validator: () {
                                  if (d.akunKreditId == null) return 'Wajib';
                                  if (d.akunKreditId == d.akunDebitId) return 'Tidak boleh sama dengan Akun Debit';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: d.nominalCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Nominal *',
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                  prefixText: 'Rp ',
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: [_RibuanFormatter()],
                                validator: (v) => _parseNomor(v ?? '') > 0 ? null : 'Wajib > 0',
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_parokiId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih Paroki')));
      return;
    }
    if (_detils.length * 2 < 2) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Minimal 2 detil')));
      return;
    }
    for (final d in _detils) {
      if (d.akunDebitId == null || d.akunKreditId == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lengkapi Akun Debit & Kredit di semua detil')));
        return;
      }
      if (d.akunDebitId == d.akunKreditId) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Akun Debit & Kredit tidak boleh sama')));
        return;
      }
      if (_parseNomor(d.nominalCtrl.text) <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nominal harus > 0')));
        return;
      }
    }
    setState(() => _saving = true);
    try {
      // Setiap detil form -> 1 baris DB (format baru)
      final detilsComp = <DetilJurnalsCompanion>[];
      for (final d in _detils) {
        final nominal = _parseNomor(d.nominalCtrl.text);
        final ket = d.ketCtrl.text.isEmpty ? null : d.ketCtrl.text;
        detilsComp.add(DetilJurnalsCompanion.insert(
          jurnalId: '',
          akunId: d.akunDebitId!,
          parokiId: _parokiId!,
          akunDebitId: Value(d.akunDebitId),
          akunKreditId: Value(d.akunKreditId),
          jumlah: Value(nominal),
          debit: Value(nominal),
          kredit: const Value(0),
          keterangan: Value(ket),
        ));
      }
      
      if (widget.jurnal != null) {
        await widget.cubit.updateJurnal(
          id: widget.jurnal!.id,
          keuskupanId: _keuskupanId!,
          tanggal: _tanggal,
          deskripsi: _deskripsiCtrl.text.isEmpty ? null : _deskripsiCtrl.text,
          noBukti: _noBuktiCtrl.text.isEmpty ? null : _noBuktiCtrl.text,
          jenisPembatasan: _jenisPembatasan,
          detils: detilsComp,
        );
        await _clearDraft();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Jurnal diperbarui ✓ (pending sync)'), backgroundColor: Colors.green));
      } else {
        await widget.cubit.createJurnal(
          keuskupanId: _keuskupanId!,
          tanggal: _tanggal,
          deskripsi: _deskripsiCtrl.text.isEmpty ? null : _deskripsiCtrl.text,
          noBukti: _noBuktiCtrl.text.isEmpty ? null : _noBuktiCtrl.text,
          jenisPembatasan: _jenisPembatasan,
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
