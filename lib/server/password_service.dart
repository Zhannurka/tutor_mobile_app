class PasswordService {
  bool canResetPassword(String email) {
    return email.contains('@') && email.contains('.');
  }
}
