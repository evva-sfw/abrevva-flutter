package com.evva.xesar.abrevva

import com.evva.xesar.abrevva.crypto.AesCCM
import com.evva.xesar.abrevva.crypto.AesGCM
import com.evva.xesar.abrevva.crypto.HKDF
import com.evva.xesar.abrevva.crypto.SimpleSecureRandom
import com.evva.xesar.abrevva.crypto.X25519Wrapper
import io.flutter.embedding.android.FlutterActivity
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

/** AbrevvaPlugin */
class AbrevvaCrypto : FlutterActivity(), MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "encrypt" -> encrypt(call, result)
            "decrypt" -> decrypt(call, result)
            "generateKeyPair" -> generateKeyPair(result)
            "computeSharedSecret" -> computeSharedSecret(call, result)
            "encryptFile" -> encryptFile(call, result)
            "decryptFile" -> decryptFile(call, result)
            "decryptFileFromURL" -> decryptFileFromURL(call, result)
            "random" -> random(call, result)
            "derive" -> derive(call, result)
            else -> {
                result.notImplemented()
            }
        }
    }

    fun encrypt(call: MethodCall, result: Result) {
        val key = Hex.decode(call.argument<String>("key"))
        val iv = Hex.decode(call.argument<String>("iv"))
        val adata = Hex.decode(call.argument<String>("adata"))
        val pt = Hex.decode(call.argument<String>("pt"))
        val tagLength = call.argument<Int>("tagLength")!!

        val ct: ByteArray = AesCCM.encrypt(key, iv, adata, pt, tagLength)
        val cipherText = ByteArray(pt.size)
        val authTag = ByteArray(tagLength)

        System.arraycopy(ct, 0, cipherText, 0, pt.size)
        System.arraycopy(ct, pt.size, authTag, 0, tagLength)

        if (ct.isEmpty()) {
            result.error("encrypt(): encryption failed", null, null)
        } else {
            val ret = mapOf(
                "cipherText" to Hex.toHexString(cipherText),
                "authTag" to Hex.toHexString(authTag)
            )
            result.success(ret)
        }
    }

    fun decrypt(call: MethodCall, result: Result) {
        val key = Hex.decode(call.argument<String>("key"))
        val iv = Hex.decode(call.argument<String>("iv"))
        val adata = Hex.decode(call.argument<String>("adata"))
        val ct = Hex.decode(call.argument<String>("ct"))
        val tagLength = call.argument<Int>("tagLength")!!

        val pt: ByteArray = AesCCM.decrypt(key, iv, adata, ct, tagLength)

        if (pt.isEmpty()) {
            result.error("decrypt(): decryption failed", null, null)
        } else {
            val ret = mapOf(
                "plainText" to Hex.toHexString(pt),
                "authOk" to true
            )
            result.success(ret)
        }
    }

    @OptIn(ExperimentalEncodingApi::class)
    fun generateKeyPair(result: Result) {
        try {
            val keyPair: X25519Wrapper.KeyPair = X25519Wrapper.generateKeyPair()

            val ret = mapOf(
                "privateKey" to Base64.toBase64String(keyPair.privateKey),
                "publicKey" to Base64.toBase64String(keyPair.publicKey)
            )
            result.success(ret)
        } catch (e: Exception) {
            result.error("generateKeyPair(): private key creation failed", null, null)
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
            result.error("computeSharedSecret(): failed to create shared key", null, null)
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
            val operationOk: Boolean = AesGCM.encryptFile(sharedKey, ptPath, ctPath)

            val ret = mapOf("opOk" to operationOk)
            result.success(ret)
        } catch (e: Exception) {
            result.error("encryptFile(): failed to encrypt file", null, null)
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
            val operationOk: Boolean = AesGCM.decryptFile(sharedKey, ctPath, ptPath)

            val ret = mapOf("opOk" to operationOk)
            result.success(ret)
        } catch (e: Exception) {
            result.error("decryptFile(): failed to decrypt file", null, null)
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
            print("REACHED")

            result.error("decryptFileFromURL(): failed to load data from url", null, null)
            return
        }

        try {
            val sharedKey = Hex.decode(sharedSecret)
            val operationOk: Boolean = AesGCM.decryptFile(sharedKey, ctPath, ptPath)

            val ret = mapOf("opOk" to operationOk)
            result.success(ret)
        } catch (e: Exception) {
            result.error("decryptFileFromURL(): failed to decrypt from file", null, null)
        }
    }

    fun random(call: MethodCall, result: Result) {
        val numBytes = call.argument<Int>("numBytes")
        val rnd: ByteArray = SimpleSecureRandom.getSecureRandomBytes(numBytes!!)

        if (rnd.isEmpty()) {
            result.error("random(): random generation failed", null, null)
        } else {
            val ret = mapOf("value" to Hex.toHexString(rnd))
            result.success(ret)
        }
    }

    fun derive(call: MethodCall, result: Result) {
        val key = Hex.decode(call.argument<String>("key"))
        val salt = Hex.decode(call.argument<String>("salt"))
        val info = Hex.decode(call.argument<String>("info"))
        val length = call.argument<Int>("length")

        val derived: ByteArray = HKDF.derive(key, salt, info, length!!)
        if (derived.isEmpty()) {
            result.error("derive(): key derivation failed", null, null)
        } else {
            val ret = mapOf(("value" to Hex.toHexString(derived)))
            result.success(ret)
        }
    }
}
