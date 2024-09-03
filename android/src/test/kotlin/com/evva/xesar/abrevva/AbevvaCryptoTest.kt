package com.evva.xesar.abrevva

import com.evva.xesar.abrevva.crypto.AesCCM
import com.evva.xesar.abrevva.crypto.AesGCM
import com.evva.xesar.abrevva.crypto.HKDF
import com.evva.xesar.abrevva.crypto.SimpleSecureRandom
import com.evva.xesar.abrevva.crypto.X25519Wrapper
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.mockk.MockKAnnotations
import io.mockk.every
import io.mockk.impl.annotations.MockK
import io.mockk.mockk
import io.mockk.mockkObject
import io.mockk.mockkStatic
import io.mockk.slot
import io.mockk.spyk
import io.mockk.unmockkAll
import io.mockk.verify
import org.bouncycastle.util.encoders.Hex
import org.junit.jupiter.api.AfterEach
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.TestInstance
import org.junit.jupiter.params.ParameterizedTest
import org.junit.jupiter.params.provider.CsvSource
import org.junit.jupiter.params.provider.MethodSource
import java.io.IOException
import java.util.stream.Stream
import org.junit.jupiter.params.provider.Arguments as JunitArguments

class AbevvaCryptoTest {

    private lateinit var abrevvaCrypto: AbrevvaCrypto

    @MockK(relaxed = true)
    private lateinit var resultMock: MethodChannel.Result

    @MockK(relaxed = true)
    private lateinit var callMock: MethodCall

    @BeforeEach
    fun beforeEach() {
        MockKAnnotations.init(this)
        mockkObject(AesCCM)
        mockkObject(AesGCM)
        mockkObject(X25519Wrapper)
        mockkObject(SimpleSecureRandom)
        mockkObject(HKDF)
        mockkStatic(Hex::class)
        every { Hex.decode(any<String>()) } returns byteArrayOf(1)
        every { callMock.argument<String>(any()) } returns "string"
        every { callMock.argument<Int>("tagLength") } returns 0
        abrevvaCrypto = AbrevvaCrypto()
    }

    @AfterEach
    fun afterEach() {
        unmockkAll()
    }

    @Nested
    @DisplayName("encrypt()")
    inner class EncryptTests {
        @Test
        fun `should reject if ct is empty`() {


            every { Hex.decode(any<String>()) } returns byteArrayOf()
            every { AesCCM.encrypt(any(), any(), any(), any(), any()) } returns ByteArray(0)

            abrevvaCrypto.encrypt(callMock, resultMock)

            verify { resultMock.error(any(), any(), any()) }
        }

        @Test
        fun `should resolve if ct is not empty`() {
            every { AesCCM.encrypt(any(), any(), any(), any(), any()) } returns ByteArray(10)

            abrevvaCrypto.encrypt(callMock, resultMock)

            verify { resultMock.success(any()) }
        }
    }

    @Nested
    @DisplayName("decrypt()")
    inner class DecryptTests {
        @Test
        fun `should reject if pt is empty`() {
            every { AesCCM.decrypt(any(), any(), any(), any(), any()) } returns ByteArray(0)

            abrevvaCrypto.decrypt(callMock, resultMock)

            verify { resultMock.error(any(), any(), any()) }
        }

        @Test
        fun `should resolve if pt is not empty`() {
            every { AesCCM.decrypt(any(), any(), any(), any(), any()) } returns ByteArray(10)

            abrevvaCrypto.decrypt(callMock, resultMock)

            verify { resultMock.success(any()) }
        }
    }

    @Nested
    @DisplayName("generateKeyPair()")
    inner class GenerateKeyPairTests {
        @Test
        fun `should resolve if keys where generated successfully`() {
            every { X25519Wrapper.generateKeyPair() } returns mockk<X25519Wrapper.KeyPair>(relaxed = true)

            abrevvaCrypto.generateKeyPair(resultMock)

            verify { resultMock.success(any()) }
        }

        @Test
        fun `should reject if keys cannot be generated`() {
            every { X25519Wrapper.generateKeyPair() } throws Exception("generateKeyPair() Fail Exception")

            abrevvaCrypto.generateKeyPair(resultMock)

            verify { resultMock.error(any(), any(), any()) }
        }
    }

