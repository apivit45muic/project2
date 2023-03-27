import 'package:flutter/material.dart';
import 'package:project2/util.dart';

class MyScreen extends StatelessWidget {
  final String message;



  const MyScreen({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Screen'),
      ),
      body: Center(
        child: Text(
          message,
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}