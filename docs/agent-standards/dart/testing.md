# Dart testing

Applies to all Dart tests. Read together with `general/testing.md`. Where the two differ, this file wins.

## Stack
Use what the package already uses. If it has no test setup yet, ask before adding one; the default to propose is:
- **Framework:** `flutter_test` for anything that touches Flutter bindings (platform channels, widgets); `package:test` for pure Dart packages.
- **Mocks:** `mocktail` (no code generation). If the project already uses `mockito` with generated mocks, keep using it.
- **Time:** `fake_async`, or an injected clock.

Prefer mocks for your own abstract interfaces and small hand-written fakes (`implements`) for platform boundaries and stateful dependencies.

## Structure
- Test files mirror `lib/`: `lib/src/connection/connection_service.dart` → `test/src/connection/connection_service_test.dart`.
- One `group` per class or method. Name tests after the behavior: `test('throws BleNotConnectedException when the transport fails', …)`.
- Create the unit under test and its doubles in `setUp`, as `late` locals of `main()`. Each test gets fresh instances. No top-level mutable state shared across files.
- Register fallback values for non-primitive argument types used with mocktail's `any()` in `setUpAll` (`registerFallbackValue(Duration.zero)`).
- Check errors with `throwsA(isA<SpecificException>())`. Use the specific type, never `throwsException`.
- Cover boundary values by looping over a small table inside a `group` and generating one `test` per case.

## Mocks and fakes
- Mock your own interfaces with mocktail: `class MockBleTransport extends Mock implements BleTransport {}`.
  - Stub async methods with `thenAnswer((_) async => value)`; stub async failures with `thenAnswer((_) async => throw error)`, not `thenThrow`.
  - Verify with `verify(() => …).called(n)` and `verifyNever(() => …)`.
- Fake platform boundaries by hand when they have state: `class FakeBleScanner implements BleScanner { … }`.

## Async and time
- `await` every future in a test. Test streams with `expectLater(stream, emitsInOrder([...]))` and `emitsError(isA<…>())`.
- Never wait with `Future.delayed`. Use `fakeAsync((async) { …; async.elapse(…); })` or an injected clock to drive timeouts.
- Cancel subscriptions and close controllers you create in tests, in `tearDown` if needed.

## Example

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockBleTransport extends Mock implements BleTransport {}

void main() {
  late MockBleTransport transport;
  late ConnectionService service;

  setUpAll(() => registerFallbackValue(Duration.zero));

  setUp(() {
    transport = MockBleTransport();
    service = ConnectionService(transport: transport);
  });

  group('ConnectionService.connect', () {
    test('returns true when the device answers', () async {
      when(() => transport.connect('A1', timeout: any(named: 'timeout')))
          .thenAnswer((_) async => true);

      final connected =
          await service.connect('A1', timeout: const Duration(seconds: 5));

      expect(connected, isTrue);
      verify(() => transport.connect('A1', timeout: any(named: 'timeout')))
          .called(1);
    });

    test('throws BleNotConnectedException when the transport fails', () async {
      when(() => transport.connect(any(), timeout: any(named: 'timeout')))
          .thenAnswer((_) async => throw const BleNotConnectedException());

      await expectLater(
        service.connect('A1', timeout: const Duration(seconds: 5)),
        throwsA(isA<BleNotConnectedException>()),
      );
    });

    for (final timeout in [Duration.zero, const Duration(seconds: -1)]) {
      test('rejects timeout $timeout without calling the transport', () async {
        await expectLater(
          service.connect('A1', timeout: timeout),
          throwsA(isA<BleInvalidTimeoutException>()),
        );
        verifyNever(
          () => transport.connect(any(), timeout: any(named: 'timeout')),
        );
      });
    }
  });
}
```

## Running
- Run the tests covering your change with the command in the project's `AGENTS.md` (e.g. `flutter test test/src/connection/connection_service_test.dart`).
