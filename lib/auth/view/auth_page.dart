// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vms/auth/controller/auth_controller.dart';
import 'package:vms/constant.dart';
import 'package:vms/gen/assets.gen.dart';
import 'package:vms/global/widget/template_textfield.dart';
import 'package:vms/global/widget/widgettext.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;

    width = MediaQuery.of(context).size.width;
    var unlistenedProvider =
        Provider.of<AuthController>(context, listen: false);
    var provider = Provider.of<AuthController>(context);
    return Scaffold(
      bottomNavigationBar: Container(
        color: primaryColor,
        height: 100,
        padding: const EdgeInsets.all(20),
        child: GestureDetector(
          onTap: () {
            if (unlistenedProvider.loadingLogin == false) {
              unlistenedProvider.checkCredentials();
            }
          },
          child: Container(
            color: secondaryColor,
            padding: const EdgeInsets.all(20),
            child: Center(
              child: provider.loadingLogin
                  ? const CupertinoActivityIndicator()
                  : const WidgetText(
                      fontWeight: FontWeight.w700,
                      text: 'Login',
                      color: Colors.white,
                    ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: provider.formKey,
          child: SizedBox(
            height: height,
            width: width,
            child: Column(
              children: [
                Expanded(
                  flex: 1,
                  child: SizedBox(
                    child: Assets.loginVector.image(fit: BoxFit.cover),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    color: primaryColor,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const WidgetText(
                          text: 'Login',
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        TemplateTextField(
                          textEditingController: provider.usernameController,
                          borderColor: Colors.white,
                          textColor: Colors.white,
                          usingValidator: true,
                          label: 'Username',
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        TemplateTextField(
                          textEditingController: provider.passwordController,
                          borderColor: Colors.white,
                          textColor: Colors.white,
                          usingValidator: true,
                          isPassword: true,
                          label: 'Password',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
