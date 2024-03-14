import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:google_sign_in/google_sign_in.dart";
import "package:note_fuse/services/firestore.dart";

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirestoreService firestoreService = FirestoreService();

  final TextEditingController textController = TextEditingController();

  bool _switchValue = false;

  void openAddNoteDialog({String? docId, String? noteText}) {
    textController.text = noteText ?? "";
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: TextField(
                maxLines: null,
                autofocus: true,
                controller: textController,
                decoration: const InputDecoration(hintText: "Add a note"),
              ),
              actions: [
                ElevatedButton(
                    onPressed: () {
                      if (docId == null) {
                        firestoreService.addNote(textController.text);
                      } else {
                        firestoreService.updateNote(docId, textController.text);
                      }
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
      appBar: AppBar(
        title: Row(
          children: [
            const SizedBox(width: 80),
            const Text("Note Fuse"),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              GoogleSignIn().signOut();
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(padding: EdgeInsets.zero, children: [
          Container(
            height: 100,
            child: const DrawerHeader(
              child: Text('Settings'),
            ),
          ),
          ListTile(
            title: FutureBuilder<Map<String, String>>(
              future: firestoreService.getAppVersion(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  final version = snapshot.data?['version'] ?? '';
                  return Text('App version: $version');
                }
              },
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Good news!'),
                    content: Text('This is the latest version.'),
                    actions: <Widget>[
                      TextButton(
                        child: Text('Close'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
          SwitchListTile(
            title: const Text('Compact View'),
            value: _switchValue,
            onChanged: (bool value) {
              // Update the state of the switch
              setState(() {
                _switchValue = value;
              });
            },
          ),
        ]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {openAddNoteDialog()},
        child: const Icon(Icons.note_add),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: firestoreService.readNotes(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
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
                    elevation: 1,
                    margin:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Dismissible(
                      key: Key(docId), // Unique key for each Dismissible widget
                      direction: DismissDirection
                          .endToStart, // Specify the swipe direction
                      background: Container(
                        color: Colors.red, // Background color for delete action
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (direction) async {
                        if (direction == DismissDirection.endToStart) {
                          // Display a confirmation dialog
                          return await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("Confirm"),
                                content: const Text(
                                    "Are you sure you want to delete this note?"),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: const Text("CANCEL"),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      // Delete the note and dismiss the dialog
                                      firestoreService.deleteNote(docId);
                                      Navigator.of(context).pop(true);
                                    },
                                    child: const Text("DELETE"),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                        return false;
                      },
                      onDismissed: (direction) {
                        if (direction == DismissDirection.endToStart) {}
                      },
                      child: ListTile(
                        title: _switchValue
                            ? Text(
                                noteText.length > 30
                                    ? '${noteText.substring(0, 30)}...'
                                    : noteText,
                                style: const TextStyle(fontSize: 14),
                                maxLines: 1,
                              )
                            : Text(
                                noteText,
                                style: const TextStyle(fontSize: 14),
                              ),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            openAddNoteDialog(docId: docId, noteText: noteText);
                          },
                        ),
                      ),
                    ),
                  );
                },
              );
            } else {
              return const Center(
                child: Text("No notes found, add some!"),
              );
            }
          }),
    );
  }
}
