// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:vms/admin/live_view/view/trip_history.dart';
import 'package:vms/admin/live_view/widget/chart.dart';
import 'package:vms/admin/live_view/widget/custom_marker.dart';
import 'package:vms/auth/controller/drivers_controller.dart';
import 'package:vms/auth/model/driver_model.dart';
import 'package:vms/constant.dart';
import 'package:vms/global/function/status_color.dart';
import 'package:vms/global/widget/widgettext.dart';

class DetailVehiclePage extends StatefulWidget {
  DetailVehiclePage({Key? key, required this.licensePlate}) : super(key: key);
  String licensePlate;

  @override
  State<DetailVehiclePage> createState() => _DetailVehiclePageState();
}

class _DetailVehiclePageState extends State<DetailVehiclePage> {
  double drawerHeight = 0.3;
  late DriverModel data;
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {},
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<DriversController>(context);
    data = provider.driverData
        .where((element) => element.licensePlate == widget.licensePlate)
        .first;
    return Scaffold(
      bottomNavigationBar: Container(
        height: 80,
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: GestureDetector(
          onTap: () {
            //! nanti disini
          },
          child: GestureDetector(
            onTap: () {
              pageMover.push(widget: const TripHistory());
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
                      text: 'Trip History',
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Icon(
                      Icons.history,
                      color: Colors.white,
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Map on the top section
          SizedBox(
            height:
                MediaQuery.of(context).size.height * (1 - drawerHeight) + 100,
            child: FlutterMap(
              options: MapOptions(
                interactiveFlags: InteractiveFlag.pinchZoom,
                maxZoom: 20,
                minZoom: 4,
                initialCenter: LatLng(
                  data.latestPosition.latitude,
                  data.latestPosition.longitude,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: const ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 100.0,
                      height: 80.0,
                      point: LatLng(data.latestPosition.latitude,
                          data.latestPosition.longitude),
                      child: GestureDetector(
                        onTap: () {
                          pageMover.push(
                            widget: DetailVehiclePage(
                              licensePlate: data.licensePlate,
                            ),
                          );
                        },
                        child: CustomMarker(
                            licensePlate: data.licensePlate,
                            status: data.status),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          Positioned(
            top: 60,
            left: 20,
            child: GestureDetector(
              onTap: () {
                pageMover.pop();
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  boxShadow: const [
                    BoxShadow(
                      offset: Offset(0, 2),
                      blurRadius: 5,
                      spreadRadius: 1,
                      color: Colors.grey,
                    )
                  ],
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.arrow_back),
              ),
            ),
          ),
          // Draggable drawer on the bottom
          DraggableScrollableSheet(
            initialChildSize: drawerHeight,
            minChildSize: 0.3,
            maxChildSize: 0.8,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      offset: Offset(0.0, -1.0),
                      blurRadius: 6.0,
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Draggable indicator
                      Center(
                        child: Container(
                          width: 40,
                          height: 5,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      // Details content
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    WidgetText(
                                      text: data.licensePlate.toUpperCase(),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 26,
                                      color: Colors.grey[700],
                                    ),
                                    WidgetText(
                                      text: data.name,
                                      fontSize: 18,
                                      color: Colors.grey[600],
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.all(5),
                                  height: 90,
                                  width: 90,
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        offset: const Offset(0, 2),
                                        blurRadius: 5,
                                        spreadRadius: 1,
                                        color: getStatusColor(data.status),
                                      )
                                    ],
                                    borderRadius: BorderRadius.circular(50),
                                    color: getStatusColor(data.status),
                                  ),
                                  child: Container(
                                    height: 80,
                                    width: 80,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: data.avatar != ''
                                        ? ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(50),
                                            child: Image.network(
                                              data.avatar,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : Icon(
                                            Icons.person_outlined,
                                            size: 60,
                                            color: getStatusColor(data.status),
                                          ),
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Container(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    children: [
                                      const WidgetText(
                                        text: '20 KM/H',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                      Row(
                                        children: [
                                          WidgetText(
                                            text: 'Speed',
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          Icon(
                                            Icons.speed,
                                            color: Colors.grey[600],
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                  Container(
                                    height: 50,
                                    width: 1,
                                    color: Colors.grey[500],
                                  ),
                                  Column(
                                    children: [
                                      const WidgetText(
                                        text: '18000 KM',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                      Row(
                                        children: [
                                          WidgetText(
                                            text: 'Distance',
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          Icon(
                                            Icons
                                                .keyboard_double_arrow_right_outlined,
                                            color: Colors.grey[600],
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                  Container(
                                    height: 50,
                                    width: 1,
                                    color: Colors.grey[500],
                                  ),
                                  Column(
                                    children: [
                                      const WidgetText(
                                        text: '80%',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                      Row(
                                        children: [
                                          WidgetText(
                                            text: 'Fuel',
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          Icon(
                                            Icons.gas_meter_outlined,
                                            color: Colors.grey[600],
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            WidgetText(
                              text: 'Service Detail',
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.grey[700],
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            SizedBox(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  WidgetText(
                                    text: 'Next service in',
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                  const WidgetText(
                                    text: '20 KM',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            SizedBox(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  WidgetText(
                                    text: 'Next service in',
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                  const WidgetText(
                                    text: '20 KM',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            SizedBox(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  WidgetText(
                                    text: 'Next service in',
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                  const WidgetText(
                                    text: '20 KM',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            WidgetText(
                              text: 'Distance Coverage Past 7 Days',
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.grey[700],
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            FlChartWidget(
                              flSpots: provider
                                  .getDriverStatistic(widget.licensePlate)
                                  .$1,
                              bottomTitles: provider
                                  .getDriverStatistic(widget.licensePlate)
                                  .$2,
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
