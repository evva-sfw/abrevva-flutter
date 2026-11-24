# Kotlin testing

Applies to all Kotlin tests. Read together with `general/testing.md`. Where the two differ, this file wins.

## Stack
Use what the module already uses. If it has no test setup yet, ask before adding one; the default to propose is:
- **Framework:** JUnit (JUnit 4 for Android modules unless JUnit 5 is already configured) with `kotlin.test` assertions.
- **Mocks:** MockK (`mockk`, `coEvery`, `coVerify`).
- **Coroutines:** `kotlinx-coroutines-test` (`runTest`, `StandardTestDispatcher`).

Prefer generated mocks for your own interfaces and small hand-written fakes for Android framework APIs and other stateful platform boundaries.

## Structure
- Local unit tests go in `src/test/`. Use instrumented tests (`src/androidTest/`) only when the behavior needs a real device. Prefer moving logic out of framework classes so local tests can cover it.
- One test class per class or feature under test: `ConnectionServiceTest`.
- Name tests after the behavior with backticks: ``fun `connect throws NotConnected when the transport fails`()``.
- Create the unit under test and its doubles in fields or a `@Before` method. Each test gets fresh instances, so don't use `companion object` state.
- Check errors with `assertFailsWith<SpecificException> { … }`. Use the specific type, never `Exception`.
- Cover boundary values with JUnit 5 `@ParameterizedTest` if available. Otherwise, loop over a small table in one test and put the case in the assertion message.

## Mocks and fakes
- Mock your own interfaces with MockK: stub with `every`/`coEvery`, verify with `verify`/`coVerify(exactly = n)`.
- Don't mock Android framework types (`BluetoothGatt`, `Context`, `SharedPreferences`) or classes you don't own. Wrap them behind an interface in production code and fake that interface in tests.
- Don't use `relaxed = true` mocks for dependencies whose return values matter to the test.

```kotlin
/** Records scan calls instead of touching the Android Bluetooth stack. */
internal class FakeBleScanner : BleScanner {
    val scannedServices = mutableListOf<List<String>>()
    var adapterEnabled = true

    override fun isAdapterEnabled(): Boolean = adapterEnabled
    override suspend fun scan(serviceUuids: List<String>) { scannedServices += serviceUuids }
}
```

## Coroutines and time
- Run every test of suspending code inside `runTest`.
- Inject a `TestDispatcher` into the class under test. Use the same dispatcher (or its scheduler) for `runTest`, so virtual time controls everything.
- Use `advanceUntilIdle()`/`advanceTimeBy()` instead of real delays. Never `Thread.sleep` or `runBlocking` in tests.
- Only if code uses `Dispatchers.Main` directly: `Dispatchers.setMain(dispatcher)` in `@Before` and `Dispatchers.resetMain()` in `@After`. Prefer injecting the dispatcher.
- Collect flows with `first()`, `take(n).toList()`, or a collector launched in `backgroundScope`. Use Turbine only if the project already uses it.

## Example

```kotlin
class ConnectionServiceTest {
    private val dispatcher = StandardTestDispatcher()
    private val transport = mockk<BleTransport>()
    private val service = ConnectionService(transport, dispatcher)

    @Test
    fun `connect returns true when the device answers`() = runTest(dispatcher) {
        coEvery { transport.connect("A1", 5_000) } returns true

        val connected = service.connect("A1", timeoutMs = 5_000)

        assertTrue(connected)
        coVerify(exactly = 1) { transport.connect("A1", 5_000) }
    }

    @Test
    fun `connect throws NotConnected when the transport fails`() = runTest(dispatcher) {
        coEvery { transport.connect(any(), any()) } throws BleException.NotConnected()

        assertFailsWith<BleException.NotConnected> {
            service.connect("A1", timeoutMs = 5_000)
        }
    }

    @Test
    fun `connect rejects non-positive timeouts without calling the transport`() = runTest(dispatcher) {
        for (timeoutMs in listOf(0L, -1L)) {
            assertFailsWith<BleException.InvalidTimeout>("timeoutMs=$timeoutMs") {
                service.connect("A1", timeoutMs = timeoutMs)
            }
        }
        coVerify(exactly = 0) { transport.connect(any(), any()) }
    }

    @Test
    fun `scanner scans only for the requested service`() = runTest(dispatcher) {
        val bleScanner = FakeBleScanner()
        val scanner = Scanner(bleScanner, dispatcher)

        scanner.start(serviceUuid = "180D")
        advanceUntilIdle()

        assertEquals(listOf(listOf("180D")), bleScanner.scannedServices)
    }
}
```

## Running
- Run the tests covering your change with the command in the project's `AGENTS.md` (e.g. `./gradlew testDebugUnitTest --tests '*ConnectionServiceTest'`).
