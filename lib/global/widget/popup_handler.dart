import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:vms/constant.dart';
import 'package:vms/gen/assets.gen.dart';
import 'package:vms/global/widget/widgettext.dart';

class PopupHandler {
  var context = navigatorKey.currentContext!;
  void showErrorPopup(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          insetPadding: const EdgeInsets.all(10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          title: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () {
                      pageMover.pop();
                    },
                    icon: const Icon(Icons.close),
                  )
                ],
              ),
              Lottie.asset(Assets.error),
              const SizedBox(
                height: 20,
              ),
              const WidgetText(
                text: 'Error',
                fontWeight: FontWeight.w700,
              ),
              const SizedBox(
                height: 20,
              ),
              Center(
                child: WidgetText(
                  text: message,
                  align: TextAlign.center,
                  maxLines: 3,
                ),
              ),
              const SizedBox(
                height: 40,
              )
            ],
          ),
        );
      },
    );
  }
}
