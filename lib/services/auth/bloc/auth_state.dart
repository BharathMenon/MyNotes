import 'package:flutter/material.dart' show immutable;
import 'package:mynotes/services/auth/auth_user.dart';

// Each type of state is a class.
@immutable
abstract class AuthState {
  const AuthState();
}

class AuthstateLoading extends AuthState {
  const AuthstateLoading();
}

class AuthstateLoggedIn extends AuthState {
  final AuthUser user;
  const AuthstateLoggedIn(this.user);
}

class AuthStateNeedsVerification extends AuthState {
  const AuthStateNeedsVerification();
}

class AuthStateLoggedOut extends AuthState {
  final Exception? exception;
  const AuthStateLoggedOut(this.exception);
}

class AuthStateLogoutFailure extends AuthState {
  final Exception exception;
  const AuthStateLogoutFailure(this.exception);
}
