//import 'dart:html';

import 'dart:ffi';
import 'dart:io';

import 'package:abrevva/abrevva_param_classes.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';

import 'abrevva_platform_interface.dart';

/// An implementation of [MethodChannelCodingStation] that uses method channels.
class MethodChannelCodingStation extends AbrevvaCodingStationPlatform {
  /// The method channel used to interact with the native platform.
  var _methodChannel = const MethodChannel('AbrevvaCodingStation');
  set methodChannel(MethodChannel channel) => _methodChannel = channel;

  @override
  Future<void> registerMqttConfigForXS(String url, String clientId, String username, String password) async {
    Map<String, String> map = {
          'url': url,
          'clientId': clientId,
          'username': username,
          'password': password,
          };
    await _methodChannel
        .invokeMethod<void>('registerMqttConfigForXS',map );
  }

  @override
  Future<void> connect() async {
    await _methodChannel
            .invokeMethod<void>('connect');
  }

  @override
  Future<void> write() async {
    await _methodChannel
            .invokeMethod<void>('write');
  }

  @override
  Future<void> disconnect() async {
    await _methodChannel
            .invokeMethod<void>('disconnect');
  }
}

/// An implementation of [AbrevvaCryptoPlatform] that uses method channels.
class MethodChannelAbrevvaCrypto extends AbrevvaCryptoPlatform {
  /// The method channel used to interact with the native platform.
  var _methodChannel = const MethodChannel('AbrevvaCrypto');
  set methodChannel(MethodChannel channel) => _methodChannel = channel;

  @override
  Future<StringResult> random(int numBytes) async {
    final result =  await _methodChannel
        .invokeMethod<Map<dynamic, dynamic>>('random', {'numBytes': numBytes});
    if (result == null || result["value"] == null) {
      throw PlatformException(code: "random(): Error retrieving StringResult");
    }
    return StringResult(result["value"]);
  }

  @override
  Future<KeyPairResult> generateKeyPair() async {
    final result = await _methodChannel
        .invokeMethod<Map<dynamic, dynamic>>('generateKeyPair');
    if (result == null 
      || result["privateKey"] == null
      || result["publicKey"] == null
      ) {
      throw PlatformException(code: "generateKeyPair(): Error retrieving KeyPairResult");
    }
    return KeyPairResult(result["privateKey"], result["publicKey"]);
  }

  @override
  Future<EncryptResult> encrypt(
      String key, String iv, String adata, String pt, int tagLength) async {
    final result =
        await _methodChannel.invokeMethod<Map<dynamic, dynamic>>('encrypt', {
      'key': key,
      'iv': iv,
      'adata': adata,
      'pt': pt,
      'tagLength': tagLength,
    });
    if (result == null 
      || result["cipherText"] == null
      || result["authTag"] == null
      ) {
      throw PlatformException(code: "encrypt(): Error retrieving EncryptResult");
    }
    return EncryptResult(result["cipherText"], result["authTag"]);
  }

  @override
  Future<DecryptResult> decrypt(
      String key, String iv, String adata, String ct, int tagLength) async {
    final result = await _methodChannel.invokeMethod<Map<dynamic, dynamic>?>('decrypt', {
      'key': key,
      'iv': iv,
      'adata': adata,
      'ct': ct,
      'tagLength': tagLength,
    });
    if (result == null 
      || result["plainText"] == null
      || result["authOk"] == null
      ) {
      throw PlatformException(code: "decrypt(): Error retrieving DecryptResult");
    }
    return DecryptResult(result["plainText"], result["authOk"]);
  }

  @override
  Future<bool> encryptFile(
      String sharedSecret, String ptPath, String ctPath) async {
    final result = await _methodChannel.invokeMethod<Map<dynamic, dynamic>>('encryptFile', {
      'sharedSecret': sharedSecret,
      'ptPath': ptPath,
      'ctPath': ctPath,
    });
    if (result == null 
      || result["opOk"] == null
      ) {
      throw PlatformException(code: "encryptFile(): Error retrieving opOk");
    }
    return result["opOk"];
  }

  @override
  Future<StringResult> computeSharedSecret(
      String privateKey, String peerPublicKey) async {
    final result = await  _methodChannel
        .invokeMethod<Map<dynamic, dynamic>?>('computeSharedSecret', {
      'privateKey': privateKey,
      'peerPublicKey': peerPublicKey,
    });
    if ( result == null 
      || result["sharedSecret"] == null
      ) {
      throw PlatformException(code: "computeSharedSecret(): Error retrieving sharedSecret");
      }
      return StringResult(result["sharedSecret"]);
  }

