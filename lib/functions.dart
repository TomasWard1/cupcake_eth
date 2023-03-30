import 'package:cupcake_eth2/CupcakeStore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'contract_linking.dart';

class CupcakeFunctions {
  ContractLinker get cl => Get.find<ContractLinker>();

  addUserFlow() {
    Get.dialog(Dialog(
      child: Container(
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
                width: double.infinity,
                child:
                    Text('Add User', style: TextStyle(color: Colors.black, fontSize: 30, fontWeight: FontWeight.bold))),
            const SizedBox(
              width: double.infinity,
              child: Text('Please insert eth address',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 19,
                  )),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: TextField(
                controller: cl.ethAddressController,
                decoration: const InputDecoration(helperText: 'Eth Address...'),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 20),
              width: double.infinity,
              child: CupcakeStore().actionButton('Done', () async {
                Get.back();
                cl.setLoading(true);
                await cl.addUser(cl.ethAddressController.text);
                cl.ethAddressController.clear();
                cl.setLoading(false);
              }),
            )
          ],
        ),
      ),
    ));
  }

  buyDialog(String type) {
    bool machine = (type == 'Machine');
    String desc = machine ? 'Insert amount' : 'Insert amount and eth address';
    Get.dialog(Dialog(
      child: Container(
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
                width: double.infinity,
                child: Text('Buy from $type',
                    style: const TextStyle(color: Colors.black, fontSize: 30, fontWeight: FontWeight.bold))),
            SizedBox(
              width: double.infinity,
              child: Text(desc,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 19,
                  )),
            ),
            if (!machine) ...[
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: TextField(
                  controller: cl.ethAddressController,
                  decoration: const InputDecoration(helperText: 'Eth Address...'),
                ),
              ),
            ],
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: TextField(
                controller: cl.cupcakeAmountController,
                decoration: const InputDecoration(helperText: 'How many cupcakes?'),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 20),
              width: double.infinity,
              child: CupcakeStore().actionButton('Done', () async {
                Get.back();
                cl.setLoading(true);

                try {
                  if (machine) {
                    await cl.buyFromMachine(int.parse(cl.cupcakeAmountController.text));
                  } else {
                    await cl.buyFromUser(int.parse(cl.cupcakeAmountController.text), cl.ethAddressController.text);
                  }
                } catch (e) {
                  Get.snackbar('Error', e.toString(), duration: const Duration(seconds: 4));
                }
                cl.cupcakeAmountController.clear();
                cl.ethAddressController.clear();
                cl.setLoading(false);
              }),
            )
          ],
        ),
      ),
    ));
  }

  String getEconomicState() {
    int myCupcakes = cl.balances[cl.myAddress.value] ?? 0;
    if (0 <= myCupcakes && myCupcakes < 100) {
      return 'Poor';
    } else if (100 <= myCupcakes && myCupcakes < 500) {
      return 'Rich';
    } else {
      return 'Millionaire';
    }
  }

  resetMachine() async {
    //only machine and balances are reset; the people will still be there\
    await cl.resetMachine();
  }
}
