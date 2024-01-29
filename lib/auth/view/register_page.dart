// ignore_for_file: library_private_types_in_public_api

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:vms/auth/controller/auth_controller.dart';
import 'package:vms/constant.dart';
import 'package:vms/global/function/random_string_generator.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  String companyName = '';
  String adminName = '';
  String username = '';
  String password = '';
  File? avatarImage;
  int currentStep = 0; // Track the current step

  @override
  Widget build(BuildContext context) {
    var unlistenedProvider =
        Provider.of<AuthController>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registration'),
      ),
      body: Stepper(
        currentStep: currentStep,
        onStepCancel: () {
          if (currentStep >= 1) {
            setState(() {
              currentStep -= 1;
            });
          }
        },
        onStepContinue: () async {
          if (currentStep < 1) {
            if (companyName.isNotEmpty) {
              setState(() {
                currentStep += 1;
              });
            } else {
              popupHandler.showErrorPopup('Company name mustn`t be empty');
            }
          } else {
            if (companyName.isNotEmpty &&
                adminName.isNotEmpty &&
                username.isNotEmpty &&
                password.isNotEmpty) {
              popupHandler.showLoading('Creating Account...');
              var companyUID = generateRandomString(length: 10);
              await unlistenedProvider
                  .addCompany(companyName, companyUID)
                  .then((value) async {
                unlistenedProvider
                    .addAdmin(adminName, password, username, companyUID)
                    .then((value) {
                  pageMover.pop();
                  pageMover.pop();
                  popupHandler.showSuccessPopup('Waiting for approval');
                });
              });
            } else {
              popupHandler.showErrorPopup('Field mustn`t be empty');
            }
          }
        },
        steps: [
          Step(
            title: const Text('Company Info'),
            content: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: 'Company Name'),
                  onChanged: (value) {
                    setState(() {
                      companyName = value;
                    });
                  },
                ),
              ],
            ),
            isActive: currentStep == 0,
          ),
          Step(
            title: const Text('Admin Info'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: 'Admin Name'),
                  onChanged: (value) {
                    setState(
                      () {
                        adminName = value;
                      },
                    );
                  },
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Username'),
                  onChanged: (value) {
                    setState(
                      () {
                        username = value;
                      },
                    );
                  },
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Password'),
                  onChanged: (value) {
                    setState(() {
                      password = value;
                    });
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  onPressed: () async {
                    final pickedImage = await ImagePicker().pickImage(
                      source: ImageSource.gallery,
                    );
                    setState(
                      () {
                        if (pickedImage != null) {
                          avatarImage = File(pickedImage.path);
                        }
                      },
                    );
                  },
                  child: const Text('Pick Avatar'),
                ),
                if (avatarImage != null)
                  Image.file(
                    avatarImage!,
                    height: 100,
                    width: 100,
                  ),
              ],
            ),
            isActive: currentStep == 1,
          ),
        ],
      ),
    );
  }
}
