import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  // Get reference to the users collection
  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');

  // Get reference to the notes collection for the current user
  CollectionReference userNotes(String userId) {
    return users.doc(userId).collection('notes');
  }

  // Read notes for the current user
  Stream<QuerySnapshot> readNotes() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final noteStream =
          userNotes(userId).orderBy('timestamp', descending: true).snapshots();
      return noteStream;
    } else {
      // Return an empty stream if user is not logged in
      return Stream.empty();
    }
  }

  // Add new note for the current user
  Future<void> addNote(String note) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      await userNotes(userId).add({
        'note': note,
        'timestamp': DateTime.now(),
      });
    }
  }

  // Delete note for the current user
  Future<void> deleteNote(String docID) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      await userNotes(userId).doc(docID).delete();
    }
  }

  // Update note for the current user
  Future<void> updateNote(String docID, String newNote) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      await userNotes(userId)
          .doc(docID)
          .update({'note': newNote, 'timestamp': DateTime.now()});
    }
  }
}
