import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vms/auth/controller/auth_controller.dart';
import 'package:vms/constant.dart';
import 'package:vms/global/widget/widgettext.dart';

class DriverProfilePage extends StatelessWidget {
  const DriverProfilePage({super.key}); // Replace with your company name

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<AuthController>(context);
    var unlistenedprovider =
        Provider.of<AuthController>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 150,
              width: 150,
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: provider.user!.avatar != ''
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: Image.network(
                          height: 150,
                          width: 150,
                          provider.user!.avatar,
                          fit: BoxFit.cover,
                        ),
                      )
                    : WidgetText(
                        text: provider.user!.name.substring(0, 1).toUpperCase(),
                        color: secondaryColor,
                        fontWeight: FontWeight.bold,
                      ),
              ),
            ),
            const SizedBox(height: 20),
            WidgetText(text: 'Username : ${provider.user!.username}'),
            const SizedBox(height: 20),
            WidgetText(text: 'Name : ${provider.user!.name}'),
            const Spacer(),
            GestureDetector(
              onTap: () {
                unlistenedprovider.logout();
              },
              child: Container(
                width: width,
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: secondaryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: WidgetText(
                    text: 'Log Out',
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const WidgetText(
              text: 'Presented By Era Prima S',
            ),
          ],
        ),
      ),
    );
  }
}
