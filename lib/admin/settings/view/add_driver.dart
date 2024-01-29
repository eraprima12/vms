// ignore_for_file: must_be_immutable, library_private_types_in_public_api

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:vms/auth/controller/auth_controller.dart';
import 'package:vms/auth/controller/drivers_controller.dart';
import 'package:vms/auth/model/driver_model.dart';
import 'package:vms/auth/model/user_model.dart';
import 'package:vms/constant.dart';
import 'package:vms/global/widget/widgettext.dart';

class AddDriver extends StatefulWidget {
  AddDriver({super.key, this.data, this.isEdit});
  bool? isEdit = false;
  User? data;
  @override
  _AddDriverState createState() => _AddDriverState();
}

class _AddDriverState extends State<AddDriver> {
  final ImagePicker _imagePicker = ImagePicker();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _vehicleUID = TextEditingController();
  Vehicle? selected;
  final formKey = GlobalKey<FormState>();

  XFile? _pickedImage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        if (widget.data != null) {
          _usernameController.text = widget.data!.username;
          _passwordController.text = widget.data!.password;
          _nameController.text = widget.data!.name;
          Provider.of<DriversController>(context, listen: false)
              .getListVehicle(unique: true);
          Provider.of<DriversController>(context, listen: false)
              .getAndMapDriverData();
          if (widget.data!.vehicle != null) {
            _vehicleUID.text = widget.data!.vehicle!.licensePlate;
            selected = widget.data!.vehicle!;
            if (widget.isEdit!) {
              Provider.of<DriversController>(context, listen: false)
                  .listVehicle
                  .add(widget.data!.vehicle!);
            }
            Provider.of<DriversController>(context, listen: false)
                .listVehicle
                .add(
                  Vehicle(
                    avatar: '',
                    companyUid: '',
                    createdAt: DateTime.now(),
                    licensePlate: 'Unassign',
                    odo: 0,
                    overspeedLimit: 0,
                    serviceOdoEvery: 0,
                    uid: '',
                  ),
                );
          }
        }
      },
    );
  }

  Future<void> _pickImage() async {
    XFile? pickedImage =
        await _imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _pickedImage = pickedImage;
      });
    }
  }

  Future<void> _submitData() async {
    Provider.of<DriversController>(context, listen: false)
        .getListVehicle(unique: true);
    Provider.of<DriversController>(context, listen: false)
        .getAndMapDriverData();
    if (formKey.currentState!.validate() && selected != null) {
      await Provider.of<AuthController>(context, listen: false)
          .addDriver(
              widget.isEdit!,
              widget.data,
              _nameController.text,
              _passwordController.text,
              _usernameController.text,
              selected != null ? selected!.uid : '',
              _pickedImage != null ? File(_pickedImage!.path) : null)
          .then((value) {
        _usernameController.clear();
        _passwordController.clear();
        _nameController.clear();
        _vehicleUID.clear();
        setState(() {
          _pickedImage = null;
        });
        selected = null;
      });
    } else {
      popupHandler.showErrorPopup('Complete the data');
    }
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;

    width = MediaQuery.of(context).size.width;
    var provider = Provider.of<DriversController>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Form'),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: _pickedImage != null
                        ? Image.file(
                            File(_pickedImage!.path),
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          )
                        : widget.isEdit!
                            ? widget.data!.avatar != ''
                                ? Image.network(
                                    widget.data!.avatar,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  )
                                : const Icon(
                                    Icons.camera_alt,
                                    size: 40,
                                  )
                            : const Icon(
                                Icons.camera_alt,
                                size: 40,
                              ),
                  ),
                ),
                const SizedBox(height: 16),
                // Form Fields
                TextFormField(
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Username Can`t be empty';
                    }
                    return null;
                  },
                  controller: _usernameController,
                  decoration: const InputDecoration(labelText: 'Username'),
                ),
                TextFormField(
                  validator: (value) {
                    if (value!.length < 6) {
                      return 'Password must longer than 6';
                    }
                    return null;
                  },
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                ),
                TextFormField(
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Name Can`t be empty';
                    }
                    return null;
                  },
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                DropdownButtonFormField<Vehicle>(
                  value: selected,
                  onChanged: (value) {
                    setState(() {
                      selected = value;
                      _vehicleUID.text = value!.licensePlate;
                    });
                  },
                  items: provider.listVehicle.map((Vehicle vehicle) {
                    return DropdownMenuItem<Vehicle>(
                      value: vehicle,
                      child: Text(vehicle.licensePlate),
                    );
                  }).toList(),
                  decoration: const InputDecoration(
                    labelText: 'Vehicle',
                    hintText: 'Select Vehicle',
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 80,
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: GestureDetector(
          onTap: _submitData,
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
}
