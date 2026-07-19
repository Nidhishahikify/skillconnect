/// Small shared, stateless helper functions.
class Helpers {
  Helpers._();

  /// Formats an ISO-8601 timestamp string for display, falling back to the
  /// raw string if it can't be parsed.
  static String formatTimestamp(String? isoString) {
    if (isoString == null || isoString.isEmpty) return '';
    final parsed = DateTime.tryParse(isoString);
    if (parsed == null) return isoString;
    return parsed.toLocal().toString().split('.')[0];
  }

  /// Strips characters that are unsafe to use as a Firestore document ID.
  static String toSafeDocId(String input) {
    return input.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
  }
}
