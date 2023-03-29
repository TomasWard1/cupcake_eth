import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'contract_linking.dart';

class CupcakeStore extends GetView<ContractLinker> {
  CupcakeStore({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: Padding(
        padding: const EdgeInsets.all(15),
        child: Obx(
          () => Column(children: [
            Image.asset('assets/cupcake.png', width: 100, height: 100),
            const Text('Cupcake ETH', style: TextStyle(color: Colors.black, fontSize: 30, fontWeight: FontWeight.bold)),
            Container(
                margin: const EdgeInsets.only(top: 40),
                width: double.infinity,
                child: Text(
                  'Machine Balance: ${controller.machineBalance.value}',
                  style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.normal),
                  textAlign: TextAlign.left,
                )),
            Container(
                margin: const EdgeInsets.only(top: 10),
                width: double.infinity,
                child: Text(
                  'My Economic State: ${controller.economicState.value}',
                  style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.normal),
                  textAlign: TextAlign.left,
                )),
            const Spacer(),
            Row(
              children: [
                const Spacer(),
                actionButton('💵 Machine', () {
                  print('Buy From Machine');
                }),
                const Spacer(),
                actionButton('💵 User', () {
                  print('Buy From User');
                }),
                const Spacer(),
                actionButton('🔃 Reset', () {
                  print('Reset');
                }),
                const Spacer(),
              ],
            )
          ]),
        ),
      )),
    );
  }

  Widget actionButton(String title, Function() action) {
    return ElevatedButton(
      onPressed: action,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.pinkAccent.shade100,
      ),
      child: Text(
        title,
        style: const TextStyle(color: Colors.black),
      ),
    );
  }
}