    @Nested
    @DisplayName("encryptFile()")
    @TestInstance(TestInstance.Lifecycle.PER_CLASS)
    inner class EncryptFileTests {
        @ParameterizedTest(name = "encryptFile({0}, {1}, {2}) should reject")
        @MethodSource("parameterizedArgs_encrypt")
        fun `encryptFile() should reject if any Param is missing`(
            ctPath: String?,
            ptPath: String?,
            sharedSecret: String?
        ) {
            every { callMock.argument<String>("ctPath") } returns ctPath
            every { callMock.argument<String>("ptPath") } returns ptPath
            every { callMock.argument<String>("sharedSecret") } returns sharedSecret
            abrevvaCrypto.encryptFile(callMock, resultMock)

            verify { resultMock.error(any(), any(), any()) }
        }

        fun parameterizedArgs_encrypt(): Stream<JunitArguments> {
            return Stream.of(
                JunitArguments.of("", "ptPath", "sharedSecret"),
                JunitArguments.of("ctPath", "", "sharedSecret"),
                JunitArguments.of("ctPath", "sharedSecret", ""),
                JunitArguments.of(null, "ptPath", "sharedSecret"),
                JunitArguments.of("ctPath", null, "sharedSecret"),
                JunitArguments.of("ctPath", "ptPath", null),
            )
        }

        @Test
        fun `should resolve if args are valid and file could be encrypted`() {
            every { AesGCM.encryptFile(any(), any(), any()) } returns true

            abrevvaCrypto.encryptFile(callMock, resultMock)

            verify { resultMock.success(any()) }
        }

        @Test
        fun `should reject if args are valid but encryption fails`() {
            every {
                AesGCM.encryptFile(
                    any(),
                    any(),
                    any()
                )
            } throws Exception("encryptFile() Fail Exception")

            abrevvaCrypto.encryptFile(callMock, resultMock)

            verify { resultMock.error(any(), any(), any()) }
        }
    }

    @Nested
    @DisplayName("decryptFile()")
    @TestInstance(TestInstance.Lifecycle.PER_CLASS)
    inner class DecryptFileTests {
        @ParameterizedTest(name = "empty args should be rejected")
        @MethodSource("parameterizedArgs_decrypt")
        fun `should reject if any Param is empty`(
            ctPath: String?,
            ptPath: String?,
            sharedSecret: String?
        ) {
            every { callMock.argument<String>("ctPath") } returns ctPath
            every { callMock.argument<String>("ptPath") } returns ptPath
            every { callMock.argument<String>("sharedSecret") } returns sharedSecret

            abrevvaCrypto.decryptFile(callMock, resultMock)

            verify { resultMock.error(any(), any(), any()) }
        }

        fun parameterizedArgs_decrypt(): Stream<JunitArguments> {
            return Stream.of(
                JunitArguments.of("", "ptPath", "sharedSecret"),
                JunitArguments.of("ctPath", "", "sharedSecret"),
                JunitArguments.of("ctPath", "ptPath", ""),
                JunitArguments.of(null, "ptPath", "sharedSecret"),
                JunitArguments.of("ctPath", null, "sharedSecret"),
                JunitArguments.of("ctPath", "ptPath", null),
            )
        }

        @Test
        fun `should resolve if args are valid and file could be encrypted`() {
            every { AesGCM.decryptFile(any(), any(), any()) } returns true

            abrevvaCrypto.decryptFile(callMock, resultMock)

            verify { resultMock.success(any()) }
        }

        @Test
        fun `should reject if encryption fails`() {
            every {
                AesGCM.decryptFile(
                    any(),
                    any(),
                    any()
                )
            } throws Exception("encryptFile() Fail Exception")

            abrevvaCrypto.decryptFile(callMock, resultMock)

            verify { resultMock.error(any(), any(), any()) }
        }
    }

