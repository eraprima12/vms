import 'package:flutter/material.dart';
import 'package:vms/constant.dart';

Color getStatusColor(status) {
  late Color res;
  status == offlineStatus
      ? res = Colors.grey
      : status == onlineStatus
          ? res = Colors.green
          : res = Colors.orange;
  return res;
}
