import 'dart:ffi';

import 'package:abrevva/abrevva_param_classes.dart';

import 'abrevva_platform_interface.dart';

class AbrevvaCodingStation {
  static Future<void> register(
      String url, String clientId, String username, String password) {
    return AbrevvaCodingStationPlatform.instance
        .register(url, clientId, username, password);
  }

  static Future<void> connect() {
    return AbrevvaCodingStationPlatform.instance.connect();
  }

  static Future<void> write() {
    return AbrevvaCodingStationPlatform.instance.write();
  }

  static Future<void> disconnect() {
    return AbrevvaCodingStationPlatform.instance.disconnect();
  }
}

class AbrevvaCrypto {
  static Future<StringResult> random(int numBytes) {
    return AbrevvaCryptoPlatform.instance.random(numBytes);
  }

  static Future<KeyPairResult> generateKeyPair() {
    return AbrevvaCryptoPlatform.instance.generateKeyPair();
  }

  static Future<EncryptResult> encrypt(
      String key, String iv, String adata, String pt, int tagLength) {
    return AbrevvaCryptoPlatform.instance
        .encrypt(key, iv, adata, pt, tagLength);
  }

  static Future<DecryptResult> decrypt(
      String key, String iv, String adata, String ct, int tagLength) {
    return AbrevvaCryptoPlatform.instance
        .decrypt(key, iv, adata, ct, tagLength);
  }

  static Future<StringResult> computeSharedSecret(
      String privateKey, String peerPublicKey) {
    return AbrevvaCryptoPlatform.instance
        .computeSharedSecret(privateKey, peerPublicKey);
  }

  static Future<bool> encryptFile(
      String sharedSecret, String ptPath, String ctPath) {
    return AbrevvaCryptoPlatform.instance
        .encryptFile(sharedSecret, ptPath, ctPath);
  }

  static Future<bool> decryptFile(
      String sharedSecret, String ctPath, String ptPath) {
    return AbrevvaCryptoPlatform.instance
        .decryptFile(sharedSecret, ctPath, ptPath);
  }

  static Future<bool> decryptFileFromURL(
      String sharedSecret, String url, String ptPath) {
    return AbrevvaCryptoPlatform.instance
        .decryptFileFromURL(sharedSecret, url, ptPath);
  }

  static Future<ED25519PublicKeyResult> computeED25519PublicKey(
      String privateKey) {
    return AbrevvaCryptoPlatform.instance.computeED25519PublicKey(privateKey);
  }

  static Future<SignResult> sign(String privateKey, String data) {
    return AbrevvaCryptoPlatform.instance.sign(privateKey, data);
  }

  static Future<void> verify(String publicKey, String data, String signature) {
    return AbrevvaCryptoPlatform.instance.verify(publicKey, data, signature);
  }

  static Future<StringResult> derive(
      String key, String salt, String info, int length) {
    return AbrevvaCryptoPlatform.instance.derive(key, salt, info, length);
  }
}

class AbrevvaBle {
  static Future<void> initialize(bool androidNeverForLocation) {
    return AbrevvaBlePlatform.instance.initialize(androidNeverForLocation);
  }

  static Future<bool> isEnabled() {
    return AbrevvaBlePlatform.instance.isEnabled();
  }

  static Future<bool> isLocationEnabled() {
    return AbrevvaBlePlatform.instance.isLocationEnabled();
  }

  static Future<void> startEnabledNotifications(
      void Function(bool result) callback) {
    return AbrevvaBlePlatform.instance.startEnabledNotifications(callback);
  }

  static Future<void> stopEnabledNotifications() {
    return AbrevvaBlePlatform.instance.stopEnabledNotifications();
  }

  static Future<void> openLocationSettings() {
    return AbrevvaBlePlatform.instance.openLocationSettings();
  }

  static Future<void> openBluetoothSettings() {
    return AbrevvaBlePlatform.instance.openBluetoothSettings();
  }

  static Future<void> openAppSettings() {
    return AbrevvaBlePlatform.instance.openAppSettings();
  }

  static Future<void> startScan({
    required void Function(BleDevice result) onScanResult,
    void Function(bool success)? onScanStart,
    void Function(bool success)? onScanStop,
    String? macFilter,
    bool? allowDuplicates,
    int? timeout,
  }) {
    return AbrevvaBlePlatform.instance.startScan(
        onScanResult: onScanResult,
        onScanStart: onScanStart,
        onScanStop: onScanStop,
        macFilter: macFilter,
        allowDuplicates: allowDuplicates,
        timeout: timeout);
  }

  static Future<String?> stopScan() {
    return AbrevvaBlePlatform.instance.stopScan();
  }

  static Future<bool> connect(String deviceId, int timeout,
      void Function(String address)? onDisconnect) {
    return AbrevvaBlePlatform.instance.connect(deviceId, timeout, onDisconnect);
  }

  static Future<void> disconnect(String deviceId) {
    return AbrevvaBlePlatform.instance.disconnect(deviceId);
  }

  static Future<List<Uint8>> read(
      String deviceId, String service, String characteristic, int timeout) {
    return AbrevvaBlePlatform.instance
        .read(deviceId, service, characteristic, timeout);
  }

  static Future<void> write(String deviceId, String service,
      String characteristic, String value, int timeout) {
    return AbrevvaBlePlatform.instance
        .write(deviceId, service, characteristic, value, timeout);
  }

  @Deprecated("Use disengageWithXvnResponse() instead.")
  static Future<DisengageStatusType> disengage(
      String deviceId,
      String mobileId,
      String mobileDeviceKey,
      String mobileGroupId,
      String mobileAccessData,
      bool isPermanentRelease) {
    return AbrevvaBlePlatform.instance.disengage(deviceId, mobileId,
        mobileDeviceKey, mobileGroupId, mobileAccessData, isPermanentRelease);
  }

  static Future<DisengageResult> disengageWithXvnResponse(
      String deviceId,
      String mobileId,
      String mobileDeviceKey,
      String mobileGroupId,
      String mobileAccessData,
      bool isPermanentRelease) {
    return AbrevvaBlePlatform.instance.disengageWithXvnResponse(
        deviceId,
        mobileId,
        mobileDeviceKey,
        mobileGroupId,
        mobileAccessData,
        isPermanentRelease);
  }

  static Future<void> startNotifications(
      String deviceId,
      String service,
      String characteristic,
      int timeout,
      void Function(String result) callback) {
    return AbrevvaBlePlatform.instance.startNotifications(
        deviceId, service, characteristic, timeout, callback);
  }

  static Future<bool> stopNotifications(
      String deviceId, String service, String characteristic, int timeout) {
    return AbrevvaBlePlatform.instance
        .stopNotifications(deviceId, service, characteristic, timeout);
  }

  static Future<bool> signalize(String deviceId) {
    return AbrevvaBlePlatform.instance.signalize(deviceId);
  }
}
