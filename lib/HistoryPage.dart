import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';


// Add the common colors and text styles here
const Color backgroundColor = Color(0xfff5f5f5);
const Color primaryColor = Color(0xffff2d55);

const TextStyle headingTextStyle = TextStyle(
  fontSize: 20,
  fontFamily: 'SFUIDisplay',
  fontWeight: FontWeight.bold,
);

const TextStyle subtitleTextStyle = TextStyle(
  fontSize: 16,
  fontFamily: 'SFUIDisplay',
);

class HistoryPage extends StatefulWidget {

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
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
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(_isThai ?'ประวัติ':'History'),
          backgroundColor: primaryColor,
        ),
        body: Center(
          child: Text('Please log in to view your history.'),
        ),
      );
    }

    String userID = user.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isThai ?'ประวัติ':'History'),
        backgroundColor: primaryColor,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('history')
            .where('user', isEqualTo: userID)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          List<QueryDocumentSnapshot> historyData = snapshot.data!.docs;

          if (historyData.isEmpty) {
            return Center(
              child: Text('You do not have any history yet.'),
            );
          }

          return ListView.separated(
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: Colors.grey[400],
            ),
            itemCount: historyData.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> data = historyData[index].data() as Map<String, dynamic>;
              DateTime timestamp = (data['timestamp'] as Timestamp).toDate();

              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${data['type']} - ${data['destination']}',
                      style: headingTextStyle,
                    ),
                    SizedBox(height: 8),
                    Text(
                      '${data['totalFare']}' ' Baht  ' ' ${timestamp.toLocal()}',
                      style: subtitleTextStyle,
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
