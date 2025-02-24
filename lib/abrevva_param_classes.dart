enum ComponentType {
  handle, escutcheon, cylinder, wallreader, emzy, iobox, unknown
}

enum BatteryStatus {
  batteryFull, batteryEmpty, unknown

}

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
  
  BleDeviceManufacturerData({this.companyIdentifier, 
  this.version, this.componentType, this.mainFirmwareVersionMajor, this.mainFirmwareVersionMinor, 
  this.mainFirmwareVersionPatch, this.componentHAL, this.batteryStatus, this.mainConstructionMode, 
  this.subComponentIdentifier, this.isOnline, this.officeModeEnabled, this.twoFactorRequired, 
  this.officeModeActive, this.identifier, this.subFirmwareVersionMajor, this.subFirmwareVersionMinor, 
  this.subFirmwareVersionPatch, this.subConstructionMode});
}

class BleDeviceAdvertisementData {
  int? rssi;
  bool? isConnectable;
  BleDeviceManufacturerData? manufacturerData;
  Map<Object?, Object?>? rawData;

  BleDeviceAdvertisementData({this.isConnectable, this.manufacturerData, this.rawData, this.rssi});
}

class BleDevice {
  String deviceId;
  String? name;
  BleDeviceAdvertisementData? advertisementData;
  BleDevice({required this.deviceId, this.name, this.advertisementData});
}

class StringResult {
  String value;
  
  StringResult(this.value);
}

class KeyPairResult {
  String privateKey;
  String publicKey;

  KeyPairResult(this.privateKey, this.publicKey);
}

class EncryptResult {
  String cipherText;
  String authTag;

  EncryptResult(this.cipherText, this.authTag);
}

class DecryptResult {
  String plainText;
  String authOk;

  DecryptResult(this.plainText, this.authOk);
}
