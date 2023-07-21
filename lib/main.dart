//import 'package:firebase_auth/firebase_auth.dart%20%20';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

// class HomePage extends StatelessWidget {
//   const HomePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder(
//         future: AuthService.firebase().initialize(),
//         builder: (context, snapshot) {
//           switch (snapshot.connectionState) {
//             case ConnectionState.done:
//               // final user = FirebaseAuth.instance.currentUser;
//               final user = AuthService.firebase().CurrentUser;
//               devtools.log(user.toString());
//               if (user != null) {
//                 if (user.isEmailverified) {
//                   devtools.log('Email is verified');
//                 } else {
//                   return const VerifyEmailView();
//                   // return const NotesView();
//                 }
//               } else {
//                 return const LoginView();
//               }
//               return const NotesView();

//             default:
//               return const SizedBox(
//                 width: 50.0,
//                 height: 50.0,
//                 child: CircularProgressIndicator(),
//               );
//           }
//         });
//   }
// }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final TextEditingController _controller;
  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CounterBloc(),
      child: Scaffold(
          appBar: AppBar(
            title: const Text('Testing bloc'),
          ),
          body: BlocConsumer<CounterBloc, CounterState>(
            listener: (context, state) {
              _controller
                  .clear(); // Every time a state is produced, the text field is cleared.
            },
            builder: (context, state) {
              final inValidvalue = (state is CounterStateInvalidNumber)
                  ? state.invalidvalue
                  : '';

              return Column(
                children: [
                  Text('Current Value => ${state.value}'),
                  Visibility(
                    child: Text('Invalid Input: ${inValidvalue}'),
                    visible: state is CounterStateInvalidNumber,
                  ),
                  TextField(
                    controller: _controller,
                    decoration:
                        const InputDecoration(hintText: 'Enter a number here'),
                    keyboardType: TextInputType.number,
                  ),
                  Row(
                    children: [
                      TextButton(
                          onPressed: () {
                            context
                                .read<CounterBloc>()
                                .add(DecrementEvent(_controller.text));
                          },
                          child: const Text('-')),
                      TextButton(
                          onPressed: () {
                            context
                                .read<CounterBloc>()
                                .add(IncrementEvent(_controller.text));
                          },
                          child: const Text('+'))
                    ],
                  )
                ],
              );
            },
          )),
    );
  } // BlocConsumer is the combination of both BlocListener and BlocBuilder.
  //BlocListener (and thus BlocConsumer) is used for side-effects, as in it listens to data and does extra
  //things. We use BlocConsumer here to clear text field every time someone presses the increment or decrement
  //button.
}

@immutable
abstract class CounterState {
  final int value;

  const CounterState(this.value);
}

class CounterStateValid extends CounterState {
  const CounterStateValid(int value) : super(value);
}

class CounterStateInvalidNumber extends CounterState {
  final String invalidvalue;
  const CounterStateInvalidNumber(
      {required this.invalidvalue, required int previousvalue})
      : super(previousvalue);
}

@immutable
abstract class CounterEvent {
  final String value;
  const CounterEvent(this.value);
}

class IncrementEvent extends CounterEvent {
  const IncrementEvent(String value) : super(value);
}

class DecrementEvent extends CounterEvent {
  const DecrementEvent(String value) : super(value);
}

class CounterBloc extends Bloc<CounterEvent, CounterState> {
  CounterBloc() : super(const CounterStateValid(0)) {
    on<IncrementEvent>((event, emit) {
      final integer = int.tryParse(event.value);
      if (integer == null) {
        emit(CounterStateInvalidNumber(
          invalidvalue: event.value,
          previousvalue: state.value,
        ));
      } else {
        emit(CounterStateValid(state.value + integer));
      }
    });
    on<DecrementEvent>((event, emit) {
      final integer = int.tryParse(event.value);
      if (integer == null) {
        emit(CounterStateInvalidNumber(
          invalidvalue: event.value,
          previousvalue: state.value,
        ));
      } else {
        emit(CounterStateValid(state.value - integer));
      }
    });
  }
}
