import 'package:flutter/material.dart';
import 'package:voting_dapp/services/functions.dart';
import 'package:web3dart/web3dart.dart';

class ElectionInfo extends StatefulWidget {
  final Web3Client ethClient;
  final String electionName;

  const ElectionInfo({
    Key? key,
    required this.ethClient,
    required this.electionName,
  }) : super(key: key);

  @override
  State<ElectionInfo> createState() => _ElectionInfoState();
}

class _ElectionInfoState extends State<ElectionInfo> {
  TextEditingController addCandidateController = TextEditingController();
  TextEditingController authorizeVoterController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(widget.electionName),
      ),
      body: Container(
        padding: EdgeInsets.all(14),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      FutureBuilder<List>(
                          future: getNumCandidates(widget.ethClient),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            return Text(
                              snapshot.data![0].toString(),
                              style: TextStyle(
                                fontSize: 50,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }),
                      Text(
                        'Total Candidates',
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      FutureBuilder<List>(
                          future: getTotalVotes(widget.ethClient),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            return Text(
                              snapshot.data![0].toString(),
                              style: TextStyle(
                                fontSize: 50,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }),
                      Text(
                        'Total votes',
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: addCandidateController,
                      decoration: InputDecoration(
                        hintText: 'Enter Candidate Name',
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      addCandidate(addCandidateController.text, widget.ethClient);
                      addCandidateController.text = '';
                    },
                    child: Text('Add Candidate'),
                  )
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: authorizeVoterController,
                      decoration: InputDecoration(
                        hintText: 'Enter Voter Address',
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      authoriseVoter(
                          authorizeVoterController.text, widget.ethClient);
                      authorizeVoterController.text = '';
                    },
                    child: Text('Authorize Voter'),
                  )
                ],
              ),
              Divider(),
              FutureBuilder<List>(
                future: getNumCandidates(widget.ethClient),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    return Column(
                      children: [
                        for (int i = 0; i < snapshot.data![0].toInt(); i++)
                          FutureBuilder<List>(
                            future: candidateInfo(i, widget.ethClient),
                            builder: (context, candidateSnapshot) {
                              if (candidateSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              } else {
                                return ListTile(
                                  title: Text('Name: ' +
                                      candidateSnapshot.data![0][0].toString()),
                                  subtitle: Text('Votes: ' +
                                      candidateSnapshot.data![0][1].toString()),
                                  trailing: ElevatedButton(
                                    onPressed: () {
                                      vote(i, widget.ethClient);
                                    },
                                    child: Text('Vote'),
                                  ),
                                );
                              }
                            },
                          )
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
