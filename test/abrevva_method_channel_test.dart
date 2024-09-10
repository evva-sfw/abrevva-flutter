import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:abrevva/abrevva_method_channel.dart';
import 'package:flutter/services.dart';
import 'package:mocktail/mocktail.dart';
import 'package:abrevva/abrevva_param_classes.dart';

class Func<T, U> {
  final T Function(U) f;

  Func(this.f);

  T invoke(U args) => f(args);
}

class MockFunction<T, U> extends Mock implements Func<T, U> {}

class MockEventChannel extends Mock implements EventChannel {}

class MockStream<T> extends Mock implements Stream<T> {}

class MockStreamSubscription<T> extends Mock implements StreamSubscription<T> {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('AbrevvaCrypto Tests', () {
    MethodChannelAbrevvaNfcPlatform platform =
        MethodChannelAbrevvaNfcPlatform();
    const MethodChannel channel = MethodChannel('AbrevvaNfc');

    setUp(() {
      platform = MethodChannelAbrevvaNfcPlatform();
      platform.methodChannel = channel;
    });

    test('read', () async {
      bool handlerCalled = false;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        if (methodCall.method == 'read') {
          handlerCalled = true;
        }
        return null;
      });

      await platform.read();

      expect(handlerCalled, true);
    });
    test('connect', () async {
      bool handlerCalled = false;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        if (methodCall.method == 'connect') {
          handlerCalled = true;
        }
        return null;
      });

      await platform.connect();

