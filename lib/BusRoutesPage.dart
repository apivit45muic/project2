import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BusRoutesPage extends StatefulWidget {
  @override
  _BusRoutesPageState createState() => _BusRoutesPageState();
}

class _BusRoutesPageState extends State<BusRoutesPage> {
  final Set<Polyline> _polyLines = {};
  late GoogleMapController _mapController;
  String _startAddress = '';
  String _destinationAddress = '';
  late LatLng _startCoordinates;
  late LatLng _destinationCoordinates;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _startCoordinates,
              zoom: 14.0,
            ),
            polylines: _polyLines,
            onMapCreated: (controller) {
              _mapController = controller;
            },
          ),
          Positioned(
            top: 50.0,
            left: 10.0,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Icon(Icons.arrow_back),
            ),
          ),
          Positioned(
            bottom: 10.0,
            left: 10.0,
            right: 10.0,
            child: Container(
              height: 100.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'From: $_startAddress',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  Text(
                    'To: $_destinationAddress',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _getDirections();
                    },
                    child: Text('Get Bus Routes'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _getUserLocation() async {
    // Use the geolocator package to get the user's current location
    // and set the initial camera position of the map.
    // ...
  }

  Future<void> _getDirections() async {
    String apiUrl = 'https://maps.googleapis.com/maps/api/directions/json?'
        'origin=${_startCoordinates.latitude},${_startCoordinates.longitude}&'
        'destination=${_destinationCoordinates.latitude},${_destinationCoordinates.longitude}&'
        'mode=transit&'
        'key=YOUR_API_KEY_HERE';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final decodedData = jsonDecode(response.body);

      List<LatLng> points = [];
      List<dynamic> routes = decodedData['routes'][0]['legs'][0]['steps'];
      for (int i = 0; i < routes.length; i++) {
        String polyline = routes[i]['polyline']['points'];
        points.addAll(_decodePolyline(polyline));
      }

      setState(() {
        _polyLines.add(Polyline(
          polylineId: PolylineId('busRoute'),
          color: Colors.blue,
          points: points,
        ));

        _startAddress = decodedData['routes'][0]['legs'][0]['start_address'];
        _destinationAddress = decodedData['routes'][0]['legs'][0]['end_address'];
      });

      // Adjust camera position to show both the start and end locations.
      LatLngBounds bounds = LatLngBounds(
        southwest: _startCoordinates,
        northeast: _destinationCoordinates,
      );
      _mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
    } else {
      throw Exception('Failed to get directions.');
    }
}

  List<LatLng> _decodePolyline(String polyline) {
    List<LatLng> points = [];
    int index = 0,
        len = polyline.length;
    int lat = 0,
        lng = 0;

    while (index < len) {
      int b,
          shift = 0,
          result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return points;
  }
}