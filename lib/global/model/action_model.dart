import 'package:flutter/material.dart';

class ActionModel {
  final String title;
  final String suffix;
  final VoidCallback voidCallback;

  ActionModel({
    required this.title,
    required this.suffix,
    required this.voidCallback,
  });
}
