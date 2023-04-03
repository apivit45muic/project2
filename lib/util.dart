import 'package:path_provider/path_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:tuple/tuple.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'TrainStationApp.dart';


//'key=AIzaSyDOrFgXTQYS6XQa2XyHJPovSm3sw_VJ6TM'
Future<Tuple2<List<String>, double>> getBusInstructions(String origin, String destination, bool isThai) async {
  String language= isThai ? 'th' : 'en';
  String apiUrl = 'https://maps.googleapis.com/maps/api/directions/json?'
      'origin=$origin&'
      'destination=$destination&'
      'mode=transit&'
      'language=$language&'
      'key=AIzaSyDOrFgXTQYS6XQa2XyHJPovSm3sw_VJ6TM';

  final response = await http.get(Uri.parse(apiUrl));

  if (response.statusCode == 200) {
    final decodedData = jsonDecode(response.body);
    print("decodedData:$decodedData");
    List<String> instructions = [];
    List<dynamic> routes = decodedData['routes'][0]['legs'][0]['steps'];
    String? currentBusNumber;
    String? arrivalStop;
    String? arrivalTime;
    int totalTime = 0;
    List<String> busNums = [];
    List<int> distances = [];

    for (int i = 0; i < routes.length; i++) {
      String travelMode = routes[i]['travel_mode'];
      int stepDuration = routes[i]['duration']['value'];

      totalTime += stepDuration;

      if (travelMode == 'TRANSIT') {
        String busNumber = routes[i]['transit_details']['line']['short_name'] ?? routes[i]['transit_details']['line']['name'];
        String headsign = routes[i]['transit_details']['headsign'];
        String departureTime = routes[i]['transit_details']['departure_time']['text'];
        int numStops = routes[i]['transit_details']['num_stops'];
        arrivalStop = routes[i]['transit_details']['arrival_stop']['name'];
        arrivalTime = routes[i]['transit_details']['arrival_time']['text'];
        print("Processing bus number: $busNumber");

        int distance = routes[i]['distance']['value'];

        busNums.add(busNumber);
        distances.add(distance);

        if (currentBusNumber == null || busNumber != currentBusNumber) {
          currentBusNumber = busNumber;
          if (busNumber.toLowerCase().contains('line')) { // Check if it's a Skytrain
            instructions.add('$departureTime\nTake Skytrain $busNumber ($headsign) : $numStops stops\nArrive at $arrivalStop at $arrivalTime');
          } else {
            instructions.add('$departureTime\nTake bus $busNumber ($headsign) : $numStops stops\nArrive at $arrivalStop at $arrivalTime');
          }
        }
      } else if (travelMode == 'WALKING') {
        String walkingInstruction = routes[i]['html_instructions'];
        walkingInstruction = walkingInstruction.replaceAll(RegExp('<[^>]*>'), ''); // Remove HTML tags
        String distance = routes[i]['distance']['text'];
        String duration = routes[i]['duration']['text'];

        instructions.add('Walk: $walkingInstruction ($distance, $duration)');
      } else if (travelMode == 'DRIVING') {
        String drivingInstruction = routes[i]['html_instructions'];
        drivingInstruction = drivingInstruction.replaceAll(RegExp('<[^>]*>'), ''); // Remove HTML tags
        String distance = routes[i]['distance']['text'];
        String duration = routes[i]['duration']['text'];

    instructions.add('Drive: $drivingInstruction ($distance, $duration)');}
      else {
        // Handle other travel modes (e.g. biking, driving).
      }
    }
    List<double> fares = [];
    double totalFares = 0.0;
    final fareData = await loadSkytrainFareData();

    int busIndex = 0;
    for (int i = 0; i < routes.length; i++) {
      if (routes[i]['travel_mode'] == 'TRANSIT') {
        String busNumber = busNums[busIndex];
        String departureStation = routes[i]['transit_details']['departure_stop']['name'];
        String arrivalStation = routes[i]['transit_details']['arrival_stop']['name'];
        double fare = calculateFare(busNumber, distances[busIndex], departureStation, arrivalStation, fareData);
        fares.add(fare);
        print("fare of ${busNums[busIndex]} is $fare");
        totalFares += fare;
        busIndex++;
      }
    }

    instructions.add("Total estimate price is is $totalFares.");

    int totalMinutes = (totalTime / 60).floor();
    int totalHours = (totalMinutes / 60).floor();
    totalMinutes = totalMinutes % 60;

    instructions.add('Arrive at destination. Total estimated time: ${totalHours}h ${totalMinutes}m');
    return Tuple2(instructions,totalFares);
  } else {
    throw Exception('Failed to get directions.');
  }
}
Future<Tuple2<List<String>, double>> getDrivingInstructions(String origin, String destination, bool isThai) async {
  String apiUrl = 'https://maps.googleapis.com/maps/api/directions/json?'
      'origin=$origin&'
      'destination=$destination&'
      'mode=driving&'
      'key=AIzaSyDOrFgXTQYS6XQa2XyHJPovSm3sw_VJ6TM';

  final response = await http.get(Uri.parse(apiUrl));

  if (response.statusCode == 200) {
    final decodedData = jsonDecode(response.body);
    List<String> instructions = [];
    List<dynamic> routes = decodedData['routes'][0]['legs'][0]['steps'];
    String primaryRoute = decodedData['routes'][0]['summary'];
    int totalTime = 0;
    double totalDistance = 0.0;
    int trafficJamTime = 0;
    const double speedThreshold = 6.0 / 3.6; // 6 km/h in meters per second

    for (int i = 0; i < routes.length; i++) {
      String travelMode = routes[i]['travel_mode'];
      int stepDuration = routes[i]['duration']['value'];

      totalTime += stepDuration;

      if (travelMode == 'DRIVING') {
        String drivingInstruction = routes[i]['html_instructions'];
        drivingInstruction = drivingInstruction.replaceAll(RegExp('<[^>]*>'), ''); // Remove HTML tags
        String distance = routes[i]['distance']['text'];
        String duration = routes[i]['duration']['text'];
        int distanceValue = routes[i]['distance']['value'];
        // print("distance: $distanceValue");
        totalDistance += distanceValue.toDouble();

        double averageSpeed = distanceValue / stepDuration;

        if (averageSpeed <= speedThreshold) {
          trafficJamTime += stepDuration;
        }

        // instructions.add('Drive: $drivingInstruction ($distance, $duration)');
      }
    }

    int totalMinutes = (totalTime / 60).floor();
    int totalHours = (totalMinutes / 60).floor();
    totalMinutes = totalMinutes % 60;

    String totalDuration = '$totalHours h $totalMinutes m';
    int trafficJamMinutes = (trafficJamTime / 60).floor();
    String trafficJamDuration = '$trafficJamMinutes minutes';

    instructions.insert(0, isThai ? 'เส้นทางที่ใช้' : 'Driving Directions');
    instructions.add(primaryRoute);
    double totalPrice = taxiPriceCalculator(totalDistance/1000, trafficJamMinutes);
    instructions.add("Total estimate price is $totalPrice");
    instructions.add(isThai ? 'มารถปลายทาง รวมเวลา: $totalDuration' : 'Arrive at destination. Total estimated time: $totalDuration');
    print("totalDistance is $totalDistance or ${totalDistance/1000}");
    print("trafficJamDuration is $trafficJamDuration");
    print("Total estimate price is $totalPrice");
    print("primaryRoute is $primaryRoute");
    return Tuple2(instructions,totalPrice);
  } else {
    throw Exception('Failed to get directions.');
  }
}

