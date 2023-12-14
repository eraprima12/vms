// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vms/admin/home/controller/home_controller.dart';
import 'package:vms/admin/home/widget/card_widget.dart';
import 'package:vms/auth/controller/auth_controller.dart';
import 'package:vms/auth/controller/drivers_controller.dart';
import 'package:vms/auth/model/driver_model.dart';
import 'package:vms/constant.dart';
import 'package:vms/gen/driver_generator.dart';
import 'package:vms/gen/position_generator.dart';
import 'package:vms/global/widget/widgettext.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      var driverData =
          await Provider.of<DriversController>(context, listen: false)
              .getAndMapDriverData();
      await Provider.of<HomeController>(context, listen: false)
          .mapAndStoreActionModel(driverData: driverData);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<DriversController>(context);
    var unlistenedProvider =
        Provider.of<DriversController>(context, listen: false);

    var homeProvider = Provider.of<HomeController>(context);
    var unlistenedHomeProvider =
        Provider.of<HomeController>(context, listen: false);
    return Scaffold(
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
                        unlistenedProvider.getAndMapDriverData();
                      },
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        children: [
                          const SizedBox(
                            height: 20,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: GestureDetector(
                              onTap: () {
                                logger.f('kegenerate');
                                generatePosition('anMynBTq4C');
                                // List<Map<String, String>> animeCharactersData =
                                //     generateAnimeCharactersData(1);
                                // for (int i = 0;
                                //     i < animeCharactersData.length;
                                //     i++) {
                                //   generateAndStoreData(
                                //       animeCharactersData[i]['name'],
                                //       animeCharactersData[i]['username']);
                                // }
                              },
                              child: WidgetText(
                                color: textColor,
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                text:
                                    'Hi, ${Provider.of<AuthController>(context).user?.username}',
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: WidgetText(
                              color: textColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              text: 'Let`s see what happened today',
                            ),
                          ),
                          const SizedBox(height: 20),
                          Hero(
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
                              searchController: homeProvider.searchController,
                              isFullScreen: false,
                              suggestionsBuilder: (BuildContext context,
                                  SearchController controller) {
                                final filteredActions = homeProvider
                                    .listOfActions
                                    .where(
                                      (element) =>
                                          element.title.toLowerCase().contains(
                                                homeProvider
                                                    .searchController.text
                                                    .toLowerCase(),
                                              ) ||
                                          element.suffix.toLowerCase().contains(
                                                homeProvider
                                                    .searchController.text
                                                    .toLowerCase(),
                                              ),
                                    )
                                    .toList();
                                return List<ListTile>.generate(
                                  filteredActions.length,
                                  (int index) {
                                    final String name =
                                        filteredActions[index].title;
                                    final String licensePlate =
                                        filteredActions[index].suffix;
                                    return ListTile(
                                      title: Text(name),
                                      trailing: Text(licensePlate),
                                      onTap:
                                          filteredActions[index].voidCallback,
                                    );
                                  },
                                );
                              },
                              builder: (BuildContext context,
                                  SearchController controller) {
                                return SearchBar(
                                  shape: MaterialStateProperty.all(
                                    const ContinuousRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(20),
                                      ),
                                    ),
                                  ),
                                  onTap: () {
                                    homeProvider.searchController.openView();
                                  },
                                  controller: homeProvider.searchController,
                                  leading: const Icon(Icons.search),
                                  hintText: 'Search',
                                  backgroundColor:
                                      MaterialStateColor.resolveWith(
                                    (states) => Colors.white,
                                  ),
                                  onChanged: (val) {
                                    homeProvider.searchController.openView();
                                    setState(() {});
                                  },
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 20),
                          provider.driverData
                                  .where((element) => element.isOnline)
                                  .toList()
                                  .isNotEmpty
                              ? Row(
                                  children: [
                                    Expanded(
                                      child: CardWithTitleAndSubtitle(
                                        color: primaryColor,
                                        title: 'Driver Online',
                                        data: WidgetText(
                                          color: Colors.white,
                                          text: provider.driverData
                                              .where(
                                                  (element) => element.isOnline)
                                              .toList()
                                              .length
                                              .toString(),
                                          fontSize: 24,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: CardWithTitleAndSubtitle(
                                        color: primaryColor,
                                        title: 'Vehicle total',
                                        data: WidgetText(
                                          color: Colors.white,
                                          text: provider.driverData.length
                                              .toString(),
                                          fontSize: 24,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : const SizedBox(),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              provider.highestDriverData.isNotEmpty
                                  ? Expanded(
                                      child: CardWithTitleAndSubtitle(
                                        color: thirdColor,
                                        title: 'Driver with Highest\nKM today',
                                        data: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(
                                              height: 40,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                CircleAvatar(
                                                  backgroundColor: Colors.white,
                                                  child: provider
                                                              .lowestDriverData
                                                              .first
                                                              .avatar !=
                                                          ''
                                                      ? ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(50),
                                                          child: Image.network(
                                                            provider
                                                                .highestDriverData
                                                                .first
                                                                .avatar,
                                                            height: 100,
                                                            width: 100,
                                                            fit: BoxFit.cover,
                                                          ),
                                                        )
                                                      : WidgetText(
                                                          text: provider
                                                              .highestDriverData
                                                              .first
                                                              .name
                                                              .substring(0, 1)
                                                              .toUpperCase(),
                                                          color: thirdColor,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      WidgetText(
                                                        text: provider
                                                            .highestDriverData
                                                            .first
                                                            .name,
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                      WidgetText(
                                                        text:
                                                            '${provider.highestDriverData.first.distanceToday} KM',
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : const SizedBox(),
                              const SizedBox(
                                width: 10,
                              ),
                              provider.lowestDriverData.isNotEmpty
                                  ? Expanded(
                                      child: CardWithTitleAndSubtitle(
                                        color: secondaryColor,
                                        title:
                                            'Driver with Lowest\nPerformance today',
                                        data: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(
                                              height: 40,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                CircleAvatar(
                                                  backgroundColor: Colors.white,
                                                  child: provider
                                                              .lowestDriverData
                                                              .first
                                                              .avatar !=
                                                          ''
                                                      ? ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(50),
                                                          child: Image.network(
                                                            provider
                                                                .lowestDriverData
                                                                .first
                                                                .avatar,
                                                            height: 50,
                                                            width: 50,
                                                            fit: BoxFit.cover,
                                                          ),
                                                        )
                                                      : WidgetText(
                                                          text: provider
                                                              .lowestDriverData
                                                              .first
                                                              .name
                                                              .substring(0, 1)
                                                              .toUpperCase(),
                                                          color: secondaryColor,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      WidgetText(
                                                        text: provider
                                                            .lowestDriverData
                                                            .first
                                                            .name,
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                      WidgetText(
                                                        text:
                                                            '${provider.lowestDriverData.first.distanceToday} KM',
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : const SizedBox(),
                            ],
                          ),
                          const SizedBox(height: 20),
                          provider.lowestDriverData.isNotEmpty
                              ? Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        offset: const Offset(0, 1),
                                        spreadRadius: 1,
                                        blurRadius: 5,
                                        color: primaryColor,
                                      )
                                    ],
                                  ),
                                  height: 200,
                                  width: width,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Stack(
                                      children: [
                                        const Positioned(
                                          right: -50,
                                          bottom: -50,
                                          child: Icon(
                                            Icons.location_city,
                                            size: 250,
                                            color: Colors.black,
                                          ),
                                        ),
                                        CardWithTitleAndSubtitle(
                                          color: primaryColor.withOpacity(0.6),
                                          title:
                                              'Driver with Lowest\nPerformance today',
                                          data: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(
                                                height: 40,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  CircleAvatar(
                                                    backgroundColor:
                                                        Colors.white,
                                                    child: provider
                                                                .lowestDriverData
                                                                .first
                                                                .avatar !=
                                                            ''
                                                        ? ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        50),
                                                            child:
                                                                Image.network(
                                                              provider
                                                                  .lowestDriverData
                                                                  .first
                                                                  .avatar,
                                                              height: 50,
                                                              width: 50,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          )
                                                        : WidgetText(
                                                            text: provider
                                                                .lowestDriverData
                                                                .first
                                                                .name
                                                                .substring(0, 1)
                                                                .toUpperCase(),
                                                            color: thirdColor,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                  ),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        WidgetText(
                                                          text: provider
                                                              .lowestDriverData
                                                              .first
                                                              .name,
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                        WidgetText(
                                                          text:
                                                              '${provider.lowestDriverData.first.distanceToday} KM',
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : const SizedBox(),
                          const SizedBox(
                            height: 120,
                          )
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
    );
  }
}
