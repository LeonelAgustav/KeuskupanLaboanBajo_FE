import 'package:flutter/material.dart';
import '../../data/local/app_database.dart';

Future<Akun?> showAkunPicker({
  required BuildContext context,
  required List<Akun> akuns,
  required String title,
  required String hint,
}) {
  return showModalBottomSheet<Akun>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => _AkunPickerSheet(akuns: akuns, title: title, hint: hint),
  );
}

class _AkunPickerSheet extends StatefulWidget {
  final List<Akun> akuns;
  final String title;
  final String hint;

  const _AkunPickerSheet({required this.akuns, required this.title, required this.hint});

  @override
  State<_AkunPickerSheet> createState() => _AkunPickerSheetState();
}

class _AkunPickerSheetState extends State<_AkunPickerSheet> {
  final _search = TextEditingController();
  late List<Akun> _filtered = widget.akuns;

  @override
  void initState() {
    super.initState();
    _search.addListener(_filter);
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _filter() {
    final query = _search.text.trim().toLowerCase();
    setState(() {
      _filtered = query.isEmpty
          ? widget.akuns
          : widget.akuns
              .where((a) => a.kode.toLowerCase().contains(query) || a.nama.toLowerCase().contains(query))
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.7,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Text(widget.title, style: Theme.of(context).textTheme.titleMedium),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              key: const Key('akun-picker-search'),
              controller: _search,
              autofocus: true,
              decoration: InputDecoration(
                hintText: widget.hint,
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              itemCount: _filtered.length,
              itemBuilder: (_, index) {
                final akun = _filtered[index];
                return ListTile(
                  dense: true,
                  title: Text('${akun.kode} - ${akun.nama}'),
                  onTap: () => Navigator.pop(context, akun),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class AkunPickerButton extends StatelessWidget {
  final List<Akun> akuns;
  final Akun? selected;
  final void Function(Akun akun) onChanged;
  final String label;
  final String? errorText;
  final bool enabled;

  const AkunPickerButton({
    super.key,
    required this.akuns,
    required this.selected,
    required this.onChanged,
    required this.label,
    this.errorText,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      // initialValue hanya dibaca sekali; key baru per akun agar teks ikut berubah
      key: ValueKey(selected?.id),
      enabled: enabled,
      readOnly: true,
      initialValue: selected == null ? '' : '${selected!.kode} - ${selected!.nama}',
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
        suffixIcon: const Icon(Icons.arrow_drop_down),
        errorText: errorText,
      ),
      onTap: () async {
        final akun = await showAkunPicker(
          context: context,
          akuns: akuns,
          title: label,
          hint: 'Cari kode atau nama akun',
        );
        if (akun != null) onChanged(akun);
      },
    );
  }
}
