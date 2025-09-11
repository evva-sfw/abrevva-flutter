<p align="center">
  <h1 align="center">Abrevva Flutter Plugin</h1>
</p>

<p align="center">
  <a href="https://pub.dev/packages/abrevva">
    <img alt="Pub Version" src="https://img.shields.io/pub/v/abrevva"></a>
  <a href="https://pub.dev/packages/abrevva">
  <img alt="Pub Points" src="https://img.shields.io/pub/points/abrevva"></a>
  <img alt="GitHub last commit" src="https://img.shields.io/github/last-commit/evva-sfw/abrevva-flutter">
  <a href="https://github.com/evva-sfw/abrevva-flutter/actions"><img alt="GitHub branch check runs" src="https://img.shields.io/github/check-runs/evva-sfw/abrevva-flutter/main"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-EVVA_License-yellow.svg?color=fce500&logo=data:image/svg+xml;base64,PCEtLSBHZW5lcmF0ZWQgYnkgSWNvTW9vbi5pbyAtLT4KPHN2ZyB2ZXJzaW9uPSIxLjEiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIgd2lkdGg9IjY0MCIgaGVpZ2h0PSIxMDI0IiB2aWV3Qm94PSIwIDAgNjQwIDEwMjQiPgo8ZyBpZD0iaWNvbW9vbi1pZ25vcmUiPgo8L2c+CjxwYXRoIGZpbGw9IiNmY2U1MDAiIGQ9Ik02MjIuNDIzIDUxMS40NDhsLTMzMS43NDYtNDY0LjU1MmgtMjg4LjE1N2wzMjkuODI1IDQ2NC41NTItMzI5LjgyNSA0NjYuNjY0aDI3NS42MTJ6Ij48L3BhdGg+Cjwvc3ZnPgo=" alt="EVVA License"></a>
</p>

The EVVA Flutter Plugin is a collection of tools to work with electronical EVVA access components. It allows for scanning and connecting via BLE.

- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Examples](#examples)

## Features

- BLE Scanner for EVVA components in range
- Localize EVVA components encountered by a scan
- Disengage EVVA components encountered by a scan
- Read / Write data via BLE

## Requirements

- Flutter >=3.3.0
- Java 17+ (Android)
- Android SDK (Android)
- Android 10+ (API level 29) (Android)
- Xcode 15.4 (iOS)
- iOS 15.0+ (iOS)

## Installation

```sh
flutter pub add abrevva
```

### iOS
Add a `post_install` hook in your Podfile to resolve a nasty [CocoaPods limitation with XCFrameworks](https://github.com/CocoaPods/CocoaPods/issues/11079).

```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
    end
  end
end
```

Execute `pod install` inside of your projects `ios/` folder.


### Android

Perform a gradle sync.

## Examples

### Initialize and scan for EVVA components

To start off first import the `abrevva` Package

```Dart
import 'package:abrevva/abrevva.dart';

async function scanForBleDevices(androidNeverForLocation: Boolean = true, timeout: Number) {
  await AbrevvaBle.initialize(androidNeverForLocation);

  AbrevvaBle.startScan(
    (scanResult: ScanResult) => {
      print("Discovered Device: ${scanResult.bleDevice.deviceId}");
    },
    (success: bool) => {
      print("onScanStart status=${success}");
    },
    (success: bool) => {
      print("onScanStop status=${success}");
    },
    null,  // macFilter
    false, // allowDuplicates
    10_000 // timeout
  );
}
```

### Read EVVA component advertisement

Get the EVVA advertisement data from a scanned EVVA component.

```Dart
final ad = device.advertisementData;
print(ad?.rssi);
print(ad?.isConnectable);

final md = ad?.manufacturerData;
print(md.batteryStatus);
print(md.isOnline);
print(md.officeModeEnabled);
print(md.officeModeActive);
// ...
```

There are several properties that can be accessed from the advertisement.

```Dart
class BleDeviceAdvertisementData {
  int? rssi;
  bool? isConnectable;
  BleDeviceManufacturerData? manufacturerData;
  Map<String, dynamic>? rawData;
}

class BleDeviceManufacturerData {
  int? companyIdentifier;
  int? version;
  ComponentType? componentType;
  int? mainFirmwareVersionMajor;
  int? mainFirmwareVersionMinor;
  int? mainFirmwareVersionPatch;
  int? componentHAL;
  BatteryStatus? batteryStatus;
  bool? mainConstructionMode;
  bool? subConstructionMode;
  bool? isOnline;
  bool? officeModeEnabled;
  bool? twoFactorRequired;
  bool? officeModeActive;
  String? identifier;
  int? subFirmwareVersionMajor;
  int? subFirmwareVersionMinor;
  int? subFirmwareVersionPatch;
  String? subComponentIdentifier;
}
```

### Localize EVVA component

With the signalize method you can localize EVVA components. On a successful signalization the component will emit a melody indicating its location.

```Dart
final success = await AbrevvaBle.signalize('deviceId');
```

### Perform disengage on EVVA components

For the component disengage you have to provide access credentials to the EVVA component. Those are generally acquired in the form of access media metadata from the Xesar software.

```Dart
final status = await AbrevvaBle.disengage(
  'deviceId',
  'mobileId',
  'mobileDeviceKey',
  'mobileGroupId',
  'mobileAccessData',
  false,
);
```

There are several access status types upon attempting the component disengage.

```Dart
enum DisengageStatusType {
  /// Component
  authorized, 
  authorizedPermanentDisengage, 
  authorizedPermanentEngage, 
  authorizedBatteryLow, 
  authorizedOffline, 
  unauthorized, 
  unauthorizedOffline, 
  signalLocalization, 
  mediumDefectOnline,
  mediumBlacklisted, 
  error,

  /// Interface
  unableToConnect,
  unableToSetNotifications,
  unableToReadChallenge,
  unableToWriteMDF,
  accessCipherError,
  bleAdapterDisabled,
  unknownDevice,
  unknownStatusCode,
  timeout,
}
```

### Coding Identification Media

Use the CodingStation to write or update access data onto an EVVA identification medium.

```Dart
class ExampleClass {
  final _abrevvaCodingStation = AbrevvaCodingStation();

  String url = "";
  String clientId = "";
  String username = "";
  String password = "";
  
  void writeMedium() async {
    try {
      await _abrevvaCodingStation.register(url, clientId, username, password);
      await _abrevvaCodingStation.connect();
      await _abrevvaCodingStation.write();
      await _abrevvaCodingStation.disconnect();
    } catch (e) {
      debugPrint("Error $e");
    }
  }
}
```
