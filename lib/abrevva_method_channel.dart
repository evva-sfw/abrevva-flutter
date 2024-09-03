//import 'dart:html';

import 'package:abrevva/abrevva_param_classes.dart';
import 'package:flutter/services.dart';
import 'dart:async';

import 'abrevva_platform_interface.dart';

/// An implementation of [AbrevvaCryptoPlatform] that uses method channels.
class MethodChannelAbrevvaCrypto extends AbrevvaCryptoPlatform {
  /// The method channel used to interact with the native platform.
  var _methodChannel = const MethodChannel('AbrevvaCrypto');
  set methodChannel(MethodChannel channel) => _methodChannel = channel;

  @override
  Future<Map<dynamic, dynamic>?> random(int numBytes) async {
    return _methodChannel
        .invokeMethod<Map<dynamic, dynamic>?>('random', {'numBytes': numBytes});
  }

  @override
  Future<Map<dynamic, dynamic>?> generateKeyPair() async {
    return _methodChannel
        .invokeMethod<Map<dynamic, dynamic>?>('generateKeyPair');
  }

  @override
  Future<Map<dynamic, dynamic>?> encrypt(
      String key, String iv, String adata, String pt, int tagLength) async {
    final encryptData =
        await _methodChannel.invokeMethod<Map<dynamic, dynamic>?>('encrypt', {
      'key': key,
      'iv': iv,
      'adata': adata,
      'pt': pt,
      'tagLength': tagLength,
    });
    return encryptData;
  }

  @override
  Future<Map<dynamic, dynamic>?> decrypt(
      String key, String iv, String adata, String ct, int tagLength) async {
    return _methodChannel.invokeMethod<Map<dynamic, dynamic>?>('decrypt', {
      'key': key,
      'iv': iv,
      'adata': adata,
      'ct': ct,
      'tagLength': tagLength,
    });
  }

  @override
  Future<Map<dynamic, dynamic>?> encryptFile(
      String sharedSecret, String ptPath, String ctPath) async {
    return _methodChannel.invokeMethod<Map<dynamic, dynamic>?>('encryptFile', {
      'sharedSecret': sharedSecret,
      'ptPath': ptPath,
      'ctPath': ctPath,
    });
  }

  @override
  Future<Map<dynamic, dynamic>?> computeSharedSecret(
      String privateKey, String peerPublicKey) async {
    return _methodChannel
        .invokeMethod<Map<dynamic, dynamic>?>('computeSharedSecret', {
      'privateKey': privateKey,
      'peerPublicKey': peerPublicKey,
    });
  }

  @override
  Future<Map<dynamic, dynamic>?> decryptFile(
      String sharedSecret, String ctPath, String adata, String ptPath) async {
    return _methodChannel.invokeMethod<Map<dynamic, dynamic>?>('decryptFile', {
      'sharedSecret': sharedSecret,
      'ctPath': ctPath,
      'adata': adata,
      'ptPath': ptPath,
    });
  }

  @override
  Future<Map<dynamic, dynamic>?> decryptFileFromURL(
      String sharedSecret, String url, String ptPath) async {
    return _methodChannel
        .invokeMethod<Map<dynamic, dynamic>?>('decryptFileFromURL', {
      'sharedSecret': sharedSecret,
      'url': url,
      'ptPath': ptPath,
    });
  }

  @override
  Future<Map<dynamic, dynamic>?> derive(
      String key, String salt, String info, int length) async {
    return _methodChannel.invokeMethod<Map<dynamic, dynamic>?>('derive', {
      'key': key,
      'salt': salt,
      'info': info,
      'length': length,
    });
  }
}

class MethodChannelAbrevvaNfcPlatform extends AbrevvaNfcPlatform {
  /// The method channel used to interact with the native platform.
  var _methodChannel = const MethodChannel('AbrevvaNfc');
  set methodChannel(MethodChannel channel) => _methodChannel = channel;

  @override
  Future<void> read() async {
    await _methodChannel.invokeMethod<void>('read');
  }

  @override
  Future<Map<dynamic, dynamic>?> connect() async {
    final deriveData =
        await _methodChannel.invokeMethod<Map<dynamic, dynamic>?>('connect');
    return deriveData;
  }

  @override
  Future<Map<dynamic, dynamic>?> disconnect() async {
    final deriveData =
        await _methodChannel.invokeMethod<Map<dynamic, dynamic>?>('disconnect');
    return deriveData;
  }
}

class MethodChannelAbrevvaBlePlatform extends AbrevvaBlePlatform {
  /// The method channel used to interact with the native platform.
  var _methodChannel = const MethodChannel('AbrevvaBle');
  set methodChannel(MethodChannel channel) => _methodChannel = channel;

  var _eventChannel = const EventChannel('AbrevvaBleEvents');
  set eventChannel(EventChannel channel) => _eventChannel = channel;

  @override
  Future<Map<dynamic, dynamic>?> initialize(
      bool androidNeverForLocation) async {
    final ret = _methodChannel.invokeMethod<Map<dynamic, dynamic>?>(
        'initialize', {'androidNeverForLocation': androidNeverForLocation});
    return ret;
  }

  @override
  Future<Map<dynamic, dynamic>?> isEnabled() async {
    final deriveData =
        await _methodChannel.invokeMethod<Map<dynamic, dynamic>?>('isEnabled');
    return deriveData;
  }

  @override
  Future<Map<dynamic, dynamic>?> isLocationEnabled() async {
    final deriveData = await _methodChannel
        .invokeMethod<Map<dynamic, dynamic>?>('isLocationEnabled');
    return deriveData;
  }

