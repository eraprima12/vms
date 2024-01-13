// ignore_for_file: library_private_types_in_public_api

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:vms/admin/settings/view/list_service.dart';
import 'package:vms/auth/controller/auth_controller.dart';
import 'package:vms/auth/model/driver_model.dart';
import 'package:vms/constant.dart';
import 'package:vms/global/widget/widgettext.dart';

class VehicleForm extends StatefulWidget {
  VehicleForm({super.key, this.data});
  Vehicle? data;

  @override
  _VehicleFormState createState() => _VehicleFormState();
}

class _VehicleFormState extends State<VehicleForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _licensePlateController = TextEditingController();
  final TextEditingController _odoController = TextEditingController();
  final TextEditingController _overspeedLimitController =
      TextEditingController();
  final TextEditingController _serviceOdoEveryController =
      TextEditingController();

  XFile? _avatarImage;

  Future<void> _pickImage() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedImage != null) {
        _avatarImage = pickedImage;
      }
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      await Provider.of<AuthController>(context, listen: false)
          .addVehicle(
              widget.data,
              _licensePlateController.text,
              int.parse(_overspeedLimitController.text),
              int.parse(_serviceOdoEveryController.text),
              int.parse(_odoController.text),
              _avatarImage != null ? File(_avatarImage!.path) : null)
          .then((value) {
        _licensePlateController.clear();
        _odoController.clear();
        _serviceOdoEveryController.clear();
        _overspeedLimitController.clear();
        setState(() {
          _avatarImage = null;
        });
      });
    } else {
      popupHandler.showErrorPopup('Complete the data');
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.data != null) {
      _licensePlateController.text = widget.data!.licensePlate;
      _overspeedLimitController.text = widget.data!.overspeedLimit.toString();
      _odoController.text = widget.data!.odo.toString();
      _serviceOdoEveryController.text = widget.data!.serviceOdoEvery.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;

    width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicle Form'),
        actions: widget.data != null
            ? [
                IconButton(
                    onPressed: () {
                      pageMover.push(
                        widget: ListService(data: widget.data!),
                      );
                    },
                    icon: const Icon(Icons.medical_services_rounded))
              ]
            : [],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: _avatarImage != null
                        ? Image.file(
                            File(_avatarImage!.path),
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          )
                        : widget.data != null
                            ? widget.data!.avatar != ''
                                ? Image.network(
                                    widget.data!.avatar,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  )
                                : const Icon(Icons.camera_alt, size: 40)
                            : const Icon(Icons.camera_alt, size: 40),
                  ),
                ),
              ),
              _buildTextField('License Plate', _licensePlateController),
              _buildTextField('Odometer', _odoController,
                  keyboardType: TextInputType.number),
              _buildTextField('Overspeed Limit', _overspeedLimitController,
                  keyboardType: TextInputType.number),
              _buildTextField('Service Odo Every', _serviceOdoEveryController,
                  keyboardType: TextInputType.number),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 80,
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: GestureDetector(
          onTap: _submitForm,
          child: Container(
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  offset: const Offset(0, 1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  color: primaryColor,
                ),
              ],
            ),
            child: const Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  WidgetText(
                    text: 'Submit',
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Icon(
                    Icons.upload,
                    color: Colors.white,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
      ),
      validator: (value) {
        if (value!.isEmpty) {
          return 'This field is required';
        }
        return null;
      },
    );
  }
}
