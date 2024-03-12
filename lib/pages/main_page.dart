import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:note_fuse/pages/home_page.dart';
import 'package:note_fuse/pages/login_page.dart';
import 'package:note_fuse/pages/update_page.dart';

import '../services/firestore.dart'; // Assuming you have the FirestoreService imported

class MainPage extends StatefulWidget {
  const MainPage({Key? key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late FirestoreService _firestoreService;
  late String currentAppVersion = '1.11';
  late String firestoreAppVersion;
  late String firebaseUrl;

  @override
  void initState() {
    super.initState();
    _firestoreService = FirestoreService();
    _checkForUpdate();
  }

  void _checkForUpdate() async {
    try {
      final versionInfo = await _firestoreService.getAppVersion();
      final version = versionInfo['version'];
      final url = versionInfo['url'];

      firestoreAppVersion = version ?? '';
      firebaseUrl = url ?? '';
      if (version != null && url != null) {
        if (version != currentAppVersion) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => UpdatePage(version: version, url: url),
            ),
          );
        }
      }
    } catch (error) {
      print('Error fetching app version: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (true) {
            if (snapshot.hasData) {
              return HomePage();
            } else {
              return LoginPage();
            }
          }
        },
      ),
    );
  }
}
