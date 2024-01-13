import 'package:flutter/material.dart';
import 'package:vms/admin/home/widget/card_widget.dart';
import 'package:vms/auth/model/user_model.dart';
import 'package:vms/constant.dart';
import 'package:vms/global/widget/widgettext.dart';

class CardWithTotalDistance extends StatelessWidget {
  const CardWithTotalDistance({
    Key? key,
    required this.color,
    required this.title,
    required this.data,
  }) : super(key: key);

  final Color color;
  final String title;
  final Widget data;

  @override
  Widget build(BuildContext context) {
    return CardWithTitleAndSubtitle(
      color: color,
      title: title,
      data: data,
    );
  }
}

class CardWithServiceInKm extends StatelessWidget {
  const CardWithServiceInKm({
    Key? key,
    required this.color,
    required this.title,
    required this.data,
  }) : super(key: key);

  final Color color;
  final String title;
  final Widget data;

  @override
  Widget build(BuildContext context) {
    return CardWithTitleAndSubtitle(
      color: color,
      title: title,
      data: data,
    );
  }
}

class CardWithAvatar extends StatelessWidget {
  const CardWithAvatar({
    super.key,
    required this.param,
  });

  final User param;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: primaryColor,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.white,
          child: param.avatar != ''
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Image.network(
                    param.avatar,
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                  ),
                )
              : WidgetText(
                  text: param.name.substring(0, 1).toUpperCase(),
                  color: textColor,
                ),
        ),
        title: WidgetText(
          text: param.name,
          color: Colors.white,
        ),
        subtitle: WidgetText(
            color: Colors.white,
            text:
                'Distance Today: ${param.distanceToday.toStringAsFixed(2)} km'),
      ),
    );
  }
}
