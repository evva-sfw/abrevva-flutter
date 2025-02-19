import 'package:abrevva/abrevva_param_classes.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
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
              )
            ]));
  }
}

var methodEvent = const EventChannel('AbrevvaBleEvent');

class BleWidget extends StatefulWidget {
  const BleWidget({super.key});

  @override
  State<BleWidget> createState() => _BleState();
}

class _BleState extends State<BleWidget> {
  final _ble = AbrevvaBle();

  @override
  void initState() {
    super.initState();
    try {
      _ble.initialize(false);
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  void disengage(String mobileId) async {
    await _ble.stopScan();
    await _ble.disengage('mobileId', 'derivedKey', 'groupId', 'accessData', true);
  }

  List<BleDevice> scanResultList = [];

  Future<void> _scanForDevices() async {
    scanResultList.clear();
    return await _ble.startScan( onScanResult: (device) {
      scanResultList.add(device);
    });
  }

  @override
  dispose() async {
    _ble.stopScan();
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
                onTap: () {
                  _ble.stopScan();
                  disengage(result.deviceId);
                },
                title: Text(result.deviceId),
                subtitle: Text('${result.advertisementData?.companyIdentifier}'),
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
  final _abrevvaCrypto = AbrevvaCrypto();

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
                      _abrevvaCrypto.random(6).then((result) {
                        setState(() {
                          value = 'random(6) => ${result.value}';
                        });
                      });
                    },
                    child: const Text('random()')),
                ElevatedButton(
                    onPressed: () {
                      _abrevvaCrypto
                          .generateKeyPair()
                          .then((result) => setState(() {
                                value =
                                    'generateKeyPair(6) =>\nPrivateKey: ${result.privateKey}\nPublicKey: ${result.publicKey}';
                              }));
                    },
                    child: const Text('createKeyPair()'))
              ],
            )));
  }
}
