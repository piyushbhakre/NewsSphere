import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:newssphere/Authentication/Login_Screen.dart';
import 'package:newssphere/Authentication/Splash_Screen.dart';
import 'package:newssphere/Main_Screens/Home_Screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SwipeCardPage(apiKey: '30c6c760234a4f42a4ac08b27a8cf94a'),
    );
  }
}
