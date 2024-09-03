package com.evva.xesar.abrevva

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.nfc.NfcAdapter
import android.os.Handler
import android.os.Looper
import androidx.annotation.MainThread
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleEventObserver
import androidx.lifecycle.LifecycleOwner
import com.evva.xesar.abrevva.nfc.KeyStoreHandler
import com.evva.xesar.abrevva.nfc.Mqtt5Client
import com.evva.xesar.abrevva.nfc.NfcDelegate
import com.evva.xesar.abrevva.nfc.Message
import com.evva.xesar.abrevva.nfc.asByteArray
import com.hivemq.client.mqtt.mqtt5.message.publish.Mqtt5Publish
import io.flutter.app.FlutterActivityEvents
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.embedding.engine.plugins.lifecycle.HiddenLifecycleReference
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.File
import java.util.Timer
import java.util.TimerTask
import kotlin.coroutines.coroutineContext

class AbrevvaNfc: MethodCallHandler,
    FlutterActivity() {

        private lateinit var contextMain: Context
        private lateinit var activityMain: Activity
    public fun eventObserver(source:  LifecycleOwner, event:  Lifecycle.Event, context: Context, activity: Activity) {
        contextMain = context
        activityMain = activity

        when(event) {
            Lifecycle.Event.ON_START -> observerOnStart(context)
            Lifecycle.Event.ON_RESUME -> observerOnResume(context, activity)
            Lifecycle.Event.ON_PAUSE -> observerOnPause(context, activity)
            else -> {}
        }
    }
    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
                "read" -> read(result)
                "connect" -> connect()
                "disconnect" -> disconnect()
            else -> {
                result.notImplemented()
            }
        }
    }
    private val host = "172.16.2.91"
    private val port = 1883
    private val clientID = "96380897-0eee-479e-80c3-84c0dde286cd"

    private val STATUS_NFC_OK = "enabled"
    private val DIRECTORY_DOCUMENTS = "/data/user/0/com.evva.xesar.abrevva_example/app_flutter/"

    private val kyOffTimer = Timer()
    private val hbTimer = Timer()

    private var mqtt5Client: Mqtt5Client? = null
    private var nfcDelegate = NfcDelegate()

    private var clientId: String? = null

    private var adapterStatus = nfcDelegate.setAdapterStatus()
    private fun observerOnStart(context: Context) {
        nfcDelegate.setAdapter(NfcAdapter.getDefaultAdapter(context))
        adapterStatus = nfcDelegate.setAdapterStatus()
        println("adapter status = $adapterStatus")

    }
    private fun observerOnResume(context: Context, activity: Activity) {
        nfcDelegate.restartForegroundDispatch(context, activity)
    }
    private fun observerOnPause(context: Context, activity: Activity) {
        nfcDelegate.disableForegroundDispatch(context, activity)
    }

    fun observerOnNewIntent(intent: Intent) {
        this.intent = intent
        nfcDelegate.processTag(intent) {
            mqtt5Client?.subscribe("readers/1/$clientId/t", ::messageReceivedCallback)
            mqtt5Client?.publish(
                "readers/1/$clientId",
                Message(
                    "ky",
                    "on",
                    nfcDelegate.getIdentifier(),
                    nfcDelegate.getHistoricalBytesAsHexString(),
                    "BAKA"
                ).asByteArray()
            )
            setDisconnectTimer()
            setHbTimer()
        }
    }

    private fun messageReceivedCallback(response: Mqtt5Publish) {
        try {
            val resp = nfcDelegate.transceive(response.payloadAsBytes)
            mqtt5Client?.publish("readers/1/$clientId/f", resp)
        } catch (e: Exception){
            println(e)
        }
    }

    private fun setDisconnectTimer() {
        kyOffTimer.scheduleAtFixedRate(object : TimerTask() {
            override fun run() {
                try {
                    // .isConnected throws SecurityException when Tag is outdated
                    nfcDelegate.isConnected()
                } catch (ex: java.lang.Exception) {
                    mqtt5Client?.publish("readers/1",Message("ky", "off", oid = clientId).asByteArray())
                    this.cancel()
                }
            }
        }, 250, 250)
    }

    private fun setHbTimer(){
        hbTimer.scheduleAtFixedRate(object : TimerTask() {
            override fun run() {
                mqtt5Client?.publish("readers/1", Message("cr", "hb", oid = clientId).asByteArray())
            }
        }, 30000, 30000)
    }

    fun read(result: Result) {
        if (adapterStatus != STATUS_NFC_OK) {
            result.error("No NFC hardware or NFC is disabled by the user", null, null)
        }
        else {
            nfcDelegate.restartForegroundDispatch(
                contextMain,
                activityMain
            )
        }
    }

    @OptIn(ExperimentalStdlibApi::class)
    fun connect() {
        val ksh = KeyStoreHandler()
        try {
            ksh.parseP12File("$DIRECTORY_DOCUMENTS/client.p12", "123")
            ksh.initKeyManagerFactory()
            ksh.initTrustManagerFactory()
        }
        catch (ex: Exception) {
            println(ex)
            return
        }

        this.clientId = clientID
        this.mqtt5Client = Mqtt5Client(clientID, port, host, ksh)
        mqtt5Client?.connect()
        print(Message("ky", "off", oid = "oidValue").asByteArray().toHexString())
    }

    fun disconnect() {
        hbTimer.cancel()
        kyOffTimer.cancel()
        mqtt5Client?.publish("readers/1",Message("cr", "off", oid = clientID).asByteArray())
        mqtt5Client?.disconnect()
    }
}