import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'LoginController.dart';

class Login extends GetView<LoginController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Column(
        children: [
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
                onPressed: () {
                  controller.loginUsingMetamask();
                },
                child: const Text('Login With Metamask')),
          ),
          Obx(
            () => Container(
              margin: const EdgeInsets.only(top: 20),
              child: Text(controller.sessionGlobal.value?.accounts.first ?? 'No account connected'),
            ),
          ),
          const Spacer()
        ],
      ),
    ));
  }
}
