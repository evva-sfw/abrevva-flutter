package com.evva.xesar.abrevva;
import android.Manifest
import android.annotation.SuppressLint
import kotlinx.serialization.Serializable
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import android.provider.Settings.Global
import androidx.activity.result.contract.ActivityResultContracts
import androidx.annotation.RequiresPermission
import androidx.core.app.ActivityCompat
import androidx.core.app.OnNewIntentProvider
import androidx.core.content.ContextCompat
import androidx.core.os.bundleOf
import androidx.lifecycle.DefaultLifecycleObserver
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleEventObserver
import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.createSavedStateHandle
import androidx.lifecycle.lifecycleScope
import androidx.lifecycle.whenCreated
import com.evva.xesar.abrevva.ble.BleDevice
import java.util.UUID
import com.evva.xesar.abrevva.ble.BleManager
import com.evva.xesar.abrevva.ble.BleWriteType
import com.evva.xesar.abrevva.disengage.DisengageStatusType
import com.evva.xesar.abrevva.util.bytesToString
import com.evva.xesar.abrevva.util.stringToBytes
import com.hivemq.client.internal.netty.ContextFuture
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.embedding.engine.plugins.lifecycle.HiddenLifecycleReference
import io.flutter.embedding.engine.plugins.util.GeneratedPluginRegister
import io.flutter.embedding.engine.systemchannels.LifecycleChannel
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.DelicateCoroutinesApi
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.flow.catch
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.flow.onEach
import kotlinx.coroutines.flow.onStart
import kotlinx.coroutines.launch
import kotlinx.coroutines.runBlocking
import no.nordicsemi.android.kotlin.ble.core.scanner.BleScanResult
import no.nordicsemi.android.kotlin.ble.scanner.BleScanner
import org.json.JSONArray


class AbrevvaStreamHandler: EventChannel.StreamHandler {
  var eventSink: EventChannel.EventSink? = null

  override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
    eventSink = events
  }

  override fun onCancel(arguments: Any?) {
    eventSink = null
  }
}

@OptIn(ExperimentalStdlibApi::class)
public class AbrevvaBle: MethodChannel.MethodCallHandler {

    private lateinit var manager: BleManager
    private lateinit var aliases: Array<String>
    private lateinit var contextMain: Context
    private lateinit var activityMain: Activity
    private lateinit var methodChannel: MethodChannel
    private var events: EventChannel.EventSink? = null

  var connectStreamHandler = AbrevvaStreamHandler()
  var startScanStreamHandler = AbrevvaStreamHandler()
  var startNotificationsStreamHandler = AbrevvaStreamHandler()
  var startEnabledNotificationsStreamHandler = AbrevvaStreamHandler()

