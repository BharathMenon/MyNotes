import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/services/auth/bloc/auth_events.dart';

import 'dart:developer' as devtools show log;

import '../firebase_options.dart';
import '../services/auth/bloc/auth_bloc.dart';
import '../services/auth/bloc/auth_state.dart';
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
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateRegistering) {
          if (state.exception is WeakPasswordAuthException) {
            await showErrorDialog(context, 'Weak Password');
          } else if (state.exception is EmaillalreadyinUseAuthException) {
            await showErrorDialog(context, 'Email already in use');
          } else if (state.exception is GenericAuthException) {
            await showErrorDialog(context, 'Authentication Error');
          } else if (state.exception is InvalidEmailAuthException) {
            await showErrorDialog(context, 'Invalid Email');
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Register'),
          backgroundColor: const Color.fromARGB(255, 35, 34, 33),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment
                  .start, // Aligns column children to the left. Text field doesn't change.
              children: [
                const SizedBox(
                  height: 80,
                  child: Text(
                    'Enter your email and password to start creating notes!',
                    style: TextStyle(fontFamily: 'REM', fontSize: 18),
                  ),
                ),
                Column(
                  children: [
                    TextField(
                        controller: _email,
                        enableSuggestions: false,
                        autocorrect: false,
                        autofocus: true,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                            hintText: 'Enter your email here',
                            hintStyle: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Color.fromARGB(255, 183, 181, 173)))),
                    SizedBox(
                      height: 85,
                      child: TextField(
                          controller: _password,
                          obscureText: true,
                          enableSuggestions: false,
                          autocorrect: false,
                          decoration: const InputDecoration(
                              hintText: 'Enter your password here',
                              hintStyle: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Color.fromARGB(255, 183, 181, 173)))),
                    )
                  ],
                ),
                Center(
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          final email = _email.text;
                          final password = _password.text;
                          context.read<AuthBloc>().add(AuthEventRegister(
                                email,
                                password,
                              ));
                        },
                        style: ButtonStyle(
                          minimumSize:
                              MaterialStateProperty.all(const Size(200, 50)),
                          backgroundColor: const MaterialStatePropertyAll(
                              Color.fromARGB(255, 35, 34, 33)),
                          shape:
                              MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100.0),
                            side: const BorderSide(
                                color: Color.fromARGB(255, 35, 34, 33)),
                          )),
                        ),
                        child: const Text('Register',
                            style: TextStyle(fontSize: 20)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(22.0),
                        child: TextButton(
                            onPressed: () {
                              context
                                  .read<AuthBloc>()
                                  .add(const AuthEventLogOut());
                            },
                            child: const Text(
                                'Already have an Account? Login here.',
                                style: TextStyle(
                                    color: Color.fromARGB(255, 35, 34, 33)))),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
