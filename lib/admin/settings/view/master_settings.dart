import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:vms/constant.dart';

class MasterSettings extends StatefulWidget {
  const MasterSettings({super.key});

  @override
  _MasterSettingsState createState() => _MasterSettingsState();
}

class _MasterSettingsState extends State<MasterSettings> {
  int? _maxSpeed;
  int? _minDistancePerDay;
  int? _servicePerKM;
  File? _splashScreenImage;

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
        title: const Text('Flutter Color and Image Picker'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Max Speed'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _maxSpeed = int.tryParse(value);
              },
            ),
            TextField(
              decoration:
                  const InputDecoration(labelText: 'Min Distance Per Day'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _minDistancePerDay = int.tryParse(value);
              },
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Service Per KM'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _servicePerKM = int.tryParse(value);
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Primary Color:'),
                GestureDetector(
                  onTap: () {
                    _selectColor(primaryColor, (color) {
                      setState(() {
                        primaryColor = color;
                      });
                    });
                  },
                  child: Container(
                    width: 30,
                    height: 30,
                    color: primaryColor,
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
                    _selectColor(secondaryColor, (color) {
                      setState(() {
                        secondaryColor = color;
                      });
                    });
                  },
                  child: Container(
                    width: 30,
                    height: 30,
                    color: secondaryColor,
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
                    _selectColor(thirdColor, (color) {
                      setState(() {
                        thirdColor = color;
                      });
                    });
                  },
                  child: Container(
                    width: 30,
                    height: 30,
                    color: thirdColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _pickImage,
              child: _splashScreenImage != null
                  ? Image.file(_splashScreenImage!)
                  : const Icon(
                      Icons.camera,
                      size: 50,
                    ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Use _maxSpeed, _minDistancePerDay, _servicePerKM,
                // _primaryColor, _secondaryColor, _thirdColor, _splashScreenImage
                print('Max Speed: $_maxSpeed');
                print('Min Distance Per Day: $_minDistancePerDay');
                print('Service Per KM: $_servicePerKM');
                print('Primary Color: $primaryColor');
                print('Secondary Color: $secondaryColor');
                print('Third Color: $thirdColor');
                print('Splash Screen Image Path: ${_splashScreenImage?.path}');
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
