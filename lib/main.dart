//import 'package:firebase_auth/firebase_auth.dart%20%20';

import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/views/login_view.dart';
import 'package:mynotes/views/notes/create_update_note_view.dart';

import 'package:mynotes/views/notes/notes_view.dart';
import 'package:mynotes/views/register_view.dart';
import 'package:mynotes/views/verify_email_view.dart';
//import 'package:mynotes/views/verify_email_view.dart';
import 'dart:developer' as devtools show log;

import 'enums/menu_action.dart';
import 'firebase_options.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
      routes: {
        loginRoute: (context) => const LoginView(),
        registerRoute: (context) => const RegisterView(),
        notesRoute: (context) => const NotesView(),
        veremailviewroute: (context) => const VerifyEmailView(),
        createupdatenoteroute: (context) => const CreateUpdateNoteView(),
      },
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: AuthService.firebase().initialize(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              // final user = FirebaseAuth.instance.currentUser;
              final user = AuthService.firebase().CurrentUser;
              devtools.log(user.toString());
              if (user != null) {
                if (user.isEmailverified) {
                  devtools.log('Email is verified');
                } else {
                  return const VerifyEmailView();
                  // return const NotesView();
                }
              } else {
                return const LoginView();
              }
              return const NotesView();

            default:
              return const SizedBox(
                width: 50.0,
                height: 50.0,
                child: CircularProgressIndicator(),
              );
          }
        });
  }
}
