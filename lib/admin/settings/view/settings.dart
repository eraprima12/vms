import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vms/admin/home/view/list_driver.dart';
import 'package:vms/admin/settings/view/list_vehicle.dart';
import 'package:vms/admin/settings/view/master_settings.dart';
import 'package:vms/auth/controller/auth_controller.dart';
import 'package:vms/constant.dart';
import 'package:vms/global/model/action_model.dart';
import 'package:vms/global/widget/widgettext.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final List<ActionModel> models = [
    ActionModel(
      title: "Master Drivers",
      suffix: "",
      voidCallback: () {
        pageMover.push(
          widget: ListDriver(
            isHighest: true,
            isMaster: true,
          ),
        );
      },
    ),
    ActionModel(
      title: "Master Settings",
      suffix: "",
      voidCallback: () {
        pageMover.push(widget: const MasterSettings());
      },
    ),
    ActionModel(
      title: "Master Vehicle",
      suffix: "",
      voidCallback: () {
        pageMover.push(widget: const ListVehicle());
      },
    ),
  ];
  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;

    width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: ListView.builder(
        itemCount: models.length,
        itemBuilder: (context, index) {
          return buildModelCard(models[index]);
        },
      ),
      appBar: AppBar(
        centerTitle: true,
        title: const WidgetText(
          text: 'Settings',
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        actions: [
          IconButton(
            onPressed: () {
              Provider.of<AuthController>(context, listen: false).logout();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
    );
  }

  Widget buildModelCard(ActionModel model) {
    return Card(
      margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        tileColor: primaryColor,
        title: WidgetText(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          text: model.title,
          color: Colors.white,
        ),
        subtitle: model.suffix == ''
            ? null
            : WidgetText(
                text: model.suffix,
                color: Colors.white,
              ),
        trailing: const Icon(
          Icons.arrow_forward_ios_outlined,
          color: Colors.white,
        ),
        onTap: model.voidCallback,
      ),
    );
  }
}
