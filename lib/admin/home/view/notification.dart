// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vms/auth/controller/drivers_controller.dart';
import 'package:vms/constant.dart';
import 'package:vms/global/widget/widgettext.dart';

class ListNotif extends StatefulWidget {
  const ListNotif({super.key});
  @override
  State<ListNotif> createState() => _ListNotifState();
}

class _ListNotifState extends State<ListNotif> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<DriversController>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'List Alert',
        ),
      ),
      body: SizedBox(
        height: height,
        width: width,
        child: ListView(
          padding: const EdgeInsets.all(10),
          children: [
            for (int i = 0; i < provider.listNotif.length; i++)
              Padding(
                padding: const EdgeInsets.all(10),
                child: ListTile(
                  minVerticalPadding: 5,
                  tileColor: primaryColor,
                  leading:
                      WidgetText(text: (i + 1).toString(), color: Colors.white),
                  title: WidgetText(
                    color: Colors.white,
                    text: '${provider.listNotif[i].driverName} - Overspeed',
                  ),
                  subtitle: WidgetText(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    text:
                        '${provider.listNotif[i].speed} KM/H - ${provider.listNotif[i].date}',
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}
