import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'contract_linking.dart';

class CupcakeStore extends GetView<ContractLinker> {
  const CupcakeStore({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(children: [
          Image.asset('assets/cupcake.png', width: 100, height: 100),
          const Text('Cupcake ETH', style: TextStyle(color: Colors.black, fontSize: 30, fontWeight: FontWeight.bold)),
          const Spacer(),
          Row(
            children: [
              const Spacer(),
              actionButton('Buy From Machine', () {
                print('Buy From Machine');
              }),
              const Spacer(),
              actionButton('Buy From User', () {
                print('Buy From User');
              }),
              const Spacer(),
            ],
          )
        ]),
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
