import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:vms/admin/home/widget/card_widget.dart';
import 'package:vms/auth/controller/auth_controller.dart';
import 'package:vms/auth/controller/drivers_controller.dart';
import 'package:vms/constant.dart';
import 'package:vms/driver/bg_locator/bg_locator_provider.dart';
import 'package:vms/driver/profile/view/profile.dart';
import 'package:vms/global/widget/card.dart';
import 'package:vms/global/widget/trip_history.dart';
import 'package:vms/global/widget/widgettext.dart';

class HomeDriver extends StatefulWidget {
  const HomeDriver({Key? key}) : super(key: key);

  @override
  State<HomeDriver> createState() => _HomeDriverState();
}

class _HomeDriverState extends State<HomeDriver> {
  String address = '';
  DateTime? lastTapTime;
  bool _isSwitchOn = false;
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      var user = Provider.of<AuthController>(context, listen: false).user!;
      _isSwitchOn = user.isOnline;
      getGPSSettings();
      logger.f(user.isOnline);
      if (user.position.isNotEmpty) {
        var position = user.position[0];
        address = await Provider.of<DriversController>(context, listen: false)
            .getAddressFromLatLng(
                latitude: position.geopoint.latitude,
                longitude: position.geopoint.longitude);
      }
      setState(() {});
    });
    super.initState();
  }

  getGPSSettings() {
    var bgLocator = Provider.of<BGLocatorProvider>(context, listen: false);
    bgLocator.initiate(context);
    if (_isSwitchOn) {
      bgLocator.onStart();
    } else {
      bgLocator.onStop();
    }
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<AuthController>(context);
    var unlistenedprovider =
        Provider.of<AuthController>(context, listen: false);
    var unlistenedbgprovider =
        Provider.of<BGLocatorProvider>(context, listen: false);
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
                        onRefresh: () async {
                          getGPSSettings();
                          var user = Provider.of<AuthController>(context,
                                  listen: false)
                              .user!;
                          _isSwitchOn = user.isOnline;
                          if (user.position.isNotEmpty) {
                            var position = user.position[0];

                            address = await Provider.of<DriversController>(
                                    context,
                                    listen: false)
                                .getAddressFromLatLng(
                                    latitude: position.geopoint.latitude,
                                    longitude: position.geopoint.longitude);
                          }
                          setState(() {});
                        },
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
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        color: primaryColor,
                                        borderRadius: BorderRadius.circular(50),
                                      ),
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
                                    ),
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                CardWithTitleAndSubtitle(
                                  data: Row(
                                    children: [
                                      Switch(
                                        value: _isSwitchOn,
                                        onChanged: (value) {
                                          setState(
                                            () {
                                              _isSwitchOn = value;
                                              unlistenedbgprovider
                                                  .updateIsOnline(value);
                                              getGPSSettings();
                                            },
                                          );
                                        },
                                      ),
                                      WidgetText(
                                        text: _isSwitchOn ? 'On' : 'Off',
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      )
                                    ],
                                  ),
                                  title: 'GPS status',
                                  color: thirdColor,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                provider.user!.vehicle != null
                                    ? Expanded(
                                        child: CardWithTitleAndSubtitle(
                                          data: Container(
                                            padding: const EdgeInsets.all(6),
                                            child: WidgetText(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 24,
                                              color: Colors.white,
                                              text: provider
                                                  .user!.vehicle!.licensePlate,
                                            ),
                                          ),
                                          title: 'Your Vehicle',
                                          color: secondaryColor,
                                        ),
                                      )
                                    : const SizedBox(),
                              ],
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: CardWithTotalDistance(
                                    color: primaryColor,
                                    title: 'Total Distance Today',
                                    data: WidgetText(
                                      color: Colors.white,
                                      text:
                                          '${provider.user!.distanceToday.toStringAsFixed(2)}KM',
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
                                          '${provider.user!.totalDistance.toStringAsFixed(2)} KM',
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: CardWithServiceInKm(
                                    color: secondaryColor,
                                    title: 'Service in ... KM',
                                    data: WidgetText(
                                      color: Colors.white,
                                      text: provider.user!.nextServiceOdo!
                                          .toStringAsFixed(2),
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: provider.user!.position.isNotEmpty
                                      ? 10
                                      : 0,
                                ),
                                provider.user!.position.isNotEmpty
                                    ? GestureDetector(
                                        onTap: () {
                                          pageMover.push(
                                              widget: TripHistory(
                                                  uid: unlistenedprovider
                                                      .user!.uid));
                                        },
                                        child: Expanded(
                                          child: CardWithServiceInKm(
                                            color: thirdColor,
                                            title: 'Trip History',
                                            data: const Row(
                                              children: [
                                                WidgetText(
                                                  color: Colors.white,
                                                  text: 'Play',
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                Icon(
                                                  Icons
                                                      .play_circle_fill_outlined,
                                                  color: Colors.white,
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                    : const SizedBox(),
                              ],
                            ),
                            const SizedBox(height: 20),
                            provider.user!.position.isNotEmpty
                                ? CardWithTitleAndSubtitle(
                                    data: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: 200,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Colors.grey,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: FlutterMap(
                                                options: MapOptions(
                                                  center: LatLng(
                                                    provider.user!.position[0]
                                                        .geopoint.latitude,
                                                    provider.user!.position[0]
                                                        .geopoint.longitude,
                                                  ),
                                                  zoom: 15,
                                                ),
                                                children: [
                                                  TileLayer(
                                                    urlTemplate:
                                                        'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                                                    subdomains: const [
                                                      'a',
                                                      'b',
                                                      'c'
                                                    ],
                                                  ),
                                                  MarkerLayer(
                                                    markers: [
                                                      Marker(
                                                        width: 30.0,
                                                        height: 30.0,
                                                        point: LatLng(
                                                          provider
                                                              .user!
                                                              .position[0]
                                                              .geopoint
                                                              .latitude,
                                                          provider
                                                              .user!
                                                              .position[0]
                                                              .geopoint
                                                              .longitude,
                                                        ),
                                                        child: const SizedBox(
                                                          child: Icon(
                                                            Icons.location_on,
                                                            color: Colors
                                                                .red, // Change to your desired color
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        WidgetText(
                                          text: address,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        WidgetText(
                                          text:
                                              '${provider.user!.position[0].geopoint.latitude}, ${provider.user!.position[0].geopoint.longitude}',
                                          color: Colors.white,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ],
                                    ),
                                    title: 'You Are Here',
                                    color: thirdColor,
                                  )
                                : const SizedBox()
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
