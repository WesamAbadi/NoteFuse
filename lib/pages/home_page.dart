import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:note_fuse/services/firestore.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _textController = TextEditingController();
  bool _compactView = false;
  bool _markdownView = true;

  void _openAddNoteDialog({String? docId, String? noteText}) {
    _textController.text = noteText ?? '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: TextField(
          maxLines: null,
          autofocus: true,
          controller: _textController,
          decoration: const InputDecoration(hintText: 'Add a note'),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              if (docId == null) {
                _firestoreService.addNote(_textController.text);
              } else {
                _firestoreService.updateNote(docId, _textController.text);
              }
              _textController.clear();
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _openViewNoteDialog(String noteText, Timestamp timestamp) {
    String formattedTimestamp =
        DateFormat.yMMMMd().add_jm().format(timestamp.toDate());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Note ($formattedTimestamp)'),
        content: Text(noteText),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Note Fuse'),
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
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              height: 100,
              child: const DrawerHeader(
                child: Text('Settings'),
              ),
            ),
            ListTile(
              title: FutureBuilder<Map<String, String>>(
                future: _firestoreService.getAppVersion(),
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
              value: _compactView,
              onChanged: (bool value) {
                setState(() {
                  _compactView = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text('Markdown View'),
              value: _markdownView,
              onChanged: (bool value) {
                setState(() {
                  _markdownView = value;
                });
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddNoteDialog(),
        child: const Icon(Icons.note_add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestoreService.readNotes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            List<DocumentSnapshot> notesList = snapshot.data!.docs;

            return ListView.builder(
              itemCount: notesList.length,
              itemBuilder: (context, index) {
                DocumentSnapshot note = notesList[index];
                String docId = note.id;
                Map<String, dynamic> noteData =
                    note.data() as Map<String, dynamic>;
                String noteText = noteData['note'];
                Timestamp timestamp = noteData['timestamp'];

                return NoteItem(
                  noteText: noteText,
                  compactView: _compactView,
                  onEdit: () =>
                      _openAddNoteDialog(docId: docId, noteText: noteText),
                  onDelete: () => _firestoreService.deleteNote(docId),
                  onView: (noteText) =>
                      _openViewNoteDialog(noteText, timestamp),
                );
              },
            );
          } else {
            return const Center(
              child: Text('No notes found, add some!'),
            );
          }
        },
      ),
    );
  }
}

class NoteItem extends StatelessWidget {
  final String noteText;
  final bool compactView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Function(String) onView;

  const NoteItem({
    required this.noteText,
    required this.compactView,
    required this.onEdit,
    required this.onDelete,
    required this.onView,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Dismissible(
        key: UniqueKey(),
        direction: DismissDirection.endToStart,
        background: Container(
          color: Colors.red,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.endToStart) {
            return await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Confirm'),
                  content:
                      const Text('Are you sure you want to delete this note?'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('CANCEL'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                      child: const Text('DELETE'),
                    ),
                  ],
                );
              },
            );
          }
          return false;
        },
        onDismissed: (direction) {
          if (direction == DismissDirection.endToStart) {
            onDelete();
          }
        },

        // child: ListTile(
        //   title: compactView
        //       ? Text(
        //           noteText.length > 30
        //               ? '${noteText.substring(0, 30)}...'
        //               : noteText,
        //           style: const TextStyle(fontSize: 14),
        //           maxLines: 1,
        //         )
        //       : Text(
        //           noteText,
        //           style: const TextStyle(fontSize: 14),
        //         ),
        //   trailing: IconButton(
        //     icon: const Icon(Icons.edit),
        //     onPressed: onEdit,
        //   ),
        // ),

        child: ListTile(
          onTap: () => onView(noteText),
          title: compactView
              ? MarkdownBody(
                  data: noteText.length > 30
                      ? '${noteText.substring(0, 30)}...'
                      : noteText)
              : MarkdownBody(data: noteText),
          trailing: IconButton(
            icon: const Icon(Icons.edit),
            onPressed: onEdit,
          ),
        ),
      ),
    );
  }
}
