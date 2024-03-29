import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vms/admin/home/view/list_driver.dart';
import 'package:vms/admin/live_view/view/detail_vehicle.dart';
import 'package:vms/admin/settings/view/list_vehicle.dart';
import 'package:vms/admin/settings/view/settings.dart';
import 'package:vms/auth/controller/auth_controller.dart';
import 'package:vms/auth/model/user_model.dart';
import 'package:vms/constant.dart';
import 'package:vms/global/model/action_model.dart';

class HomeController extends ChangeNotifier {
  SearchController searchController = SearchController();
  List<ActionModel> listOfActions = [];

  mapAndStoreActionModel({required List<User> driverData}) {
    List<ActionModel> defaultActionModels = [
      ActionModel(
          title: 'List Vehicle',
          suffix: '',
          voidCallback: () {
            searchController.closeView('List Vehicle');
            pageMover.push(widget: const ListVehicle());
            FocusManager.instance.primaryFocus?.unfocus();
          }),
      ActionModel(
          title: 'Best Driver',
          suffix: '',
          voidCallback: () {
            searchController.closeView('Best Driver');
            pageMover.push(
                widget: ListDriver(
              isHighest: true,
            ));
            FocusManager.instance.primaryFocus?.unfocus();
          }),
      ActionModel(
          title: 'Worst Driver',
          suffix: '',
          voidCallback: () {
            searchController.closeView('Worst Driver');
            pageMover.push(
                widget: ListDriver(
              isHighest: false,
            ));
            FocusManager.instance.primaryFocus?.unfocus();
          }),
      ActionModel(
          title: 'logout',
          suffix: '',
          voidCallback: () {
            searchController.closeView('Logout');
            Provider.of<AuthController>(navigatorKey.currentContext!,
                    listen: false)
                .logout();
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
          suffix: e.vehicleUid != '' ? e.vehicle!.licensePlate : '',
          voidCallback: () {
            searchController.closeView(e.name);
            pageMover.push(
              widget: DetailVehiclePage(
                uid: e.uid,
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
