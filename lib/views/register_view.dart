import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/auth/auth_service.dart';

import 'dart:developer' as devtools show log;

import '../firebase_options.dart';
import '../utilities/utilities/dialogs/error_dialog.dart';

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
                final UserCredential = await AuthService.firebase()
                    .createUser(email: email, password: password);
                final user = AuthService.firebase().CurrentUser;
                AuthService.firebase().sendEmailVerification();
                Navigator.of(context).pushNamed(veremailviewroute);
                devtools.log(UserCredential.toString());
              } on WeakPasswordAuthException {
                await showErrorDialog(
                    context, 'The entered password is weak:<');
                devtools.log('The entered password is weak!');
              } on EmaillalreadyinUseAuthException {
                await showErrorDialog(context, 'This email is already in use');
                devtools.log('This email is already in use');
              } on InvalidEmailAuthException {
                await showErrorDialog(context, 'This email ID is invalid');
                devtools.log("This email ID is invalid");
              } on GenericAuthException {
                await showErrorDialog(context, 'Generic Authentication Error');
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