  @override
  Future<bool> decryptFile(
      String sharedSecret, String ctPath, String ptPath) async {
    final result = await _methodChannel.invokeMethod<Map<dynamic, dynamic>>('decryptFile', {
      'sharedSecret': sharedSecret,
      'ctPath': ctPath,
      'ptPath': ptPath,
    });
    if (result == null 
      || result["opOk"] == null
      ) {
      throw PlatformException(code: "decryptFile(): Error retrieving opOk");
    }
    return result["opOk"];
  }

  @override
  Future<bool> decryptFileFromURL(
      String sharedSecret, String url, String ptPath) async {
    final result = await  _methodChannel
        .invokeMethod<Map<dynamic, dynamic>>('decryptFileFromURL', {
      'sharedSecret': sharedSecret,
      'url': url,
      'ptPath': ptPath,
    });
    if (result == null 
      || result["opOk"] == null
      ) {
      throw PlatformException(code: "decryptFile(): Error retrieving opOk");
    }
    return result["opOk"];
  }

  @override
  Future<StringResult> derive(
      String key, String salt, String info, int length) async {
    final result = await _methodChannel.invokeMethod<Map<dynamic, dynamic>>('derive', {
      'key': key,
      'salt': salt,
      'info': info,
      'length': length,
    });
    if (result == null 
      || result["value"] == null
      ) {
      throw PlatformException(code: "decryptFile(): Error retrieving value");
    }
    return StringResult(result["value"]);
  }
}

class MethodChannelAbrevvaBlePlatform extends AbrevvaBlePlatform {
  /// The method channel used to interact with the native platform.
  var _methodChannel = const MethodChannel('AbrevvaBle');
  set methodChannel(MethodChannel channel) => _methodChannel = channel;

  final _notificationStreams = <String, dynamic>{};
  final _connectStreams = <String, dynamic>{};
  dynamic _enabledNotificationStream;

  /// Setter are neccessary for testing
  var _connectEventChannel = const EventChannel('connectEventChannel');
  set connectEventChannel(EventChannel channel) => _connectEventChannel = channel;

  var _startScanEventChannel = const EventChannel('startScanEventChannel');
  set startScanEventChannel(EventChannel channel) => _startScanEventChannel = channel;

  var _startNotificationsEventChannel = const EventChannel('startNotificationsEventChannel');
  set startNotificationsEventChannel(EventChannel channel) => _startNotificationsEventChannel = channel;

  var _startEnabledNotificationsEventChannel = const EventChannel('startEnabledNotificationsEventChannel');
  set startEnabledNotificationsEventChannel(EventChannel channel) => _startEnabledNotificationsEventChannel = channel;

  @override
  Future<void> initialize(
      bool androidNeverForLocation) async {
        if (Platform.isAndroid) {
          List<Permission> permissions = [];
          final eval = await _methodChannel.invokeMethod<bool?>('evaluateSdkVersion') ?? false;
          if (eval) {
            permissions.add(Permission.bluetoothScan);
            permissions.add(Permission.bluetoothConnect);
          } else {
            permissions.add(Permission.bluetooth);
          }

          if (androidNeverForLocation){
            permissions.add(Permission.location);
          }
          
          await permissions.request();
          return; 
          } else {
            return await _methodChannel.invokeMethod<void>(
              'initialize', {'androidNeverForLocation': androidNeverForLocation});
          }
      }

  @override
  Future<bool> isEnabled() async {
    return await _methodChannel
      .invokeMethod<bool?>('isEnabled') ?? false;
  }

  @override
  Future<bool> isLocationEnabled() async {
    return await _methodChannel
      .invokeMethod<bool?>('isLocationEnabled') ?? false;
  }

  @override
  Future<void> startEnabledNotifications(
      void Function(bool result) callback) async {
      _enabledNotificationStream =_startEnabledNotificationsEventChannel.receiveBroadcastStream().listen((event) {
      if ( event == null 
        || event["value"] == null) {
        throw PlatformException(code: "startEnabledNotifications(): Error retrieving value");
      }
      callback(event['value']);
    });
    return await _methodChannel.invokeMethod<void>('startEnabledNotifications');
  }

  @override
  Future<void> stopEnabledNotifications() async {
    _enabledNotificationStream?.cancel();
    return await _methodChannel
        .invokeMethod<void>('stopEnabledNotifications');
  }

