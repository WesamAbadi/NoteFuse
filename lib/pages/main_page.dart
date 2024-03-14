import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:note_fuse/pages/home_page.dart';
import 'package:note_fuse/pages/login_page.dart';
import 'package:note_fuse/pages/update_page.dart';
import '../services/firestore.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late FirestoreService _firestoreService;
  late String currentAppVersion = '1.22';
  late String firestoreAppVersion;
  late String firebaseUrl;
  bool isLoading = true;

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
      final mandatory = versionInfo['mandatory'];
      final mandatoryBool = mandatory == 'true';

      firestoreAppVersion = version ?? '';
      firebaseUrl = url ?? '';
      if (version != null && url != null && mandatory != null) {
        if (version != currentAppVersion) {
          await Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => UpdatePage(
                  currentAppVersion: currentAppVersion,
                  version: version,
                  url: url,
                  mandatory: mandatoryBool),
            ),
          );
        }
      }
    } catch (error) {
      print('Error fetching app version: $error');
    } finally {
      // Set isLoading to false once the version check is complete
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading // Check isLoading flag
          ? Center(
              child: CircularProgressIndicator(),
            )
          : StreamBuilder(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.waiting) {
                  if (snapshot.hasData) {
                    return HomePage();
                  } else {
                    return LoginPage();
                  }
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
    );
  }
}
