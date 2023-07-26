//Each event is a separate class
import 'package:flutter/material.dart' show immutable;

@immutable
abstract class AuthEvent {
  const AuthEvent();
}

class AuthEventInitialize extends AuthEvent {
  const AuthEventInitialize();
}

class AuthEventLogIn extends AuthEvent {
  final String Email;
  final String password;

  const AuthEventLogIn(this.Email, this.password);
}

class AuthEventLogOut extends AuthEvent {
  const AuthEventLogOut();
}
