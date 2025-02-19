import 'dart:ffi';

import 'package:abrevva/abrevva_param_classes.dart';
import 'abrevva_platform_interface.dart';

class AbrevvaCrypto {
  Future<StringResult> random(int numBytes) {
    return AbrevvaCryptoPlatform.instance.random(numBytes);
  }

  Future<KeyPairResult> generateKeyPair() {
    return AbrevvaCryptoPlatform.instance.generateKeyPair();
  }

  Future<EncryptResult> encrypt(
      String key, String iv, String adata, String pt, int tagLength) {
    return AbrevvaCryptoPlatform.instance
        .encrypt(key, iv, adata, pt, tagLength);
  }

  Future<DecryptResult> decrypt(
      String key, String iv, String adata, String ct, int tagLength) {
    return AbrevvaCryptoPlatform.instance
        .decrypt(key, iv, adata, ct, tagLength);
  }

  Future<StringResult> computeSharedSecret(
      String privateKey, String peerPublicKey) {
    return AbrevvaCryptoPlatform.instance
        .computeSharedSecret(privateKey, peerPublicKey);
  }

  Future<Bool> encryptFile(
      String sharedSecret, String ptPath, String ctPath) {
    return AbrevvaCryptoPlatform.instance
        .encryptFile(sharedSecret, ptPath, ctPath);
  }

  Future<Bool> decryptFile(
      String sharedSecret, String ctPath, String adata, String ptPath) {
    return AbrevvaCryptoPlatform.instance
        .decryptFile(sharedSecret, ctPath, adata, ptPath);
  }

  Future<Bool> decryptFileFromURL(
      String sharedSecret, String url, String ptPath) {
    return AbrevvaCryptoPlatform.instance
        .decryptFileFromURL(sharedSecret, url, ptPath);
  }

  Future<StringResult> derive(
      String key, String salt, String info, int length) {
    return AbrevvaCryptoPlatform.instance.derive(key, salt, info, length);
  }
}

class AbrevvaBle {
  Future<void> initialize(bool androidNeverForLocation) {
    return AbrevvaBlePlatform.instance.initialize(androidNeverForLocation);
  }

  Future<bool> isEnabled() {
    return AbrevvaBlePlatform.instance.isEnabled();
  }

  Future<bool> isLocationEnabled() {
    return AbrevvaBlePlatform.instance.isLocationEnabled();
  }

  Future<void> startEnabledNotifications(void Function(bool result) callback) {
    return AbrevvaBlePlatform.instance.startEnabledNotifications(callback);
  }

  Future<void> stopEnabledNotifications() {
    return AbrevvaBlePlatform.instance.stopEnabledNotifications();
  }

  Future<void> openLocationSettings() {
    return AbrevvaBlePlatform.instance.openLocationSettings();
  }

  Future<void> openBluetoothSettings() {
    return AbrevvaBlePlatform.instance.openBluetoothSettings();
  }

  Future<void> openAppSettings() {
    return AbrevvaBlePlatform.instance.openAppSettings();
  }

  Future<void> startScan({
      required void Function(BleDevice result) onScanResult,
      void Function(bool success)? onScanStart,
      void Function(bool success)? onScanStop,
      String? macFilter,
      bool? allowDuplicates,
      int? timeout,
    }) {
    return AbrevvaBlePlatform.instance.startScan(
      onScanResult: onScanResult,
      onScanStop: onScanStop, 
      macFilter: macFilter,
      allowDuplicates: allowDuplicates, 
      timeout: timeout
    );
  }

  Future<String?> stopScan() {
    return AbrevvaBlePlatform.instance.stopScan();
  }

  Future<bool> connect(String deviceId, int timeout, void Function(String address)? onDisconnect) {
    return AbrevvaBlePlatform.instance.connect(deviceId, timeout, onDisconnect);
  }

  Future<bool> disconnect(String deviceId) {
    return AbrevvaBlePlatform.instance.disconnect(deviceId);
  }

  Future<List<Uint8>> read(
      String deviceId, 
      String service,
      String characteristic,
      int timeout
    ) {
      return AbrevvaBlePlatform.instance
        .read(deviceId, service, characteristic, timeout);
  }

  Future<void> write(String deviceId, String service,
      String characteristic, String value, int timeout) {
    return AbrevvaBlePlatform.instance
        .write(deviceId, service, characteristic, value, timeout);
  }

  Future<DisengageStatusType> disengage(
      String mobileId,
      String mobileDeviceKey,
      String mobileGroupId,
      String mobileAccessData,
      bool isPermanentRelease) {
    return AbrevvaBlePlatform.instance.disengage(mobileId, mobileDeviceKey,
        mobileGroupId, mobileAccessData, isPermanentRelease);
  }

  Future<void> startNotifications(
      String deviceId,
      String service,
      String characteristic,
      int timeout,
      void Function(String result) callback
    ) {
    return AbrevvaBlePlatform.instance.startNotifications(
      deviceId,
      service,
      characteristic,
      timeout,
      callback
    );
  }

  Future<bool> stopNotifications(
      String deviceId, String service, String characteristic, int timeout) {
    return AbrevvaBlePlatform.instance
        .stopNotifications(deviceId, service, characteristic, timeout);
  }

  Future<bool> signalize(String deviceId) {
    return AbrevvaBlePlatform.instance.signalize(deviceId);
  }
}
