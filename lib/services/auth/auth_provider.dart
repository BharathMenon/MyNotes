// ignore_for_file: non_constant_identifier_names

import 'package:mynotes/services/auth/auth_user.dart';

abstract class AuthProvider {
  AuthUser? get CurrentUser;
  Future<AuthUser> logIn({
    required String email,
    required String password,
  });
  Future<AuthUser> createUser({
    required String email,
    required String password,
  });
  Future<void> logOut();
  Future<void> sendEmailVerification();
  Future<void> initialize();
  Future<void> sendPasswordReset({required String Email});
}
