class Validators {
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email required';
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    
    return null;
  }

  static String? password(String? value, {int minLength = 6}) {
    if (value == null || value.isEmpty) {
      return 'Password required';
    }
    
    if (value.length < minLength) {
      return 'Minimum $minLength characters';
    }
    
    return null;
  }

  static String? required(String? value, {String fieldName = 'Field'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName required';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone required';
    }
    
    // Basic phone validation - adjust regex as needed
    final phoneRegex = RegExp(r'^[0-9]{10,}$');
    final cleanedPhone = value.replaceAll(RegExp(r'[^\d]'), '');
    
    if (!phoneRegex.hasMatch(cleanedPhone)) {
      return 'Please enter a valid phone number';
    }
    
    return null;
  }
}

