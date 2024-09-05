import 'dart:typed_data';
import 'package:collection/collection.dart';

enum ScanMode {
  SCAN_MODE_LOW_POWER,
  SCAN_MODE_BALANCED,
  SCAN_MODE_LOW_LATENCY,
}

class RequestBleDeviceParams {
  List<String>? services;
  String? name;
  String? namePrefix;
  List<String>? optionalServices;
  bool? allowDuplicates;
  ScanMode? scanMode;
  int? timeout;
  Function eq = const ListEquality().equals;

  RequestBleDeviceParams(
      {this.services,
      this.name,
      this.namePrefix,
      this.optionalServices,
      this.allowDuplicates,
      this.scanMode,
      this.timeout});

  getMap() {
    var map = {
      'services': services,
      'name': name,
      'namePrefix': namePrefix,
      'optionalServices': optionalServices,
      'allowDuplicates': allowDuplicates,
      'scanMode': scanMode,
      'timeout': timeout,
    };
    map.removeWhere((key, value) => value == null);
    return (map);
  }
}

class StartNotificationsParams {
  String deviceId;
  String service;
  String characteristic;
  int timeout;

  StartNotificationsParams(
      {required this.deviceId,
      required this.service,
      required this.characteristic,
      required this.timeout});

  getMap() {
    return {
      'deviceId': deviceId,
      'service': service,
      'characteristic': characteristic,
      'timeout': timeout,
    };
  }
}

class BleDevice {
  String deviceId;
  String? name;
  List<String>? uuids;
  BleDevice({required this.deviceId, this.name, this.uuids});
  Function eq = const ListEquality().equals;

  @override
  bool operator ==(Object other) {
    if (other is! BleDevice) return false;
    if (deviceId != other.deviceId) return false;
    if (name != other.name) return false;
    if (!eq(uuids, other.uuids)) return false;

    return true;
  }
}

class ScanResult {
  BleDevice device;
  String? localName;
  int? rssi;
  int? txPower;
  Map<String, String>? manufacturerData;
  Map<String, ByteData>? serviceData;
  List<String>? uuids;
  String? rawAdvertisement;
  Function eqMap = const MapEquality().equals;
  Function eqList = const ListEquality().equals;

  ScanResult({
    required this.device,
    this.localName,
    this.rssi,
    this.txPower,
    this.manufacturerData,
    this.serviceData,
    this.uuids,
    this.rawAdvertisement,
  });

  @override
  bool operator ==(Object other) {
    if (other is! ScanResult) return false;
    if (device != other.device) return false;
    if (localName != other.localName) return false;
    if (rssi != other.rssi) return false;
    if (!eqMap(manufacturerData, other.manufacturerData)) return false;
    if (!eqMap(serviceData, other.serviceData)) return false;
    if (!eqList(uuids, other.uuids)) return false;
    if (rawAdvertisement != other.rawAdvertisement) return false;

    return true;
  }
}

class ReadResult {
  String? value;

  ReadResult({this.value});
}
