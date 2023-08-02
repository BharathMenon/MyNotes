import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/auth/bloc/auth_bloc.dart';
import 'package:mynotes/services/auth/bloc/auth_events.dart';
import 'package:mynotes/services/auth/bloc/auth_state.dart';
import 'package:mynotes/utilities/utilities/dialogs/loading_dialog.dart';
import 'dart:developer' as devtools show log;
import '../firebase_options.dart';
import '../utilities/utilities/dialogs/error_dialog.dart';
import 'package:bloc/bloc.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  CloseDialog? _closeDialogHandle;
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
        if (state is AuthStateLoggedOut) {
          if (state.exception is UserNotFoundAuthException) {
            await showErrorDialog(
                context, 'Cannot find a User with entered credentials!');
          } else if (state.exception is WrongPasswordAuthException) {
            await showErrorDialog(context, 'Entered Password is wrong');
          } else if (state.exception is GenericAuthException) {
            await showErrorDialog(context, 'Authentication error');
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
            title: const Text(
              'Login',
            ),
            backgroundColor: const Color.fromARGB(255, 35, 34, 33)),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  height: 80,
                  child: Text(
                    'Please login to your account in order to create and interact with notes!',
                    style: TextStyle(fontFamily: 'REM', fontSize: 18),
                  ),
                ),

                //height: 0.0,
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
                          color: Color.fromARGB(255, 183, 181, 173)),
                    )),

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
                            color: Color.fromARGB(255, 183, 181, 173)),
                        fillColor: Colors.black,
                      )),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final email = _email.text;
                    final password = _password.text;
                    context
                        .read<AuthBloc>()
                        .add(AuthEventLogIn(email, password));
                  },
                  style: ButtonStyle(
                    minimumSize: MaterialStateProperty.all(const Size(200, 50)),
                    backgroundColor: const MaterialStatePropertyAll(
                        Color.fromARGB(255, 35, 34, 33)),
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100.0),
                      side: const BorderSide(
                          color: Color.fromARGB(255, 35, 34, 33)),
                    )),
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: TextButton(
                      onPressed: () {
                        context
                            .read<AuthBloc>()
                            .add(const AuthEventShouldRegister());
                      },
                      child: const Text('Not Registered yet? Register here.',
                          style: TextStyle(
                              color: Color.fromARGB(255, 35, 34, 33)))),
                ),
                TextButton(
                    onPressed: () {
                      context
                          .read<AuthBloc>()
                          .add(const AuthEventForgotPassword(null));
                    },
                    child: const Text('I forgot my Password.',
                        style:
                            TextStyle(color: Color.fromARGB(255, 35, 34, 33))))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
