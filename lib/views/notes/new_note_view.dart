import 'package:flutter/material.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:sqflite/sqflite.dart';

import '../../services/crud/notes_service.dart';

class NewNotesView extends StatefulWidget {
  const NewNotesView({super.key});

  @override
  State<NewNotesView> createState() => _NewNotesViewState();
}

class _NewNotesViewState extends State<NewNotesView> {
  DatabaseNote? _note;
  late final NotesService _notesService;
  late final TextEditingController _textController;
  @override
  void initState() {
    _notesService = NotesService();
    _textController = TextEditingController();
    super.initState();
  }

  void _textControllerListener() async {
    final note = _note;
    if (note == null) {
      return;
    }
    final text = _textController.text;
    await _notesService.updateNote(
      note: note,
      text: text,
    );
  }

  void _setuptextcontrollerListener() {
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
  }

  Future<DatabaseNote> createNewNote() async {
    final existingNote = _note;
    if (existingNote != null) {
      return existingNote;
    }
    final currentUser = AuthService.firebase().CurrentUser;
    final email = currentUser!.email!;
    final owner = await _notesService.getUser(email: email);
    return await _notesService.createNote(owner: owner);
  }

  void _deleteNoteiftextisEmpty() {
    final note = _note;
    if (_textController.text.isEmpty && note != null) {
      _notesService.deleteNote(id: note.id);
    }
  }

  void _saveNoteiftextnotempty() async {
    final note = _note;
    if (_textController.text.isNotEmpty && note != null) {
      await _notesService.updateNote(
        note: note,
        text: _textController.text,
      );
    }
  }

  @override
  void dispose() {
    _saveNoteiftextnotempty();
    _deleteNoteiftextisEmpty();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Note')),
      body: FutureBuilder(
        future: createNewNote(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              _note = (snapshot.data);
              _setuptextcontrollerListener();
              return TextField(
                controller: _textController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: 'Start typing here...',
                ),
              );
            default:
              return const Center(child: const CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
