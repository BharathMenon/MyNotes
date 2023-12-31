import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/material.dart';

@immutable //This class all it's subclasses are always immutable.
class AuthUser {
  final String id;
  final bool isEmailverified;
  final String email;
  const AuthUser({
    required this.id,
    required this.email,
    required this.isEmailverified,
  });
  //Now, we have to pass AuthUser(isEmailverified: true/false) instead of AuthUser(True/False)
  factory AuthUser.fromFirebase(User user) => AuthUser(
        id: user.uid,
        email: user.email!,
        isEmailverified: user.emailVerified,
      );
}
