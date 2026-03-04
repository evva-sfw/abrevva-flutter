package com.evva.xesar.abrevva

import com.evva.xesar.abrevva.crypto.AesCcm
import com.evva.xesar.abrevva.crypto.AesGcm
import com.evva.xesar.abrevva.crypto.HKDF
import com.evva.xesar.abrevva.crypto.SimpleSecureRandom
import com.evva.xesar.abrevva.crypto.X25519Wrapper
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import org.bouncycastle.util.encoders.Base64
import org.bouncycastle.util.encoders.Hex
import java.io.BufferedInputStream
import java.io.File
import java.io.FileOutputStream
import java.io.IOException
import java.net.HttpURLConnection
import java.net.URL
import java.nio.file.Paths
import kotlin.io.encoding.ExperimentalEncodingApi

private enum class CryptoError {
    EncryptCryptoError,
    EncryptEmptyResultError,
    EncryptInvalidArgumentError,
    EncryptFileCryptoError,
    EncryptFileInvalidArgumentError,
    DecryptInvalidArgumentError,
    DecryptEmptyResultError,
    DecryptCryptoError,
    DecryptFileCryptoError,
    DecryptFileInvalidArgumentError,
    DecryptFileFromURLNetworkError,
    DecryptFileFromURLNotFoundError,
    DecryptFileFromURLInaccessibleError,
    DecryptFileFromURLNoResponseDataError,
    DecryptFileFromURLInvalidArgumentError,
    DecryptFileFromURLCryptoError,
    GenerateKeypairError,
    ComputeSharedSecretError,
    ComputeSharedSecretInvalidArgumentError,
    ComputeED25519PublicKeyError,
    ComputeED25519PublicKeyInvalidArgumentError,
    SignCryptoError,
    SignInvalidArgumentError,
    VerifyCryptoError,
    VerifyFailedError,
    VerifyInvalidArgumentError,
    RandomError,
    DeriveInvalidArgumentError,
    DeriveEmptyResultError,
    DeriveCryptoError
}

