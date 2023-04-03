import 'package:flutter/material.dart';
import 'package:project2/getDirection.dart';
import 'package:project2/HistoryPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'SettingsPage.dart';

// Add the common colors and text styles here
const Color backgroundColor = Color(0xfff5f5f5);
const Color primaryColor = Color(0xffff2d55);

const TextStyle buttonTextStyle = TextStyle(
  fontSize: 15,
  fontFamily: 'SFUIDisplay',
  fontWeight: FontWeight.bold,
  color: Colors.white,
);

class DirectionPage extends StatefulWidget {
  @override
  _DirectionPageState createState() => _DirectionPageState();
}

class _DirectionPageState extends State<DirectionPage> {
  bool _isThai = false;

  @override
  void initState() {
    super.initState();
    _getLanguageSetting();
  }

  void _getLanguageSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isThai = prefs.getBool('isThai') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Directions App'),
        backgroundColor: primaryColor,
      ),
      body: Column(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GetDirection(
                      isThai: _isThai,
                    ),
                  ),
                );
              },
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/directions_image.png', // Replace with your own image asset
                    fit: BoxFit.cover,
                  ),
                  Container(
                    color: primaryColor.withOpacity(0.0),
                  ),
                  Positioned(
                    top: 260, // Change this value to position the text further down
                    left: 0,
                    right: 0,
                    child : Center(
                      child: Text(
                      _isThai ? 'ไปยังหน้าเส้นทาง' : 'Go to Directions',
                        style: buttonTextStyle.copyWith(fontSize: 28,
                          color: Colors.black54,
                          shadows: [
                            Shadow(
                              offset: Offset(1.0, 1.0),
                              blurRadius: 3.0,
                              color: Color.fromARGB(255, 0, 0, 0),
                            ),
                          ],
                        ),
                    ),
                  ),
                  )],
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HistoryPage(),
                  ),
                );
              },
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 200, maxHeight: 200),
                      child: Image.asset(
                        'assets/history.png', // Replace with your own image asset
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  Container(
                    color: primaryColor.withOpacity(0.0),
                  ),
                  Positioned(
                  top: 265, // Change this value to position the text further down
                  left: 0,
                  right: 0,
                  child : Center(
                    child: Text(
                      _isThai ? 'ดูประวัติ' : 'View History',
                      style: buttonTextStyle.copyWith(fontSize: 28,
                        color: Colors.black54,
                        shadows: [
                          Shadow(
                            offset: Offset(1.0, 1.0),
                            blurRadius: 3.0,
                            color: Color.fromARGB(255, 0, 0, 0),
                          ),
                        ],
                      ),
                    ),
                  ),
                  )],
              ),
            ),
          ),


        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: primaryColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: Icon(Icons.home),
              color: Colors.white,
              onPressed: () {
                // Do nothing, already on the home page
              },
            ),
            IconButton(
              icon: Icon(Icons.settings),
              color: Colors.white,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingsPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}