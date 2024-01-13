// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vms/admin/settings/view/add_vehicle.dart';
import 'package:vms/auth/controller/drivers_controller.dart';
import 'package:vms/constant.dart';
import 'package:vms/global/widget/template_textfield.dart';
import 'package:vms/global/widget/widgettext.dart';

class ListVehicle extends StatefulWidget {
  const ListVehicle({
    super.key,
  });
  @override
  State<ListVehicle> createState() => _ListVehicleState();
}

class _ListVehicleState extends State<ListVehicle> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<DriversController>(context, listen: false)
          .getListVehicle(unique: false);
      Provider.of<DriversController>(context, listen: false)
          .getAndMapDriverData();
    });
  }

  TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<DriversController>(context);
    return SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            pageMover.push(widget: VehicleForm());
          },
          backgroundColor: primaryColor,
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
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
                    Expanded(
                      child: TemplateTextField(
                        onType: (val) {
                          setState(() {});
                        },
                        textEditingController: controller,
                        hint: 'Search Vehicle License Plate',
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: provider.listVehicle
                      .where((element) => element.licensePlate
                          .toLowerCase()
                          .contains(controller.text.toLowerCase()))
                      .length,
                  itemBuilder: (ctx, i) {
                    var item = provider.listVehicle
                        .where((element) => element.licensePlate
                            .toLowerCase()
                            .contains(controller.text.toLowerCase()))
                        .toList();
                    return ListTile(
                      onTap: () {
                        pageMover.push(
                            widget: VehicleForm(
                          data: item[i],
                        ));
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
                                text: item[i]
                                    .licensePlate
                                    .substring(0, 1)
                                    .toUpperCase(),
                                color: secondaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                      ),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          WidgetText(text: item[i].licensePlate),
                          const SizedBox()
                        ],
                      ),
                      subtitle: WidgetText(
                          text: '${item[i].odo.toStringAsFixed(2)} KM'),
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
