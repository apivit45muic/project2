import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

import 'package:project2/util.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isThai = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bus Directions',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Bus Directions'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                child: Text(_isThai ? 'Switch to English' : 'Switch to Thai'),
                onPressed: () {
                  setState(() {
                    _isThai = !_isThai;
                  });
                },
              ),
              SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      FutureBuilder(
                        future: getBusInstructions('mahidol salaya', 'siam centre', _isThai),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            List<String> instructions = snapshot.data as List<String>;
                            return ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: instructions.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  title: Text(instructions[index]),
                                );
                              },
                            );
                          }
                        },
                      ),
                      SizedBox(height: 20),
                      FutureBuilder(
                        future: getDrivingInstructions('mahidol salaya', 'siam centre', _isThai),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            List<String> instructions = snapshot.data as List<String>;
                            return ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: instructions.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  title: Text(instructions[index]),
                                );
                              },
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}