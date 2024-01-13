// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:vms/admin/home/widget/card_widget.dart';
import 'package:vms/admin/live_view/widget/custom_marker.dart';
import 'package:vms/auth/controller/drivers_controller.dart';
import 'package:vms/auth/model/user_model.dart';
import 'package:vms/constant.dart';
import 'package:vms/global/function/status_color.dart';
import 'package:vms/global/widget/trip_history.dart';
import 'package:vms/global/widget/widgettext.dart';

class DetailVehiclePage extends StatefulWidget {
  DetailVehiclePage({Key? key, required this.uid}) : super(key: key);
  String uid;

  @override
  State<DetailVehiclePage> createState() => _DetailVehiclePageState();
}

class _DetailVehiclePageState extends State<DetailVehiclePage> {
  double drawerHeight = 0.3;
  late User data;
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        await Provider.of<DriversController>(context, listen: false)
            .getAndMapDriverData();
        setState(() {});
      },
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<DriversController>(context);
    data =
        provider.driverData.where((element) => element.uid == widget.uid).first;
    return Scaffold(
      bottomNavigationBar: Container(
        height: 80,
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: GestureDetector(
          onTap: () {
            pageMover.push(
              widget: TripHistory(
                uid: widget.uid,
              ),
            );
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
                initialCenter: data.position.isNotEmpty
                    ? LatLng(
                        data.position[0].geopoint.latitude,
                        data.position[0].geopoint.longitude,
                      )
                    : const LatLng(-7.2, 112),
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
                      point: data.position.isNotEmpty
                          ? LatLng(
                              data.position[0].geopoint.latitude,
                              data.position[0].geopoint.longitude,
                            )
                          : const LatLng(-7.2, 112),
                      child: GestureDetector(
                        onTap: () {
                          pageMover.push(
                            widget: DetailVehiclePage(
                              uid: data.uid,
                            ),
                          );
                        },
                        child: CustomMarker(
                            licensePlate: data.vehicle!.licensePlate,
                            status: data.isOnline),
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
                                      text: data.vehicle!.licensePlate
                                          .toUpperCase(),
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
                                        color: getStatusColor(data.isOnline),
                                      )
                                    ],
                                    borderRadius: BorderRadius.circular(50),
                                    color: getStatusColor(data.isOnline),
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
                                            color:
                                                getStatusColor(data.isOnline),
                                          ),
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            SizedBox(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    children: [
                                      WidgetText(
                                        text: data.position.isNotEmpty
                                            ? '${(data.position[0].speed * 3.6).toStringAsFixed(0)} KM/H'
                                            : '0 KM/H',
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
                                      WidgetText(
                                        text:
                                            '${data.vehicle!.odo.toStringAsFixed(0)} KM',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                      Row(
                                        children: [
                                          WidgetText(
                                            text: 'Odometer',
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
                                    text: 'Service Odo Every...',
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                  WidgetText(
                                    text:
                                        '${data.vehicle!.serviceOdoEvery.toStringAsFixed(0)} KM',
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
                                  WidgetText(
                                    text:
                                        '${data.nextServiceOdo!.toStringAsFixed(0)} KM',
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
                                    text: 'Last service ODO',
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                  WidgetText(
                                    text:
                                        '${data.vehicle!.lastService!.serviceAtOdo.toStringAsFixed(0)} KM',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                WidgetText(
                                  text: 'Distance Coverage',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.grey[700],
                                ),
                                IconButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return SimpleDialog(
                                          insetPadding:
                                              const EdgeInsets.all(10),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          title: Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  IconButton(
                                                    onPressed: () {
                                                      pageMover.pop();
                                                    },
                                                    icon:
                                                        const Icon(Icons.close),
                                                  )
                                                ],
                                              ),
                                              const WidgetText(
                                                text: 'Pilih tanggal',
                                                fontWeight: FontWeight.w700,
                                              ),
                                              const SizedBox(
                                                height: 20,
                                              ),
                                              const SizedBox(
                                                height: 40,
                                              )
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  icon: const Icon(Icons.date_range),
                                )
                              ],
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: CardWithTitleAndSubtitle(
                                    data: WidgetText(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 24,
                                        text:
                                            '${data.distanceToday.toStringAsFixed(2)} KM'),
                                    title: 'Today',
                                    color: primaryColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: CardWithTitleAndSubtitle(
                                      data: WidgetText(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 24,
                                          text:
                                              '${data.totalDistanceYesterday.toStringAsFixed(2)} KM'),
                                      title: 'Yesterday',
                                      color: primaryColor),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: CardWithTitleAndSubtitle(
                                      data: WidgetText(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 24,
                                          text:
                                              '${data.totalDistancePast7Days.toStringAsFixed(2)} KM'),
                                      title: 'Past 7 days',
                                      color: primaryColor),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: CardWithTitleAndSubtitle(
                                      data: WidgetText(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 24,
                                          text:
                                              '${data.totalDistance.toStringAsFixed(2)} KM'),
                                      title: 'Total',
                                      color: primaryColor),
                                ),
                              ],
                            ),
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
