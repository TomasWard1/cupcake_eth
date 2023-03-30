import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web_socket_channel/io.dart';

class ContractLinker extends GetxController {
  final String _rpcUrl = "http://10.0.2.2:7545";
  final String _wsUrl = "ws://10.0.2.2:7545/";
  final String _privateKey = "0x7532cA092dFbda1752852b9feB936983128EDBe3";

  @override
  void onInit() async {
    await contractLinking();
    super.onInit();
  }

  //my vars
  final contractLoading = true.obs;
  final balanceCount = 0.obs;
  final machineBalance = 0.obs;
  RxString myAddress = ''.obs;
  RxMap<String, int> balances = RxMap<String, int>({});
  RxList<String> activeAddress = RxList<String>([]);
  TextEditingController ethAddressController = TextEditingController();
  TextEditingController cupcakeAmountController = TextEditingController();

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
  late ContractFunction _balances;
  late ContractFunction _balanceCount;
  late ContractFunction _machineBalance;
  late ContractFunction _activeAddresses;
  late ContractFunction _reset;

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
    _credentials = EthPrivateKey.fromHex(_privateKey);
    myAddress.value = _credentials.address.hex;
  }

  Future<void> getDeployedContract() async {
    // Telling Web3dart where our contract is declared.
    _contract = DeployedContract(ContractAbi.fromJson(_abiCode, "VendingMachine"), _contractAddress);

    // Extracting the functions, declared in contract.
    _addPerson = _contract.function("addPerson");
    _buyFromMachine = _contract.function("buyFromMachine");
    _buyFromUser = _contract.function("buyFromUser");
    _balances = _contract.function("balances");
    _balanceCount = _contract.function("balance_count");
    _machineBalance = _contract.function("machine_balance");
    _activeAddresses = _contract.function("activeAddresses");
    _reset = _contract.function("resetMachine");

    await refreshMachineBalance();
    await refreshActiveAddresses();

    //agregar al que esta llamando al contrato a la lista de participantes del mercado
    String myAddress = _credentials.address.hex;
    if (!activeAddress.contains(myAddress)) {
      await addMe();
    }
    setLoading(false);
  }

  addMe() async {
    BigInt cId = await _client.getChainId();
    await _client.sendTransaction(_credentials,
        Transaction.callContract(contract: _contract, function: _addPerson, parameters: [_credentials.address]),
        chainId: cId.toInt());

    await refreshActiveAddresses();
  }

  addUser(String address) async {
    EthereumAddress ad = EthereumAddress.fromHex(address);
    BigInt cId = await _client.getChainId();
    await _client.sendTransaction(
        _credentials, Transaction.callContract(contract: _contract, function: _addPerson, parameters: [ad]),
        chainId: cId.toInt());

    await refreshActiveAddresses();
  }

  refreshBalanceCount() async {
    //get balance count
    List balanceCountList = await _client.call(contract: _contract, function: _balanceCount, params: []);
    BigInt balanceCountBigInt = balanceCountList[0];
    balanceCount.value = balanceCountBigInt.toInt();
  }

  refreshMachineBalance() async {
    //get machine balance
    List machineBalanceList = await _client.call(contract: _contract, function: _machineBalance, params: []);
    BigInt machineBalanceBigInt = machineBalanceList[0];
    machineBalance.value = machineBalanceBigInt.toInt();
  }

  refreshActiveAddresses() async {
    await refreshBalanceCount();

    for (var i = 0; i < balanceCount.value; i++) {
      List temp = await _client.call(contract: _contract, function: _activeAddresses, params: [BigInt.from(i)]);
      EthereumAddress ad = temp[0];
      activeAddress.add(ad.hex);
      activeAddress.refresh();
    }

    await refreshActiveBalances();
  }

  refreshActiveBalances() async {
    for (var i = 0; i < activeAddress.length; i++) {
      List temp = await _client
          .call(contract: _contract, function: _balances, params: [EthereumAddress.fromHex(activeAddress[i])]);
      balances[activeAddress[i]] = (temp[0] as BigInt).toInt();
    }
  }

  buyFromMachine(int amount) async {
    BigInt cId = await _client.getChainId();
    await _client.sendTransaction(
        _credentials,
        Transaction.callContract(
            contract: _contract, function: _buyFromMachine, parameters: [BigInt.parse(amount.toString())]),
        chainId: cId.toInt());

    await refreshMachineBalance();
    await refreshActiveBalances();
  }

  buyFromUser(int amount, String address) async {
    BigInt cId = await _client.getChainId();
    await _client.sendTransaction(
        _credentials,
        Transaction.callContract(
            contract: _contract,
            function: _buyFromUser,
            parameters: [EthereumAddress.fromHex(address), BigInt.parse(amount.toString())]),
        chainId: cId.toInt());

    await refreshMachineBalance();
    await refreshActiveBalances();
  }

  String bytesToString(Uint8List bytes) {
    return String.fromCharCodes(bytes);
  }

  resetMachine() async {
    setLoading(true);

    BigInt cId = await _client.getChainId();
    await _client.sendTransaction(
        _credentials, Transaction.callContract(contract: _contract, function: _reset, parameters: []),
        chainId: cId.toInt());

    setLoading(false);
  }

  setLoading(bool l) {
    contractLoading.value = l;
  }
}
