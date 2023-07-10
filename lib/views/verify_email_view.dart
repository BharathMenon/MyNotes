import 'package:firebase_auth/firebase_auth.dart%20%20';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Email')),
      body: Column(
        children: [
          const Text(
              "We've sent you an email for verification. Please click on it to verify your account."),
          const Text(
              "If you haven't received a verification email yet, press the button below: "),
          TextButton(
              onPressed: () async {
                final user = FirebaseAuth.instance.currentUser;
                await user?.sendEmailVerification();
              },
              child: const Text('Send Email Verification')),
          TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                await Navigator.of(context).pushNamedAndRemoveUntil(
                  registerRoute,
                  (route) => false,
                );
              },
              child: const Text('Restart'))
        ], //bflutter123 - password
      ),
    );
  }
}
