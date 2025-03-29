// lib/utils/validation_utils.dart

bool isValidEmail(String email) {
  return RegExp(
    r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$',
  ).hasMatch(email);
}

bool isValidPhoneNumber(String phone) {
  return RegExp(r'^[0-9]{10,15}$').hasMatch(phone);
}

bool isValidName(String name) {
  return RegExp(r'^[a-zA-Z\s]{1,50}$').hasMatch(name);
}

bool isPasswordSecure(String password) {
  if (password.length < 8) return false;
  if (!password.contains(RegExp(r'[A-Z]'))) return false;
  if (!password.contains(RegExp(r'[a-z]'))) return false;
  if (!password.contains(RegExp(r'[0-9]'))) return false;
  if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) return false;
  return true;
}

String? validateLocation(String? location) {
  if (location == null || location.isEmpty) {
    return 'Please select a location.';
  }
  return null;
}

String? validateDates(DateTime? departureDate, DateTime? returnDate) {
  if (departureDate != null && returnDate != null) {
    if (departureDate.isAfter(returnDate)) {
      return 'Departure date cannot be after return date.';
    }
  }
  return null;
}
