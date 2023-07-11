import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/material.dart';

@immutable //This class all it's subclasses are always immutable.
class AuthUser {
  final bool isEmailverified;

  const AuthUser(this.isEmailverified);
  factory AuthUser.fromFirebase(User user) => AuthUser(user.emailVerified);
}
