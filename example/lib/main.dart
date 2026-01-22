import 'package:abrevva/abrevva_param_classes.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:abrevva/abrevva.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomeWidget(),
    );
  }
}

class HomeWidget extends StatelessWidget {
  const HomeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Home'),
        ),
        body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Center(
                heightFactor: 1.5,
                child: ElevatedButton(
                  child: const Text('Ble'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const BleWidget()),
                    );
                  },
                ),
              ),
              Center(
                heightFactor: 1.5,
                child: ElevatedButton(
                  child: const Text('Crypto'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CryptoWidget()),
                    );
                  },
                ),
              ),
              Center(
                heightFactor: 1.5,
                child: ElevatedButton(
                  child: const Text('CodingStation'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CodingStationWidget()),
                    );
                  },
                ),
              )
            ]));
  }
}

class BleWidget extends StatefulWidget {
  const BleWidget({super.key});

  @override
  State<BleWidget> createState() => _BleState();
}

class _BleState extends State<BleWidget> {
  @override
  void initState() {
    super.initState();
    try {
      AbrevvaBle.initialize(false);
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  List<BleDevice> scanResultList = [];

  Future<void> _scanForDevices() async {
    scanResultList.clear();
    return await AbrevvaBle.startScan( onScanResult: (device) {
      setState(() {
              scanResultList.add(device);
      });
    });
  }

  @override
  dispose() async {
    AbrevvaBle.stopScan();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ble test (scroll down to scan)'),
      ),
      body: RefreshIndicator(
        onRefresh: _scanForDevices,
        child: ListView.builder(
            itemCount: scanResultList.length,
            itemBuilder: (context, index) {
              final result = scanResultList[index];
              return ListTile(
                onTap: () async {
                  AbrevvaBle.stopScan();
                  final result = await AbrevvaBle.disengageWithXvnResponse(
                      'deviceId',
                      'mobileId',
                      'mobileDeviceKey',
                      'mobileGroupId',
                      'mobileAccessData',
                      true
                  );
                  if (kDebugMode) {
                    print("status=${result.status} xvnData=${result.xvnData}");
                  }
                },
                title: Text("${result.advertisementData?.manufacturerData?.identifier}", style: const TextStyle(color: Colors.blueAccent)),
                subtitle: Text('${result.advertisementData?.manufacturerData?.companyIdentifier}'),
              );
            }),
      ),
    );
  }
}

class CryptoWidget extends StatefulWidget {
  const CryptoWidget({super.key});

  @override
  State<CryptoWidget> createState() => _CryptoState();
}

class _CryptoState extends State<CryptoWidget> {
  String value = 'Output';
  String privateKey = '';
  String publicKey = '';
  String signature = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Crypto test'),
        ),
        body: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                Padding(
                    padding: const EdgeInsets.all(50.0),
                    child: Text(
                      value,
                    )),
                ElevatedButton(
                    onPressed: () {
                      AbrevvaCrypto.random(6).then((result) {
                        setState(() {
                          value = 'random(6) => ${result.value}';
                        });
                      });
                    },
                    child: const Text('random()')),
                ElevatedButton(
                    onPressed: () {
                      AbrevvaCrypto
                          .generateKeyPair()
                          .then((result) => setState(() {
                                privateKey = result.privateKey;
                                publicKey = result.publicKey;
                                value =
                                    'generateKeyPair() =>\nprivateKey: ${result.privateKey}\npublicKey: ${result.publicKey}';
                              }));
                    },
                    child: const Text('createKeyPair()')),
                ElevatedButton(
                    onPressed: () {
                      AbrevvaCrypto
                          .computeED25519PublicKey(privateKey)
                          .then((result) => setState(() {
                        publicKey = result.publicKey;
                        value =
                        'computeED25519PublicKey() =>\npublicKey: ${result.publicKey}';
                      }));
                    },
                    child: const Text('computeED25519PublicKey()')),
                ElevatedButton(
                    onPressed: () {
                      AbrevvaCrypto
                          .sign(privateKey, '12345')
                          .then((result) => setState(() {
                        signature = result.signature;
                        value =
                        'sign() =>\nsignature: ${result.signature}';
                      })).catchError((err) => setState(() {
                        if (kDebugMode) { print(err); }
                      }));
                    },
                    child: const Text('sign()')),
                ElevatedButton(
                    onPressed: () {
                      AbrevvaCrypto
                          .verify(publicKey, '12345', signature).then((_) => setState(() {
                        value = 'verify() =>\nvalid';
                      })).catchError((err) => setState(() {
                        if (kDebugMode) { print(err); }
                        value = 'verify() =>\ninvalid';
                      }));
                    },
                    child: const Text('verify()'))
              ],
            )));
  }
}

class CodingStationWidget extends StatefulWidget {
  const CodingStationWidget({super.key});

  @override
  State<CodingStationWidget> createState() => _CodingStationState();
}

class _CodingStationState extends State<CodingStationWidget> {
  String url = "";
  String clientId = "";
  String username = "";
  String password = "";

  String value = 'Output';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('CodingStation test'),
        ),
        body: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                Padding(
                    padding: const EdgeInsets.all(50.0),
                    child: Text(
                      value,
                    )),
                ElevatedButton(
                    onPressed: () async {
                      try {
                        await AbrevvaCodingStation.register(url,clientId,username,password);
                        setState(() {
                          value = 'register(): success';
                          }
                        );
                      } catch (e) {
                        setState(() {
                          value = 'register(): $e';
                          }
                        );
                      }
                    },
                    child: const Text('register()')
                    ),
                ElevatedButton(
                    onPressed: () async {
                      try {
                        await AbrevvaCodingStation.connect();
                        setState(() {
                          value = 'connect(): success';
                          }
                        );
                      } catch (e) {
                        setState(() {
                          value = 'connect(): $e';
                          }
                        );
                      }
                    },
                    child: const Text('connect()')
                    ),
                ElevatedButton(
                    onPressed: () async {
                      try {
                        await AbrevvaCodingStation.write();
                        setState(() {
                          value = 'write(): success';
                          }
                        );
                      } catch (e) {
                        setState(() {
                          value = 'write(): $e';
                          }
                        );
                      }
                    },
                    child: const Text('write()')
                    ),
                ElevatedButton(
                    onPressed: () async {
                        await AbrevvaCodingStation.disconnect();
                        setState(() {
                          value = 'disconnect(): success';
                          }
                        );
                    },
                    child: const Text('disconnect()')
                    ),
              ],
            )));
  }
}
