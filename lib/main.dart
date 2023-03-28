import 'package:cupcake_eth2/contract_linking.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'CupcakeStore.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(ContractLinker());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CupcakeStore(),
    );
  }
}
