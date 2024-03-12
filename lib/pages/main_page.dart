import 'package:firebase_auth/firebase_auth.dart';
//import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
//import 'package:flutter/widgets.dart';
import 'package:note_fuse/pages/home_page.dart';

import 'login_page.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return HomePage();
            } else {
              return LoginPage();
              //return const Center(child: CircularProgressIndicator());
            }
          }),
    );
  }
}
