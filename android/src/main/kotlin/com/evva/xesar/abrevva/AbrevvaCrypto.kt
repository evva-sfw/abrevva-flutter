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
import java.io.FileOutputStream
import java.io.IOException
import java.net.URL
import java.nio.file.Paths
import kotlin.io.encoding.ExperimentalEncodingApi

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
        try {
            val key = Hex.decode(call.argument<String>("key"))
            val iv = Hex.decode(call.argument<String>("iv"))
            val adata = Hex.decode(call.argument<String>("adata"))
            val pt = Hex.decode(call.argument<String>("pt"))
            val tagLength = call.argument<Int>("tagLength")!!

            val ct: ByteArray = AesCcm.encrypt(key, iv, adata, pt, tagLength)
            val cipherText = ByteArray(pt.size)
            val authTag = ByteArray(tagLength)

            System.arraycopy(ct, 0, cipherText, 0, pt.size)
            System.arraycopy(ct, pt.size, authTag, 0, tagLength)

            if (ct.isEmpty()) {
                return result.error("encrypt(): encryption failed", null, null)
            }
            val ret = mapOf(
                "cipherText" to Hex.toHexString(cipherText),
                "authTag" to Hex.toHexString(authTag)
            )
            result.success(ret)
        } catch (e: Exception) {
            result.error("encrypt(): encrypt failed", e.toString(), null)
        }
    }

    fun decrypt(call: MethodCall, result: Result) {
        try {
            val key = Hex.decode(call.argument<String>("key"))
            val iv = Hex.decode(call.argument<String>("iv"))
            val adata = Hex.decode(call.argument<String>("adata"))
            val ct = Hex.decode(call.argument<String>("ct"))
            val tagLength = call.argument<Int>("tagLength")!!

            val pt: ByteArray = AesCcm.decrypt(key, iv, adata, ct, tagLength)

            if (pt.isEmpty()) {
                return result.error("decrypt(): decryption failed", null, null)
            }
            val ret = mapOf(
                "plainText" to Hex.toHexString(pt),
                "authOk" to true
            )
            result.success(ret)
        } catch (e: Exception) {
            result.error("decrypt(): decrypt failed", e.toString(), null)
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
            result.error("generateKeyPair(): private key creation failed", e.toString(), null)
        }
    }

    @OptIn(ExperimentalEncodingApi::class)
    fun computeSharedSecret(call: MethodCall, result: Result) {
        try {
            val privateKey = call.argument<String>("privateKey")
            if (privateKey == null || privateKey == "") {
                result.error("computeSharedSecret(): invalid private key", null, null)
                return
            }
            val peerPublicKey = call.argument<String>("peerPublicKey")
            if (peerPublicKey == null || peerPublicKey == "") {
                result.error("computeSharedSecret(): invalid peer public key", null, null)
                return
            }
            val sharedSecret: ByteArray = X25519Wrapper.computeSharedSecret(
                Base64.decode(privateKey),
                Base64.decode(peerPublicKey)
            )

            val ret = mapOf("sharedSecret" to Hex.toHexString(sharedSecret))
            result.success(ret)
        } catch (e: Exception) {
            result.error("computeSharedSecret(): failed to create shared key", e.toString(), null)
        }
    }

    fun encryptFile(call: MethodCall, result: Result) {
        try {
            val ptPath = call.argument<String>("ptPath")
            if (ptPath == null || ptPath == "") {
                result.error("encryptFile(): invalid ptPath", null, null)
                return
            }
            val ctPath = call.argument<String>("ctPath")
            if (ctPath == null || ctPath == "") {
                result.error("encryptFile(): invalid ctPath", null, null)
                return
            }
            val sharedSecret = call.argument<String>("sharedSecret")
            if (sharedSecret == null || sharedSecret == "") {
                result.error("encryptFile(): invalid shared secret", null, null)
                return
            }

            val sharedKey = Hex.decode(sharedSecret)
            val operationOk: Boolean = AesGcm.encryptFile(sharedKey, ptPath, ctPath)

            val ret = mapOf("opOk" to operationOk)
            result.success(ret)
        } catch (e: Exception) {
            result.error("encryptFile(): failed to encrypt file", e.toString(), null)
        }
    }

    fun decryptFile(call: MethodCall, result: Result) {
        try {
            val sharedSecret = call.argument<String>("sharedSecret")
            if (sharedSecret == null || sharedSecret == "") {
                result.error("decryptFile(): invalid shared secret", null, null)
                return
            }
            val ctPath = call.argument<String>("ctPath")
            if (ctPath == null || ctPath == "") {
                result.error("decryptFile(): invalid ctPath", null, null)
                return
            }
            val ptPath = call.argument<String>("ptPath")
            if (ptPath == null || ptPath == "") {
                result.error("decryptFile(): invalid ptPath", null, null)
                return
            }

            val sharedKey = Hex.decode(sharedSecret)
            val operationOk: Boolean = AesGcm.decryptFile(sharedKey, ctPath, ptPath)

            val ret = mapOf("opOk" to operationOk)
            result.success(ret)
        } catch (e: Exception) {
            result.error("decryptFile(): failed to decrypt file", e.toString(), null)
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
            result.error("decryptFileFromURL(): invalid shared secret", null, null)
            return
        }
        val url = call.argument<String>("url")
        if (url == null || url == "") {
            result.error("decryptFileFromURL(): invalid url", null, null)
            return
        }
        val ptPath = call.argument<String>("ptPath")
        if (ptPath == null || ptPath == "") {
            result.error("decryptFileFromURL(): invalid ptPath", null, null)
            return
        }
        val ctPath = Paths.get(ptPath).parent.toString() + "/blob"
        try {
            writeToFile(ctPath, url)
        } catch (e: IOException) {
            result.error("decryptFileFromURL(): failed to load data from url", e.toString(), null)
            return
        }
        try {
            val sharedKey = Hex.decode(sharedSecret)
            val operationOk: Boolean = AesGcm.decryptFile(sharedKey, ctPath, ptPath)

            val ret = mapOf("opOk" to operationOk)
            result.success(ret)
        } catch (e: Exception) {
            result.error("decryptFileFromURL(): failed to decrypt from file", e.toString(), null)
        }
    }

    fun random(call: MethodCall, result: Result) {
        try {
            val numBytes = call.argument<Int>("numBytes")
            val rnd: ByteArray = SimpleSecureRandom.getSecureRandomBytes(numBytes!!)

            if (rnd.isEmpty()) {
                return result.error("random(): random generation failed", null, null)
            }
            val ret = mapOf("value" to Hex.toHexString(rnd))
            result.success(ret)
        } catch (e: Exception) {
            result.error("random(): random failed", e.toString(), null)
        }
    }

    fun derive(call: MethodCall, result: Result) {
        try {
            val key = Hex.decode(call.argument<String>("key"))
            val salt = Hex.decode(call.argument<String>("salt"))
            val info = Hex.decode(call.argument<String>("info"))
            val length = call.argument<Int>("length")

            val derived: ByteArray = HKDF.derive(key, salt, info, length!!)
            if (derived.isEmpty()) {
                return result.error("derive(): key derivation failed", null, null)
            }
            val ret = mapOf(("value" to Hex.toHexString(derived)))
            result.success(ret)
        } catch (e: Exception) {
            result.error("derive(): derive failed", e.toString(), null)
        }
    }

    fun computeED25519PublicKey(call: MethodCall, result: Result) {
        try {
            val privateKey = call.argument<String>("privateKey")
            if (privateKey == null || privateKey == "") {
                return result.error("computeED25519PublicKey(): invalid private key", null, null)
            }
            val publicKey = X25519Wrapper.computeED25519PublicKey(Base64.decode(privateKey))

            val ret = mapOf("publicKey" to Base64.toBase64String(publicKey))
            result.success(ret)
        } catch (e: Exception) {
            result.error("computeED25519PublicKey(): computation failed", e.toString(), null)
        }
    }

    fun sign(call: MethodCall, result: Result) {
        try {
            val privateKey = call.argument<String>("privateKey")
            if (privateKey == null || privateKey == "") {
                return result.error("sign(): invalid private key", null, null)
            }
            val data = call.argument<String>("data")
            if (data == null || data == "") {
                return result.error("sign(): invalid data", null, null)
            }
            val signature = X25519Wrapper.sign(Base64.decode(privateKey), data.encodeToByteArray())

            val ret = mapOf("signature" to Base64.toBase64String(signature))
            result.success(ret)
        } catch (e: Exception) {
            result.error("sign(): sign failed", e.toString(), null)
        }
    }

    fun verify(call: MethodCall, result: Result) {
        try {
            val publicKey = call.argument<String>("publicKey")
            if (publicKey == null || publicKey == "") {
                return result.error("verify(): invalid publicKey key", null, null)
            }
            val data = call.argument<String>("data")
            if (data == null || data == "") {
                return result.error("verify(): invalid data", null, null)
            }
            val signature = call.argument<String>("signature")
            if (signature == null || signature == "") {
                return result.error("verify(): invalid signature", null, null)
            }
            val success =
                X25519Wrapper.verify(
                    Base64.decode(publicKey),
                    data.encodeToByteArray(),
                    Base64.decode(signature)
                )
            if (!success) {
                return result.error("verify(): bad signature", null, null)
            }
            result.success(null)
        } catch (e: Exception) {
            result.error("verify(): verify failed", e.toString(), null)
        }
    }
}
