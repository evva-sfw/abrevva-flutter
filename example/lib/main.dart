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

  void connectToDevice(ScanResult result) async {
    await _ble.stopLEScan();

    await _ble.connect(result.device.deviceId, 10000);

    _ble.disengage('mobileId', 'derivedKey', 'groupId', 'accessData', true);
  }

  List<ScanResult> scanResultList = [];

  Future<void> _scanForDevices() async {
    scanResultList.clear();
    return await _ble.requestLEScan(RequestBleDeviceParams(timeout: 5000),
        (result) {
      if (result.manufacturerData != null &&
          result.manufacturerData!.containsKey("2153")) {
        setState(() {
          scanResultList.add(result);
        });
      }
    });
  }

  @override
  dispose() async {
    _ble.stopLEScan();
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
                  _ble.stopLEScan();
                  connectToDevice(result);
                },
                title: Text(result.device.deviceId),
                subtitle: Text(result.device.name ?? ""),
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
                          value = 'random(6) => ${result?['value']}';
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
                                    'generateKeyPair(6) =>\nPrivateKey: ${result?['privateKey']}\nPublicKey: ${result?['publicKey']}';
                              }));
                    },
                    child: const Text('createKeyPair()'))
              ],
            )));
  }
}
