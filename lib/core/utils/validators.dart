/// Shared form-field validators.
class Validators {
  Validators._();

  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return 'Enter email';
    final value = v.trim();
    if (!RegExp(r"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$")
        .hasMatch(value)) {
      return 'Enter valid email';
    }
    return null;
  }

  static String? password(String? v) {
    if (v == null || v.isEmpty) return 'Enter password';
    if (v.length < 6) return 'Password must be at least 6 chars';
    return null;
  }

  static String? name(String? v) {
    if (v == null || v.trim().isEmpty) return 'Enter name';
    if (!RegExp(r'^[a-zA-Z ]{3,}$').hasMatch(v.trim())) {
      return 'Enter a valid name (only letters, min 3 chars)';
    }
    return null;
  }

  static String? contactNumber(String? v) {
    if (v == null || v.trim().isEmpty) return 'Enter Contact Number';
    if (!RegExp(r'^[0-9]{10}$').hasMatch(v.trim())) {
      return 'Enter a valid 10-digit contact number';
    }
    return null;
  }

  static String? skill(String? v) {
    if (v == null || v.trim().isEmpty) return 'Enter Skill';
    if (!RegExp(r'^[a-zA-Z ]{2,30}$').hasMatch(v.trim())) {
      return 'Enter a valid skill name (only letters)';
    }
    return null;
  }

  static String? experience(String? v) {
    if (v == null || v.trim().isEmpty) return 'Enter Experience';
    if (!RegExp(r'^[a-zA-Z0-9 ]{1,20}$').hasMatch(v.trim())) {
      return 'Enter a valid experience (e.g. 2 years)';
    }
    return null;
  }

  static String? availability(String? v) {
    if (v == null || v.trim().isEmpty) return 'Enter Availability';
    if (!RegExp(r'^[a-zA-Z0-9:\- ]{4,20}$').hasMatch(v.trim())) {
      return 'Enter valid availability (e.g. 9AM-5PM)';
    }
    return null;
  }

  static String? location(String? v) {
    if (v == null || v.trim().isEmpty) return 'Enter Location';
    if (!RegExp(r'^[a-zA-Z ]{2,30}$').hasMatch(v.trim())) {
      return 'Enter a valid location name';
    }
    return null;
  }
}
