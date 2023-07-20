// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:mynotes/extension/list/filter.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:path_provider/path_provider.dart'
//     show MissingPlatformDirectoryException, getApplicationDocumentsDirectory;
// import 'package:path/path.dart' show join;

// import 'crud_exceptions.dart';

// class NotesService {
//   Database? _db;
//   List<DatabaseNote> _notes = [];

//   DatabaseUser? _user;

//   static final NotesService _shared = NotesService._sharedInstance();
//   NotesService._sharedInstance() {
//     _notesStreamController = StreamController<List<DatabaseNote>>.broadcast(
//       onListen: () {
//         _notesStreamController.sink.add(_notes);
//       },
//     );
//   }
//   factory NotesService() => _shared;

//   late final StreamController<List<DatabaseNote>> _notesStreamController;
//   Stream<List<DatabaseNote>> get allNotes =>
//       _notesStreamController.stream.filter((note) {
//         final currentUser = _user;
//         if (currentUser != null) {
//           return note.userId == currentUser.id;
//         } else {
//           throw UserShouldBesetbeforeReadingAllNotes();
//         }
//       });

//   Future<void> _cacheNotes() async {
//     final allnotes = await getallnotes();
//     _notes = allnotes.toList();
//     _notesStreamController.add(_notes);
//   }

//   Future<DatabaseUser> getorCreateUser({
//     required String email,
//     bool setAsCurrentUser = true,
//   }) async {
//     try {
//       final user = await getUser(email: email);
//       if (setAsCurrentUser) {
//         _user = user;
//       }
//       return user;
//     } on UserNotfound {
//       final createdUser = await createUser(email: email);
//       if (setAsCurrentUser) {
//         _user = createdUser;
//       }
//       return createdUser;
//     } catch (e) {
//       if (e == UserNotfound) {
//         final createdUser = await createUser(email: email);
//         _user = createdUser;
//         return createdUser;
//       }
//       rethrow;
//     }
//   }

//   Future<DatabaseUser> createUser({required String email}) async {
//     await _ensureDbisOpen();
//     final db = _getDatabaseorthrow();
//     final results = await db.query(
//       userTable,
//       limit: 1,
//       where: 'email = ?',
//       whereArgs: [email.toLowerCase()],
//     );
//     if (results.isNotEmpty) {
//       throw UserAlreadyExists();
//     }
//     final id = await db.insert(userTable, {
//       //Don't need to insert the id as it is on auto-increment.
//       emailcolumn: email.toLowerCase(),
//     });
//     return DatabaseUser(
//       id: id,
//       email: email,
//     );
//   }

//   Future<DatabaseUser> getUser({required String email}) async {
//     await _ensureDbisOpen();
//     final db = _getDatabaseorthrow();
//     final results = await db.query(
//       userTable,
//       limit: 1,
//       where: 'email = ?',
//       whereArgs: [email.toLowerCase()],
//     );
//     if (results.isEmpty) {
//       throw UserNotfound();
//     } else {
//       return DatabaseUser.fromRow(results.first);
//     }
//   }

//   Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
//     await _ensureDbisOpen();
//     final db = _getDatabaseorthrow();
//     final dbuser = await getUser(email: owner.email);
//     //id of the given owner databaseUser must also be the same as the one in user table.(not just the email)
//     if (dbuser != owner) {
//       throw UserNotfound();
//     }

//     //create the notes
//     const text = '';
//     final noteId = await db.insert(notesTable, {
//       uidcolumn: owner.id,
//       textcolumn: text,
//     });

//     final note = DatabaseNote(
//       id: noteId,
//       userId: owner.id,
//       text: text,
//     );
//     _notes.add(note);
//     _notesStreamController
//         .add(_notes); //.add() sends a data through the stream.
//     return note;
//   }

//   Future<void> deleteNote({required int id}) async {
//     await _ensureDbisOpen();
//     final db = _getDatabaseorthrow();
//     final deletedcount = await db.delete(
//       notesTable,
//       where: 'id = ?',
//       whereArgs: [id],
//     );
//     if (deletedcount == 0) {
//       throw CouldNotdeleteNote();
//     } else {
//       _notes.removeWhere((note) => note.id == id);
//       _notesStreamController.add(_notes);
//     }
//   }

//   Future<int> deleteallNotes() async {
//     await _ensureDbisOpen();
//     final db = _getDatabaseorthrow();

//     final numberofdeletions = await db.delete(notesTable);
//     _notes = [];
//     _notesStreamController.add(_notes);
//     return numberofdeletions;
//   }

//   Future<DatabaseNote> getNote(int id) async {
//     await _ensureDbisOpen();
//     final db = _getDatabaseorthrow();
//     final results = await db.query(
//       notesTable,
//       limit: 1,
//       where: 'id = ?',
//       whereArgs: [id],
//     );
//     if (results.isEmpty) {
//       throw NoteNotFound();
//     }
//     final note = DatabaseNote.fromRow(results.first);
//     _notes.removeWhere((n) => n.id == note.id);
//     _notes.add(
//         note); //Adding to the end of list doesn't matter here as id is present as an attribute of DatabaseNote.
//     _notesStreamController.add(_notes);
//     return note;
//   }