    public fun eventObserver(
        source:  LifecycleOwner,
        event:  Lifecycle.Event,
        context: Context,
        activity: Activity,
        bleChannel: MethodChannel
    )
    {
        contextMain = context
        activityMain = activity
        methodChannel = bleChannel

        when(event) {
            Lifecycle.Event.ON_START -> observerOnStart()
            else -> {}
        }
    }
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
          "initialize" -> initialize(call, result)
          "evaluateSdkVersion" -> evaluateSdkVersion(call, result)
            "isEnabled" -> isEnabled(result)
            "isLocationEnabled" -> isLocationEnabled(result)
            "stopEnabledNotifications" -> stopEnabledNotifications(result)
            "openLocationSettings" -> openLocationSettings(result)
            "openBluetoothSettings" -> openBluetoothSettings(result)
            "openAppSettings" -> openAppSettings(result)
            "startScan" -> startScan(call, result)
            "stopScan" -> stopScan(result)
            "connect" -> connect(call, result)
            "disconnect" -> disconnect(call, result)
            "read" -> read(call, result)
            "write" -> write(call, result)
            "disengage" -> disengage(call, result)
            "stopNotifications" -> stopNotifications(call, result)
            "signalize" -> signalize(call, result)
          "startEnabledNotifications" -> startEnabledNotifications(call, result)
          "startNotifications" -> startNotifications(call, result)
            else -> {
                result.notImplemented()
            }
        }
    }

    fun observerOnStart() {
        manager = BleManager(contextMain)
        aliases = arrayOf()
    }

    fun evaluateSdkVersion(call: MethodCall, result: MethodChannel.Result){
      result.success((Build.VERSION.SDK_INT >= Build.VERSION_CODES.S))
    }

    // Runtime Permissions are handled in dart
    fun  initialize(call: MethodCall, result: MethodChannel.Result) {
      result.success(null)
    }

    fun isEnabled(result: MethodChannel.Result) {
        result.success(manager.isBleEnabled())
    }

    fun isLocationEnabled(result: MethodChannel.Result) {
        result.success(manager.isLocationEnabled())
    }

    fun startEnabledNotifications(call: MethodCall, result: MethodChannel.Result) {
      val success = manager.startBleEnabledNotifications { enabled: Boolean ->
        val result = mapOf("value" to enabled)
        activityMain.runOnUiThread {
          startEnabledNotificationsStreamHandler.eventSink?.success(result)
        }
      }

      if (success) {
        result.success(null)
      }
      else {
        result.error("startEnabledNotifications(): failed", null, null)
      }
    }

    fun stopEnabledNotifications(result: MethodChannel.Result) {
        manager.stopBleEnabledNotifications()
        result.success(null)
    }

    fun openLocationSettings(result: MethodChannel.Result) {
        val intent = Intent(Settings.ACTION_LOCATION_SOURCE_SETTINGS)
        activityMain.startActivity(intent)
        result.success(null)
    }

    fun openBluetoothSettings(result: MethodChannel.Result) {
        val intent = Intent(Settings.ACTION_BLUETOOTH_SETTINGS)
        activityMain.startActivity(intent)
        result.success(null)
    }

    fun openAppSettings(result: MethodChannel.Result) {
        val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
        intent.data = Uri.parse("package:" + activityMain.packageName)

        activityMain.startActivity(intent)
        result.success(null)
    }

    fun startScan(call: MethodCall, result: MethodChannel.Result) {
      val macFilter = call.argument<String>("macFilter")
      val allowDuplicates = call.argument<Boolean>("allowDuplicates") ?: false
      val timeout = call.argument<Long>("timeout") ?: 10_000
      println("Starting Scan...")
      manager.startScan(
        { device ->
          activityMain.runOnUiThread {
            startScanStreamHandler.eventSink?.success(
              mapOf(
                "event" to "onScanResult",
                "value" to getBleDeviceData(device)
              )
            )
          }
        },
        { error ->
          activityMain.runOnUiThread {
            startScanStreamHandler.eventSink?.success(
              mapOf(
                "event" to "onScanStart",
                "value" to error
              )
            )
          }
        },
        { error ->
          activityMain.runOnUiThread {
            startScanStreamHandler.eventSink?.success(
              mapOf(
                "event" to "onScanStop",
                "value" to error
              )
            )
          }
        },
        macFilter,
        allowDuplicates,
        timeout
      )
      result.success(null)
    }

    fun stopScan(result: MethodChannel.Result) {
        manager.stopScan()
      result.success(null)
    }

  @RequiresPermission(value = "android.permission.BLUETOOTH_CONNECT")
    fun signalize(call: MethodCall, result: MethodChannel.Result) {
        val deviceId = call.argument<String>("deviceId") ?: ""
        val device = manager.getBleDevice(deviceId) ?: run {
          return result.error("connect(): device not found", null, null)
        }
        manager.signalize(device) { success: Boolean ->
            if (success) {
                result.success(null)
            } else {
                result.error("signalize(): failed", null, null)
            }
        }
    }

    @RequiresPermission(value = "android.permission.BLUETOOTH_CONNECT")
    fun connect(call: MethodCall, result: MethodChannel.Result) {
      val deviceId = call.argument<String>("deviceId") ?: ""
      val timeout = call.argument<Double>("timeout")?.toLong() ?: 10000
      val device = manager.getBleDevice(deviceId) ?: run {
        return result.error("connect(): device not found", null, null)
      }
      manager.connect(device, { success: Boolean ->
        if (success) {
          result.success(true)
        } else {
          result.error("connect(): failed to connect", null, null)
        }
      }, { success ->
        activityMain.runOnUiThread {
          connectStreamHandler.eventSink?.success(
            mapOf(
              "value" to deviceId
            )
          )
        }
      },
        timeout
      )
    }

    @RequiresPermission(value = "android.permission.BLUETOOTH_CONNECT")
    fun disconnect(call: MethodCall, result: MethodChannel.Result) {
      val deviceId = call.argument<String>("deviceId") ?: ""
      val device = manager.getBleDevice(deviceId) ?: run {
        return result.error("connect(): device not found", null, null)
      }
      manager.disconnect(device) { success: Boolean ->
        if (success) {
          result.success(success)
        } else {
          result.error("disconnect(): failed to disconnect", null, null)
        }
      }
    }

    @OptIn(DelicateCoroutinesApi::class)
    @RequiresPermission(value = "android.permission.BLUETOOTH_CONNECT")
    fun read(call: MethodCall, result: MethodChannel.Result) {
      val deviceId = call.argument<String>("deviceId") ?: ""
      val timeout = call.argument<Double>("timeout")?.toLong() ?: 10000
      val characteristic = getCharacteristic(call, result)
        ?: return result.error("read(): bad characteristic", null, null)
      val device = manager.getBleDevice(deviceId) ?: run {
        return result.error("connect(): device not found", null, null)
      }

      GlobalScope.launch {
        val data = device.read(characteristic.first, characteristic.second, timeout)
        if (data != null){
          result.success(mapOf(
            "value" to bytesToString(data)
          ))
        }
        else {
          result.error("read(): failed to read from device", null, null)
        }
      }
    }

    @OptIn(DelicateCoroutinesApi::class)
    @RequiresPermission(value = "android.permission.BLUETOOTH_CONNECT")
    fun write(call: MethodCall, result: MethodChannel.Result) {
        val deviceId = call.argument<String>("deviceId") ?: ""
        val timeout = call.argument<Double>("timeout")?.toLong() ?: 10000
        val characteristic =
            getCharacteristic(call, result) ?: return result.error("read(): bad characteristic", null, null)
        val value =
            call.argument<String>("value") ?: return result.error("write(): missing value for write", null, null)
        val device = manager.getBleDevice(deviceId) ?: run {
          return result.error("connect(): device not found", null, null)
        }

      GlobalScope.launch {
        val success = device.write(
          characteristic.first,
          characteristic.second,
          stringToBytes(value),
          BleWriteType.NO_RESPONSE,
          timeout
        )
        if (success) {
          result.success(null)
        } else {
          result.error("write(): failed to write to device", null, null)
        }
      }
    }

    @RequiresPermission(value = "android.permission.BLUETOOTH_CONNECT")
    fun disengage(call: MethodCall, result: MethodChannel.Result) {
        val deviceId = call.argument<String>("deviceId") ?: ""
        val mobileId = call.argument<String>("mobileId") ?: ""
        val mobileDeviceKey = call.argument<String>("mobileDeviceKey") ?: ""
        val mobileGroupId = call.argument<String>("mobileGroupId") ?: ""
        val mobileAccessData = call.argument<String>("mobileAccessData") ?: ""
        var isPermanentRelease = false
        try {
            isPermanentRelease = call.argument<Boolean>("isPermanentRelease") ?: false
        } catch (_:Exception){}
        val device = manager.getBleDevice(deviceId) ?: run {
          return result.error("connect(): device not found", null, null)
        }
        manager.disengage(
            device,
            mobileId,
            mobileDeviceKey,
            mobileGroupId,
            mobileAccessData,
            isPermanentRelease
        ) { status: DisengageStatusType ->
            result.success(status.toString())
        }
    }
    @OptIn(DelicateCoroutinesApi::class)
    @RequiresPermission(value = "android.permission.BLUETOOTH_CONNECT")
    fun stopNotifications(call: MethodCall, result: MethodChannel.Result) {
        val deviceId = call.argument<String>("deviceId") ?: ""
        val characteristic =
            getCharacteristic(call, result)
                ?: return result.error("stopNotifications(): bad characteristic", null, null)
        val device = manager.getBleDevice(deviceId) ?: run {
          return result.error("connect(): device not found", null, null)
        }
        GlobalScope.launch {
          val success = device.stopNotifications(characteristic.first, characteristic.second)
          if (success) {
            result.success(success)
          } else {
            result.error("stopNotifications(): failed to unset notifications", null, null)
          }
        }
    }

    private fun getCharacteristic(call: MethodCall, result: MethodChannel.Result): Pair<UUID, UUID>? {
        val serviceString = call.argument<String>("service") ?: ""
        val serviceUUID: UUID?

        try {
            serviceUUID = UUID.fromString(serviceString)
        } catch (e: IllegalArgumentException) {
            result.error("getCharacteristic(): invalid service uuid", null, null)
            return null
        }

        if (serviceUUID == null) {
            result.error("getCharacteristic(): service uuid required", null, null)
            return null
        }

        val characteristicString = call.argument<String>("characteristic") ?: ""
        val characteristicUUID: UUID?

        try {
            characteristicUUID = UUID.fromString(characteristicString)
        } catch (e: IllegalArgumentException) {
            result.error("getCharacteristic(): invalid characteristic uuid", null, null)
            return null
        }

        if (characteristicUUID == null) {
            result.error("getCharacteristic(): characteristic uuid required", null, null)
            return null
        }

        return Pair(serviceUUID, characteristicUUID)
    }

    @OptIn(DelicateCoroutinesApi::class)
    @RequiresPermission(value = "android.permission.BLUETOOTH_CONNECT")
    fun startNotifications(call: MethodCall, result: MethodChannel.Result) {
      val deviceId = call.argument<String>("deviceId") ?: ""
      val timeout = call.argument<Number>("timeout") ?: 5000
      val characteristic = getCharacteristic(call, result)
      val device = manager.getBleDevice(deviceId) ?: run {
        return result.error("connect(): device not found", null, null)
      }
      if (characteristic == null) {
        events?.success(
          mapOf(
            "status" to "error",
            "description" to "startNotifications(): bad characteristic"
          )
        )
        return
      }

      GlobalScope.launch {
        val success = device.setNotifications(characteristic.first,
          characteristic.second, { data ->
            val key =
              "notification|${deviceId}|${(characteristic.first)}|${(characteristic.second)}"
            startNotificationsStreamHandler.eventSink?.success(
              mapOf(
                key to mapOf(
                  "value" to bytesToString(
                    data
                  )
                )
              )
            )
          })
        if (success) {
          result.success(success)
        } else {
          result.error("startNotifications(): failed to set notifications", null, null)
        }
      }
    }

  public fun getBleDeviceData(device: BleDevice): Map<*, *> {
    val bleDeviceData = mutableMapOf<String, Any?>(
      "deviceId" to device.address,
      "name" to device.localName
    )

    val advertisementData = mutableMapOf<String, Any?>(
      "rssi" to device.advertisementData?.rssi,
      "isConnectable" to device.advertisementData?.isConnectable
    )

      val mfData = device.advertisementData?.manufacturerData
      val manufacturerData = mutableMapOf<String, Any?>(
        "companyIdentifier" to (mfData?.companyIdentifier?.toInt() ?: 0),
        "version" to (mfData?.version?.toInt() ?: 0),
        "componentType" to
        when (mfData?.componentType?.toInt() ?: 0) {
          98 -> "escutcheon"
          100 -> "handle"
          105 -> "iobox"
          109 -> "emzy"
          119 -> "wallreader"
          122 -> "cylinder"
          else -> "unknown"
        },
        "mainFirmwareVersionMajor" to mfData?.mainFirmwareVersionMajor?.toInt(),
        "mainFirmwareVersionMinor" to mfData?.mainFirmwareVersionMinor?.toInt(),
        "mainFirmwareVersionPatch" to mfData?.mainFirmwareVersionPatch?.toInt(),
        "componentHAL" to mfData?.componentHAL,
        "batteryStatus" to if (mfData?.batteryStatus == true)  "battery-full" else "battery-empty",
        "isOnline" to mfData?.isOnline,
        "subConstructionMode" to mfData?.subConstructionMode,
        "mainConstructionMode" to mfData?.mainConstructionMode,
        "officeModeEnabled" to mfData?.officeModeEnabled,
        "twoFactorRequired" to mfData?.twoFactorRequired,
        "officeModeActive" to mfData?.officeModeActive,
        "reservedBits" to mfData?.reservedBits,
        "identifier" to mfData?.identifier,
        "subFirmwareVersionMajor" to mfData?.subFirmwareVersionMajor?.toInt(),
        "subFirmwareVersionMinor" to mfData?.subFirmwareVersionMinor?.toInt(),
        "subFirmwareVersionPatch" to mfData?.subFirmwareVersionPatch?.toInt(),
        "subComponentIdentifier" to mfData?.subComponentIdentifier
      )
    advertisementData["manufacturerData"] = manufacturerData
    bleDeviceData["advertisementData"] = advertisementData

    return bleDeviceData
  }
}
