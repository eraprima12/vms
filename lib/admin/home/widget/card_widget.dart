import 'package:flutter/material.dart';
import 'package:vms/constant.dart';
import 'package:vms/global/function/random_string_generator.dart';
import 'package:vms/global/widget/widgettext.dart';

class CardWithTitleAndSubtitle extends StatelessWidget {
  const CardWithTitleAndSubtitle(
      {super.key,
      required this.data,
      required this.title,
      required this.color});
  final String title;
  final Widget data;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
              offset: const Offset(0, 1),
              spreadRadius: 1,
              blurRadius: 5,
              color: color!)
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WidgetText(
              text: title,
              color: Colors.white,
            ),
            const SizedBox(height: 10),
            data
          ],
        ),
      ),
    );
  }
}
