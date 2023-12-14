// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:vms/auth/controller/drivers_controller.dart';
import 'package:vms/auth/model/user_model.dart';
import 'package:vms/constant.dart';
import 'package:vms/global/widget/widgettext.dart';

class TripHistory extends StatefulWidget {
  const TripHistory({Key? key, required this.uid}) : super(key: key);
  final String uid;

  @override
  _TripHistoryPageState createState() => _TripHistoryPageState();
}

class _TripHistoryPageState extends State<TripHistory> {
  List<LatLng> animatedLatLngList = [];

  Timestamp? value;
  MapController mapController = MapController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late User data;
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        await Provider.of<DriversController>(context, listen: false)
            .getAndMapDriverData();
        data = Provider.of<DriversController>(context, listen: false)
            .driverData
            .where((element) => element.uid == widget.uid)
            .first;
        value = data.tripHistory[0];
        setState(() {});
      },
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<DriversController>(context);
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Trip History'),
      ),
      body: value == null
          ? const Center(
              child: CupertinoActivityIndicator(),
            )
          : Scaffold(
              bottomNavigationBar: Container(
                height: 80,
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: GestureDetector(
                  onTap: () {
                    _startAnimation(date: value!);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          offset: const Offset(0, 1),
                          spreadRadius: 1,
                          blurRadius: 5,
                          color: primaryColor,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          WidgetText(
                            text: 'Play',
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Icon(
                            Icons.play_circle,
                            color: Colors.white,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              body: Stack(
                children: [
                  FlutterMap(
                    options: const MapOptions(
                      center: LatLng(-7.2, 112),
                      zoom: 15.0,
                    ),
                    mapController: mapController,
                    children: [
                      TileLayer(
                        urlTemplate:
                            "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                        subdomains: const ['a', 'b', 'c'],
                      ),
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: animatedLatLngList,
                            color: primaryColor,
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
                  DraggableScrollableSheet(
                    maxChildSize: 0.2,
                    minChildSize: 0.2,
                    initialChildSize: 0.2,
                    builder: (BuildContext context,
                        ScrollController scrollController) {
                      return Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        child: SingleChildScrollView(
                          controller: scrollController,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Center(
                                child: Container(
                                  width: 40,
                                  height: 5,
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              DropDownWidget(
                                  selectedValue: value!,
                                  onChanged: (values) {
                                    value = values;
                                    setState(() {});
                                  },
                                  tripHistory: data.tripHistory),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }

  void _startAnimation({required Timestamp date}) async {
    animatedLatLngList = [];
    var dataWithDate = data.position
        .where((element) =>
            DateFormat('dd-MMM-yyyy').format(element.dateTime) ==
            DateFormat('dd-MMM-yyyy').format(date.toDate()))
        .toList();
    logger.f(dataWithDate.length);
    for (int i = 0; i < dataWithDate.length; i++) {
      await Future.delayed(
          const Duration(milliseconds: 500)); // Adjust as needed

      setState(() {
        animatedLatLngList.add(LatLng(dataWithDate[i].geopoint.latitude,
            dataWithDate[i].geopoint.longitude));
      });

      mapController.move(animatedLatLngList.last, 15.0);
    }
  }
}

class DropDownWidget extends StatelessWidget {
  final Timestamp selectedValue;
  final ValueChanged<Timestamp?> onChanged;
  final List<Timestamp> tripHistory;

  const DropDownWidget({
    required this.selectedValue,
    required this.onChanged,
    required this.tripHistory,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const WidgetText(
            text: 'Select Date',
            fontWeight: FontWeight.bold,
          ),
          DropdownButton<Timestamp>(
            isExpanded: true,
            value: selectedValue,
            onChanged: onChanged,
            items: tripHistory
                .map<DropdownMenuItem<Timestamp>>(
                  (Timestamp value) => DropdownMenuItem<Timestamp>(
                    value: value,
                    child: WidgetText(
                        text: DateFormat('dd-MMM-yyyy').format(value.toDate())),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
