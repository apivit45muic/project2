import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:project2/util.dart';
import 'package:geocoding/geocoding.dart';
import 'package:tuple/tuple.dart';

// Add this import

class GetDirection extends StatefulWidget {
  final bool isThai;

  GetDirection({required this.isThai});

  @override
  _GetDirectionState createState() => _GetDirectionState();
}

class _GetDirectionState extends State<GetDirection> {
  String? origin;
  String destination = '';
  TextEditingController originController = TextEditingController();
  TextEditingController destinationController = TextEditingController();
  String isSaved = 'none'; // Add this variable
  double busFare = 0.0;
  double taxiFare = 0.0;

  @override
  void initState() {
    super.initState();
    initAsync();
  }

  Future<void> initAsync() async {
    await getCurrentLocation();
    print("origin : $origin");
    setState(() {
      originController.text = '$origin';
    });
  }

  Future<void> getCurrentLocation() async {
    print('Entering getCurrentLocation()');
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Permission denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('Permission denied forever');
    }

    if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      print('Position obtained: $position');
      setState(() {
        origin = '${position.latitude},${position.longitude}';
        print('Origin set to: $origin');
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    bool isThai = widget.isThai;
    Color primaryColor = Color(0xffff2d55);
    Color secondaryColor = Color(0xfff5f5f5);
    TextStyle buttonTextStyle = TextStyle(
      fontSize: 15,
      fontFamily: 'SFUIDisplay',
      fontWeight: FontWeight.bold,
    );


    return Scaffold(
      appBar: AppBar(
        title: Text('Directions'),
        backgroundColor: primaryColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: originController,
              decoration: InputDecoration(
                labelText: isThai ? 'ต้นทาง' : 'Origin',
              ),
            ),
            TextField(
              controller: destinationController,
              decoration: InputDecoration(
                labelText: isThai ? 'ปลายทาง' : 'Destination',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  origin = originController.text.isEmpty ? origin : originController.text;
                  destination = destinationController.text;
                });
              },
              style: ElevatedButton.styleFrom(
                primary: primaryColor,
                textStyle: buttonTextStyle,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(isThai ? 'ค้นหาเส้นทาง' : 'Get Directions'),
            ),
            // Check if destination and origin are set before showing the FutureBuilders
            if (destination.isNotEmpty && origin != null)
              Column(
                children: [
                  if (isSaved == 'none' || isSaved == 'bus')
                    FutureBuilder<Tuple2<List<String>, double>>(
            future: getBusInstructions(origin!, destination, isThai),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                Tuple2<List<String>, double> result = snapshot.data as Tuple2<List<String>, double>;
                List<String> instructions = result.item1;
                busFare = result.item2;
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
                  ElevatedButton(
                    onPressed: isSaved != 'none' ? null : () {
                      if (busFare == 0) {
                        return;
                      }
                      saveToHistory(destination, busFare, 'bus');
                      setState(() {
                        isSaved = 'bus';
                      });
                    },
                    style: isSaved != 'none' ? ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.grey),
                    ) : ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.green),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check,
                          color: Colors.white,
                        ),
                        SizedBox(width: 8),
                        Text(
                          isThai ? 'บันทึกลงประวัติ' : 'Save to history',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
            SizedBox(height: 20),
                  if (isSaved == 'none' || isSaved == 'taxi')
            FutureBuilder<Tuple2<List<String>, double>>(
              future: getDrivingInstructions(origin!, destination, isThai),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  Tuple2<List<String>, double> result = snapshot.data as Tuple2<List<String>, double>;
                  List<String> instructions = result.item1;
                  taxiFare = result.item2;
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
      ElevatedButton(
        onPressed: isSaved != 'none' ? null : () {
          if (taxiFare == 0) {
            return;
          }
          saveToHistory(destination, taxiFare, 'taxi');
          setState(() {
            isSaved = 'taxi';
          });
        },
        style: isSaved != 'none' ? ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.grey),
        ) : ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.green),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check,
              color: Colors.white,
            ),
            SizedBox(width: 8),
            Text(
              isThai ? 'บันทึกลงประวัติ' : 'Save to history',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
],
        ),
              ],
            ),
        ),
    );
  }
}
