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

  Future<Map<dynamic, dynamic>?> random(int numBytes) {
    throw UnimplementedError('random() has not been implemented.');
  }

  Future<Map<dynamic, dynamic>?> generateKeyPair() {
    throw UnimplementedError('random() has not been implemented.');
  }

  Future<Map<dynamic, dynamic>?> encrypt(
      String key, String iv, String adata, String pt, int tagLength) {
    throw UnimplementedError('encrypt() has not been implemented.');
  }

  Future<Map<dynamic, dynamic>?> decrypt(
      String key, String iv, String adata, String ct, int tagLength) {
    throw UnimplementedError('decrypt() has not been implemented.');
  }

  Future<Map<dynamic, dynamic>?> encryptFile(
      String sharedSecret, String ptPath, String ctPath) {
    throw UnimplementedError('encryptFile() has not been implemented.');
  }

  Future<Map<dynamic, dynamic>?> computeSharedSecret(
      String privateKey, String peerPublicKey) {
    throw UnimplementedError('computeSharedSecret() has not been implemented.');
  }

  Future<Map<dynamic, dynamic>?> decryptFile(
      String sharedSecret, String ctPath, String adata, String ptPath) {
    throw UnimplementedError('decryptFile() has not been implemented.');
  }

  Future<Map<dynamic, dynamic>?> decryptFileFromURL(
      String sharedSecret, String url, String ptPath) {
    throw UnimplementedError('decryptFileFromURL() has not been implemented.');
  }

  Future<Map<dynamic, dynamic>?> derive(
      String key, String salt, String info, int length) {
    throw UnimplementedError('derive() has not been implemented.');
  }
}

abstract class AbrevvaNfcPlatform extends PlatformInterface {
  /// Constructs a .
  AbrevvaNfcPlatform() : super(token: _token);

  static final Object _token = Object();

  static AbrevvaNfcPlatform _instance = MethodChannelAbrevvaNfcPlatform();

  /// The default instance of [AbrevvaNfcPlatformPlatform] to use.
  ///
  /// Defaults to [MethodChannelAbrevvaNfcPlatform].
  static AbrevvaNfcPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [AbrevvaNfcPlatform] when
  /// they register themselves.
  static set instance(AbrevvaNfcPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> read() {
    throw UnimplementedError('read() has not been implemented.');
  }

  Future<Map<dynamic, dynamic>?> connect() {
    throw UnimplementedError('connect() has not been implemented.');
  }

  Future<Map<dynamic, dynamic>?> disconnect() {
    throw UnimplementedError('disconnect() has not been implemented.');
  }
}

abstract class AbrevvaBlePlatform extends PlatformInterface {
  /// Constructs a .
  AbrevvaBlePlatform() : super(token: _token);

  static final Object _token = Object();

  static AbrevvaBlePlatform _instance = MethodChannelAbrevvaBlePlatform();

  /// The default instance of [AbrevvaNfcPlatformPlatform] to use.
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

  Future<Map<dynamic, dynamic>?> initialize(bool androidNeverForLocation) {
    throw UnimplementedError('initialize() has not been implemented.');
  }

  Future<Map<dynamic, dynamic>?> isEnabled() {
    throw UnimplementedError('isEnabled() has not been implemented.');
  }

  Future<Map<dynamic, dynamic>?> isLocationEnabled() {
    throw UnimplementedError('isLocationEnabled() has not been implemented.');
  }

  Future<void> startEnabledNotifications(void Function(bool result) callback) {
    throw UnimplementedError(
        'startEnabledNotifications() has not been implemented.');
  }

  Future<Map<dynamic, dynamic>?> stopEnabledNotifications() {
    throw UnimplementedError(
        'stopEnabledNotifications() has not been implemented.');
  }

  Future<Map<dynamic, dynamic>?> runInitialization() {
    throw UnimplementedError('runInitialization() has not been implemented.');
  }

  Future<Map<dynamic, dynamic>?> openLocationSettings() {
    throw UnimplementedError(
        'openLocationSettings() has not been implemented.');
  }

  Future<Map<dynamic, dynamic>?> openBluetoothSettings() {
    throw UnimplementedError(
        'openBluetoothSettings() has not been implemented.');
  }

  Future<Map<dynamic, dynamic>?> openAppSettings() {
    throw UnimplementedError('openAppSettings() has not been implemented.');
  }

  Future<void> requestLEScan(RequestBleDeviceParams options,
      void Function(ScanResult result) callback) {
    throw UnimplementedError('requestLEScan() has not been implemented.');
  }

  Future<String?> stopLEScan() {
    throw UnimplementedError('stopLEScan() has not been implemented.');
  }

  Future<Map<dynamic, dynamic>?> connect(String deviceId, int timeout) {
    throw UnimplementedError('connect() has not been implemented.');
  }

  Future<Map<dynamic, dynamic>?> disconnect(String deviceId) {
    throw UnimplementedError('disconnect() has not been implemented.');
  }

  Future<Map<dynamic, dynamic>?> read(
      String deviceId, String service, String characteristic, int timeout) {
    throw UnimplementedError('read() has not been implemented.');
  }

  Future<Map<dynamic, dynamic>?> write(String deviceId, String service,
      String characteristic, String value, int timeout) {
    throw UnimplementedError('write() has not been implemented.');
  }

  Future<Map<dynamic, dynamic>?> disengage(
      String mobileId,
      String mobileDeviceKey,
      String mobileGroupId,
      String mobileAccessData,
      bool isPermanentRelease) {
    throw UnimplementedError('disengage() has not been implemented.');
  }

  Future<void> startNotifications(StartNotificationsParams options,
      void Function(ReadResult result) callback) {
    throw UnimplementedError('startNotifications() has not been implemented.');
  }

  Future<Map<dynamic, dynamic>?> stopNotifications(
      String deviceId, String service, String characteristic, int timeout) {
    throw UnimplementedError('startNotifications() has not been implemented.');
  }

  Future<Map<dynamic, dynamic>?> signalize(String deviceId) {
    throw UnimplementedError('deviceId() has not been implemented.');
  }
}
