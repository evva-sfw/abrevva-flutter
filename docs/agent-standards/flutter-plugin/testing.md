# Flutter plugin: testing

Applies to Flutter plugins. Adds plugin-specific test rules on top of `swift/testing.md`, `kotlin/testing.md` and `dart/testing.md`.

## What to cover
- **Services and domain on each side:** ordinary unit tests in that language. This is where most tests belong.
- **Dart channel layer:** one test per method that checks the method name and arguments against the contract constants, and one test per error code that checks the mapping to the plugin's exception type.
- **Dart public API:** tests against a fake platform instance, not the real channel.
- **Kotlin and Swift entry classes:** one test per method that checks the call is decoded, delegated to the service, and replied to exactly once. Also test the `unsupported` and not-implemented paths.
- A channel contract change updates the channel tests on all three sides in the same change.

## Dart channel layer
Use the test binary messenger to stand in for the native side. Reset the handler in `tearDown`.

```dart
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel(ChannelContract.channel);
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  late List<MethodCall> calls;
  late MethodChannelBle platform;

  setUp(() {
    calls = [];
    platform = MethodChannelBle();
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return true;
    });
  });

  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  test('connect sends the device id under the contract key', () async {
    await platform.connect('A1');

    expect(calls.single.method, ChannelContract.connect);
    expect(calls.single.arguments, {ChannelContract.argDeviceId: 'A1'});
  });

  test('maps not_connected to BleNotConnectedException', () async {
    messenger.setMockMethodCallHandler(
      channel,
      (_) async => throw PlatformException(code: ChannelContract.errorNotConnected),
    );

    await expectLater(
      platform.connect('A1'),
      throwsA(isA<BleNotConnectedException>()),
    );
  });
}
```

## Dart public API
Replace the platform instance with a fake. `MockPlatformInterfaceMixin` lets the fake pass the platform interface's token check.

```dart
class FakeBlePlatform with MockPlatformInterfaceMixin implements BlePlatform {
  final connectedIds = <String>[];

  @override
  Future<bool> connect(String deviceId) async {
    connectedIds.add(deviceId);
    return true;
  }
}

void main() {
  late FakeBlePlatform fakePlatform;

  setUp(() {
    fakePlatform = FakeBlePlatform();
    BlePlatform.instance = fakePlatform;
  });

  test('connect forwards to the platform', () async {
    await Ble().connect(BleDevice(id: 'A1'));

    expect(fakePlatform.connectedIds, ['A1']);
  });
}
```

## Kotlin entry class
- Call `onMethodCall` with a `MethodCall(ChannelContract.CONNECT, mapOf(ChannelContract.ARG_DEVICE_ID to "A1"))` and a mocked `MethodChannel.Result`.
- Inject the services into the entry class (or a handler it delegates to) so tests can replace them. Don't construct the entry class through `onAttachedToEngine` in unit tests.
- Verify exactly one of `success`, `error` or `notImplemented` was called, with the expected value or contract error code.

## Swift entry class
- Call `handle(_:result:)` with a `FlutterMethodCall(methodName:arguments:)` built from `ChannelContract`, and a result closure that records what it received.
- Inject the services so tests can replace them with `swift-mocking` mocks or actor-isolated fakes.
- Use `confirmation(expectedCount: 1)` to check that the result closure was called exactly once, and check the value or the `FlutterError` code.
- Entry-class tests are `@MainActor`, like the entry class.
