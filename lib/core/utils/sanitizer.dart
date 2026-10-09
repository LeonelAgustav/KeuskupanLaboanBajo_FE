/// Input sanitization helpers to prevent XSS / formatting injection before save/sync.
class InputSanitizer {
  /// Strip null bytes, trim whitespace, remove raw HTML tags
  static String? sanitizeText(String? input) {
    if (input == null) return null;
    var clean = input.replaceAll('\x00', '').trim();
    // remove basic html tags
    clean = clean.replaceAll(RegExp(r'<[^>]*>'), '');
    return clean.isEmpty ? null : clean;
  }

  /// Clean email: trim, lowercase
  static String sanitizeEmail(String input) {
    return input.replaceAll('\x00', '').trim().toLowerCase();
  }

  /// Clean and parse currency/number strings to double
  static double parseAmount(String input) {
    if (input.trim().isEmpty) return 0.0;
    // remove currency prefixes, periods (as thousand separators), replace comma with period
    var clean = input.replaceAll(RegExp(r'[^\d,.-]'), '');
    // Indonesian format: 1.000.000,50 -> 1000000.50
    if (clean.contains(',') && clean.contains('.')) {
      clean = clean.replaceAll('.', '').replaceAll(',', '.');
    } else if (clean.contains(',')) {
      clean = clean.replaceAll(',', '.');
    }
    return double.tryParse(clean) ?? 0.0;
  }
}
