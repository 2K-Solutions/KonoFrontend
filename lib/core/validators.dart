class Validators {
  const Validators._();

  static String? required(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'E-mail is required';
    }
    if (!value.contains('@') || value.length < 5) {
      return 'Enter a valid e-mail address';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  static String? Function(String?) matches(String Function() other, String fieldName) {
    return (value) {
      if (value != other()) {
        return '$fieldName does not match';
      }
      return null;
    };
  }
}
