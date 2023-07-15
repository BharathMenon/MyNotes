import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart'
    show MissingPlatformDirectoryException, getApplicationDocumentsDirectory;
import 'package:path/path.dart' show join;

import 'crud_exceptions.dart';

class NotesService {
  Database? _db;
  Future<DatabaseUser> createUser({required String email}) async {
    final db = _getDatabaseorthrow();
    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (results.isNotEmpty) {
      throw UserAlreadyExists();
    }
    final id = await db.insert(userTable, {
      //Don't need to insert the id as it is on auto-increment.
      emailcolumn: email.toLowerCase(),
    });
    return DatabaseUser(
      id: id,
      email: email,
    );
  }

  Future<DatabaseUser> getUser({required String email}) async {
    final db = _getDatabaseorthrow();
    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (results.isEmpty) {
      throw UserNotfound();
    } else {
      return DatabaseUser.fromRow(results.first);
    }
  }

  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    final db = _getDatabaseorthrow();
    final dbuser = await getUser(email: owner.email);
    //id of the given owner databaseUser must also be the same as the one in user table.(not just the email)
    if (dbuser != owner) {
      throw UserNotfound();
    }

    //create the notes
    const text = '';
    final noteId = await db.insert(notesTable, {
      uidcolumn: owner.id,
      textcolumn: text,
      isSyncedWithCloudcolumn: 1,
    });

    final note = DatabaseNote(
      id: noteId,
      userId: owner.id,
      text: text,
      isSyncedWithCloud: true,
    );
    return note;
  }

  Future<void> deleteNote({required int id}) async {
    final db = _getDatabaseorthrow();
    final deletedcount = await db.delete(
      notesTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (deletedcount != 1) {
      throw CouldNotdeleteNote();
    }
  }

  Future<int> deleteallNotes() async {
    final db = _getDatabaseorthrow();
    return await db.delete(notesTable);
  }

  Future<DatabaseNote> getNote(int id) async {
    final db = _getDatabaseorthrow();
    final results = await db.query(
      notesTable,
      limit: 1,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (results.isEmpty) {
      throw NoteNotFound();
    }
    return DatabaseNote.fromRow(results.first);
  }

  Future<Iterable<DatabaseNote>> getallnotes() async {
    final db = _getDatabaseorthrow();
    final notes = await db.query(notesTable);
    return notes.map((noterow) => DatabaseNote.fromRow(noterow));
  }

  Future<DatabaseNote> updateNote({
    required DatabaseNote note,
    required String text,
  }) async {
    final db = _getDatabaseorthrow();
    await getNote(note.id);
    final updatecount = await db
        .update(notesTable, {textcolumn: text, isSyncedWithCloudcolumn: 0});
    if (updatecount == 0) throw CouldnotUpdateNote();
    return await getNote(note.id);
  }

  Database _getDatabaseorthrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseNotOpen();
    } else {
      return db;
    }
  }

  Future<void> deleteUser({required String email}) async {
    final db = _getDatabaseorthrow();
    final deletedcount = db.delete(
      userTable,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (deletedcount != 1) {
      throw CouldNotdeleteUser();
    }
  }

  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseNotOpen();
    } else {
      await db.close();
      _db = null;
    }
  }

  Future<void> open() async {
    if (_db != null) throw DatabaseAlreadyDefinedException();
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;
      //create user table
      await db.execute(createUserTable);
      //create note table
      await db.execute(createNoteTable);

      await db.execute(createUserTable);
    } on MissingPlatformDirectoryException {
      throw UnabletogetDocumentDirectory();
    }
  }
}

@immutable
class DatabaseUser {
  final int id;
  final String email;

  const DatabaseUser({
    required this.id,
    required this.email,
  });

  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map[idcolumn] as int,
        email = map[emailcolumn] as String;
  @override
  String toString() => 'Person, ID = $id, Email = $email';

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class DatabaseNote {
  final int id;
  final int userId;
  final String text;
  final bool isSyncedWithCloud;

  DatabaseNote(
      {required this.id,
      required this.userId,
      required this.text,
      required this.isSyncedWithCloud});
  DatabaseNote.fromRow(Map<String, Object?> map)
      : id = map[idcolumn] as int,
        userId = map[uidcolumn] as int,
        text = map[textcolumn] as String,
        isSyncedWithCloud =
            (map[isSyncedWithCloudcolumn] as int) == 1 ? true : false;

  @override
  String toString() =>
      'note, ID: $id, UserId: $userId, isSyncedwithCloud: $isSyncedWithCloud,text: $text';
  @override
  bool operator ==(covariant DatabaseNote other) => id == other.id;
  @override
  int get hashCode => id.hashCode;
}

const dbName = 'notes.db';
const notesTable = 'notes';
const userTable = 'user';
const idcolumn = 'id';
const emailcolumn = 'email';
const uidcolumn = 'userId';
const textcolumn = 'text';
const isSyncedWithCloudcolumn = 'is_synced_with_cloud';
const createUserTable = '''
          CREATE TABLE IF NOT EXISTS "user" (
      "id"	INTEGER NOT NULL,
      "email"	TEXT NOT NULL UNIQUE,
      PRIMARY KEY("id" AUTOINCREMENT)
    );
''';
const createNoteTable = '''
    CREATE TABLE IF NOT EXISTS "note" (
      "id"	INTEGER NOT NULL,
      "user_id"	INTEGER NOT NULL,
      "text"	TEXT NOT NULL UNIQUE,
      "issyncedwithcloud"	INTEGER NOT NULL,
      PRIMARY KEY("id" AUTOINCREMENT),
      FOREIGN KEY("user_id") REFERENCES "user"("id")
    )''';
