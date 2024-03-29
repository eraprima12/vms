import 'package:flutter/material.dart';
import 'package:vms/global/function/status_color.dart';
import 'package:vms/global/widget/widgettext.dart';

class CustomMarker extends StatelessWidget {
  final String licensePlate;
  final bool status;

  const CustomMarker(
      {super.key, required this.licensePlate, required this.status});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5.0),
            border: Border.all(color: Colors.black),
          ),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: WidgetText(
              text: licensePlate.toUpperCase(),
            ),
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        Container(
          height: 20,
          width: 20,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            color: getStatusColor(status),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(50),
            ),
          ),
        )
      ],
    );
  }
}
