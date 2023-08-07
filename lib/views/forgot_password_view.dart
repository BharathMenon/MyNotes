import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/auth/bloc/auth_events.dart';
import 'package:mynotes/services/auth/bloc/auth_state.dart';
import 'package:mynotes/utilities/utilities/dialogs/error_dialog.dart';
import 'package:mynotes/utilities/utilities/dialogs/password_reset_email_sent_dialog.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/auth/bloc/auth_bloc.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  late final TextEditingController _controller;
// We always have to do this for text controllers. We need to initialize and dispose them in initstate() and dispose() respectively.
  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
    @override
    void dispose() {
      _controller.dispose();
      super.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateForgotPassword) {
          if (state.hasSentEmail) {
            _controller.clear();
            await showPasswordResetemailsentDialog(context);
          }
          if (state.exception != null) {
            if (state.exception == InvalidEmailAuthException()) {
              await showErrorDialog(
                  context, 'The entered Email is invalid. Please Try again.');
            }
          } else if (state.exception == UserNotFoundAuthException()) {
            await showErrorDialog(context,
                "This acount doesn't exist. Please go back one step to register an account");
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Forgot Password'),
          backgroundColor: const Color.fromARGB(255, 35, 34, 33),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(children: [
              const SizedBox(
                height: 98,
                child: Text(
                  'If you forgot your password, simply enter your email, and we will send you a password reset link.',
                  style: TextStyle(fontFamily: 'REM', fontSize: 18),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(6.0),
                child: SvgPicture.asset(
                  "assets/icon/forgot_password.svg",
                  height: size.height * 0.3,
                  alignment: Alignment.centerRight,
                ),
              ),
              SizedBox(
                height: 75,
                child: TextField(
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  autofocus: true,
                  controller: _controller,
                  decoration: const InputDecoration(
                      hintText: 'Your email address...',
                      hintStyle: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Color.fromARGB(255, 183, 181, 173))),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: TextButton(
                  onPressed: () {
                    final email = _controller.text;
                    context
                        .read<AuthBloc>()
                        .add(AuthEventForgotPassword(email));
                  },
                  child: const Text('Send me a password reset link',
                      style: TextStyle(color: Color.fromARGB(255, 35, 34, 33))),
                ),
              ),
              TextButton(
                onPressed: () {
                  context.read<AuthBloc>().add(
                      const AuthEventLogOut()); // Sends user to Login Page.
                },
                child: const Text('Back to Login Page',
                    style: TextStyle(color: Color.fromARGB(255, 35, 34, 33))),
              )
            ]),
          ),
        ),
      ),
    );
  }
}
