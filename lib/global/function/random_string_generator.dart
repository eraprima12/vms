import 'dart:math';

import 'package:flutter/cupertino.dart';

final Random _random = Random();

String generateRandomString({required int length}) {
  const String chars =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';

  String result = '';
  for (int i = 0; i < length; i++) {
    result += chars[_random.nextInt(chars.length)];
  }
  return result;
}

Color getRandomBrightColor() {
  final Random random = Random();
  final int r = random.nextInt(128) + 128; // 128-255 for the red component
  final int g = random.nextInt(128) + 128; // 128-255 for the green component
  final int b = random.nextInt(128) + 128; // 128-255 for the blue component
  return Color.fromARGB(
      255, r, g, b); // 255 for the alpha component (fully opaque)
}