  @override
  Future<void> openLocationSettings() async {
    return await _methodChannel
        .invokeMethod<void>('openLocationSettings');
  }

  @override
  Future<void> openBluetoothSettings() async {
    return await _methodChannel
        .invokeMethod<void>('openBluetoothSettings');
  }

  @override
  Future<void> openAppSettings() async {
    return await _methodChannel
        .invokeMethod<void>('openAppSettings');
  }

  BatteryStatus _getBatteryStatusHelper(String? status)  {
    if (status == null){
      return BatteryStatus.unknown;
    }
    else if (status == 'battery-full') {
      return BatteryStatus.batteryFull;
    }
    else {
      return BatteryStatus.batteryEmpty;
    }
  }

  ComponentType _getComponentType(String? type){
    return type == null ? ComponentType.unknown : ComponentType.values.byName(type);
  }

  BleDevice _mapScanResult(Map<Object?, Object?> data) {
      Map<Object?, Object?> advertismentData = data["advertisementData"] as Map<Object?, Object?> ;
      Map<Object?, Object?> mfData = advertismentData["manufacturerData"] as Map<Object?, Object?> ;
      final mf = BleDeviceManufacturerData(
        companyIdentifier: mfData["companyIdentifier"] as int?,
        version: mfData["version"] as int?,
        componentType: _getComponentType(mfData["componentType"] as String?),
        mainFirmwareVersionMajor: mfData["mainFirmwareVersionMajor"] as int?,
        mainFirmwareVersionMinor:  mfData["mainFirmwareVersionMinor"] as int?,
        mainFirmwareVersionPatch:  mfData["mainFirmwareVersionPatch"] as int?,
        componentHAL:  mfData["componentHAL"] as int?,
        batteryStatus:  _getBatteryStatusHelper(mfData["batteryStatus"] as String?),
        mainConstructionMode:  mfData["mainConstructionMode"] as bool?,
        subConstructionMode:  mfData["subConstructionMode"] as bool?,
        isOnline:  mfData["isOnline"] as bool?,
        officeModeEnabled:  mfData["officeModeEnabled"] as bool?,
        twoFactorRequired:  mfData["twoFactorRequired"] as bool?,
        officeModeActive:  mfData["officeModeActive"] as bool?,
        identifier:  mfData["identifier"] as String?,
        subFirmwareVersionMajor:  mfData["subFirmwareVersionMajor"] as int?,
        subFirmwareVersionMinor:  mfData["subFirmwareVersionMinor"] as int?,
        subFirmwareVersionPatch:  mfData["subFirmwareVersionPatch"] as int?,
        subComponentIdentifier:  mfData["subComponentIdentifier"] as String?,
        );
     return BleDevice(
          deviceId:  data["deviceId"] as String,
          name: data["name"] as String?,
          advertisementData: BleDeviceAdvertisementData(
            rssi: advertismentData["rssi"] as int?,
            rawData: data["raw"] as Map<Object?, Object?>?,
            isConnectable: advertismentData["isConnectable"] as bool?,
            manufacturerData: mf
          )
          );
  }

  @override
  Future<void> startScan({
      required void Function(BleDevice result) onScanResult,
      void Function(bool success)? onScanStart,
      void Function(bool success)? onScanStop,
      String? macFilter,
      bool? allowDuplicates,
      int? timeout,
    }) async {
    dynamic brodcastStream;

    brodcastStream =
        _startScanEventChannel.receiveBroadcastStream().listen((result) {
          switch (result["event"]) {
            case "onScanResult":
              onScanResult(_mapScanResult(result["value"]));
              break;
            case "onScanStart":
              onScanStart?.call(result["value"] as bool);
              break;
            case "onScanStop":
                  brodcastStream.cancel();
                onScanStop?.call(result["value"] as bool);
              break;
            default:
              return;
          }
    });

    return await _methodChannel.invokeMethod<void>('startScan', {
      'macFilter': macFilter,
      'allowDuplicates': allowDuplicates,
      'timeout': timeout
    });
  }

  @override
  Future<String?> stopScan() async {
    return _methodChannel.invokeMethod<String?>('stopScan');
  }

