# Swift testing

Applies to all Swift tests. Read together with `general/testing.md`. Where the two differ, this file wins.

## Stack
- **Framework:** Swift Testing (`import Testing`, `@Suite`, `@Test`, `#expect`, `#require`). Write new tests with Swift Testing, not XCTest, and never mix XCTest assertions into Swift Testing tests.
- **Mocks:** [`swift-mocking`](https://github.com/fetch-rewards/swift-mocking) (`import Mocking`, `@Mocked`).
- Use the patterns already established in the project. Prefer generated protocol mocks where they are concurrency-safe, and the established actor-isolated fakes for platform APIs and other non-`Sendable` boundaries.

## Structure
- One `struct` suite per type or feature under test, marked `@Suite("<TypeName>")` or `@Suite("<TypeName>.<method>")`.
- Swift Testing creates a new suite instance for every test, so set up dependencies in stored properties or `init`. No `static var` state.
- Give every test a display name that describes the behavior: `@Test("throws notConnected when the transport fails")`.
- Use `#require` for preconditions that make the rest of the test meaningless (unwrapping, required setup). Use `#expect` for the actual assertions.
- Cover boundary values with parameterized tests (`@Test(arguments:)`) instead of copy-pasted tests.
- Check errors with `#expect(throws:)`. Use the specific error value or type, never only "throws something".

## Mocks with swift-mocking
- `@Mocked` on a protocol generates `<Protocol>Mock`. Use the `compilationCondition` the project already uses for its mocks.
- Stub through the generated `_method` property: `.returns(...)`, `.throws(...)`, `.invokes { ... }`.
- Verify interactions with `callCount`, `lastInvocation` and `invocations`.
- Prefer the checked constructors (`returns`, `invokes`). Use the `unchecked` variants only for non-`Sendable` types, and only where no actor-isolated fake exists for that boundary.

```swift
@Mocked(compilationCondition: .debug)
protocol BleTransport: Sendable {
    func connect(deviceId: String, timeout: Duration) async throws -> Bool
}
```

## Actor-isolated fakes
Use a small `actor` fake for platform APIs (CoreBluetooth, CoreLocation, `UserDefaults` wrappers) and other non-`Sendable` boundaries. It records calls and returns configurable values, and it is safe under strict concurrency.

```swift
protocol CentralManaging: Sendable {
    func state() async -> CentralState
    func scan(forServices serviceUuids: [String]) async
}

/// Records central manager calls without touching CoreBluetooth.
actor FakeCentralManager: CentralManaging {
    private(set) var scannedServices: [[String]] = []
    private var reportedState: CentralState = .poweredOn

    func setState(_ state: CentralState) { reportedState = state }
    func state() -> CentralState { reportedState }
    func scan(forServices serviceUuids: [String]) { scannedServices.append(serviceUuids) }
}
```

## Concurrency
- Tests compile under Swift 6 strict concurrency with no new warnings.
- Mark a test or suite `@MainActor` when the type under test is `@MainActor`.
- Wait for callbacks and events with `confirmation(expectedCount:)`, never with `Task.sleep`.
- Inject a clock instead of using `Date()`, `ContinuousClock` or real timeouts, so timeout paths run instantly.
- Swift Testing runs tests in parallel. Use `.serialized` only with a comment explaining why.

## Example

```swift
import Testing
@testable import BleKit

@Suite("ConnectionService.connect")
struct ConnectionServiceConnectTests {
    private let transport = BleTransportMock()

    @Test("returns true when the device answers")
    func connectSucceeds() async throws {
        transport._connect.implementation = .returns(true)
        let service = ConnectionService(transport: transport)

        let connected = try await service.connect(deviceId: "A1", timeout: .seconds(5))

        #expect(connected)
        #expect(transport._connect.callCount == 1)
        #expect(transport._connect.lastInvocation?.deviceId == "A1")
    }

    @Test("throws notConnected when the transport fails")
    func connectFails() async {
        transport._connect.implementation = .throws(BleError.notConnected)
        let service = ConnectionService(transport: transport)

        await #expect(throws: BleError.notConnected) {
            try await service.connect(deviceId: "A1", timeout: .seconds(5))
        }
    }

    @Test("rejects non-positive timeouts", arguments: [Duration.zero, .seconds(-1)])
    func rejectsInvalidTimeout(timeout: Duration) async {
        let service = ConnectionService(transport: transport)

        await #expect(throws: BleError.invalidTimeout) {
            try await service.connect(deviceId: "A1", timeout: timeout)
        }
        #expect(transport._connect.callCount == 0)
    }

    @Test("scans only for the requested service")
    func scansRequestedService() async {
        let central = FakeCentralManager()
        let scanner = Scanner(central: central)

        await scanner.start(serviceUuid: "180D")

        #expect(await central.scannedServices == [["180D"]])
    }
}
```

## Running
- Run the tests covering your change with the command in the project's `AGENTS.md` (e.g. `swift test --filter ConnectionServiceConnectTests`, or `xcodebuild test … -only-testing:<Target>/<Suite>`).
