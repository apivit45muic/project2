import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:http/http.dart' as http;

Future<void> fetchData() async {
  String url = 'https://datagov.mot.go.th/api/3/action/datastore_search?limit=5&resource_id=83cc22d0-a7aa-4709-bcdb-bc47476c2cc3';
  String apiKey = 'HyhrNARy7dzYP48hbe0auDUAvhvSc637';

  http.Response response = await http.get(
    Uri.parse(url),
    headers: {
      'api-key': apiKey,
    },
  );

  if (response.statusCode == 200) {
    var data = jsonDecode(response.body);
    print(data);
  } else {
    print('Request failed with status: ${response.statusCode}.');
  }
}

class TrainStation {
  late String type;
  late String originLine;
  late String originCode;
  late String originStation;
  late String destinationLine;
  late String destinationCode;
  late String destinationStation;
  late int fare;

  TrainStation(List<dynamic> row) {
    try {
      type = row[0];
      originLine = row[1];
      originCode = row[2];
      originStation = row[3];
      destinationLine = row[4];
      destinationCode = row[5];
      destinationStation = row[6];
      fare = row[7];
    } catch (e) {
      print('Error parsing fare: $e');
      type = '';
      originLine = '';
      originCode = '';
      originStation = '';
      destinationLine = '';
      destinationCode = '';
      destinationStation = '';
      fare = 0;
    }
  }
}
//String file = 'assets/drt2566_06-.csv';
Future<List<Map<String, String>>> loadSkytrainFareData() async {
  final fareDataString = await rootBundle.loadString('assets/drt2566_06-.csv');
  List<List<dynamic>> rowsAsListOfValues = const CsvToListConverter().convert(fareDataString);

  List<Map<String, String>> fareData = [];

  List<String> headers = rowsAsListOfValues[0].cast<String>();
  for (int i = 1; i < rowsAsListOfValues.length; i++) {
    List<String> rowValues = rowsAsListOfValues[i].map((value) => value.toString()).toList();
    Map<String, String> row = Map.fromIterables(headers, rowValues);
    fareData.add(row);
  }

  return fareData;
}




class TrainStationApp extends StatefulWidget {
  @override
  _TrainStationAppState createState() => _TrainStationAppState();
}

class _TrainStationAppState extends State<TrainStationApp> {
  List<TrainStation> _stations = [];

  Future<void> _loadStations() async {
    final csvString = await rootBundle.loadString('assets/drt2566_06-.csv');
    final csv = CsvToListConverter().convert(csvString);
    setState(() {
      _stations = csv.map((row) => TrainStation(row)).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _loadStations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Train Station App'),
      ),
      body: Center(
        child: _stations.isEmpty
            ? CircularProgressIndicator()
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Select origin station:',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            DropdownButton<String>(
              value: null,
              hint: Text('Select station'),
              onChanged: (value) {},
              items: _stations.map((station) {
                return DropdownMenuItem(
                  value: station.originStation,
                  child: Text(station.originStation),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            Text(
              'Select destination station:',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            DropdownButton<String>(
              value: null,
              hint: Text('Select station'),
              onChanged: (value) {},
              items: _stations.map((station) {
                return DropdownMenuItem(
                  value: station.destinationStation,
                  child: Text(station.destinationStation),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              child: Text('Calculate fare'),
            ),
          ],
        ),
      ),
    );
  }
}
