import 'package:firebase_auth/firebase_auth.dart%20%20';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

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
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      body: FutureBuilder(
          future: Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
          ),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                final user = FirebaseAuth.instance.currentUser;
                //final emailVerified = user?.emailVerified ?? false;
                //If lhs of ?? is null, rhs is passed.
                if (user?.emailVerified ?? false) {
                  print("You are a verified user");
                } else {
                  print('You need to verify your email first');
                }
                return const Text('Done');
              default:
                return const Text('Loading...');
            }
          }),
    );
  }
}
