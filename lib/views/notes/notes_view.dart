import 'package:flutter/material.dart';
import 'package:mynotes/services/crud/notes_service.dart';
import 'dart:developer' as devtools show log;
import '../../constants/routes.dart';
import '../../enums/menu_action.dart';
import '../../services/auth/auth_service.dart';
import '../../utilities/show_error_dialog.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final NotesService _notesService;
  @override
  void initState() {
    _notesService = NotesService();
    super.initState();
  }

  @override
  void dispose() {
    _notesService.close();
    super.dispose();
  }

  String get userEmail => AuthService.firebase().CurrentUser!.email!;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Notes '),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(newNoteroute);
            },
            icon: const Icon(Icons.add),
          ),
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              // devtools.log(value.toString());
              switch (value) {
                case MenuAction.logout:
                  final shouldLogout = await showLogoutDialog(context);
                  if (shouldLogout) {
                    await AuthService.firebase().logOut();
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil(loginRoute, (_) => false);
                  }
                  devtools.log(shouldLogout.toString());
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,
                  child: Text('Log Out'),
                ),
              ];
            },
          )
        ],
      ),
      body: FutureBuilder(
        future: _notesService.getorCreateUser(
          email: userEmail,
        ),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return StreamBuilder(
                stream: _notesService.allNotes,
                builder: (context, snapshot) {
                  switch (ConnectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.active:
                      return const Text('Waiting for all Notes...');
                    default:
                      return Center(child: const CircularProgressIndicator());
                  }
                },
              );
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
