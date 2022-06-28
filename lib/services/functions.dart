import 'package:flutter/services.dart';
import 'package:voting_dapp/utils/constants.dart';
import 'package:web3dart/contracts.dart';
import 'package:web3dart/web3dart.dart';

Future<DeployedContract> loadContract() async {
  String abi = await rootBundle.loadString('assets/abi.json');
  String contractAddress = contractAddress1;
  final contract = DeployedContract(ContractAbi.fromJson(abi, 'Election'),
      EthereumAddress.fromHex(contractAddress));
  return contract;
}

Future<String> callFunction(String funcname, List<dynamic> args,
    Web3Client ethClient, String privateKey) async {
  EthPrivateKey credentials = EthPrivateKey.fromHex(privateKey);
  DeployedContract contract = await loadContract();
  final ethFunction = contract.function(funcname);
  final result = await ethClient.sendTransaction(
    credentials,
    Transaction.callContract(
        contract: contract, function: ethFunction, parameters: args),
    chainId: null,
    fetchChainIdFromNetworkId: true,
  );
  return result;
}

Future<String> startElection(String name, Web3Client ethClient) async {
  var response =
      await callFunction('startElection', [name], ethClient, owner_private_key);
  print('Election started successfully');
  return response;
}

Future<String> addCandidate(String name, Web3Client ethClient) async {
  var response =
      await callFunction('addCandidate', [name], ethClient, owner_private_key);
  print('Candidate added successfully');
  return response;
}

Future<String> authoriseVoter(String address, Web3Client ethClient) async {
  var response = await callFunction('authoriseVoter',
      [EthereumAddress.fromHex(address)], ethClient, owner_private_key);
  print('Voter Authorized successfully');
  return response;
}

Future<List> getNumCandidates(Web3Client ethClient) async {
  List<dynamic> response = await ask('getNumCandidates', [], ethClient);
  return response;
}

Future<List> getTotalVotes(Web3Client ethClient) async {
  List<dynamic> response = await ask('getTotalVotes', [], ethClient);
  return response;
}

Future<List> candidateInfo(int index, Web3Client ethClient) async {
  List<dynamic> response =
      await ask('candidateInfo', [BigInt.from(index)], ethClient);
  return response;
}

Future<List<dynamic>> ask(
    String funcName, List<dynamic> args, Web3Client ethClient) async {
  final contract = await loadContract();
  final ethFunction = contract.function(funcName);
  final result = await ethClient.call(
      contract: contract, function: ethFunction, params: args);
  return result;
}

Future<String> vote(int candidateIndex, Web3Client ethClient) async {
  var response = await callFunction(
      'vote', [BigInt.from(candidateIndex)], ethClient, voter_private_key);
  print("Vote counted Successfully");
  return response;
}
