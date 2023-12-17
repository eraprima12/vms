import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vms/constant.dart';
import 'package:vms/driver/permission/controller/permission_controller.dart';
import 'package:vms/global/widget/widgettext.dart';

class GPSPermissionPage extends StatefulWidget {
  const GPSPermissionPage({Key? key}) : super(key: key);

  @override
  State<GPSPermissionPage> createState() => _GPSPermissionPageState();
}

class _GPSPermissionPageState extends State<GPSPermissionPage>
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
              Image.asset('assets/login_vector.png'),
              const SizedBox(
                height: 30,
              ),
              const WidgetText(
                text: 'Layanan GPS',
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              const SizedBox(
                height: 12,
              ),
              WidgetText(
                text: 'Aktifkan layanan GPS perangkat anda.',
                color: secondaryColor,
              ),
              const SizedBox(
                height: 122,
              ),
              InkWell(
                onTap: () {
                  provider.requestGPSService(context);
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
                            text: 'Aktifkan',
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
