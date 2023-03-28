import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web_socket_channel/io.dart';

class ContractLinker extends GetxController {
  final String _rpcUrl = "http://127.0.0.1:7545";
  final String _wsUrl = "ws://10.0.2.2:7545/";
  final String _privateKey = "0x1d7b7ded689291a5e0ad27c2be3bcee534dde5fefb783f44877a3b645b628be5";

  @override
  void onInit() async {
    await contractLinking();
    super.onInit();
  }

  //my vars
  final contractLoading = true.obs;
  final economicState = ''.obs;
  final balanceCount = 0.obs;
  final machineBalance = 0.obs;
  final balances = {}.obs;

  //contract vars
  late Web3Client _client;
  late String _abiCode;
  late EthereumAddress _contractAddress;
  late Credentials _credentials;
  late DeployedContract _contract;

  //functions
  late ContractFunction _addPerson;
  late ContractFunction _buyFromMachine;
  late ContractFunction _buyFromUser;
  late ContractFunction _myEconomicState;
  late ContractFunction _balances;
  late ContractFunction _balanceCount;
  late ContractFunction _machineBalance;

  contractLinking() async {
    await initialSetup();
  }

  initialSetup() async {
    // establish a connection to the ethereum rpc node. The socketConnector
    // property allows more efficient event streams over websocket instead of
    // http-polls. However, the socketConnector property is experimental.
    _client = Web3Client(_rpcUrl, Client(), socketConnector: () {
      return IOWebSocketChannel.connect(_wsUrl).cast<String>();
    });

    await getAbi();
    await getCredentials();
    await getDeployedContract();
  }

  Future<void> getAbi() async {
    // Reading the contract abi
    String abiStringFile = await rootBundle.loadString("src/artifacts/VendingMachine.json");
    var jsonAbi = jsonDecode(abiStringFile);
    _abiCode = jsonEncode(jsonAbi["abi"]);

    _contractAddress = EthereumAddress.fromHex(jsonAbi["networks"]["5777"]["address"]);
  }

  Future<void> getCredentials() async {
    _credentials = await _client.credentialsFromPrivateKey(_privateKey);
  }

  Future<void> getDeployedContract() async {
    // Telling Web3dart where our contract is declared.
    _contract = DeployedContract(ContractAbi.fromJson(_abiCode, "VendingMachine"), _contractAddress);

    // Extracting the functions, declared in contract.
    _addPerson = _contract.function("addPerson");
    _buyFromMachine = _contract.function("buyFromMachine");
    _buyFromUser = _contract.function("buyFromUser");
    _myEconomicState = _contract.function("myEconomicState");
    _balances = _contract.function("balances");
    _balanceCount = _contract.function("balance_count");
    _machineBalance = _contract.function("machine_balance");

    await addMe();
    await setEconomicState();
    await getBalances();

    contractLoading.value = false;
  }

  addMe() async {
    await _client.sendTransaction(_credentials,
        Transaction.callContract(contract: _contract, function: _addPerson, parameters: [_credentials.address]));
  }

  setEconomicState() async {
    String es = await _client.sendTransaction(
        _credentials, Transaction.callContract(contract: _contract, function: _myEconomicState, parameters: []));
    economicState.value = es;
  }

  getBalances() async {
    print('getting balances');

    //get machine balance
    List machineBalanceList = await _client.call(contract: _contract, function: _balanceCount, params: []);
    BigInt machineBalanceBigInt = machineBalanceList[0];
    machineBalance.value = machineBalanceBigInt.toInt();

    //get balance count
    List balanceCountList = await _client.call(contract: _contract, function: _balanceCount, params: []);
    BigInt balanceCountBigInt = balanceCountList[0];
    balanceCount.value = balanceCountBigInt.toInt();

    //get all user balances and store them in a map
    for (var i = 0; i < balanceCount.value; i++) {
      List temp = await _client.call(contract: _contract, function: _balances, params: []);
      balances[temp[i][0]] = temp[i][1];
    }

    contractLoading.value = false;
  }
}
