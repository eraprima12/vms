import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vms/auth/controller/auth_controller.dart';
import 'package:vms/auth/controller/drivers_controller.dart';
import 'package:vms/auth/model/driver_model.dart';
import 'package:vms/constant.dart';
import 'package:vms/gen/position_generator.dart';
import 'package:vms/global/widget/widgettext.dart';
import 'package:vms/home/widget/card_widget.dart';
import 'package:vms/live_view/view/detail_vehicle.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DriversController>(context, listen: false)
          .getAndMapDriverData();
    });
    super.initState();
  }

  SearchController searchController = SearchController();

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<DriversController>(context);
    var unlistenedProvider =
        Provider.of<DriversController>(context, listen: false);
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
                                generatePosition('LOaEowQmbS');
                                // List<Map<String, String>> animeCharactersData =
                                //     generateAnimeCharactersData(10);

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
                          SearchAnchor(
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
                            suggestionsBuilder: (BuildContext context,
                                SearchController controller) {
                              final filteredDrivers = provider.driverData
                                  .where(
                                    (element) =>
                                        element.licensePlate
                                            .toLowerCase()
                                            .contains(
                                              searchController.text
                                                  .toLowerCase(),
                                            ) ||
                                        element.name.toLowerCase().contains(
                                              searchController.text
                                                  .toLowerCase(),
                                            ),
                                  )
                                  .toList();
                              return List<ListTile>.generate(
                                filteredDrivers.length,
                                (int index) {
                                  final String name =
                                      filteredDrivers[index].name;
                                  final String licensePlate =
                                      filteredDrivers[index].licensePlate;
                                  return ListTile(
                                    title: Text(name),
                                    trailing: Text(licensePlate),
                                    onTap: () {
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();
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
                                  searchController.openView();
                                },
                                controller: searchController,
                                leading: const Icon(Icons.search),
                                hintText: 'Search',
                                backgroundColor: MaterialStateColor.resolveWith(
                                  (states) => Colors.white,
                                ),
                                onChanged: (val) {
                                  searchController.openView();
                                  setState(() {});
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: CardWithTitleAndSubtitle(
                                  color: primaryColor,
                                  title: 'Driver Online',
                                  data: WidgetText(
                                    color: Colors.white,
                                    text: provider.driverData
                                        .where((element) =>
                                            element.status == onlineStatus)
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
                                  color: secondaryColor,
                                  title: 'Vehicle total',
                                  data: WidgetText(
                                    color: Colors.white,
                                    text: provider.driverData.length.toString(),
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
                                        color: fourthColor,
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
                                                          color: fourthColor,
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

class CardWithAvatar extends StatelessWidget {
  const CardWithAvatar({
    super.key,
    required this.param,
  });

  final DriverModel param;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: primaryColor,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.white,
          child: param.avatar != ''
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Image.network(
                    param.avatar,
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                  ),
                )
              : WidgetText(
                  text: param.name.substring(0, 1).toUpperCase(),
                  color: textColor,
                ),
        ),
        title: WidgetText(
          text: param.name,
          color: Colors.white,
        ),
        subtitle: WidgetText(
            color: Colors.white,
            text:
                'Distance Today: ${param.distanceToday.toStringAsFixed(2)} km'),
      ),
    );
  }
}
