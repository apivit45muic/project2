import 'package:flutter/material.dart';
import 'package:project2/Screens/SignInScreen.dart';
import 'package:project2/DirectionPage.dart';
import 'package:project2/Screens/SignUpScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isSignedIn = prefs.getBool('isSignedIn') ?? false;

  runApp(MyApp(isSignedIn: isSignedIn));
}

class MyApp extends StatelessWidget {
  final bool isSignedIn;

  MyApp({required this.isSignedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Directions App',
      home: Scaffold(
        body: isSignedIn ? DirectionPage() : SignIn(),
      ),
    );
  }
}
