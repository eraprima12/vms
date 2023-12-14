import 'package:flutter/material.dart';
import 'package:vms/constant.dart';

Color getStatusColor(status) {
  late Color res;
  status ? res = Colors.green : res = Colors.grey;
  return res;
}

Color getBackgroundColor(BuildContext context) {
  final ThemeData theme = Theme.of(context);
  return theme.colorScheme.background;
}

Color invertBackgroundColor(BuildContext context) {
  Color backgroundColor = getBackgroundColor(context);

  // Calculate the perceived brightness of the background color
  double perceivedBrightness = (backgroundColor.red * 299 +
          backgroundColor.green * 587 +
          backgroundColor.blue * 114) /
      1000;

  // Decide whether to use light or dark text based on the perceived brightness
  return perceivedBrightness > 128 ? textColor : Colors.white;
}