  @override
  Future<bool> connect(
    String deviceId,
    int timeout,
    void Function(String address)? onDisconnect,
    ) async {

      if (onDisconnect != null) {
        _connectStreams[deviceId] =
          _connectEventChannel.receiveBroadcastStream().listen((result) {
          if (result["value"] == null) {
            throw PlatformException(code: "connect(): Error retrieving value");
          }
          final addr = result["value"] as String;
          _connectStreams[addr]?.cancel();
          _connectStreams.remove(addr);
          onDisconnect.call(addr);
        });
      }

      final result = await _methodChannel.invokeMethod<bool?>('connect', {
        'deviceId': deviceId,
        'timeout': timeout,
      });
      if (result == null) {
        throw PlatformException(code: "connect(): Error retrieving value");
      }
      return result;
  }

  @override
  Future<bool> disconnect(String deviceId) async {
    final result = await _methodChannel.invokeMethod<bool?>('disconnect', {
      'deviceId': deviceId,
    });
    if (result == null) {
      throw PlatformException(code: "disconnect(): Error retrieving value");
    }
    return result;
  }

  @override
  Future<List<Uint8>> read(
      String deviceId,
      String service,
      String characteristic,
      int timeout
    ) async {
      final result = await _methodChannel.invokeMethod<Map<dynamic, dynamic>?>('read', {
        'deviceId': deviceId,
        'service': service,
        'characteristic': characteristic,
        'timeout': timeout,
      });
      if (result == null
        || result["value"] == null
      ) {
        throw PlatformException(code: "read(): Error retrieving value");
      }
      return result["value"] as List<Uint8>;
  }

  @override
  Future<void> write(
      String deviceId,
      String service,
      String characteristic,
      String value,
      int timeout
    ) async {
      return await _methodChannel.invokeMethod<void>('write', {
        'deviceId': deviceId,
        'service': service,
        'characteristic': characteristic,
        'value': value,
        'timeout': timeout,
      });
  }

  String _toCamelCase(String input) {
    List<String> words = input.toLowerCase().split('_');
    for (int i = 1; i < words.length; i++) {
      words[i] = words[i].substring(0, 1).toUpperCase() + words[i].substring(1);
    }
    return words.join('');
  }

  @override
  Future<DisengageStatusType> disengage(
      String deviceId,
      String mobileId,
      String mobileDeviceKey,
      String mobileGroupId,
      String mobileAccessData,
      bool isPermanentRelease
    ) async {
    final result = await _methodChannel.invokeMethod<String?>('disengage', {
      'deviceId': deviceId,
      'mobileId': mobileId,
      'mobileDeviceKey': mobileDeviceKey,
      'mobileGroupId': mobileGroupId,
      'mobileAccessData': mobileAccessData,
      'isPermanentRelease': isPermanentRelease,
    });
    if (result == null) {
      throw PlatformException(code: "disengage(): Error retrieving value");
    }
    return DisengageStatusType.values.byName(_toCamelCase(result));
  }
  
  @override
  Future<bool> startNotifications(
      String deviceId,
      String service,
      String characteristic,
      int timeout,
      void Function(String result) callback) async {


    final key = "notification|$deviceId|$service|$characteristic";
    _notificationStreams[key] =
        _startNotificationsEventChannel.receiveBroadcastStream().listen((event) {
      if (event == null || event["status"] == "error") {
        _notificationStreams[key]?.cancel();
        return;
      }
      if (event[key]){
        callback(event[key]["value"]);
      }
    });

    final result = await _methodChannel.invokeMethod<Map<dynamic, dynamic>>('startNotifications',
    {
      'deviceId': deviceId,
      'service': service,
      'characteristic': characteristic,
      'timeout': timeout,
    });
    if (result == null 
      || result["value"] == null
      ) {
      throw PlatformException(code: "startNotifications(): Error retrieving value");
    }
    return result["value"];
  }

  @override
  Future<bool> stopNotifications(
    String deviceId,
      String service,
      String characteristic, 
      int timeout
      ) async {
        final key = "notification|$deviceId|$service|$characteristic";
        _notificationStreams[key]?.cancel();
        _notificationStreams.remove(key);

        final result = await _methodChannel
        .invokeMethod<Map<dynamic, dynamic>?>('stopNotifications', {
          'deviceId': deviceId,
          'service': service,
          'characteristic': characteristic,
          'timeout': timeout,
        });
        if (result == null 
          || result["value"] == null
          ) {
          throw PlatformException(code: "stopNotifications(): Error retrieving value");
        }
        return result["value"];  
  }

  @override
  Future<bool> signalize(String deviceId) async {
    final result = await _methodChannel
        .invokeMethod<bool?>(
            'signalize', {'deviceId': deviceId});
    if (result == null) {
      throw PlatformException(code: "stopNotifications(): Error retrieving value");
    }
    return result;
  }
}
