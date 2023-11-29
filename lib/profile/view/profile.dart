import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vms/auth/controller/auth_controller.dart';
import 'package:vms/global/widget/widgettext.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const WidgetText(
          text: 'Profile',
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
}
