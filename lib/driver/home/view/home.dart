import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:vms/admin/home/controller/home_controller.dart';
import 'package:vms/admin/home/widget/card_widget.dart';
import 'package:vms/auth/controller/auth_controller.dart';
import 'package:vms/auth/controller/drivers_controller.dart';
import 'package:vms/auth/model/driver_model.dart';
import 'package:vms/constant.dart';
import 'package:vms/driver/profile/view/profile.dart';
import 'package:vms/gen/position_generator.dart';
import 'package:vms/global/widget/card.dart';
import 'package:vms/global/widget/widgettext.dart';

class HomeDriver extends StatefulWidget {
  const HomeDriver({Key? key}) : super(key: key);

  @override
  State<HomeDriver> createState() => _HomeDriverState();
}

class _HomeDriverState extends State<HomeDriver> {
  String address = '';
  DateTime? lastTapTime;
  @override
  void initState() {
    Provider.of<AuthController>(context, listen: false).initListener();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // var position = Provider.of<AuthController>(context, listen: false)
      //     .user!
      //     .latestPosition;
      // address = await Provider.of<DriversController>(context, listen: false)
      //     .getAddressFromLatLng(
      //         latitude: position.latitude, longitude: position.longitude);
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<AuthController>(context);
    var unlistenedprovider =
        Provider.of<AuthController>(context, listen: false);
    return WillPopScope(
      onWillPop: () async {
        DateTime now = DateTime.now();
        if (lastTapTime == null ||
            now.difference(lastTapTime!) > const Duration(seconds: 2)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Press back again to exit'),
            ),
          );
          lastTapTime = now;
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: Builder(builder: (context) {
          return SafeArea(
            child: SingleChildScrollView(
              child: SizedBox(
                height: height,
                width: width,
                child: Column(
                  children: [
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async {},
                        child: ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          children: [
                            const SizedBox(
                              height: 20,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: WidgetText(
                                      color: textColor,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                      text: 'Hi, ${provider.user!.username}',
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      pageMover.push(
                                          widget: const DriverProfilePage());
                                    },
                                    child: CircleAvatar(
                                      backgroundColor: Colors.white,
                                      child: provider.user!.avatar != ''
                                          ? ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                              child: Image.network(
                                                provider.user!.avatar,
                                                height: 50,
                                                width: 50,
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                          : WidgetText(
                                              text: provider.user!.username
                                                  .substring(0, 1)
                                                  .toUpperCase(),
                                              color: secondaryColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: CardWithTotalDistance(
                                    color: primaryColor,
                                    title: 'Total Distance Today',
                                    data: WidgetText(
                                      color: Colors.white,
                                      text: provider.user!.distanceToday
                                          .toStringAsFixed(2),
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: CardWithTotalDistance(
                                    color: primaryColor,
                                    title: 'Total Distance Coverage',
                                    data: WidgetText(
                                      color: Colors.white,
                                      text:
                                          '${provider.user!.totalDistance.toStringAsFixed(0)} KM',
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            CardWithServiceInKm(
                              color: secondaryColor,
                              title: 'Service in ... KM',
                              data: const WidgetText(
                                color: Colors.white,
                                text: '500 KM',
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 20),
                            // CardWithTitleAndSubtitle(
                            //   data: Column(
                            //     crossAxisAlignment: CrossAxisAlignment.start,
                            //     children: [
                            //       SizedBox(
                            //         height: 200,
                            //         width: MediaQuery.of(context).size.width,
                            //         child: Container(
                            //           decoration: BoxDecoration(
                            //             border: Border.all(
                            //               color: Colors.grey,
                            //             ),
                            //             borderRadius: BorderRadius.circular(8),
                            //           ),
                            //           child: ClipRRect(
                            //             borderRadius: BorderRadius.circular(8),
                            //             child: FlutterMap(
                            //               options: MapOptions(
                            //                 center: LatLng(
                            //                   provider.user!
                            //                       .latestPosition.latitude,
                            //                   provider.user!
                            //                       .latestPosition.longitude,
                            //                 ),
                            //                 zoom: 15,
                            //               ),
                            //               children: [
                            //                 TileLayer(
                            //                   urlTemplate:
                            //                       'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                            //                   subdomains: const ['a', 'b', 'c'],
                            //                 ),
                            //                 MarkerLayer(
                            //                   markers: [
                            //                     Marker(
                            //                       width: 30.0,
                            //                       height: 30.0,
                            //                       point: LatLng(
                            //                         provider
                            //                             .user!
                            //                             .latestPosition
                            //                             .latitude,
                            //                         provider
                            //                             .user!
                            //                             .latestPosition
                            //                             .longitude,
                            //                       ),
                            //                       child: Container(
                            //                         child: const Icon(
                            //                           Icons.location_on,
                            //                           color: Colors
                            //                               .red, // Change to your desired color
                            //                         ),
                            //                       ),
                            //                     ),
                            //                   ],
                            //                 ),
                            //               ],
                            //             ),
                            //           ),
                            //         ),
                            //       ),
                            //       const SizedBox(height: 10),
                            //       WidgetText(
                            //         text: address,
                            //         color: Colors.white,
                            //         fontWeight: FontWeight.w600,
                            //       ),
                            //       WidgetText(
                            //         text:
                            //             '${provider.user!.latestPosition.latitude}, ${provider.user!.latestPosition.longitude}',
                            //         color: Colors.white,
                            //         fontWeight: FontWeight.w400,
                            //       ),
                            //     ],
                            //   ),
                            //   title: 'You Are Here',
                            //   color: thirdColor,
                            // )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