class AbrevvaCrypto : MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "encrypt" -> encrypt(call, result)
            "decrypt" -> decrypt(call, result)
            "generateKeyPair" -> generateKeyPair(call, result)
            "computeSharedSecret" -> computeSharedSecret(call, result)
            "encryptFile" -> encryptFile(call, result)
            "decryptFile" -> decryptFile(call, result)
            "decryptFileFromURL" -> decryptFileFromURL(call, result)
            "random" -> random(call, result)
            "derive" -> derive(call, result)
            "computeED25519PublicKey" -> computeED25519PublicKey(call, result)
            "sign" -> sign(call, result)
            "verify" -> verify(call, result)
            else -> {
                result.notImplemented()
            }
        }
    }

    fun encrypt(call: MethodCall, result: Result) {
        val key: ByteArray
        val iv: ByteArray
        val adata: ByteArray
        val pt: ByteArray

        try {
            key = Hex.decode(call.argument<String>("key"))
            iv = Hex.decode(call.argument<String>("iv"))
            adata = Hex.decode(call.argument<String>("adata"))
            pt = Hex.decode(call.argument<String>("pt"))
        } catch (e: Exception) {
            return result.error(
                AbrevvaCrypto::class.java.simpleName,
                CryptoError.EncryptInvalidArgumentError.name,
                e.toString()
            )
        }

        val tagLength = call.argument<Int>("tagLength") ?: 0

        try {
            val ct: ByteArray = AesCcm.encrypt(key, iv, adata, pt, tagLength)
            val cipherTextData = ByteArray(pt.size)
            val authTagData = ByteArray(tagLength)

            System.arraycopy(ct, 0, cipherTextData, 0, pt.size)
            System.arraycopy(ct, pt.size, authTagData, 0, tagLength)

            if (ct.isEmpty()) {
                return result.error(
                    AbrevvaCrypto::class.java.simpleName,
                    CryptoError.EncryptEmptyResultError.name,
                    null
                )
            }
            val ret = mapOf(
                "cipherText" to Hex.toHexString(cipherTextData),
                "authTag" to Hex.toHexString(authTagData)
            )
            result.success(ret)
        } catch (e: Exception) {
            result.error(
                AbrevvaCrypto::class.java.simpleName,
                CryptoError.EncryptCryptoError.name,
                e.toString()
            )
        }
    }

    fun decrypt(call: MethodCall, result: Result) {
        val key: ByteArray
        val iv: ByteArray
        val adata: ByteArray
        val ct: ByteArray
        try {
            key = Hex.decode(call.argument<String>("key"))
            iv = Hex.decode(call.argument<String>("iv"))
            adata = Hex.decode(call.argument<String>("adata"))
            ct = Hex.decode(call.argument<String>("ct"))
        } catch (e: Exception) {
            return result.error(
                AbrevvaCrypto::class.java.simpleName,
                CryptoError.DecryptInvalidArgumentError.name,
                e.toString()
            )
        }

        val tagLength = call.argument<Int>("tagLength") ?: 0

        try {
            val data: ByteArray = AesCcm.decrypt(key, iv, adata, ct, tagLength)
            if (data.isEmpty()) {
                return result.error(
                    AbrevvaCrypto::class.java.simpleName,
                    CryptoError.DecryptEmptyResultError.name,
                    null
                )
            }
            val ret = mapOf(
                "plainText" to Hex.toHexString(data),
                "authOk" to true
            )
            result.success(ret)
        } catch (e: Exception) {
            result.error(
                AbrevvaCrypto::class.java.simpleName,
                CryptoError.DecryptCryptoError.name,
                e.toString()
            )
        }
    }

    @OptIn(ExperimentalEncodingApi::class)
    fun generateKeyPair(call: MethodCall, result: Result) {
        try {
            val keyPair: X25519Wrapper.KeyPair = X25519Wrapper.generateKeyPair()
            val ret = mapOf(
                "privateKey" to Base64.toBase64String(keyPair.privateKey),
                "publicKey" to Base64.toBase64String(keyPair.publicKey)
            )
            result.success(ret)
        } catch (e: Exception) {
            result.error(
                AbrevvaCrypto::class.java.name,
                CryptoError.GenerateKeypairError.name,
                e.toString()
            )
        }
    }

    @OptIn(ExperimentalEncodingApi::class)
    fun computeSharedSecret(call: MethodCall, result: Result) {
        val privateKey = call.argument<String>("privateKey")
        if (privateKey == null || privateKey == "") {
            return result.error(
                AbrevvaCrypto::class.java.simpleName,
                CryptoError.ComputeSharedSecretInvalidArgumentError.name,
                null
            )
        }

        val peerPublicKey = call.argument<String>("peerPublicKey")
        if (peerPublicKey == null || peerPublicKey == "") {
            return result.error(
                AbrevvaCrypto::class.java.simpleName,
                CryptoError.ComputeSharedSecretInvalidArgumentError.name,
                null
            )
        }

        try {
            val sharedSecret: ByteArray = X25519Wrapper.computeSharedSecret(
                Base64.decode(privateKey),
                Base64.decode(peerPublicKey)
            )

            val ret = mapOf("sharedSecret" to Hex.toHexString(sharedSecret))
            result.success(ret)
        } catch (e: Exception) {
            return result.error(
                AbrevvaCrypto::class.java.simpleName,
                CryptoError.ComputeSharedSecretError.name,
                e.toString()
            )
        }
    }

    fun encryptFile(call: MethodCall, result: Result) {
        val ptPath = call.argument<String>("ptPath")
        if (ptPath == null || ptPath == "") {
            return result.error(
                AbrevvaCrypto::class.java.simpleName,
                CryptoError.EncryptFileInvalidArgumentError.name,
                null
            )
        }

        val ctPath = call.argument<String>("ctPath")
        if (ctPath == null || ctPath == "") {
            return result.error(
                AbrevvaCrypto::class.java.simpleName,
                CryptoError.EncryptFileInvalidArgumentError.name,
                null
            )
        }

        val sharedSecret = call.argument<String>("sharedSecret")
        if (sharedSecret == null || sharedSecret == "") {
            return result.error(
                AbrevvaCrypto::class.java.simpleName,
                CryptoError.EncryptFileInvalidArgumentError.name,
                null
            )
        }

        try {
            val sharedKey = Hex.decode(sharedSecret)
            val operationOk: Boolean = AesGcm.encryptFile(sharedKey, ptPath, ctPath)

            val ret = mapOf("opOk" to operationOk)
            result.success(ret)
        } catch (e: Exception) {
            return result.error(
                AbrevvaCrypto::class.java.simpleName,
                CryptoError.EncryptFileCryptoError.name,
                e.toString()
            )
        }
    }

    fun decryptFile(call: MethodCall, result: Result) {
        val sharedSecret = call.argument<String>("sharedSecret")
        if (sharedSecret == null || sharedSecret == "") {
            return result.error(
                AbrevvaCrypto::class.java.simpleName,
                CryptoError.DecryptFileInvalidArgumentError.name,
                null
            )
        }

        val ctPath = call.argument<String>("ctPath")
        if (ctPath == null || ctPath == "") {
            return result.error(
                AbrevvaCrypto::class.java.simpleName,
                CryptoError.DecryptFileInvalidArgumentError.name,
                null
            )
        }

        val ptPath = call.argument<String>("ptPath")
        if (ptPath == null || ptPath == "") {
            return result.error(
                AbrevvaCrypto::class.java.simpleName,
                CryptoError.DecryptFileInvalidArgumentError.name,
                null
            )
        }

        try {
            val sharedKey = Hex.decode(sharedSecret)
            val operationOk: Boolean = AesGcm.decryptFile(sharedKey, ctPath, ptPath)

            val ret = mapOf("opOk" to operationOk)
            result.success(ret)
        } catch (e: Exception) {
            return result.error(
                AbrevvaCrypto::class.java.simpleName,
                CryptoError.DecryptFileCryptoError.name,
                e.toString()
            )
        }
    }

    fun writeToFile(ctPath: String, url: String) {
        BufferedInputStream(URL(url).openStream()).use { `in` ->
            FileOutputStream(ctPath).use { fileOutputStream ->
                val dataBuffer = ByteArray(4096)
                var bytesRead: Int
                while (`in`.read(dataBuffer, 0, 4096).also { bytesRead = it } != -1) {
                    fileOutputStream.write(dataBuffer, 0, bytesRead)
                }
            }
        }
    }

    fun decryptFileFromURL(call: MethodCall, result: Result) {
        val sharedSecret = call.argument<String>("sharedSecret")
        if (sharedSecret == null || sharedSecret == "") {
            return result.error(
                AbrevvaCrypto::class.java.simpleName,
                CryptoError.DecryptFileFromURLInvalidArgumentError.name,
                null
            )
        }

        val uri = call.argument<String>("url")
        if (uri == null || uri == "") {
            return result.error(
                AbrevvaCrypto::class.java.simpleName,
                CryptoError.DecryptFileFromURLInvalidArgumentError.name,
                null
            )
        }

        val ptPath = call.argument<String>("ptPath")
        if (ptPath == null || ptPath == "") {
            return result.error(
                AbrevvaCrypto::class.java.simpleName,
                CryptoError.DecryptFileFromURLInvalidArgumentError.name,
                null
            )
        }
        val ctPath = Paths.get(ptPath).parent.toString() + "/blob"

        val file = File(ctPath)
        val url: URL
        val connection: HttpURLConnection
        val statusCode: Int

        try {
            url = URL(uri)
            connection = url.openConnection() as HttpURLConnection
            statusCode = connection.responseCode
        } catch (e: Exception) {
            return result.error(
                AbrevvaCrypto::class.java.simpleName,
                CryptoError.DecryptFileFromURLNetworkError.name,
                e
            )
        }

        try {
            when (statusCode) {
                200 -> {
                    val inputStream = connection.inputStream
                    val bufferedInputStream = BufferedInputStream(inputStream)
                    val outputStream = FileOutputStream(file)
                    val dataBuffer = ByteArray(4096)
                    var bytesRead: Int

                    while (bufferedInputStream.read(dataBuffer, 0, 4096)
                            .also { bytesRead = it } != -1
                    ) {
                        outputStream.write(dataBuffer, 0, bytesRead)
                    }
                    outputStream.flush()
                    outputStream.close()
                }

                404 -> {
                    return result.error(
                        statusCode.toString(),
                        AbrevvaCrypto::class.java.simpleName,
                        CryptoError.DecryptFileFromURLNotFoundError.name
                    )
                }

                else -> {
                    return result.error(
                        statusCode.toString(),
                        AbrevvaCrypto::class.java.simpleName,
                        CryptoError.DecryptFileFromURLInaccessibleError.name
                    )
                }
            }
        } catch (e: IOException) {
            return result.error(
                AbrevvaCrypto::class.java.simpleName,
                CryptoError.DecryptFileFromURLNoResponseDataError.name,
                e
            )
        }


        try {
            val sharedKey = Hex.decode(sharedSecret)
            val operationOk: Boolean = AesGcm.decryptFile(sharedKey, ctPath, ptPath)

            val ret = mapOf("opOk" to operationOk)
            result.success(ret)
        } catch (e: Exception) {
            result.error(
                AbrevvaCrypto::class.java.simpleName,
                CryptoError.DecryptFileFromURLCryptoError.name,
                e.toString()
            )
        }
    }

    fun random(call: MethodCall, result: Result) {
        try {
            val numBytes = call.argument<Int>("numBytes")
            val rnd: ByteArray = SimpleSecureRandom.getSecureRandomBytes(numBytes!!)
            val ret = mapOf("value" to Hex.toHexString(rnd))

            result.success(ret)
        } catch (e: Exception) {
            return result.error(
                AbrevvaCrypto::class.java.simpleName,
                CryptoError.RandomError.name,
                e.toString()
            )
        }
    }

    fun derive(call: MethodCall, result: Result) {
        val key: ByteArray
        val salt: ByteArray
        val info: ByteArray
        try {
            key = Hex.decode(call.argument<String>("key"))
            salt = Hex.decode(call.argument<String>("salt"))
            info = Hex.decode(call.argument<String>("info"))
        } catch (e: Exception) {
            return result.error(
                AbrevvaCrypto::class.java.simpleName,
                CryptoError.DeriveInvalidArgumentError.name,
                e.toString()
            )
        }
        val length = call.argument<Int>("length") ?: 0

        try {
            val derived: ByteArray = HKDF.derive(key, salt, info, length)
            if (derived.isEmpty()) {
                return result.error(
                    AbrevvaCrypto::class.java.simpleName,
                    CryptoError.DeriveEmptyResultError.name,
                    null
                )
            }
            val ret = mapOf(("value" to Hex.toHexString(derived)))
            result.success(ret)
        } catch (e: Exception) {
            return result.error(
                AbrevvaCrypto::class.java.simpleName,
                CryptoError.DeriveCryptoError.name,
                e.toString()
            )
        }
    }

    fun computeED25519PublicKey(call: MethodCall, result: Result) {
        try {
            val privateKey = call.argument<String>("privateKey")
            if (privateKey == null || privateKey == "") {
                return result.error(
                    AbrevvaCrypto::class.java.simpleName,
                    CryptoError.ComputeED25519PublicKeyInvalidArgumentError.name,
                    null
                )
            }
            val publicKey = X25519Wrapper.computeED25519PublicKey(Base64.decode(privateKey))
            val ret = mapOf("publicKey" to Base64.toBase64String(publicKey))

            result.success(ret)
        } catch (e: Exception) {
            return result.error(
                AbrevvaCrypto::class.java.simpleName,
                CryptoError.ComputeED25519PublicKeyError.name,
                e.toString()
            )
        }
    }

    fun sign(call: MethodCall, result: Result) {
        try {
            val privateKey = call.argument<String>("privateKey")
            if (privateKey == null || privateKey == "") {
                return result.error(
                    AbrevvaCrypto::class.java.simpleName,
                    CryptoError.SignInvalidArgumentError.name,
                    null
                )
            }
            val data = call.argument<String>("data")
            if (data == null || data == "") {
                return result.error(
                    AbrevvaCrypto::class.java.simpleName,
                    CryptoError.SignInvalidArgumentError.name,
                    null
                )
            }
            val signature = X25519Wrapper.sign(Base64.decode(privateKey), data.encodeToByteArray())
            val ret = mapOf("signature" to Base64.toBase64String(signature))

            result.success(ret)
        } catch (e: Exception) {
            return result.error(
                AbrevvaCrypto::class.java.simpleName,
                CryptoError.SignCryptoError.name,
                e.toString()
            )
        }
    }

    fun verify(call: MethodCall, result: Result) {
        val publicKey = call.argument<String>("publicKey")
        if (publicKey == null || publicKey == "") {
            return result.error(
                AbrevvaCrypto::class.java.simpleName,
                CryptoError.VerifyInvalidArgumentError.name,
                null
            )
        }

        val data = call.argument<String>("data")
        if (data == null || data == "") {
            return result.error(
                AbrevvaCrypto::class.java.simpleName,
                CryptoError.VerifyInvalidArgumentError.name,
                null
            )
        }

        val signature = call.argument<String>("signature")
        if (signature == null || signature == "") {
            return result.error(
                AbrevvaCrypto::class.java.simpleName,
                CryptoError.VerifyInvalidArgumentError.name,
                null
            )
        }

        try {
            val success =
                X25519Wrapper.verify(
                    Base64.decode(publicKey),
                    data.encodeToByteArray(),
                    Base64.decode(signature)
                )
            if (!success) {
                return result.error(
                    AbrevvaCrypto::class.java.simpleName,
                    CryptoError.VerifyFailedError.name,
                    null
                )
            }
            result.success(null)
        } catch (e: Exception) {
            return result.error(
                AbrevvaCrypto::class.java.simpleName,
                CryptoError.VerifyCryptoError.name,
                e.toString()
            )
        }
    }
}
