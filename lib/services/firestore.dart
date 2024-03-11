import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  //Get collection of notes
  final CollectionReference notes =
      FirebaseFirestore.instance.collection('notes');

//read notes
  Stream<QuerySnapshot> readNotes() {
    final noteStream = notes.orderBy('timestamp', descending: true).snapshots();

    return noteStream;
  }

  //Add new note
  Future<void> addNote(String note) {
    return notes.add({
      'note': note,
      'timestamp': DateTime.now(),
    });
  }
  //Delete note

  //Update note
}
