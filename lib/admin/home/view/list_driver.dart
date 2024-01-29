// ignore_for_file: must_be_immutable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:vms/admin/live_view/view/detail_vehicle.dart';
import 'package:vms/admin/settings/view/add_driver.dart';
import 'package:vms/auth/controller/drivers_controller.dart';
import 'package:vms/constant.dart';
import 'package:vms/global/widget/template_textfield.dart';
import 'package:vms/global/widget/widgettext.dart';

class ListDriver extends StatefulWidget {
  ListDriver({super.key, required this.isHighest, this.isMaster});

  bool? isMaster = false;
  bool isHighest;
  @override
  State<ListDriver> createState() => _ListDriverState();
}

class _ListDriverState extends State<ListDriver> {
  Timestamp value = Timestamp.now();
  TextEditingController controller = TextEditingController();
  List<Timestamp> list = [];
  @override
  void initState() {
    var driverData =
        Provider.of<DriversController>(context, listen: false).driverData;
    for (int i = 0; i < driverData.length; i++) {
      for (int j = 0; j < driverData[i].tripHistory.length; j++) {
        list.add(driverData[i].tripHistory[j]);
      }
    }
    var temp = Set<Timestamp>.from(list);
    list = temp.toList();
    list.sort(
      (a, b) => b.compareTo(a),
    );
    value = list[0];
    logger.f(list.length);
    setState(() {});
    super.initState();
  }

  calculateDistance() {
    var provider = Provider.of<DriversController>(context, listen: false);
    var driverData = widget.isHighest
        ? Provider.of<DriversController>(context, listen: false)
            .highestDriverData
        : Provider.of<DriversController>(context, listen: false)
            .lowestDriverData;
    for (int i = 0; i < provider.highestDriverData.length; i++) {
      driverData[i].distanceToday = provider.distanceCoverageCounter(
          driverData[i].position, value.toDate());
    }
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<DriversController>(context);
    return SafeArea(
      child: Scaffold(
        floatingActionButton: widget.isMaster ?? false
            ? FloatingActionButton(
                onPressed: () {
                  pageMover.push(
                      widget: AddDriver(
                    isEdit: false,
                  ));
                },
                backgroundColor: primaryColor,
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                ),
              )
            : null,
        body: SizedBox(
          height: height,
          width: width,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  children: [
                    IconButton(
                        onPressed: () {
                          pageMover.pop();
                        },
                        icon: const Icon(Icons.arrow_back_ios)),
                    SizedBox(
                      height: 70,
                      width: width - 80,
                      child: Column(
                        children: [
                          Expanded(
                            child: TemplateTextField(
                              onType: (val) {
                                setState(() {});
                              },
                              textEditingController: controller,
                              hint: 'Search driver name',
                            ),
                          ),
                          // Expanded(
                          //   child: DropDownWidget(
                          //     selectedValue: value,
                          //     onChanged: (values) {
                          //       value = values ?? Timestamp.now();
                          //       setState(() {});
                          //     },
                          //     tripHistory: list,
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: widget.isHighest
                      ? provider.highestDriverData
                          .where((element) => element.name
                              .toLowerCase()
                              .contains(controller.text.toLowerCase()))
                          .length
                      : provider.lowestDriverData
                          .where((element) => element.name
                              .toLowerCase()
                              .contains(controller.text.toLowerCase()))
                          .length,
                  itemBuilder: (ctx, i) {
                    var item = widget.isHighest
                        ? provider.highestDriverData
                            .where((element) => element.name
                                .toLowerCase()
                                .contains(controller.text.toLowerCase()))
                            .toList()
                        : provider.lowestDriverData
                            .where((element) => element.name
                                .toLowerCase()
                                .contains(controller.text.toLowerCase()))
                            .toList();
                    return ListTile(
                      onTap: () {
                        if (widget.isMaster!) {
                          pageMover.push(
                              widget: AddDriver(
                            data: item[i],
                            isEdit: true,
                          ));
                        } else {
                          pageMover.push(
                              widget: DetailVehiclePage(uid: item[i].uid));
                        }
                      },
                      leading: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: item[i].avatar != ''
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: Image.network(
                                  item[i].avatar,
                                  height: 50,
                                  width: 50,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : WidgetText(
                                text:
                                    item[i].name.substring(0, 1).toUpperCase(),
                                color: secondaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                      ),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          WidgetText(text: item[i].name),
                          i == 0 && widget.isHighest
                              ? Lottie.asset('assets/king.json', height: 50)
                              : i == 0 && !widget.isHighest
                                  ? Lottie.asset('assets/dislike.json',
                                      height: 50)
                                  : const SizedBox()
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          WidgetText(
                              fontWeight: FontWeight.bold,
                              text:
                                  'Today : ${item[i].distanceToday.toStringAsFixed(2)} KM'),
                          WidgetText(
                              fontWeight: FontWeight.bold,
                              text:
                                  'Yesterday : ${item[i].totalDistanceYesterday.toStringAsFixed(2)} KM'),
                          WidgetText(
                              fontWeight: FontWeight.bold,
                              text:
                                  'Past 7 Days : ${item[i].totalDistancePast7Days.toStringAsFixed(2)} KM'),
                          WidgetText(
                              fontWeight: FontWeight.bold,
                              text:
                                  'Total : ${item[i].totalDistance.toStringAsFixed(2)} KM'),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
