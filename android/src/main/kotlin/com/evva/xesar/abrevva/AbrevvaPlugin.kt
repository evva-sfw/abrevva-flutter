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
  private lateinit var channelBle: MethodChannel

  private lateinit var connectEventChannel: EventChannel
  private lateinit var startScanEventChannel: EventChannel
  private lateinit var startNotificationsEventChannel: EventChannel
  private lateinit var startEnabledNotificationsEventChannel: EventChannel

  private var abrevvaCrypto = AbrevvaCrypto()
  private var abrevvaBle = AbrevvaBle()

  private lateinit var context: Context
  private lateinit var activity: Activity
  private lateinit var flutterPluginBinding: FlutterPlugin.FlutterPluginBinding

  val lifecycleObserver = LifecycleEventObserver { source, event ->
    abrevvaBle.eventObserver(source, event, context, activity, channelBle)
  }

  @SuppressLint("MissingPermission")
  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    this.context = flutterPluginBinding.applicationContext
    this.flutterPluginBinding = flutterPluginBinding

    channelCrypto = MethodChannel(flutterPluginBinding.binaryMessenger, "AbrevvaCrypto")
    channelCrypto.setMethodCallHandler(abrevvaCrypto)

    channelBle = MethodChannel(flutterPluginBinding.binaryMessenger, "AbrevvaBle")
    channelBle.setMethodCallHandler(abrevvaBle)

    connectEventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "connectEventChannel")
    startScanEventChannel =
      EventChannel(flutterPluginBinding.binaryMessenger, "startScanEventChannel")
    startNotificationsEventChannel =
      EventChannel(flutterPluginBinding.binaryMessenger, "startNotificationsEventChannel")
    startEnabledNotificationsEventChannel =
      EventChannel(flutterPluginBinding.binaryMessenger, "startEnabledNotificationsEventChannel")

    connectEventChannel.setStreamHandler(abrevvaBle.connectStreamHandler)
    startScanEventChannel.setStreamHandler(abrevvaBle.startScanStreamHandler)
    startNotificationsEventChannel.setStreamHandler(abrevvaBle.startNotificationsStreamHandler)
    startEnabledNotificationsEventChannel.setStreamHandler(abrevvaBle.startEnabledNotificationsStreamHandler)
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channelCrypto.setMethodCallHandler(null)
    channelBle.setMethodCallHandler(null)

    connectEventChannel.setStreamHandler(null)
    startScanEventChannel.setStreamHandler(null)
    startNotificationsEventChannel.setStreamHandler(null)
    startEnabledNotificationsEventChannel.setStreamHandler(null)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity

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
