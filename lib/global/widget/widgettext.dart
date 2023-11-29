import 'package:flutter/material.dart';
import 'package:vms/constant.dart';

class WidgetText extends StatelessWidget {
  final String text;
  final double? fontSize;
  final TextOverflow? overflow;
  final FontWeight? fontWeight;
  final Color? color;
  final int? maxLines;
  final TextAlign? align;
  final String? fontFamily;
  final double? height;

  const WidgetText({
    Key? key,
    this.align,
    this.overflow,
    required this.text,
    this.fontSize,
    this.fontWeight,
    this.color,
    this.height = 1,
    this.fontFamily,
    this.maxLines,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: align ?? TextAlign.left,
      overflow: overflow ?? TextOverflow.ellipsis,
      style: TextStyle(
        color: color ?? textColor,
        fontWeight: fontWeight ?? FontWeight.w500,
        fontFamily: 'milliard',
        fontSize: fontSize ?? 14,
        height: 1.5,
      ),
      maxLines: maxLines,
    );
  }
}
