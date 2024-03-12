import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:note_fuse/firebase_options.dart';
// import 'package:dynamic_color/dynamic_color.dart';

import 'pages/main_page.dart';
// import 'pages/home_page.dart';
// import 'services/firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      //for debugging purposes, keep it commented out
      //home: MainPage(),
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange)),
      home: MainPage(),
    );
  }
}
