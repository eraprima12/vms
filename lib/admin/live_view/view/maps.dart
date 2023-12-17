import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:vms/admin/live_view/view/detail_vehicle.dart';
import 'package:vms/admin/live_view/widget/custom_marker.dart';
import 'package:vms/auth/controller/drivers_controller.dart';
import 'package:vms/auth/model/driver_model.dart';
import 'package:vms/auth/model/user_model.dart';
import 'package:vms/constant.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late StreamController<List<User>> _userStreamController;
  late StreamSubscription<QuerySnapshot> _userSubscription;
  late MapController mapController;

  SearchController searchController = SearchController();
  @override
  void initState() {
    super.initState();
    mapController = MapController();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        Provider.of<DriversController>(context, listen: false)
            .getAndMapDriverData();
      },
    );
    _userStreamController = StreamController<List<User>>.broadcast();
    _startListeningToUserData();
  }

  @override
  void dispose() {
    _userStreamController.close();
    _userSubscription.cancel();
    super.dispose();
  }

  void _startListeningToUserData() {
    String? companyUid = localStorage.read(companyUidKey) ?? '';
    _userSubscription = FirebaseFirestore.instance
        .collection('user')
        .where('type', isEqualTo: driverKey)
        .where('company_uid', isEqualTo: companyUid)
        .snapshots()
        .listen((userSnapshot) {
      if (userSnapshot.docs.isNotEmpty) {
        _fetchUserData(userSnapshot.docs).then((users) {
          _userStreamController.add(users);
        });
      }
    });
  }

  Future<List<User>> _fetchUserData(
      List<QueryDocumentSnapshot<Object?>> docs) async {
    List<User> users = [];

    var futures = <Future>[];

    for (var userDoc in docs) {
      var userRef =
          FirebaseFirestore.instance.collection('user').doc(userDoc.id);

      var positionsSnapshot = await userRef
          .collection('position')
          .get(); // Fetch positions directly

      var temp = User.fromJson(userDoc.data() as Map<String, dynamic>);
      var vehicleRef =
          FirebaseFirestore.instance.collection('vehicle').doc(temp.vehicleUid);

      var future = vehicleRef.get();
      futures.add(future);

      users.add(temp
        ..position = positionsSnapshot.docs.map((positionDoc) {
          return PositionModel.fromMap(positionDoc.data());
        }).toList());
    }

    var vehicleSnapshots = await Future.wait(futures);

    for (var i = 0; i < users.length; i++) {
      var snapshot = vehicleSnapshots[i];
      Map<String, dynamic> dataVehicle =
          snapshot.data() as Map<String, dynamic>;
      Vehicle vehicle = Vehicle.fromJson(dataVehicle);
      users[i].vehicle = vehicle;
      users[i].position.sort(
            (a, b) => b.dateTime.compareTo(a.dateTime),
          );
    }

    return users;
  }

  @override
  Widget build(BuildContext context) {
    var driverProvider = Provider.of<DriversController>(context);
    var unlistenedDiverProvider =
        Provider.of<DriversController>(context, listen: false);
    return StreamBuilder<List<User>>(
      stream: _userStreamController.stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const CircularProgressIndicator();
        }

        List<User> user = snapshot.data!;

        return SafeArea(
          child: Stack(
            children: [
              FlutterMap(
                options: MapOptions(
                  maxZoom: 12,
                  zoom: 5,
                  initialCenter: const LatLng(-7.2, 112),
                  minZoom: 4,
                  initialCameraFit: driverProvider.latlnglist.length > 2
                      ? CameraFit.bounds(
                          bounds: driverProvider.getBoundsFromLatLngList(
                              driverProvider.latlnglist),
                          padding: const EdgeInsets.all(50),
                        )
                      : null,
                  interactiveFlags:
                      InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: const ['a', 'b', 'c'],
                  ),
                  MarkerLayer(
                    markers: user.map(
                      (e) {
                        if (e.position.isNotEmpty) {
                          return Marker(
                            width: 100.0,
                            height: 80.0,
                            point: LatLng(e.position[0].geopoint.latitude,
                                e.position[0].geopoint.longitude),
                            child: GestureDetector(
                              onTap: () {
                                pageMover.push(
                                  widget: DetailVehiclePage(
                                    uid: e.uid,
                                  ),
                                );
                              },
                              child: CustomMarker(
                                  licensePlate: e.vehicle!.licensePlate,
                                  status: e.isOnline),
                            ),
                          );
                        }
                        return const Marker(
                            point: LatLng(0, 0), child: SizedBox());
                      },
                    ).toList(),
                  ),
                ],
              ),
              Positioned(
                top: 20,
                right: 10,
                left: 10,
                child: Hero(
                  tag: 'search',
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
                                element.vehicle!.licensePlate
                                    .toLowerCase()
                                    .contains(
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
                              filteredDrivers[index].vehicle!.licensePlate;
                          return ListTile(
                            title: Text(name),
                            trailing: Text(licensePlate),
                            onTap: () {
                              FocusManager.instance.primaryFocus?.unfocus();
                              searchController.closeView(name);
                              pageMover.push(
                                widget: DetailVehiclePage(
                                  uid: filteredDrivers[index].uid,
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
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
