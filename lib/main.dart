// ignore_for_file: use_build_context_synchronous, use_build_context_synchronously
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get_storage/get_storage.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:vms/admin/home/controller/home_controller.dart';
import 'package:vms/admin/menu/view/menu.dart';
import 'package:vms/auth/controller/auth_controller.dart';
import 'package:vms/auth/controller/drivers_controller.dart';
import 'package:vms/auth/view/auth_page.dart';
import 'package:vms/constant.dart';
import 'package:vms/driver/bg_locator/bg_locator_provider.dart';
import 'package:vms/driver/home/view/home.dart';
import 'package:vms/driver/permission/controller/permission_controller.dart';
import 'package:vms/gen/assets.gen.dart';
import 'package:vms/global/function/local_storage_handler.dart';
import 'package:vms/global/widget/widgettext.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await GetStorage.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthController()),
        ChangeNotifierProvider(create: (context) => HomeController()),
        ChangeNotifierProvider(create: (context) => DriversController()),
        ChangeNotifierProvider(create: (context) => BGLocatorProvider()),
        ChangeNotifierProvider(
            create: (context) => GPSLocationPermissionHandlerProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      scaffoldMessengerKey: scaffoldKey,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Splashscreen(title: 'Flutter Demo Home Page'),
    );
  }
}

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key, required this.title});

  final String title;

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        String? token = localStorage.read(tokenKey);
        String? uid = localStorage.read(uidKey) ?? '';
        String? companyUid = localStorage.read(companyUidKey) ?? '';
        if (token != null) {
          await Provider.of<AuthController>(context, listen: false)
              .getMasterSettings(uid: companyUid);
          setState(() {});
          Future.delayed(const Duration(milliseconds: 2000))
              .then((value) async {
            await Provider.of<AuthController>(context, listen: false)
                .getAndSetUserDetail(uid: uid);
            await Provider.of<DriversController>(context, listen: false)
                .getAndMapDriverData();
            pageMover.pushAndRemove(
                widget: getIsDriver()
                    ? const HomeDriver()
                    : const TabBarBottomNavPage());
          });
        } else {
          Future.delayed(const Duration(milliseconds: 500)).then(
            (value) => pageMover.pushAndRemove(widget: const LoginPage()),
          );
        }
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;

    width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SizedBox(
        height: height,
        width: width,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 150,
                width: 150,
                child: splashLink != ''
                    ? CachedNetworkImage(
                        imageUrl: splashLink,
                        height: 60,
                        errorWidget: (context, error, _) {
                          return const CupertinoActivityIndicator();
                        },
                        width: 130,
                        cacheManager: CacheManager(
                          Config(
                            "splash",
                            stalePeriod: const Duration(days: 7),
                            //one week cache period
                          ),
                        ),
                      )
                    : Lottie.asset(Assets.splash),
              ),
              splashLink != ''
                  ? WidgetText(
                      text: 'VMS',
                      color: primaryColor,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    )
                  : const SizedBox()
            ],
          ),
        ),
      ),
    );
  }
}
