import 'package:abrevva/abrevva_param_classes.dart';
import 'abrevva_platform_interface.dart';

class AbrevvaCrypto {
  Future<Map<dynamic, dynamic>?> random(int numBytes) {
    return AbrevvaCryptoPlatform.instance.random(numBytes);
  }

  Future<Map<dynamic, dynamic>?> generateKeyPair() {
    return AbrevvaCryptoPlatform.instance.generateKeyPair();
  }

  Future<Map<dynamic, dynamic>?> encrypt(
      String key, String iv, String adata, String pt, int tagLength) {
    return AbrevvaCryptoPlatform.instance
        .encrypt(key, iv, adata, pt, tagLength);
  }

  Future<Map<dynamic, dynamic>?> decrypt(
      String key, String iv, String adata, String ct, int tagLength) {
    return AbrevvaCryptoPlatform.instance
        .decrypt(key, iv, adata, ct, tagLength);
  }

  Future<Map<dynamic, dynamic>?> computeSharedSecret(
      String privateKey, String peerPublicKey) {
    return AbrevvaCryptoPlatform.instance
        .computeSharedSecret(privateKey, peerPublicKey);
  }

  Future<Map<dynamic, dynamic>?> encryptFile(
      String sharedSecret, String ptPath, String ctPath) {
    return AbrevvaCryptoPlatform.instance
        .encryptFile(sharedSecret, ptPath, ctPath);
  }

  Future<Map<dynamic, dynamic>?> decryptFile(
      String sharedSecret, String ctPath, String adata, String ptPath) {
    return AbrevvaCryptoPlatform.instance
        .decryptFile(sharedSecret, ctPath, adata, ptPath);
  }

  Future<Map<dynamic, dynamic>?> decryptFileFromURL(
      String sharedSecret, String url, String ptPath) {
    return AbrevvaCryptoPlatform.instance
        .decryptFileFromURL(sharedSecret, url, ptPath);
  }

  Future<Map<dynamic, dynamic>?> derive(
      String key, String salt, String info, int length) {
    return AbrevvaCryptoPlatform.instance.derive(key, salt, info, length);
  }
}

class AbrevvaNfc {
  Future<void> read() {
    return AbrevvaNfcPlatform.instance.read();
  }

  Future<Map<dynamic, dynamic>?> connect() {
    return AbrevvaNfcPlatform.instance.connect();
  }

  Future<Map<dynamic, dynamic>?> disconnect() {
    return AbrevvaNfcPlatform.instance.disconnect();
  }
}

class AbrevvaBle {
  Future<Map<dynamic, dynamic>?> initialize(bool androidNeverForLocation) {
    return AbrevvaBlePlatform.instance.initialize(androidNeverForLocation);
  }

  Future<Map<dynamic, dynamic>?> isEnabled() {
    return AbrevvaBlePlatform.instance.isEnabled();
  }

  Future<Map<dynamic, dynamic>?> isLocationEnabled() {
    return AbrevvaBlePlatform.instance.isLocationEnabled();
  }

  Future<void> startEnabledNotifications(void Function(bool result) callback) {
    return AbrevvaBlePlatform.instance.startEnabledNotifications(callback);
  }

  Future<Map<dynamic, dynamic>?> stopEnabledNotifications() {
    return AbrevvaBlePlatform.instance.stopEnabledNotifications();
  }

  Future<Map<dynamic, dynamic>?> openLocationSettings() {
    return AbrevvaBlePlatform.instance.openLocationSettings();
  }

  Future<Map<dynamic, dynamic>?> openBluetoothSettings() {
    return AbrevvaBlePlatform.instance.openBluetoothSettings();
  }

  Future<Map<dynamic, dynamic>?> openAppSettings() {
    return AbrevvaBlePlatform.instance.openAppSettings();
  }

  Future<void> requestLEScan(RequestBleDeviceParams options,
      void Function(ScanResult result) callback) {
    return AbrevvaBlePlatform.instance.requestLEScan(options, callback);
  }

  Future<String?> stopLEScan() {
    return AbrevvaBlePlatform.instance.stopLEScan();
  }

  Future<Map<dynamic, dynamic>?> connect(String deviceId, int timeout) {
    return AbrevvaBlePlatform.instance.connect(deviceId, timeout);
  }

  Future<Map<dynamic, dynamic>?> disconnect(String deviceId) {
    return AbrevvaBlePlatform.instance.disconnect(deviceId);
  }

  Future<Map<dynamic, dynamic>?> read(
      String deviceId, String service, String characteristic, int timeout) {
    return AbrevvaBlePlatform.instance
        .read(deviceId, service, characteristic, timeout);
  }

  Future<Map<dynamic, dynamic>?> write(String deviceId, String service,
      String characteristic, String value, int timeout) {
    return AbrevvaBlePlatform.instance
        .write(deviceId, service, characteristic, value, timeout);
  }

  Future<Map<dynamic, dynamic>?> disengage(
      String mobileId,
      String mobileDeviceKey,
      String mobileGroupId,
      String mobileAccessData,
      bool isPermanentRelease) {
    return AbrevvaBlePlatform.instance.disengage(mobileId, mobileDeviceKey,
        mobileGroupId, mobileAccessData, isPermanentRelease);
  }

  Future<void> startNotifications(StartNotificationsParams options,
      void Function(ReadResult result) callback) {
    return AbrevvaBlePlatform.instance.startNotifications(options, callback);
  }

  Future<Map<dynamic, dynamic>?> stopNotifications(
      String deviceId, String service, String characteristic, int timeout) {
    return AbrevvaBlePlatform.instance
        .stopNotifications(deviceId, service, characteristic, timeout);
  }

  Future<Map<dynamic, dynamic>?> signalize(String deviceId) {
    return AbrevvaBlePlatform.instance.signalize(deviceId);
  }
}
