import 'package:firebase_auth/firebase_auth.dart%20%20';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/utilities/show_error_dialog.dart';
import 'dart:developer' as devtools show log;

import '../firebase_options.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Column(
        children: [
          TextField(
              controller: _email,
              enableSuggestions: false,
              autocorrect: false,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'Enter your email here',
              )),
          TextField(
              controller: _password,
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              decoration: const InputDecoration(
                hintText: 'Enter your password here',
              )),
          TextButton(
            onPressed: () async {
              final email = _email.text;
              final password = _password.text;
              try {
                final UserCredential = await FirebaseAuth.instance
                    .createUserWithEmailAndPassword(
                        email: email, password: password);
                final user = FirebaseAuth.instance.currentUser;
                user?.sendEmailVerification();
                Navigator.of(context).pushNamed(veremailviewroute);
                devtools.log(UserCredential.toString());
              } on FirebaseAuthException catch (e) {
                if (e.code == 'weak-password') {
                  await showErrorDialog(
                      context, 'The entered password is weak:<');
                  devtools.log('The entered password is weak!');
                } else if (e.code == 'email-already-in-use') {
                  await showErrorDialog(
                      context, 'This email is already in use');
                  devtools.log('This email is already in use');
                } else if (e.code == 'invalid-email') {
                  await showErrorDialog(context, 'This email ID is invalid');
                  devtools.log("This email ID is invalid");
                } else {
                  await showErrorDialog(context, 'Error: ${e.code}');
                }
              } catch (e) {
                await showErrorDialog(context, 'Error: ${e.toString()}');
              }
            },
            child: const Text('Register'),
          ),
          TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil(loginRoute, (route) => false);
              },
              child: const Text('Already have an Account? Login here.'))
        ],
      ),
    );
  }
}
