import 'package:path_provider/path_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
//'key=AIzaSyDOrFgXTQYS6XQa2XyHJPovSm3sw_VJ6TM'
Future<List<String>> getBusInstructions(String origin, String destination, bool isThai) async {
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
    List<String> instructions = [];
    List<dynamic> routes = decodedData['routes'][0]['legs'][0]['steps'];
    String? currentBusNumber;
    String? arrivalStop;
    String? arrivalTime;
    int totalTime = 0;

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

        if (busNumber != currentBusNumber) {
          currentBusNumber = busNumber;
          instructions.add('$departureTime\nTake bus $busNumber ($headsign) : $numStops stops\nArrive at $arrivalStop at $arrivalTime');
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

    int totalMinutes = (totalTime / 60).floor();
    int totalHours = (totalMinutes / 60).floor();
    totalMinutes = totalMinutes % 60;

    instructions.add('Arrive at destination. Total estimated time: ${totalHours}h ${totalMinutes}m');
    return instructions;
  } else {
    throw Exception('Failed to get directions.');
  }
}
Future<List<String>> getDrivingInstructions(String origin, String destination, bool isThai) async {
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
    int totalTime = 0;

    for (int i = 0; i < routes.length; i++) {
      String travelMode = routes[i]['travel_mode'];
      int stepDuration = routes[i]['duration']['value'];

      totalTime += stepDuration;

      if (travelMode == 'DRIVING') {
        String drivingInstruction = routes[i]['html_instructions'];
        drivingInstruction = drivingInstruction.replaceAll(RegExp('<[^>]*>'), ''); // Remove HTML tags
        String distance = routes[i]['distance']['text'];
        String duration = routes[i]['duration']['text'];

        instructions.add('Drive: $drivingInstruction ($distance, $duration)');
      }
    }

    int totalMinutes = (totalTime / 60).floor();
    int totalHours = (totalMinutes / 60).floor();
    totalMinutes = totalMinutes % 60;

    String totalDuration = '$totalHours h $totalMinutes m';

    instructions.insert(0, isThai ? 'วิธีการขับรถ' : 'Driving Directions');
    instructions.add(isThai ? 'มารถปลายทาง รวมเวลา: $totalDuration' : 'Arrive at destination. Total estimated time: $totalDuration');
    return instructions;
  } else {
    throw Exception('Failed to get directions.');
  }
}

void saveDecodedDataToFile(String decodedData) async {
  final file = await new File('decoded_data.txt').create();
  file.writeAsString(decodedData);
  print('File saved!');
}