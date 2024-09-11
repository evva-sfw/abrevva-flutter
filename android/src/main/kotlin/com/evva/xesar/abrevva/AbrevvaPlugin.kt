package com.evva.xesar.abrevva

import android.annotation.SuppressLint
import android.app.Activity
import android.content.Context
import androidx.lifecycle.LifecycleEventObserver
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.embedding.engine.plugins.lifecycle.HiddenLifecycleReference
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel


class AbrevvaPlugin : FlutterPlugin, FlutterActivity(), ActivityAware {
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