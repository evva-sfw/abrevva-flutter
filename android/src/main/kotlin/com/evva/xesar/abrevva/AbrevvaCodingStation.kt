package com.evva.xesar.abrevva

import android.app.Activity
import android.content.Context
import android.content.Intent
import com.evva.xesar.abrevva.auth.AuthManager
import com.evva.xesar.abrevva.cs.CodingStation
import com.evva.xesar.abrevva.mqtt.MqttConnectionOptionsTLS
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.DelicateCoroutinesApi
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import kotlinx.coroutines.runBlocking
import java.net.URL

class AbrevvaCodingStation(applicationContext: Context) : MethodChannel.MethodCallHandler {
    private var activity: Activity? = null
    private var codingStation: CodingStation = CodingStation(applicationContext)
    private var mqttConnectionOptionsTLS: MqttConnectionOptionsTLS? = null
    
    fun eventObserver(activity: Activity) {
        this.activity = activity
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "register" -> register(call, result)
            "connect" -> connect(call, result)
            "write" -> write(call, result)
            "disconnect" -> disconnect(call, result)
            else -> {
                result.notImplemented()
            }
        }
    }

    @OptIn(DelicateCoroutinesApi::class)
    fun register(call: MethodCall, result: MethodChannel.Result) {
        val clientId = call.argument<String>("clientId") ?: ""
        val username = call.argument<String>("username") ?: ""
        val password = call.argument<String>("password") ?: ""
        GlobalScope.launch {

            try {
                val url = URL(call.argument<String>("url") ?: "")
                mqttConnectionOptionsTLS =
                    AuthManager.getMqttConfigForXS(url, clientId, username, password)


            } catch (e: Exception) {
                return@launch result.error("register(): $e", null, null)
            }
            result.success(true)
        }
    }

    fun connect(call: MethodCall, result: MethodChannel.Result) {
        if (mqttConnectionOptionsTLS == null) {
            return result.error(
                "connect(): No MqttCredentials present. call register() first",
                null,
                null
            )
        }
        runBlocking {
            try {
                codingStation.connect(mqttConnectionOptionsTLS!!)
            } catch (e: Exception) {
                result.error("connect(): $e", null, null)
                return@runBlocking
            }
            result.success(true)
        }
    }

    @OptIn(DelicateCoroutinesApi::class)
    fun write(call: MethodCall, result: MethodChannel.Result) {
        GlobalScope.launch {
            if (activity != null) {
                try {
                    codingStation.startTagReader(activity!!, 10_000)
                    result.success(true)
                } catch (e: Exception) {
                    result.error("$e", null, null)
                }
            }
        }
    }

    fun disconnect(call: MethodCall, result: MethodChannel.Result) {
        codingStation.disconnect()
        result.success(true)
    }

    fun onNewIntentHandler(intent: Intent) {
        codingStation.onHandleIntent(intent)
    }
}