//   Future<Iterable<DatabaseNote>> getallnotes() async {
//     await _ensureDbisOpen();
//     final db = _getDatabaseorthrow();
//     final notes = await db.query(notesTable);
//     return notes.map((noterow) => DatabaseNote.fromRow(noterow));
//   }

//   Future<DatabaseNote> updateNote({
//     required DatabaseNote note,
//     required String text,
//   }) async {
//     await _ensureDbisOpen();
//     final db = _getDatabaseorthrow();
//     //Make sure note exists.
//     await getNote(note.id);
//     final updatecount = await db.update(
//         notesTable,
//         {
//           textcolumn: text,
//         },
//         where: 'id = ?',
//         whereArgs: [note.id]);
//     if (updatecount == 0) {
//       throw CouldnotUpdateNote();
//     } else {
//       final updatedNote = await getNote(note.id);
//       _notes.removeWhere((n) => n.id == note.id);
//       _notes.add(updatedNote);
//       _notesStreamController.add(_notes);
//       return updatedNote;
//     }
//   }

//   Database _getDatabaseorthrow() {
//     final db = _db;
//     if (db == null) {
//       throw DatabaseNotOpen();
//     } else {
//       return db;
//     }
//   }

//   Future<void> deleteUser({required String email}) async {
//     await _ensureDbisOpen();
//     final db = _getDatabaseorthrow();
//     final deletedcount = await db.delete(
//       userTable,
//       where: 'email = ?',
//       whereArgs: [email.toLowerCase()],
//     );
//     if (deletedcount == 0) {
//       throw CouldNotdeleteUser();
//     }
//   }

//   Future<void> close() async {
//     final db = _db;
//     if (db == null) {
//       throw DatabaseNotOpen();
//     } else {
//       await db.close();
//       _db = null;
//     }
//   }

//   Future<void> _ensureDbisOpen() async {
//     try {
//       await open();
//     } on DatabaseAlreadyDefinedException {}
//   }

//   Future<void> open() async {
//     if (_db != null) throw DatabaseAlreadyDefinedException();
//     try {
//       final docsPath = await getApplicationDocumentsDirectory();
//       final dbPath = join(docsPath.path, dbName);
//       final db = await openDatabase(dbPath);
//       _db = db;
//       //create user table
//       await db.execute(createUserTable);
//       //create note table
//       await db.execute(createNoteTable);
//       await _cacheNotes();
//       await db.execute(createUserTable);
//     } on MissingPlatformDirectoryException {
//       throw UnabletogetDocumentDirectory();
//     }
//   }
// }

// @immutable
// class DatabaseUser {
//   final int id;
//   final String email;

//   const DatabaseUser({
//     required this.id,
//     required this.email,
//   });

//   DatabaseUser.fromRow(Map<String, Object?> map)
//       : id = map[idcolumn] as int,
//         email = map[emailcolumn] as String;
//   @override
//   String toString() => 'Person, ID = $id, Email = $email';

//   @override
//   bool operator ==(covariant DatabaseUser other) => id == other.id;

//   @override
//   int get hashCode => id.hashCode;
// }

// class DatabaseNote {
//   final int id;
//   final int userId;
//   final String text;

//   DatabaseNote({
//     required this.id,
//     required this.userId,
//     required this.text,
//   });
//   DatabaseNote.fromRow(Map<String, Object?> map)
//       : id = map[idcolumn] as int,
//         userId = map[uidcolumn] as int,
//         text = map[textcolumn] as String;

//   @override
//   String toString() => 'note, ID: $id, UserId: $userId,text: $text';
//   @override
//   bool operator ==(covariant DatabaseNote other) => id == other.id;
//   @override
//   int get hashCode => id.hashCode;
// }

// const dbName = 'notes.db';
// const notesTable = 'note';
// const userTable = 'user';
// const idcolumn = 'id';
// const emailcolumn = 'email';
// const uidcolumn = 'user_id';
// const textcolumn = 'text';

// const createUserTable = '''
//           CREATE TABLE IF NOT EXISTS "user" (
//       "id"	INTEGER NOT NULL,
//       "email"	TEXT NOT NULL UNIQUE,
//       PRIMARY KEY("id" AUTOINCREMENT)
//     );
// ''';
// const createNoteTable = '''
//     CREATE TABLE IF NOT EXISTS "note" (
//       "id"	INTEGER NOT NULL,
//       "user_id"	INTEGER NOT NULL,
//       "text"	TEXT NOT NULL UNIQUE,
      
//       PRIMARY KEY("id" AUTOINCREMENT),
//       FOREIGN KEY("user_id") REFERENCES "user"("id")
//     )''';
