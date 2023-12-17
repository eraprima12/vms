// ignore_for_file: annotate_overrides, must_be_immutable

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vms/constant.dart';
import 'package:vms/driver/permission/controller/permission_controller.dart';
import 'package:vms/global/widget/marquee_widget.dart';
import 'package:vms/global/widget/widgettext.dart';

class LocationPermissionPage extends StatefulWidget {
  LocationPermissionPage({Key? key, required this.allowedPermission})
      : super(key: key);
  String? allowedPermission;
  @override
  State<LocationPermissionPage> createState() => _LocationPermissionPageState();
}

class _LocationPermissionPageState extends State<LocationPermissionPage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      Provider.of<GPSLocationPermissionHandlerProvider>(
        context,
        listen: false,
      ).isAcceptAll(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<GPSLocationPermissionHandlerProvider>(
      context,
    );
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 100,
              ),
              WidgetText(
                text:
                    'Ubah Perizinan ${widget.allowedPermission}\nke “Izinkan sepanjang waktu"',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                align: TextAlign.center,
              ),
              const SizedBox(
                height: 50,
              ),
              Row(
                children: [
                  Container(
                    height: 30,
                    width: 30,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Center(
                      child: WidgetText(
                        text: '1',
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  const Flexible(
                    child: MarqueeWidget(
                      child: WidgetText(
                        text: 'Tekan tombol "Buka Pengaturan" dibawah ini.',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Container(
                    height: 30,
                    width: 30,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Center(
                      child: WidgetText(
                        text: '2',
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  const WidgetText(
                    text: 'Pilih "Izinkan Sepanjang Waktu".',
                  ),
                ],
              ),
              const SizedBox(
                width: 11,
              ),
              Image.asset('assets/bg_home.png'),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Container(
                    height: 30,
                    width: 30,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Center(
                      child: WidgetText(
                        text: '3',
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  const WidgetText(
                    text: 'Kemudian, kembali ke Smart Driver.',
                  ),
                ],
              ),
              const SizedBox(
                height: 122,
              ),
              InkWell(
                onTap: () {
                  provider.openAppSetting();
                },
                child: AnimatedContainer(
                  curve: Curves.ease,
                  duration: const Duration(milliseconds: 1000),
                  padding: const EdgeInsets.symmetric(vertical: 13.5),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: provider.loadData
                        ? const CupertinoActivityIndicator(
                            color: Colors.white,
                          )
                        : const WidgetText(
                            text: 'Buka Pengaturan',
                            color: Colors.white,
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
