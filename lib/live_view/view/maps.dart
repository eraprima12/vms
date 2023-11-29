import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:provider/provider.dart';
import 'package:vms/auth/controller/drivers_controller.dart';
import 'package:vms/constant.dart';
import 'package:vms/live_view/view/detail_vehicle.dart';
import 'package:vms/live_view/widget/custom_marker.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final StreamController<QuerySnapshot<Map<String, dynamic>>>
      _markersController = StreamController.broadcast();
  Stream<QuerySnapshot<Map<String, dynamic>>>? _markersStream;
  late MapController mapController;
  TextEditingController srcController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {},
    );
    mapController = MapController();
    _markersStream =
        FirebaseFirestore.instance.collection('driver').snapshots();
    _markersStream!.listen((event) {
      _markersController.add(event);
    });
  }

  SearchController searchController = SearchController();

  @override
  Widget build(BuildContext context) {
    var driverProvider = Provider.of<DriversController>(context);
    var unlistenedDiverProvider =
        Provider.of<DriversController>(context, listen: false);
    return SafeArea(
      child: Scaffold(
        body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _markersController.stream,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            List<Marker> markers = [];
            for (var document in snapshot.data!.docs) {
              var data = document.data();
              if (data['latestPosition'] != null) {
                GeoPoint geoPoint = data['latestPosition'];
                String licensePlate = data['licensePlate'];
                String status = data['status'];
                markers.add(
                  Marker(
                    width: 100.0,
                    height: 80.0,
                    point: LatLng(geoPoint.latitude, geoPoint.longitude),
                    child: GestureDetector(
                      onTap: () {
                        pageMover.push(
                          widget: DetailVehiclePage(
                            licensePlate: licensePlate,
                          ),
                        );
                      },
                      child: CustomMarker(
                          licensePlate: licensePlate, status: status),
                    ),
                  ),
                );
              }
            }

            return Stack(
              children: [
                FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    maxZoom: 12,
                    minZoom: 4,
                    initialCameraFit: CameraFit.bounds(
                      bounds: driverProvider
                          .getBoundsFromLatLngList(driverProvider.latlnglist),
                      padding: const EdgeInsets.all(50),
                    ),
                    interactiveFlags:
                        InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: mapKey,
                      additionalOptions: {'accessToken': mbToken, 'id': mbId},
                    ),
                    MarkerLayer(
                      markers: markers,
                    ),
                    MarkerClusterLayer(
                      mapController: mapController,
                      mapCamera: MapCamera.initialCamera(
                        const MapOptions(),
                      ),
                      options: MarkerClusterLayerOptions(
                        maxClusterRadius: 120,
                        size: const Size(40, 40000),
                        alignment: Alignment.center,
                        markers: markers,
                        polygonOptions: const PolygonOptions(
                          borderColor: Colors.blueAccent,
                          color: Colors.black12,
                          borderStrokeWidth: 3,
                        ),
                        builder: (context, markers) {
                          return Container(
                            color: Colors.blueAccent,
                            padding: const EdgeInsets.all(40),
                            child: Text(
                              markers.length.toString(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: 20,
                  right: 10,
                  left: 10,
                  child: SearchAnchor(
                    viewBackgroundColor:
                        const Color.fromARGB(255, 255, 255, 255),
                    viewShape: const ContinuousRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(20),
                      ),
                      side: BorderSide(
                        color: Color.fromARGB(255, 255, 255, 255),
                      ),
                    ),
                    searchController: searchController,
                    isFullScreen: true,
                    suggestionsBuilder:
                        (BuildContext context, SearchController controller) {
                      final filteredDrivers = driverProvider.driverData
                          .where(
                            (element) =>
                                element.licensePlate.toLowerCase().contains(
                                      searchController.text.toLowerCase(),
                                    ) ||
                                element.name.toLowerCase().contains(
                                      searchController.text.toLowerCase(),
                                    ),
                          )
                          .toList();
                      return List<ListTile>.generate(
                        filteredDrivers.length,
                        (int index) {
                          final String name = filteredDrivers[index].name;
                          final String licensePlate =
                              filteredDrivers[index].licensePlate;
                          return ListTile(
                            title: Text(name),
                            trailing: Text(licensePlate),
                            onTap: () {
                              FocusManager.instance.primaryFocus?.unfocus();
                              searchController.closeView(name);
                              pageMover.push(
                                widget: DetailVehiclePage(
                                  licensePlate: licensePlate,
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                    builder:
                        (BuildContext context, SearchController controller) {
                      return SearchBar(
                        shape: MaterialStateProperty.all(
                          const ContinuousRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(20),
                            ),
                          ),
                        ),
                        onTap: () {
                          searchController.openView();
                        },
                        controller: searchController,
                        leading: const Icon(Icons.search),
                        hintText: 'Search',
                        backgroundColor: MaterialStateColor.resolveWith(
                          (states) => const Color.fromARGB(255, 255, 255, 255),
                        ),
                        onChanged: (val) {
                          searchController.openView();
                          setState(() {});
                        },
                      );
                    },
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}
