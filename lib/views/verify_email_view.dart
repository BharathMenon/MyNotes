import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/services/auth/bloc/auth_bloc.dart';
import 'package:mynotes/services/auth/bloc/auth_events.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Verify Email'),
          backgroundColor: const Color.fromARGB(255, 35, 34, 33)),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 50,
                child: Text(
                    "We've sent you an email for verification. Please click on it to verify your account.",
                    style: TextStyle(fontFamily: 'REM', fontSize: 18)),
              ),
              const SizedBox(
                height: 80,
                child: Text(
                    "If you haven't received a verification email yet, press the button below: ",
                    style: TextStyle(fontFamily: 'REM', fontSize: 18)),
              ),
              ElevatedButton(
                  onPressed: () {
                    final user = AuthService.firebase().CurrentUser;
                    context
                        .read<AuthBloc>()
                        .add(const AuthEventSendEmailVerification());
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
                    'Send Email Verification',
                    style: TextStyle(fontSize: 15),
                  )),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextButton(
                    onPressed: () async {
                      context.read<AuthBloc>().add(const AuthEventLogOut());
                    },
                    child: const Text('Restart',
                        style:
                            TextStyle(color: Color.fromARGB(255, 35, 34, 33)))),
              )
            ], //bflutter123 - password
          ),
        ),
      ),
    );
  }
}
