import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class TripHistory extends StatefulWidget {
  const TripHistory({super.key});

  @override
  _TripHistoryPageState createState() => _TripHistoryPageState();
}

class _TripHistoryPageState extends State<TripHistory> {
  List<LatLng> defaultLatLngData = generateDefaultLatLngData();
  List<LatLng> animatedLatLngList = [];
  MapController mapController = MapController();

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip History'),
      ),
      body: FlutterMap(
        options: MapOptions(
          center: defaultLatLngData.isNotEmpty
              ? defaultLatLngData.first
              : const LatLng(0, 0),
          zoom: 15.0,
        ),
        mapController: mapController,
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: const ['a', 'b', 'c'],
          ),
          PolylineLayer(
            polylines: [
              Polyline(
                points: animatedLatLngList,
                color: Colors.blue,
                strokeWidth: 4.0,
              ),
            ],
          ),
          MarkerLayer(
            markers: [
              Marker(
                width: 30.0,
                height: 30.0,
                point: animatedLatLngList.isNotEmpty
                    ? animatedLatLngList.last
                    : const LatLng(0, 0),
                child: const Icon(
                  Icons.location_on,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _startAnimation() async {
    for (int i = 0; i < defaultLatLngData.length; i++) {
      await Future.delayed(
          const Duration(milliseconds: 500)); // Adjust as needed

      setState(() {
        animatedLatLngList.add(defaultLatLngData[i]);
      });

      mapController.move(animatedLatLngList.last, 15.0);
    }
  }

  static List<LatLng> generateDefaultLatLngData() {
    List<LatLng> defaultLatLngData = [];
    for (int i = 0; i < 100; i++) {
      double lat = 37.7749 + i * 0.0001;
      double lng = -122.4194 + i * 0.0001;
      defaultLatLngData.add(LatLng(lat, lng));
    }
    return defaultLatLngData;
  }
}
