import 'package:cupcake_eth2/functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'contract_linking.dart';

class CupcakeStore extends GetView<ContractLinker> {
  CupcakeStore({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          floatingActionButton: Row(
            children: [
              const Spacer(),
              actionButton('💵 Machine', () => CupcakeFunctions().buyDialog('Machine')),
              const Spacer(),
              actionButton('💵 User', () => CupcakeFunctions().buyDialog('User')),
              const Spacer(),
              actionButton('🔃 Reset', () => CupcakeFunctions().resetMachine()),
              const Spacer(),
              actionButton('+', () => CupcakeFunctions().addUserFlow()),
              const Spacer(),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(15),
            child: Obx(
              () => Column(mainAxisSize: MainAxisSize.min, children: [
                Image.asset('assets/cupcake.png', width: 100, height: 100),
                const Text('Cupcake ETH',
                    style: TextStyle(color: Colors.black, fontSize: 30, fontWeight: FontWeight.bold)),
                Container(
                    margin: const EdgeInsets.only(top: 40),
                    width: double.infinity,
                    child: Text(
                      'Machine Balance: ${controller.machineBalance.value}',
                      style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.normal),
                      textAlign: TextAlign.left,
                    )),
                Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 20),
                    width: double.infinity,
                    child: Text(
                      'My Economic State: ${CupcakeFunctions().getEconomicState()}',
                      style: const TextStyle(color: Colors.black, fontSize: 18),
                      textAlign: TextAlign.left,
                    )),
                const Divider(
                  color: Colors.black,
                  thickness: 1,
                ),
                Container(
                    margin: const EdgeInsets.only(top: 20, bottom: 15),
                    width: double.infinity,
                    child: const Text(
                      '📡 Marketplace Tracker',
                      style: TextStyle(color: Colors.black, fontSize: 25, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.left,
                    )),
                if (controller.contractLoading.value) ...[
                  const Center(
                    child: CircularProgressIndicator(
                      color: Colors.pinkAccent,
                    ),
                  )
                ] else ...[
                  Expanded(
                    child: ListView.builder(
                        padding: const EdgeInsets.only(bottom: 50),
                        shrinkWrap: true,
                        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                        itemCount: controller.balances.length,
                        itemBuilder: (c, i) {
                          String address = controller.balances.keys.elementAt(i);
                          String cupcakes = controller.balances[address].toString();
                          bool isMe = address == controller.myAddress.value;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                                border: Border.all(color: (isMe) ? Colors.pinkAccent : Colors.black, width: 3),
                                borderRadius: BorderRadius.circular(20)),
                            child: ListTile(
                              title: Text(
                                address,
                                maxLines: 1,
                                style: const TextStyle(
                                  color: Colors.black,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Text(
                                      cupcakes,
                                      style: const TextStyle(
                                          color: Colors.black, fontWeight: FontWeight.bold, fontSize: 17),
                                    ),
                                  ),
                                  Image.asset('assets/cupcake.png', width: 25, height: 25),
                                ],
                              ),
                            ),
                          );
                        }),
                  ),
                ],
              ]),
            ),
          )),
    );
  }

  Widget actionButton(String title, Function action) {
    return ElevatedButton(
      onPressed: () => action(),
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
