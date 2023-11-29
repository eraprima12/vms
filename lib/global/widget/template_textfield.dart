// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:vms/global/widget/widgettext.dart';

class TemplateTextField extends StatelessWidget {
  TemplateTextField(
      {super.key,
      required this.textEditingController,
      this.borderColor,
      this.hint,
      this.prefixIcon,
      this.onType,
      this.usingValidator,
      this.isPassword,
      this.textColor,
      this.label});
  TextEditingController textEditingController;
  Color? borderColor;
  Function(String val)? onType;
  String? label;
  String? hint;
  Color? textColor;
  Icon? prefixIcon;
  bool? isPassword;
  bool? usingValidator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onChanged: onType,
      style: TextStyle(color: textColor ?? Colors.black),
      controller: textEditingController,
      obscureText: isPassword ?? false,
      validator: usingValidator != null
          ? (val) {
              return val!.isEmpty ? 'Tidak Boleh Kosong' : null;
            }
          : null,
      decoration: InputDecoration(
        prefixIcon: prefixIcon,
        label: label == null
            ? null
            : WidgetText(
                text: label ?? '',
                color: textColor,
              ),
        hintText: hint,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            width: 1,
            color: borderColor ?? Colors.grey,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            width: 1,
            color: borderColor ?? Colors.grey,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(
            width: 1,
            color: borderColor ?? Colors.grey,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            width: 1,
            color: Colors.red,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}