  @override
  Future<void> startEnabledNotifications(
      void Function(bool result) callback) async {
    var cancelStream = false;
    var brodcastStream = _eventChannel.receiveBroadcastStream(
        {'callbackName': 'onEnabledChanged'}).listen((event) {
      if (event["status"] != "error") {
        callback(event['value']);
      }
      cancelStream = true;
    });

    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (cancelStream) {
        brodcastStream.cancel();
        timer.cancel();
      }
    });
  }

  @override
  Future<Map<dynamic, dynamic>?> stopEnabledNotifications() async {
    return _methodChannel
        .invokeMethod<Map<dynamic, dynamic>?>('stopEnabledNotifications');
  }

  @override
  Future<Map<dynamic, dynamic>?> openLocationSettings() async {
    return _methodChannel
        .invokeMethod<Map<dynamic, dynamic>?>('openLocationSettings');
  }

  @override
  Future<Map<dynamic, dynamic>?> openBluetoothSettings() async {
    return _methodChannel
        .invokeMethod<Map<dynamic, dynamic>?>('openBluetoothSettings');
  }

  @override
  Future<Map<dynamic, dynamic>?> openAppSettings() async {
    return _methodChannel
        .invokeMethod<Map<dynamic, dynamic>?>('openAppSettings');
  }

  @override
  Future<void> requestLEScan(RequestBleDeviceParams options,
      void Function(ScanResult result) callback) async {
    var optionsMap = options.getMap();

    optionsMap['callbackName'] = 'requestLEScan';
    var cancelStream = false;

    var brodcastStream =
        _eventChannel.receiveBroadcastStream(optionsMap).listen((event) {
      if (event == null) {
        return;
      }
      if (event["status"] != null) {
        cancelStream = true;
        return;
      }

      var bleDeviceMap = event["device"];
      var scanResults = ScanResult(
        device: BleDevice(
          deviceId: bleDeviceMap["deviceId"]!!,
          name: bleDeviceMap["name"],
          uuids: bleDeviceMap["uuids"]?.split(':'),
        ),
        localName: event["localName"],
        rssi: event["rssi"],
        txPower: event["txPower"],
        manufacturerData: event["manufacturerData"]?.cast<String, String>(),
        uuids: event["uuids"]?.split(':'),
        rawAdvertisement: event["rawAdvertisement"],
      );
      callback(scanResults);
    });

    var timeout = Duration(milliseconds: options.timeout ?? 10000);
    Timer(timeout, () => brodcastStream.cancel());

    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (cancelStream) {
        brodcastStream.cancel();
        timer.cancel();
      }
    });
  }

  @override
  Future<String?> stopLEScan() async {
    return _methodChannel.invokeMethod<String?>('stopLEScan');
  }

  @override
  Future<Map<dynamic, dynamic>?> connect(String deviceId, int timeout) async {
    return _methodChannel.invokeMethod<Map<dynamic, dynamic>?>('connect', {
      'deviceId': deviceId,
      'timeout': timeout,
    });
  }

  @override
  Future<Map<dynamic, dynamic>?> disconnect(String deviceId) async {
    return _methodChannel.invokeMethod<Map<dynamic, dynamic>?>('disconnect', {
      'deviceId': deviceId,
    });
  }

  @override
  Future<Map<dynamic, dynamic>?> read(String deviceId, String service,
      String characteristic, int timeout) async {
    return _methodChannel.invokeMethod<Map<dynamic, dynamic>?>('read', {
      'deviceId': deviceId,
      'service': service,
      'characteristic': characteristic,
      'timeout': timeout,
    });
  }

  @override
  Future<Map<dynamic, dynamic>?> write(String deviceId, String service,
      String characteristic, String value, int timeout) async {
    return _methodChannel.invokeMethod<Map<dynamic, dynamic>?>('write', {
      'deviceId': deviceId,
      'service': service,
      'characteristic': characteristic,
      'value': value,
      'timeout': timeout,
    });
  }

  @override
  Future<Map<dynamic, dynamic>?> disengage(
      String mobileId,
      String mobileDeviceKey,
      String mobileGroupId,
      String mobileAccessData,
      bool isPermanentRelease) async {
    return _methodChannel.invokeMethod<Map<dynamic, dynamic>?>('disengage', {
      'mobileId': mobileId,
      'mobileDeviceKey': mobileDeviceKey,
      'mobileGroupId': mobileGroupId,
      'mobileAccessData': mobileAccessData,
      'isPermanentRelease': isPermanentRelease,
    });
  }

  @override
  Future<void> startNotifications(StartNotificationsParams options,
      void Function(ReadResult result) callback) async {
    var optionsMap = options.getMap();
    optionsMap['callbackName'] = 'startNotifications';

    bool cancelStream = false;

    var brodcastStream =
        _eventChannel.receiveBroadcastStream(optionsMap).listen((event) {
      if (event == null || event["status"] == "success") {
        return;
      }
      if (event["status"] == "error") {
        cancelStream = true;
        return;
      }
      callback(event['value']);
      cancelStream = true;
    });

    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (cancelStream) {
        brodcastStream.cancel();
        timer.cancel();
      }
    });
  }

  @override
  Future<Map<dynamic, dynamic>?> stopNotifications(String deviceId,
      String service, String characteristic, int timeout) async {
    final deriveData = await _methodChannel
        .invokeMethod<Map<dynamic, dynamic>?>('stopNotifications', {
      'deviceId': deviceId,
      'service': service,
      'characteristic': characteristic,
      'timeout': timeout,
    });
    return deriveData;
  }

  @override
  Future<Map<dynamic, dynamic>?> signalize(String deviceId) async {
    final deriveData = await _methodChannel
        .invokeMethod<Map<dynamic, dynamic>?>(
            'signalize', {'deviceId': deviceId});
    return deriveData;
  }
}
