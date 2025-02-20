import 'dart:ffi';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'abrevva_method_channel.dart';
import 'abrevva_param_classes.dart';

abstract class AbrevvaCryptoPlatform extends PlatformInterface {
  /// Constructs a FlutterPluginPlatform.
  AbrevvaCryptoPlatform() : super(token: _token);

  static final Object _token = Object();

  static AbrevvaCryptoPlatform _instance = MethodChannelAbrevvaCrypto();

  /// The default instance of [AbrevvaCryptoPlatform] to use.
  ///
  /// Defaults to [MethodChannelAbrevvaCrypto].
  static AbrevvaCryptoPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [AbrevvaCryptoPlatform] when
  /// they register themselves.
  static set instance(AbrevvaCryptoPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<StringResult> random(int numBytes) {
    throw UnimplementedError('random() has not been implemented.');
  }

  Future<KeyPairResult> generateKeyPair() {
    throw UnimplementedError('random() has not been implemented.');
  }

  Future<EncryptResult> encrypt(
      String key, String iv, String adata, String pt, int tagLength) {
    throw UnimplementedError('encrypt() has not been implemented.');
  }

  Future<DecryptResult> decrypt(
      String key, String iv, String adata, String ct, int tagLength) {
    throw UnimplementedError('decrypt() has not been implemented.');
  }

  Future<bool> encryptFile(
      String sharedSecret, String ptPath, String ctPath) {
    throw UnimplementedError('encryptFile() has not been implemented.');
  }

  Future<StringResult> computeSharedSecret(
      String privateKey, String peerPublicKey) {
    throw UnimplementedError('computeSharedSecret() has not been implemented.');
  }

  Future<bool> decryptFile(
      String sharedSecret, String ctPath, String adata, String ptPath) {
    throw UnimplementedError('decryptFile() has not been implemented.');
  }

  Future<bool> decryptFileFromURL(
      String sharedSecret, String url, String ptPath) {
    throw UnimplementedError('decryptFileFromURL() has not been implemented.');
  }

  Future<StringResult> derive(
      String key, String salt, String info, int length) {
    throw UnimplementedError('derive() has not been implemented.');
  }
}

abstract class AbrevvaBlePlatform extends PlatformInterface {
  /// Constructs a .
  AbrevvaBlePlatform() : super(token: _token);

  static final Object _token = Object();

  static AbrevvaBlePlatform _instance = MethodChannelAbrevvaBlePlatform();

  /// The default instance of [AbrevvaBlePlatform] to use.
  ///
  /// Defaults to [MethodChannelAbrevvaBlePlatform].
  static AbrevvaBlePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [AbrevvaBlePlatform] when
  /// they register themselves.
  static set instance(AbrevvaBlePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> initialize(bool androidNeverForLocation) {
    throw UnimplementedError('initialize() has not been implemented.');
  }

  Future<bool> isEnabled() {
    throw UnimplementedError('isEnabled() has not been implemented.');
  }

  Future<bool> isLocationEnabled() {
    throw UnimplementedError('isLocationEnabled() has not been implemented.');
  }

  Future<void> startEnabledNotifications(void Function(bool result) callback) {
    throw UnimplementedError(
        'startEnabledNotifications() has not been implemented.');
  }

  Future<void> stopEnabledNotifications() {
    throw UnimplementedError(
        'stopEnabledNotifications() has not been implemented.');
  }

  Future<Map<dynamic, dynamic>?> runInitialization() {
    throw UnimplementedError('runInitialization() has not been implemented.');
  }

  Future<void> openLocationSettings() {
    throw UnimplementedError(
        'openLocationSettings() has not been implemented.');
  }

  Future<void> openBluetoothSettings() {
    throw UnimplementedError(
        'openBluetoothSettings() has not been implemented.');
  }

  Future<void> openAppSettings() {
    throw UnimplementedError('openAppSettings() has not been implemented.');
  }

  Future<void> startScan({
      required void Function(BleDevice result) onScanResult,
      void Function(bool success)? onScanStart,
      void Function(bool success)? onScanStop,
      String? macFilter,
      bool? allowDuplicates,
      int? timeout,
    }) {
    throw UnimplementedError('startScan() has not been implemented.');
  }

  Future<String?> stopScan() {
    throw UnimplementedError('stopScan() has not been implemented.');
  }

  Future<bool> connect(String deviceId, int timeout, void Function(String address)? onDisconnect) {
    throw UnimplementedError('connect() has not been implemented.');
  }

  Future<bool> disconnect(String deviceId) {
    throw UnimplementedError('disconnect() has not been implemented.');
  }

  Future<List<Uint8>> read(
      String deviceId, String service, String characteristic, int timeout) {
    throw UnimplementedError('read() has not been implemented.');
  }

  Future<void> write(String deviceId, String service,
      String characteristic, String value, int timeout) {
    throw UnimplementedError('write() has not been implemented.');
  }

  Future<DisengageStatusType> disengage(
      String mobileId,
      String mobileDeviceKey,
      String mobileGroupId,
      String mobileAccessData,
      bool isPermanentRelease) {
    throw UnimplementedError('disengage() has not been implemented.');
  }

  Future<void> startNotifications(
      String deviceId,
      String service,
      String characteristic,
      int timeout,
      void Function(String result) callback
    ) {
    throw UnimplementedError('startNotifications() has not been implemented.');
  }

  Future<bool> stopNotifications(
      String deviceId, String service, String characteristic, int timeout) {
    throw UnimplementedError('startNotifications() has not been implemented.');
  }

  Future<bool> signalize(String deviceId) {
    throw UnimplementedError('deviceId() has not been implemented.');
  }
}
