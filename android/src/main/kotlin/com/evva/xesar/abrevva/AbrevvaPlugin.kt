package com.evva.xesar.abrevva

import android.annotation.SuppressLint
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.media.metrics.Event
import android.nfc.NfcAdapter
import android.os.Bundle
import android.os.PersistableBundle
import androidx.annotation.RequiresPermission
import androidx.core.app.OnNewIntentProvider
import androidx.core.util.Consumer
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleEventObserver
import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.ProcessLifecycleOwner
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.embedding.engine.plugins.lifecycle.HiddenLifecycleReference
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.flow.catch
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.flow.onEach
import kotlinx.coroutines.flow.onStart
import kotlinx.coroutines.launch
import kotlinx.coroutines.runBlocking
import no.nordicsemi.android.kotlin.ble.scanner.BleScanner

class AbrevvaPlugin: FlutterPlugin, FlutterActivity(), ActivityAware {
    private lateinit var channelCrypto: MethodChannel
    private lateinit var channelNfc: MethodChannel
    private lateinit var channelBle: MethodChannel

    private lateinit var eventBle: EventChannel

    private var abrevvaCrypto = AbrevvaCrypto()
    private var abrevvaNfc = AbrevvaNfc()
    private var abrevvaBle = AbrevvaBle()

    private lateinit var context: Context
    private lateinit var activity: Activity
    private lateinit var flutterPluginBinding: FlutterPlugin.FlutterPluginBinding

    val lifecycleObserver = LifecycleEventObserver { source, event ->
        abrevvaBle.eventObserver(source, event, context, activity, channelBle)
        abrevvaNfc.eventObserver(source, event, context, activity)
    }

    @SuppressLint("MissingPermission")
    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        this.context = flutterPluginBinding.applicationContext
        this.flutterPluginBinding = flutterPluginBinding

        channelCrypto = MethodChannel(flutterPluginBinding.binaryMessenger, "AbrevvaCrypto")
        channelCrypto.setMethodCallHandler(abrevvaCrypto)

        channelNfc = MethodChannel(flutterPluginBinding.binaryMessenger, "AbrevvaNfc")
        channelNfc.setMethodCallHandler(abrevvaNfc)

        channelBle = MethodChannel(flutterPluginBinding.binaryMessenger, "AbrevvaBle")
        channelBle.setMethodCallHandler(abrevvaBle)

        eventBle = EventChannel(flutterPluginBinding.binaryMessenger, "AbrevvaBleEvents")
        eventBle.setStreamHandler(abrevvaBle)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channelCrypto.setMethodCallHandler(null)
        channelNfc.setMethodCallHandler(null)
        channelBle.setMethodCallHandler(null)

        eventBle.setStreamHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addOnNewIntentListener {
            abrevvaNfc.observerOnNewIntent(it)
            true
        }

        (binding.lifecycle as HiddenLifecycleReference)
            .lifecycle
            .addObserver(lifecycleObserver)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        TODO("Not yet implemented")
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        TODO("Not yet implemented")
    }

    override fun onDetachedFromActivity() {
    }
}