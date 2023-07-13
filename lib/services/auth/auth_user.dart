import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/material.dart';

@immutable //This class all it's subclasses are always immutable.
class AuthUser {
  final bool isEmailverified;

  const AuthUser({required this.isEmailverified});
  //Now, we have to pass AuthUser(isEmailverified: true/false) instead of AuthUser(True/False)
  factory AuthUser.fromFirebase(User user) =>
      AuthUser(isEmailverified: user.emailVerified);
}
