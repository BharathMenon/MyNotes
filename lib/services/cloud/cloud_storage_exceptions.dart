class CloudStorageException implements Exception {
  const CloudStorageException(); //Aparently makes it easier to make an instance of this class.
}

// C
class CouldNotCreateNoteException extends CloudStorageException {}

// R
class CouldNotGetAllNotesException extends CloudStorageException {}

// U
class CouldNotUpdateNoteExeption extends CloudStorageException {}

class CouldNotDeleteNoteException extends CloudStorageException {}
