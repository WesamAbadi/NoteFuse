import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/material.dart";
import "package:note_fuse/services/firestore.dart";

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirestoreService firestoreService = FirestoreService();

  final TextEditingController textController = TextEditingController();

  void openAddNoteDialog() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: TextField(
                controller: textController,
                decoration: const InputDecoration(hintText: "Add a note"),
              ),
              actions: [
                ElevatedButton(
                    onPressed: () {
                      firestoreService.addNote(textController.text);
                      textController.clear();
                      Navigator.pop(context);
                    },
                    child: const Text("Add")),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Note Fuse")),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {openAddNoteDialog()},
        child: const Icon(Icons.note_add),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: firestoreService.readNotes(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List notesList = snapshot.data!.docs;

              return ListView.builder(
                itemCount: notesList.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot note = notesList[index];
                  String docId = note.id;

                  Map<String, dynamic> noteData =
                      note.data() as Map<String, dynamic>;
                  String noteText = noteData['note'];

                  return Card(
                    elevation: 1, // Add elevation for a shadow effect
                    margin:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: ListTile(
                      title: Text(
                        noteText,
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      // You can add more styling or additional widgets here
                    ),
                  );
                },
              );
            } else {
              return const Center(
                child: Text("No notes found"),
              );
            }
          }),
    );
  }
}
