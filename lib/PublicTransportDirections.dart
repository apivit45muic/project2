import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class PublicTransportDirections extends StatefulWidget {
  final LatLng start;
  final LatLng end;

  const PublicTransportDirections({Key? key, required this.start, required this.end}) : super(key: key);

  @override
  _PublicTransportDirectionsState createState() => _PublicTransportDirectionsState();
}

class _PublicTransportDirectionsState extends State<PublicTransportDirections> {
  late List<String> directions;

  @override
  void initState() {
    super.initState();
    _getDirections();
  }

  Future<void> _getDirections() async {
    final apiKey = 'AIzaSyDOrFgXTQYS6XQa2XyHJPovSm3sw_VJ6TM';
    final url = Uri.parse('https://maps.googleapis.com/maps/api/directions/json'
        '?origin=${widget.start.latitude},${widget.start.longitude}'
        '&destination=${widget.end.latitude},${widget.end.longitude}'
        '&mode=transit'
        '&transit_mode=bus'
        '&key=$apiKey');
    final response = await http.get(url);
    final data = json.decode(response.body);
    setState(() {
      directions = _parseDirections(data);
    });
  }

  List<String> _parseDirections(Map<String, dynamic> data) {
    final routes = data['routes'] as List<dynamic>;
    final legs = routes[0]['legs'] as List<dynamic>;
    final steps = legs[0]['steps'] as List<dynamic>;
    final busSteps = steps.where((step) => step['travel_mode'] == 'TRANSIT' && step['transit_details']['line']['vehicle']['type'] == 'BUS').toList();
    final directions = busSteps.map<String>((step) {
      final line = step['transit_details']['line'];
      final vehicleType = line['vehicle']['name'];
      final routeName = line['short_name'];
      final arrivalStop = step['transit_details']['arrival_stop']['name'];
      final departureStop = step['transit_details']['departure_stop']['name'];
      return '$vehicleType $routeName from $departureStop to $arrivalStop';
    }).toList();
    return directions;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Public Transport Directions'),
      ),
      body: ListView.builder(
        itemCount: directions.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(directions[index]),
          );
        },
      ),
    );
  }
}
