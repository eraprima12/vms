import 'package:flutter/material.dart';
import 'package:vms/auth/model/driver_model.dart';
import 'package:vms/constant.dart';
import 'package:vms/global/model/action_model.dart';
import 'package:vms/live_view/view/detail_vehicle.dart';
import 'package:vms/settings/view/settings.dart';

class HomeController extends ChangeNotifier {
  SearchController searchController = SearchController();
  List<ActionModel> listOfActions = [];

  mapAndStoreActionModel({required List<DriverModel> driverData}) {
    List<ActionModel> defaultActionModels = [
      ActionModel(
          title: 'List Vehicle',
          suffix: '',
          voidCallback: () {
            searchController.closeView('Settings');
            FocusManager.instance.primaryFocus?.unfocus();
          }),
      ActionModel(
          title: 'Best Driver',
          suffix: '',
          voidCallback: () {
            searchController.closeView('Settings');
            FocusManager.instance.primaryFocus?.unfocus();
          }),
      ActionModel(
          title: 'Worst Driver',
          suffix: '',
          voidCallback: () {
            searchController.closeView('Settings');
            FocusManager.instance.primaryFocus?.unfocus();
          }),
      ActionModel(
        title: 'Settings',
        suffix: '',
        voidCallback: () {
          searchController.closeView('Settings');
          pageMover.push(widget: const Settings());
          FocusManager.instance.primaryFocus?.unfocus();
        },
      ),
    ];
    listOfActions = List.from(defaultActionModels);
    driverData.map(
      (e) {
        var data = ActionModel(
          title: e.name,
          suffix: e.licensePlate,
          voidCallback: () {
            searchController.closeView(e.name);
            pageMover.push(
              widget: DetailVehiclePage(
                licensePlate: e.licensePlate,
              ),
            );
            FocusManager.instance.primaryFocus?.unfocus();
          },
        );
        listOfActions.add(data);
      },
    ).toList();
    notifyListeners();
  }
}
