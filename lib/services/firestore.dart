import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
// Get the version feild in the app_info collection
  Future<Map<String, String>> getAppVersion() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('versions')
          .doc('latest')
          .get();

      // Retrieve the 'version' and 'url' fields from the document
      final version = snapshot.data()?['version'] ?? '';
      final url = snapshot.data()?['url'] ?? '';
      final mandatory = snapshot.data()?['mandatory']?.toString() ??
          'false'; // Convert to string

      // Return a map containing both the version, the URL, and the mandatory status as strings
      return {'version': version, 'url': url, 'mandatory': mandatory};
    } catch (e) {
      print('Error getting app version: $e');
      // Return default values in case of an error
      return {'version': '', 'url': '', 'mandatory': 'false'}; // Return strings
    }
  }

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