    @Nested
    @DisplayName("decryptFileFromURL()")
    inner class DecryptFileFromURLTests {

        @Nested
        @DisplayName("should reject if any Param is empty")
        @TestInstance(TestInstance.Lifecycle.PER_CLASS)
        inner class DecryptFileFromURL_ParameterizedTest {
            @ParameterizedTest
            @MethodSource("parameterizedArgs_decryptFileFromURL")
            fun `should reject if any Param is empty`(
                sharedSecret: String?,
                url: String?,
                ptPath: String?
            ) {
                every { callMock.argument<String>("sharedSecret") } returns sharedSecret
                every { callMock.argument<String>("url") } returns url
                every { callMock.argument<String>("ptPath") } returns ptPath

                abrevvaCrypto.decryptFileFromURL(callMock, resultMock)

                verify { resultMock.error(any(), any(), any()) }
            }

            fun parameterizedArgs_decryptFileFromURL(): Stream<JunitArguments> {
                return Stream.of(
                    JunitArguments.of("", "url", "ptPath"),
                    JunitArguments.of("sharedSecret", "", "ptPath"),
                    JunitArguments.of("sharedSecret", "url", ""),
                    JunitArguments.of(null, "url", "ptPath"),
                    JunitArguments.of("sharedSecret", null, "ptPath"),
                    JunitArguments.of("sharedSecret", "url", null),
                )
            }
        }

        @Test
        fun `decryptFileFromURL() should reject if ctPath-File is not accessible`() {
            val moduleSpy =
                spyk(AbrevvaCrypto())
            every {
                moduleSpy.writeToFile(
                    any(),
                    any()
                )
            } throws IOException("decryptFileFromURL() Fail Exception")

            moduleSpy.decryptFileFromURL(callMock, resultMock)

            verify { resultMock.error(any(), any(), any()) }
        }

        @Test
        fun `decryptFileFromURL() should reject if decode fails`() {
            val moduleSpy =
                spyk(AbrevvaCrypto())
            every { moduleSpy.writeToFile(any(), any()) } returns Unit
            every { Hex.decode(any<String>()) } throws Exception("decryptFileFromURL() Fail Exception")

            moduleSpy.decryptFileFromURL(callMock, resultMock)

            verify { resultMock.error(any(), any(), any()) }
        }

        @Test
        fun `decryptFileFromURL() should resolve if everything works as intended`() {
            val moduleSpy =
                spyk(AbrevvaCrypto())
            every { moduleSpy.writeToFile(any(), any()) } returns Unit
            every { AesGCM.decryptFile(any(), any(), any()) } returns true

            moduleSpy.decryptFileFromURL(callMock, resultMock)

            verify { resultMock.success(any()) }
        }
    }

    @Nested
    @DisplayName("random()")
    inner class RandomTests {
        @ParameterizedTest(name = "random(numBytes: {0}) resolved String size should be {1}")
        @CsvSource("2,4", "4,8", "7,14")
        fun `should return random bytes n number of bytes if successful`(
            numBytes: Int,
            expectedStrLen: Int
        ) {
            val resultSlot = slot<Map<String, String>>()
            every { callMock.argument<Int>("numBytes") } returns numBytes
            every { resultMock.success(capture(resultSlot)) } returns Unit

            abrevvaCrypto.random(callMock, resultMock)


            assert(resultSlot.captured["value"]!!.length == expectedStrLen)
        }

        @Test
        fun `should reject if bytes cannot be generated`() {
            every { SimpleSecureRandom.getSecureRandomBytes(any()) } returns ByteArray(0)
            every { callMock.argument<Int>("numBytes") } returns 10

            abrevvaCrypto.random(callMock, resultMock)

            verify { resultMock.error(any(), any(), any()) }
        }
    }

    @Nested
    @DisplayName("derive()")
    inner class DeriveTests {

        @Test
        fun `should resolve if successful`() {
            every { callMock.argument<Int>("length") } returns 0
            every { HKDF.derive(any(), any(), any(), any()) } returns ByteArray(0)

            abrevvaCrypto.derive(callMock, resultMock)

            verify { resultMock.error(any(), any(), any()) }
        }

        @Test
        fun `should reject if unsuccessful`() {
            every { callMock.argument<Int>("length") } returns 10
            every { HKDF.derive(any(), any(), any(), any()) } returns ByteArray(10)
            abrevvaCrypto.derive(callMock, resultMock)

            verify { resultMock.success(any()) }
        }
    }
}