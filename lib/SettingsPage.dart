// settings_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'DirectionPage.dart';
import 'Screens/SignUpScreen.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  User? _user;
  bool _isThai = false;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    _getLanguageSetting();
  }

  void _getLanguageSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isThai = prefs.getBool('isThai') ?? false;
    });
  }

  void _saveLanguageSetting(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isThai', value);
  }


  //to remove sign-in status from SharedPreferences and sign out from FirebaseAuth
  void _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('isSignedIn');
    await FirebaseAuth.instance.signOut();

    Navigator.of(context).popUntil((route) => route.isFirst);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SignUpScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    Color primaryColor = Color(0xffff2d55);
    Color secondaryColor = Color(0xfff5f5f5);
    TextStyle buttonTextStyle = TextStyle(
      fontSize: 15,
      fontFamily: 'SFUIDisplay',
      fontWeight: FontWeight.bold,
    );

    if (_user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Settings'),
          backgroundColor: primaryColor,
        ),
        body: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Text(
              'Profile',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: secondaryColor,
              ),
              child: Row(
                children: [
                  Icon(Icons.email_outlined),
                  SizedBox(width: 10),
                  Text(_user?.email ?? 'Anonymous'),
                ],
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              child: Text('Logout'),
              onPressed: _logout,
              style: ElevatedButton.styleFrom(
                primary: primaryColor,
                textStyle: buttonTextStyle,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
        ]),
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DirectionPage(),
                    ),
                  );
                  // Do nothing, already on the home page
                },
              ),
              IconButton(
                icon: Icon(Icons.settings),
                color: Colors.white,
                onPressed: () {
                  // Do nothing, already on the home page
                },
              ),
            ],
          ),
        ),
      );
    }


    //have account
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Profile',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: secondaryColor,
              ),
              child: Row(
                children: [
                  Icon(Icons.email_outlined),
                  SizedBox(width: 10),
                  Text(_user?.email ?? 'No email'),
                ],
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              child: Text('Logout'),
              onPressed: _logout,
              style: ElevatedButton.styleFrom(
                primary: primaryColor,
                textStyle: buttonTextStyle,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 30),
            Text(
              'Language',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              child: Text(_isThai ? 'Switch to English' : 'Switch to Thai'),
              onPressed: () {
                setState(() {
                  _isThai = !_isThai;
                  _saveLanguageSetting(_isThai);
                });
              },
              style: ElevatedButton.styleFrom(
                primary: primaryColor,
                textStyle: buttonTextStyle,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DirectionPage(),
                  ),
                );
                // Do nothing, already on the home page
              },
            ),
            IconButton(
              icon: Icon(Icons.settings),
              color: Colors.white,
              onPressed: () {
                // Do nothing, already on the home page
              },
            ),
          ],
        ),
      ),
    );
  }
}


