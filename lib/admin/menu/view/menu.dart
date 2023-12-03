import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:vms/admin/home/view/home.dart';
import 'package:vms/admin/live_view/view/maps.dart';
import 'package:vms/admin/settings/view/settings.dart';
import 'package:vms/auth/controller/auth_controller.dart';
import 'package:vms/constant.dart';

class TabBarBottomNavPage extends StatefulWidget {
  const TabBarBottomNavPage({super.key});

  @override
  State<TabBarBottomNavPage> createState() => _TabBarBottomNavPageState();
}

class _TabBarBottomNavPageState extends State<TabBarBottomNavPage> {
  DateTime? lastTapTime;
  @override
  void initState() {
    super.initState();
    Provider.of<AuthController>(context, listen: false).initListener();
  }

  int selectedIndex = 0;
  TextStyle optionStyle =
      const TextStyle(fontSize: 30, fontWeight: FontWeight.w600);
  List<Widget> widgetOptions = <Widget>[
    const HomePage(),
    const MapScreen(),
    const Settings(),
  ];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        DateTime now = DateTime.now();
        if (lastTapTime == null ||
            now.difference(lastTapTime!) > const Duration(seconds: 2)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Press back again to exit'),
            ),
          );
          lastTapTime = now;
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: widgetOptions.elementAt(selectedIndex),
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                blurRadius: 20,
                color: Colors.black.withOpacity(.1),
              )
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
              child: GNav(
                rippleColor: Colors.grey[300]!,
                hoverColor: Colors.grey[100]!,
                gap: 8,
                iconSize: 24,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                duration: const Duration(milliseconds: 400),
                activeColor: Colors.white,
                tabBackgroundColor: primaryColor,
                color: textColor,
                tabs: [
                  GButton(
                    icon: Icons.home_outlined,
                    text: 'Home',
                    iconActiveColor: Colors.white,
                    backgroundColor: primaryColor,
                    textColor: Colors.white,
                  ),
                  GButton(
                    icon: Icons.map_outlined,
                    text: 'Map',
                    iconActiveColor: Colors.white,
                    backgroundColor: primaryColor,
                    textColor: Colors.white,
                  ),
                  GButton(
                    icon: Icons.person_outline,
                    text: 'Settings',
                    iconActiveColor: Colors.white,
                    backgroundColor: primaryColor,
                    textColor: Colors.white,
                  ),
                ],
                selectedIndex: selectedIndex,
                onTabChange: (index) {
                  setState(() {
                    selectedIndex = index;
                  });
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