void saveDecodedDataToFile(String decodedData) async {
  final file = await new File('decoded_data.txt').create();
  file.writeAsString(decodedData);
  print('File saved!');
}

double taxiPriceCalculator(double totalDistance, int trafficJamMinutes){
    double fare = 0.0;

    if (totalDistance <= 1) {
      fare = 35.0;
    } else if (totalDistance <= 10) {
      fare = 35.0 + (totalDistance - 1) * 6.50;
    } else if (totalDistance <= 20) {
      fare = 35.0 + 9 * 6.50 + (totalDistance - 10) * 7.00;
    } else if (totalDistance <= 40) {
      fare = 35.0 + 9 * 6.50 + 10 * 7.00 + (totalDistance - 20) * 8.00;
    } else if (totalDistance <= 60) {
      fare = 35.0 + 9 * 6.50 + 10 * 7.00 + 20 * 8.00 + (totalDistance - 40) * 8.50;
    } else if (totalDistance <= 80) {
      fare = 35.0 + 9 * 6.50 + 10 * 7.00 + 20 * 8.00 + 20 * 8.50 + (totalDistance - 60) * 9.00;
    } else {
      fare = 35.0 + 9 * 6.50 + 10 * 7.00 + 20 * 8.00 + 20 * 8.50 + 20 * 9.00 + (totalDistance - 80) * 10.50;
    }

    return fare += trafficJamMinutes*6;
}

double calculateFare(String busNum, int distance, String departureStation, String arrivalStation, List<Map<String, String>> fareData) {
  double fare;
  print("calculate fare of $busNum");

  if (busNum.contains('AC')) {
    fare = 16.0; // Base fare for AC buses
  } else if (busNum.contains('BRT')) {
    fare = 15.0; // Flat fare for BRT buses
  } else if (busNum.contains('A3') || busNum.contains('A4')) {
    fare = 50.0; // Flat fare for A3 and A4 buses
  } else if (busNum.toLowerCase().contains('line')) {
    fare = 0.0; // Initialize fare for Skytrains
    for (var fareRow in fareData) {
      if (fareRow['สถานีต้นทาง'] == departureStation && fareRow['สถานีปลายทาง'] == arrivalStation) {
        fare = double.parse((fareRow['ค่าโดยสารหน่วยบาท']?.replaceAll(' ', '') ?? '').trim());
        break;
      }
    }
  } else {
    fare = 8.0; // Base fare for regular buses
  }

  // Increment fare based on distance
  if (busNum.contains('AC')) {
    if (distance > 4 || distance < 16) {
      fare += 5;
    } else if (distance > 16){
      fare += 10;
    }
  }

  return fare;
}



Future<void> saveToHistory(String destination, double totalFare, String type) async {
  User? user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    print('User not logged in');
    return;
  }

  String userID = user.uid;

  CollectionReference history = FirebaseFirestore.instance.collection('history');

  return history
      .add({
    'user': userID,
    'destination': destination,
    'totalFare': totalFare,
    'type': type, // 'bus' or 'taxi'
    'timestamp': FieldValue.serverTimestamp(), // Add a timestamp to keep track of when the data was saved
  })
      .then((value) => print('History saved'))
      .catchError((error) => print('Failed to save history: $error'));
}