      expect(handlerCalled, true);
    });
    test('disconnect', () async {
      bool handlerCalled = false;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        if (methodCall.method == 'disconnect') {
          handlerCalled = true;
        }
        return null;
      });

      await platform.disconnect();

      expect(handlerCalled, true);
    });
  });
  group('AbrevvaCrypto Tests', () {
    MethodChannelAbrevvaCrypto platform = MethodChannelAbrevvaCrypto();
    const MethodChannel channel = MethodChannel('AbrevvaCrypto');

    setUp(() {
      platform = MethodChannelAbrevvaCrypto();
      platform.methodChannel = channel;
    });
    test('random', () async {
      bool handlerCalled = false;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        if (methodCall.method == 'random') {
          handlerCalled = true;
        }
        return null;
      });

      await platform.random(5);

      expect(handlerCalled, true);
    });
    test('generateKeyPair', () async {
      bool handlerCalled = false;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        if (methodCall.method == 'generateKeyPair') {
          handlerCalled = true;
        }
        return null;
      });

      await platform.generateKeyPair();

      expect(handlerCalled, true);
    });
    test('encrypt', () async {
      bool handlerCalled = false;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        if (methodCall.method == 'encrypt') {
          handlerCalled = true;
        }
        return null;
      });

      await platform.encrypt('key', 'iv', 'adata', 'pt', 0);

      expect(handlerCalled, true);
    });
    test('decrypt', () async {
      bool handlerCalled = false;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        if (methodCall.method == 'decrypt') {
          handlerCalled = true;
        }
        return null;
      });

      await platform.decrypt('key', 'iv', 'adata', 'ct', 0);

      expect(handlerCalled, true);
    });
    test('encryptFile', () async {
      bool handlerCalled = false;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        if (methodCall.method == 'encryptFile') {
          handlerCalled = true;
        }
        return null;
      });

      await platform.encryptFile('sharedSecret', 'ptPath', 'ctPath');

      expect(handlerCalled, true);
    });
    test('computeSharedSecret', () async {
      bool handlerCalled = false;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        if (methodCall.method == 'computeSharedSecret') {
          handlerCalled = true;
        }
        return null;
      });

      await platform.computeSharedSecret('privateKey', 'publicKey');

      expect(handlerCalled, true);
    });
    test('decryptFile', () async {
      bool handlerCalled = false;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        if (methodCall.method == 'decryptFile') {
          handlerCalled = true;
        }
        return null;
      });

      await platform.decryptFile('sharedSecret', 'ctPath', 'adata', 'ptPath');

      expect(handlerCalled, true);
    });
    test('decryptFileFromURL', () async {
      bool handlerCalled = false;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        if (methodCall.method == 'decryptFileFromURL') {
          handlerCalled = true;
        }
        return null;
      });

      await platform.decryptFileFromURL('sharedSecret', 'url', 'ptPath');

      expect(handlerCalled, true);
    });
    test('decryptFile', () async {
      bool handlerCalled = false;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        if (methodCall.method == 'decryptFile') {
          handlerCalled = true;
        }
        return null;
      });

      await platform.decryptFile('sharedSecret', 'ctPath', 'adata', 'ptPath');

      expect(handlerCalled, true);
    });
    test('derive', () async {
      bool handlerCalled = false;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        if (methodCall.method == 'derive') {
          handlerCalled = true;
        }
        return null;
      });

      await platform.derive('key', 'salt', 'info', 0);

      expect(handlerCalled, true);
    });
  });
  group('AbrevvaBle Tests', () {
    MethodChannelAbrevvaBlePlatform platform =
        MethodChannelAbrevvaBlePlatform();
    const MethodChannel channel = MethodChannel('AbrevvaBle');
    late var eventChannel = MockEventChannel();
    late var mockStream = MockStream<dynamic>();

    setUp(() {
      platform = MethodChannelAbrevvaBlePlatform();
      platform.methodChannel = channel;
      registerFallbackValue(ScanResult(device: BleDevice(deviceId: 'fakeId')));
      platform.eventChannel = eventChannel;
      when(() => eventChannel.receiveBroadcastStream(any()))
          .thenAnswer((_) => mockStream);
      when(() => mockStream.listen(captureAny()))
          .thenReturn(MockStreamSubscription());
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    group("startEnabledNotifications", () {
      late MockFunction<void, bool> testCallback;
      dynamic capturedFunction;
      setUp(() {
        testCallback = MockFunction<void, bool>();

        platform.startEnabledNotifications(testCallback.invoke);

        capturedFunction =
            verify(() => mockStream.listen(captureAny())).captured.single;
      });

      test('should not call callback on error', () async {
        capturedFunction({'status': 'error'});

        verifyNever(() => testCallback.invoke(any()));
      });

      test('should call callback if no error occurred', () async {
        capturedFunction({'status': 'ok', 'value': true});

        verify(() => testCallback.invoke(any())).called(1);
      });
    });
    group('startNotifications', () {
      test('callback should not be called on error', () {
        final testCallback = MockFunction<void, ScanResult>();
        platform.requestLEScan(RequestBleDeviceParams(), testCallback.invoke);
        final capturedFunction =
            verify(() => mockStream.listen(captureAny())).captured.single;

        capturedFunction({'status': 'error'});

        verifyNever(() => testCallback.invoke(any()));
      });
    });
    group("requestLEScan", () {
      test('callback should not be called on error', () {
        final testCallback = MockFunction<void, ScanResult>();
        platform.requestLEScan(RequestBleDeviceParams(), testCallback.invoke);
        final capturedFunction =
            verify(() => mockStream.listen(captureAny())).captured.single;

        capturedFunction({'status': 'error'});

        verifyNever(() => testCallback.invoke(any()));
      });

      test(
          'callback should be called and ScanResult should contain correct data',
          () {
        ScanResult callbackResults =
            ScanResult(device: BleDevice(deviceId: 'id'));
        final event = {
          'device': {
            'deviceId': 'deviceId',
            'name': 'name',
            'uuids': 'uuid1:uuid2:uuid3',
          },
          'localName': 'localName',
          'rssi': 24,
          'txPower': 42,
          'uuids': 'uuid1:uuid2:uuid3',
          'manufacturerData': {'mfdata': 'string'},
          'rawAdvertisement': 'rawDataString'
        };
        testCallback(ScanResult result) => callbackResults = result;
        platform.requestLEScan(RequestBleDeviceParams(), testCallback);
        final capturedFunction =
            verify(() => mockStream.listen(captureAny())).captured.single;

        capturedFunction(event);

        final expectedResult = ScanResult(
            device: BleDevice(
                deviceId: 'deviceId',
                name: 'name',
                uuids: 'uuid1:uuid2:uuid3'.split(':')),
            localName: 'localName',
            rssi: 24,
            txPower: 42,
            manufacturerData: {'mfdata': 'string'},
            uuids: ['uuid1', 'uuid2', 'uuid3'],
            rawAdvertisement: 'rawDataString');

        expect(expectedResult, callbackResults);
      });
    });
    test('isEnabled', () async {
      bool handlerCalled = false;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        if (methodCall.method == 'isEnabled') {
          handlerCalled = true;
        }
        return null;
      });

      await platform.isEnabled();

      expect(handlerCalled, true);
    });
    test('isLocationEnabled', () async {
      bool handlerCalled = false;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        if (methodCall.method == 'isLocationEnabled') {
          handlerCalled = true;
        }
        return null;
      });

      await platform.isLocationEnabled();

      expect(handlerCalled, true);
    });
    test('stopEnabledNotifications', () async {
      bool handlerCalled = false;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        if (methodCall.method == 'stopEnabledNotifications') {
          handlerCalled = true;
        }
        return null;
      });

      await platform.stopEnabledNotifications();

      expect(handlerCalled, true);
    });
    test('openLocationSettings', () async {
      bool handlerCalled = false;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        if (methodCall.method == 'openLocationSettings') {
          handlerCalled = true;
        }
        return null;
      });

      await platform.openLocationSettings();

      expect(handlerCalled, true);
    });
    test('openBluetoothSettings', () async {
      bool handlerCalled = false;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        if (methodCall.method == 'openBluetoothSettings') {
          handlerCalled = true;
        }
        return null;
      });

      await platform.openBluetoothSettings();

      expect(handlerCalled, true);
    });
    test('openAppSettings', () async {
      bool handlerCalled = false;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        if (methodCall.method == 'openAppSettings') {
          handlerCalled = true;
        }
        return null;
      });

      await platform.openAppSettings();

      expect(handlerCalled, true);
    });
    test('stopLEScan', () async {
      bool handlerCalled = false;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        if (methodCall.method == 'stopLEScan') {
          handlerCalled = true;
        }
        return null;
      });

      await platform.stopLEScan();

      expect(handlerCalled, true);
    });
    test('initialize', () async {
      bool handlerCalled = false;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        if (methodCall.method == 'initialize') {
          handlerCalled = true;
        }
        return null;
      });

      await platform.initialize(false);

      expect(handlerCalled, true);
    });
    test('disconnect', () async {
      bool handlerCalled = false;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        if (methodCall.method == 'disconnect') {
          handlerCalled = true;
        }
        return null;
      });

      await platform.disconnect('deviceId');

      expect(handlerCalled, true);
    });
    test('write', () async {
      bool handlerCalled = false;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        if (methodCall.method == 'write') {
          handlerCalled = true;
        }
        return null;
      });

      await platform.write('deviceId', 'service', 'characteristic', 'value', 0);

      expect(handlerCalled, true);
    });

    test('stopNotifications', () async {
      bool handlerCalled = false;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        if (methodCall.method == 'stopNotifications') {
          handlerCalled = true;
        }
        return null;
      });

      await platform.stopNotifications(
          'deviceId', 'service', 'characteristic', 0);

      expect(handlerCalled, true);
    });
  });
}
