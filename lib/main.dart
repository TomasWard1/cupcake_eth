import 'package:cupcake_eth2/CupcakeStore.dart';
import 'package:cupcake_eth2/LoginController.dart';
import 'package:cupcake_eth2/contract_linking.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'Login.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(ContractLinker());
  Get.put(LoginController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Login());
  }
}















