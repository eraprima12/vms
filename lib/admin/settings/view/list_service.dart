// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vms/auth/controller/drivers_controller.dart';
import 'package:vms/auth/model/driver_model.dart';
import 'package:vms/constant.dart';
import 'package:vms/global/function/random_string_generator.dart';
import 'package:vms/global/widget/widgettext.dart';

class ListService extends StatefulWidget {
  ListService({super.key, required this.data});
  Vehicle data;
  @override
  State<ListService> createState() => _ListServiceState();
}

class _ListServiceState extends State<ListService> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<DriversController>(context, listen: false)
          .getListServices(uid: widget.data.uid);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    void showServicePopup(BuildContext context) {
      TextEditingController value = TextEditingController();

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              'Add Service',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: value,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Odometer',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter the odometer value';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    if (value.text.isNotEmpty) {
                      var uid = generateRandomString(length: 10);
                      await FirebaseFirestore.instance
                          .collection('vehicle')
                          .doc(widget.data.uid)
                          .collection('service')
                          .doc(uid)
                          .set({
                        'created_at': Timestamp.now(),
                        'uid': uid,
                        'vehicle_uid': widget.data.uid,
                        'service_at_odo': int.parse(value.text),
                      });
                      Provider.of<DriversController>(context, listen: false)
                          .getListServices(uid: widget.data.uid);
                      pageMover.pop();
                      popupHandler.showSuccessPopup('Success');
                    }
                  },
                  child: const Text('Add Service'),
                ),
              ],
            ),
          );
        },
      );
    }

    var provider = Provider.of<DriversController>(context);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showServicePopup(context);
        },
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        title: Text(
          'List Service ${widget.data.licensePlate}',
        ),
      ),
      body: SizedBox(
        height: height,
        width: width,
        child: ListView(
          children: [
            for (int i = 0; i < provider.listService.length; i++)
              ListTile(
                leading: WidgetText(text: (i + 1).toString()),
                title: WidgetText(
                  text: DateFormat('dd-MMM-yyyy')
                      .format(provider.listService[i].createdAt),
                ),
                subtitle: WidgetText(
                  text: '${provider.listService[i].serviceAtOdo} KM',
                ),
              )
          ],
        ),
      ),
    );
  }
}
