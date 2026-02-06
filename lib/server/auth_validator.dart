class AuthValidator {
  bool isValidEmail(String email) {
    return email.contains('@') && email.contains('.');
  }

  bool isValidPassword(String password) {
    return password.length >= 6;
  }

  bool canLogin(String email, String password) {
    return isValidEmail(email) && isValidPassword(password);
  }

  bool canRegister(String email, String password, String role) {
    if (role != 'student' && role != 'tutor') return false;
    return canLogin(email, password);
  }
}
