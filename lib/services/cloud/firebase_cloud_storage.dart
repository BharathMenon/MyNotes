import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mynotes/services/cloud/cloud_storage_constants.dart';
import 'package:mynotes/services/cloud/cloud_storage_exceptions.dart';
import 'package:mynotes/services/cloud/cloud_storage_exceptions.dart';
import 'package:mynotes/services/cloud/firebase_cloud_storage.dart';
import 'cloud_note.dart';

class FirebaseCloudStorage {
  final notes = FirebaseFirestore.instance.collection('notes');

  Future<void> updateNote({
    required String documentId,
    required String text,
  }) async {
    try {
      await notes
          .doc(documentId)
          .update({textFieldName: text}); //path => documentId
    } catch (e) {
      throw CouldNotUpdateNoteExeption();
    }
  }

  Future<void> deletenote({
    required String documentId,
  }) async {
    try {
      await notes.doc(documentId).delete();
    } catch (e) {
      throw CouldNotDeleteNoteException();
    }
  }

// Will be used in StreamBuilder
  Stream<Iterable<CloudNote>> allNotes({required String ownerUserId}) {
    final allnotes = notes
        .where(ownerUserIdFieldName, isEqualTo: ownerUserId)
        .snapshots()
        .map((event) => event.docs.map((doc) => CloudNote.fromSnapshot(doc)));
    return allnotes;
  }

// Will be used in FutureBuilder

  Future<CloudNote> createNewNote({required String ownerUserId}) async {
    final document = await notes.add({
      ownerUserIdFieldName: ownerUserId,
      textFieldName: '',
    });
    final Docsnap = await document.get();
    return CloudNote(
        documentId: Docsnap.id,
        ownerUserId: Docsnap.data()?[ownerUserIdFieldName],
        text: Docsnap.data()![textFieldName]);
    //Much easier to access data from Documentsnapshot than Documentreference. Hence, use .get() and then .data()
  }

//Making FirebaseCloudStorage a Singleton.
  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance() {}
  factory FirebaseCloudStorage() => _shared;
}
