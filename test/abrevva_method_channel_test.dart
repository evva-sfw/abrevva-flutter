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

class MockFuture<T> extends Mock implements Future<T> {}

class MockStream<T> extends Mock implements Stream<T> {}

class MockStreamSubscription<T> extends Mock implements StreamSubscription<T> {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
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
        return {"value": "abcde"};
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
        return {
          'privateKey': 'privateKey',
          'publicKey': 'publicKey'
        };
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
        return {
          'cipherText': 'cipherText',
          'authTag': 'authTag'
        };
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
        return {
          'plainText': 'plainText',
          'authOk': 'authOk'
        };
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
        return {
          'opOk': true
        };
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
        return {
          'sharedSecret': 'sharedSecret'
        };
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
        return {
          'opOk': true
        };
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
        return {
          'opOk': true
        };
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
        return {
          'opOk': true
        };
      });

      await platform.decryptFile('sharedSecret', 'ctPath', 'ptPath');

      expect(handlerCalled, true);
    });
    test('derive', () async {
      bool handlerCalled = false;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        if (methodCall.method == 'derive') {
          handlerCalled = true;
        }
        return {
          'value': 'value'
        };
      });

      await platform.derive('key', 'salt', 'info', 0);

      expect(handlerCalled, true);
    });
  });
  group('AbrevvaBle Tests', () {
    MethodChannelAbrevvaBlePlatform platform =
        MethodChannelAbrevvaBlePlatform();
    const MethodChannel channel = MethodChannel('AbrevvaBle');
    late var mockEventChannel = MockEventChannel();
    late var mockStream = MockStream<dynamic>();
    late var mockStreamSubscription = MockStreamSubscription();
    late MockFunction<void, bool> testCallback;
    dynamic capturedFunction;

    void simulateNativeMethodCall(String functionName, dynamic output){
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          return methodCall.method == functionName ? output : null;
        }
      );
    }

    setUp(() {
      platform = MethodChannelAbrevvaBlePlatform();
      platform.methodChannel = channel;
      registerFallbackValue(BleDevice(deviceId: "deviceId"));
      platform.startEnabledNotificationsEventChannel = mockEventChannel;
      platform.connectEventChannel = mockEventChannel;
      platform.startNotificationsEventChannel = mockEventChannel;
      platform.startScanEventChannel = mockEventChannel;
      when(() => mockEventChannel.receiveBroadcastStream(any()))
          .thenAnswer((_) => mockStream);
      mockStreamSubscription = MockStreamSubscription();
      when(() => mockStream.listen(captureAny()))
          .thenReturn(mockStreamSubscription);
      testCallback = MockFunction<void, bool>();

    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
      capturedFunction = null;
    });
        
    group("startEnabledNotifications", () {
      test('should not call callback on error', () async {
        simulateNativeMethodCall('startEnabledNotifications', null);

        try {
          platform.startEnabledNotifications(testCallback.invoke);
          fail("startEnabledNotifications(): should have thrown");
        // ignore: empty_catches
        } catch (e) {}
        verifyNever(() => testCallback.invoke(any()));
   
      });

      test('should call callback if no error occurred', () async {
        simulateNativeMethodCall('startEnabledNotifications', {
          'value': true
        });

        await platform.startEnabledNotifications(testCallback.invoke);
        capturedFunction =
              verify(() => mockStream.listen(captureAny())).captured.last;
          capturedFunction({
          'value': true
        });

        verify(() => testCallback.invoke(any())).called(1);
      });
    });
    group('startNotifications', () {
      test('callback should not be called on error', () {
        final testCallback = MockFunction<void, String>();
        simulateNativeMethodCall('startNotifications', {
          'value': true
        });
        
        platform.startNotifications('deviceId', 'service', 'char', 1000, testCallback.invoke);
        final capturedFunction =
            verify(() => mockStream.listen(captureAny())).captured.single;
        when(() => mockStreamSubscription.cancel()).thenAnswer((_) => MockFuture());
        capturedFunction({'status': 'error'});

        verifyNever(() => testCallback.invoke(any()));
      });
    });
    group("startScan", () {
      test('callback should not be called on error', () async {
        simulateNativeMethodCall('startScan', {});
        final onScanResultCallback = MockFunction<void, BleDevice>();
        await platform.startScan(onScanResult: onScanResultCallback.invoke);
        final capturedFunction =
            verify(() => mockStream.listen(captureAny())).captured.single;

        capturedFunction({'status': 'error'});

        verifyNever(() => onScanResultCallback.invoke(any()));
      });

      test(
          'callback should be called and ScanResult should contain correct data',
          () {
        simulateNativeMethodCall('startScan', {});
        BleDevice callbackResults =
            BleDevice(deviceId: "id");
        final event = {
          'event': 'onScanResult',
          'value': {
            'deviceId': 'deviceId',
            'name': 'name',
            'advertisementData': {
              'manufacturerData': {
                'companyIdentifier': 123,
                'isOnline': true,
                'identifier': 'identifierString'
              }
            }
          }
        };
        testCallback(BleDevice result) => callbackResults = result;
        platform.startScan(onScanResult: testCallback);
        final capturedFunction =
            verify(() => mockStream.listen(captureAny())).captured.last;

        capturedFunction(event);

        expect(callbackResults.deviceId, 'deviceId');
        expect(callbackResults.name, 'name');
        expect(callbackResults.advertisementData?.isOnline, true);
        expect(callbackResults.advertisementData?.companyIdentifier, 123);
        expect(callbackResults.advertisementData?.identifier, 'identifierString');
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
      when(() => mockStreamSubscription.cancel()).thenAnswer((_) => MockFuture());

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
    test('stopScan', () async {
      bool handlerCalled = false;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        if (methodCall.method == 'stopScan') {
          handlerCalled = true;
        }
        return null;
      });

      await platform.stopScan();

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
      simulateNativeMethodCall('disconnect', true);

      final result = await platform.disconnect('deviceId');

      expect(result, true);
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
      simulateNativeMethodCall('stopNotifications', {'value': true});
      when(() => mockStreamSubscription.cancel()).thenAnswer((_) => MockFuture());

      final result = await platform.stopNotifications(
          'deviceId', 'service', 'characteristic', 0);

      expect(result, true);
    });
  });
}
