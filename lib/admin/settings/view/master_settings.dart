import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import 'package:vms/auth/controller/auth_controller.dart';
import 'package:vms/auth/model/master_model.dart';
import 'package:vms/constant.dart';
import 'package:vms/global/model/hexcolor.dart';
import 'package:vms/global/widget/widgettext.dart';

class MasterSettings extends StatefulWidget {
  const MasterSettings({super.key});

  @override
  _MasterSettingsState createState() => _MasterSettingsState();
}

class _MasterSettingsState extends State<MasterSettings> {
  File? _splashScreenImage;
  var _primaryColor = primaryColor;

  var _secondaryColor = secondaryColor;

  var _thirdColor = thirdColor;

  void _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _splashScreenImage = File(pickedFile.path);
      });
    }
  }

  void _selectColor(Color currentColor, ValueChanged<Color> onSelectColor) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick a color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: currentColor,
              onColorChanged: onSelectColor,
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preferensi Tampilan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Primary Color:'),
                GestureDetector(
                  onTap: () {
                    _selectColor(_primaryColor, (color) {
                      setState(() {
                        _primaryColor = color;
                      });
                    });
                  },
                  child: Container(
                    width: 30,
                    height: 30,
                    color: _primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Secondary Color:'),
                GestureDetector(
                  onTap: () {
                    _selectColor(_secondaryColor, (color) {
                      setState(() {
                        _secondaryColor = color;
                      });
                    });
                  },
                  child: Container(
                    width: 30,
                    height: 30,
                    color: _secondaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Third Color:'),
                GestureDetector(
                  onTap: () {
                    _selectColor(_thirdColor, (color) {
                      setState(() {
                        _thirdColor = color;
                      });
                    });
                  },
                  child: Container(
                    width: 30,
                    height: 30,
                    color: _thirdColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const WidgetText(text: 'Splash Screen Image'),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _pickImage,
              child: _splashScreenImage != null
                  ? Image.file(
                      _splashScreenImage!,
                      height: 200,
                      width: 200,
                      fit: BoxFit.contain,
                    )
                  : splashLink != ''
                      ? CachedNetworkImage(
                          imageUrl: splashLink,
                          height: 200,
                          errorWidget: (context, error, _) {
                            return const CupertinoActivityIndicator();
                          },
                          width: 200,
                          cacheManager: CacheManager(
                            Config(
                              "splash",
                              stalePeriod: const Duration(days: 7),
                              //one week cache period
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.camera,
                          size: 50,
                        ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                Provider.of<AuthController>(context, listen: false)
                    .saveMasterDataToFirestore(
                        Company(
                          primaryColor: _primaryColor.toHex(),
                          secondaryColor: _secondaryColor.toHex(),
                          thirdColor: _thirdColor.toHex(),
                        ),
                        _splashScreenImage);
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
