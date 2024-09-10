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
import java.util.UUID
import com.evva.xesar.abrevva.ble.BleManager
import com.evva.xesar.abrevva.util.bytesToString
import com.evva.xesar.abrevva.util.stringToBytes
import com.evva.xesar.abrevva.nfc.toHexString
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

public class AbrevvaBle: MethodChannel.MethodCallHandler, EventChannel.StreamHandler {

    private lateinit var manager: BleManager
    private lateinit var aliases: Array<String>
    private lateinit var contextMain: Context
    private lateinit var activityMain: Activity
    private lateinit var methodChannel: MethodChannel
    private var events: EventChannel.EventSink? = null
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
            "runInitialization" -> runInitialization(call, result)
            "isEnabled" -> isEnabled(result)
            "isLocationEnabled" -> isLocationEnabled(result)
            "stopEnabledNotifications" -> stopEnabledNotifications(result)
            "openLocationSettings" -> openLocationSettings(result)
            "openBluetoothSettings" -> openBluetoothSettings(result)
            "openAppSettings" -> openAppSettings(result)
            "stopLEScan" -> stopLEScan(result)
            "connect" -> connect(call, result)
            "disconnect" -> disconnect(call, result)
            "read" -> read(call, result)
            "write" -> write(call, result)
            "disengage" -> disengage(call, result)
            "stopNotifications" -> stopNotifications(call, result)
            "signalize" -> signalize(call, result)
            else -> {
                result.notImplemented()
            }
        }
    }
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        this.events = events
        val mapArgs = arguments as  Map<*, *>
        when(mapArgs["callbackName"]){
            "requestLEScan" -> requestLEScan((mapArgs["timeout"] as Int).toLong())
            "onEnabledChanged" -> enabledNotifications()
            "startNotifications" -> startNotifications(mapArgs, events)
            else -> {
                events?.error("Method not implemented", null, null)
            }
        }
    }
    override fun onCancel(arguments: Any?) {
        this.events = null
    }
    fun observerOnStart() {
        manager = BleManager(contextMain)
        aliases = arrayOf()
    }


    fun  initialize(call: MethodCall, result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val neverForLocation = call.argument<Boolean>("androidNeverForLocation") ?: false
            println("neverForLocation: $neverForLocation")
            this.aliases = if (neverForLocation) {
                arrayOf(
                    android.Manifest.permission.BLUETOOTH_SCAN,
                    android.Manifest.permission.BLUETOOTH_CONNECT,
                )
            } else {
                arrayOf(
                    android.Manifest.permission.BLUETOOTH_SCAN,
                    android.Manifest.permission.BLUETOOTH_CONNECT,
                    android.Manifest.permission.ACCESS_FINE_LOCATION,
                )
            }
        } else {
            this.aliases = arrayOf(
                android.Manifest.permission.ACCESS_COARSE_LOCATION,
                android.Manifest.permission.ACCESS_FINE_LOCATION,
                android.Manifest.permission.BLUETOOTH,
                android.Manifest.permission.BLUETOOTH_ADMIN,
            )
        }

        this.aliases.forEach {
            if (ContextCompat.checkSelfPermission(contextMain, it) == PackageManager.PERMISSION_DENIED){
                ActivityCompat.requestPermissions(
                    activityMain,
                    this.aliases,
                    1
                )
                return@initialize
            }
        }
        result.success(mapOf("status" to "success"))
    }

    private fun runInitialization(call: MethodCall, result: MethodChannel.Result) {
        if (!activityMain.packageManager.hasSystemFeature(PackageManager.FEATURE_BLUETOOTH_LE)) {
            return result.error("runInitialization(): BLE is not supported", null, null)
        }

        if (!manager.isBleEnabled()) {
            return result.error("runInitialization(): BLE is not available", null, null)
        }
        result.success(null)
    }

    fun isEnabled(result: MethodChannel.Result) {
        result.success(mapOf("value" to manager.isBleEnabled()))
    }

    fun isLocationEnabled(result: MethodChannel.Result) {
        result.success(mapOf("value" to manager.isLocationEnabled()))
    }

    fun stopEnabledNotifications(result: MethodChannel.Result) {
        manager.stopBleEnabledNotifications()
    }

    fun openLocationSettings(result: MethodChannel.Result) {
        val intent = Intent(Settings.ACTION_LOCATION_SOURCE_SETTINGS)
        activityMain.startActivity(intent)
    }

    fun openBluetoothSettings(result: MethodChannel.Result) {
        val intent = Intent(Settings.ACTION_BLUETOOTH_SETTINGS)
        activityMain.startActivity(intent)
    }

    fun openAppSettings(result: MethodChannel.Result) {
        val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
        intent.data = Uri.parse("package:" + activityMain.packageName)

        activityMain.startActivity(intent)
    }

    fun requestLEScan(timeout: Long) {
            manager.startScan({ success: Boolean ->
                activityMain.runOnUiThread {
                    if (!success) {
                        events?.success(mapOf("status" to "error", "description"  to "requestLEScan(): failed to start"))
                    }
                }
            }, { result: BleScanResult ->
                activityMain.runOnUiThread {
                    val scanResult = getScanResultFromNordic(result)
                    activityMain.runOnUiThread {
                        events?.success(scanResult)
                    }
                }
            }, { address: String ->
                activityMain.runOnUiThread {
                        events?.success(mapOf("status" to "error", "description"  to "connected|${address}"))
                }
            },{ address: String ->
                activityMain.runOnUiThread {
                    events?.success(mapOf("status" to "error", "description"  to "disconnected|${address}"))
                }
            },
                timeout
            )
        }

    fun stopLEScan(result: MethodChannel.Result) {
        manager.stopScan()
    }

    fun signalize(call: MethodCall, result: MethodChannel.Result) {
        val deviceId = call.argument<String>("deviceId") ?: ""

        manager.signalize(deviceId) { success: Boolean ->
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

        manager.connect(deviceId, { success: Boolean ->
            if (success) {
                result.success(null)
            } else {
                result.error("connect(): failed to connect", null, null)
            }
        }, timeout)
    }

    @RequiresPermission(value = "android.permission.BLUETOOTH_CONNECT")
    fun disconnect(call: MethodCall, result: MethodChannel.Result) {
        val deviceId = call.argument<String>("deviceId") ?: ""

        manager.disconnect(deviceId) { success: Boolean ->
            if (success) {
                result.success(null)
            } else {
                result.error("disconnect(): failed to disconnect", null, null)
            }
        }
    }

    @RequiresPermission(value = "android.permission.BLUETOOTH_CONNECT")
    fun read(call: MethodCall, result: MethodChannel.Result) {
        val deviceId = call.argument<String>("deviceId") ?: ""
        val timeout = call.argument<Double>("timeout")?.toLong() ?: 10000

        val characteristic = getCharacteristic(call, result)
            ?: return result.error("read(): bad characteristic", null,null)

        manager.read(deviceId, characteristic.first, characteristic.second, { success: Boolean, data: ByteArray? ->
            if (success) {
                result.success(mapOf("value" to bytesToString(data!!)))
            } else {
                result.error("read(): failed to read from device", null, null)
            }
        }, timeout)
    }

    @RequiresPermission(value = "android.permission.BLUETOOTH_CONNECT")
    fun write(call: MethodCall, result: MethodChannel.Result) {
        val deviceId = call.argument<String>("deviceId") ?: ""
        val timeout = call.argument<Double>("timeout")?.toLong() ?: 10000

        val characteristic =
            getCharacteristic(call, result) ?: return result.error("read(): bad characteristic", null, null)
        val value =
            call.argument<String>("value") ?: return result.error("write(): missing value for write", null, null)

        manager.write(
            deviceId,
            characteristic.first,
            characteristic.second,
            stringToBytes(value),
            { success: Boolean ->
                if (success) {
                    result.success(null)
                } else {
                    result.error("write(): failed to write to device", null, null)
                }
            },
            timeout
        )
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

        manager.disengage(
            deviceId,
            mobileId,
            mobileDeviceKey,
            mobileGroupId,
            mobileAccessData,
            isPermanentRelease
        ) { status: Any ->
            result.success(mapOf("value" to status as String))
        }
    }
    @RequiresPermission(value = "android.permission.BLUETOOTH_CONNECT")
    fun stopNotifications(call: MethodCall, result: MethodChannel.Result) {
        val deviceId = call.argument<String>("deviceId") ?: ""
        val characteristic =
            getCharacteristic(call, result)
                ?: return result.error("stopNotifications(): bad characteristic", null, null)

        manager.stopNotifications(deviceId, characteristic.first, characteristic.second) { success: Boolean ->
            if (success) {
                result.success(null)
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


    fun getBleDeviceFromNordic(result: BleScanResult): Map<String, Any> {
        val bleDevice: MutableMap<String, Any> = mutableMapOf("deviceId" to result.device.address)

        if (result.device.hasName) {
            bleDevice["name"] = result.device.name as String
        }

        var uuids:String = ""
        result.data?.scanRecord?.serviceUuids?.forEach { uuid -> uuids += "$uuid:" }

        if (uuids.isNotEmpty()) {
            bleDevice["uuids"] = uuids
        }
        return bleDevice
    }

    fun getScanResultFromNordic(result: BleScanResult): MutableMap<String, Any> {
        val scanResult: MutableMap<String, Any> = mutableMapOf()
        val bleDevice = getBleDeviceFromNordic(result)

        scanResult["device"] = bleDevice
        if (result.device.hasName) {
            scanResult["localName"] = result.device.name as String
        }
        if (result.data?.rssi != null) {
            scanResult["rssi"] = result.data!!.rssi
        }
        if (result.data?.txPower != null) {
            scanResult["txPower"] = result.data!!.txPower ?: 0
        } else {
            scanResult["txPower"] = 127
        }

        val manufacturerData: MutableMap<String, Any> = mutableMapOf()

        val scanRecordBytes = result.data?.scanRecord?.bytes
        if (scanRecordBytes != null) {
            try {
                // Extract EVVA manufacturer-id
                var arr = byteArrayOf(0x01)
                arr.toHexString()
                val keyHex = byteArrayOf(scanRecordBytes.getByte(6)!!).toHexString() + byteArrayOf(
                    scanRecordBytes.getByte(5)!!
                ).toHexString()
                val keyDec = keyHex.toInt(16)

                // Slice out manufacturer data
                val bytes = scanRecordBytes.copyOfRange(7, scanRecordBytes.size)

                manufacturerData[keyDec.toString()] = bytesToString(bytes.value)
            } catch (e: Exception) {
                System.err.println("getScanResultFromNordic(): invalid manufacturer data")
            }
        }

        scanResult["manufacturerData"] = manufacturerData

        val serviceDataObject: MutableMap<String, Any> = mutableMapOf()
        val serviceData = result.data?.scanRecord?.serviceData
        serviceData?.forEach {
            serviceDataObject[it.key.toString()] = bytesToString(it.value.value)
        }
        scanResult["serviceData"] = serviceDataObject

        /*
        *   uuids are concatenated into a string (delimiter ':') because the flutter
        *   bridge has issues with arrays in this context
        */
        var uuids: String = ""
        result.data?.scanRecord?.serviceUuids?.forEach { uuid -> uuids += "$uuid:" }
        scanResult["rawAdvertisement"] = result.data?.scanRecord?.bytes?.toString() as String
        return scanResult
    }

    private fun enabledNotifications() {
        val success = manager.startBleEnabledNotifications { enabled: Boolean ->
            val result = mapOf("value" to enabled)
            activityMain.runOnUiThread {
                events?.success(result)
            }
        }
        if (!success) {
            events?.success(mapOf("status" to "error", "description"  to "startEnabledNotifications(): Failed to set handler"))
        }
    }
    private fun getCharacteristic(mapArgs: Map<*, *>, events: EventChannel.EventSink?): Pair<UUID, UUID>? {
        val serviceString = mapArgs.getOrDefault("service", "") as String
        val serviceUUID: UUID?

        try {
            serviceUUID = UUID.fromString(serviceString)
        } catch (e: IllegalArgumentException) {
            events?.success(mapOf("status" to "error", "description"  to "getCharacteristic(): invalid service uuid"))
            return null
        }

        if (serviceUUID == null) {
            events?.success(mapOf("status" to "error", "description"  to "getCharacteristic(): service uuid required"))
            return null
        }

        val characteristicString = mapArgs.getOrDefault("characteristic", "") as String
        val characteristicUUID: UUID?

        try {
            characteristicUUID = UUID.fromString(characteristicString)
        } catch (e: IllegalArgumentException) {
            events?.success(mapOf("status" to "error", "description"  to "getCharacteristic(): invalid characteristic uuid"))
            return null
        }

        if (characteristicUUID == null) {
            events?.success(mapOf("status" to "error", "description"  to "getCharacteristic(): characteristic uuid required"))
            return null
        }

        return Pair(serviceUUID, characteristicUUID)
    }
    @RequiresPermission(value = "android.permission.BLUETOOTH_CONNECT")
    fun startNotifications(mapArgs: Map<*, *>, events: EventChannel.EventSink?) {
        val deviceId = mapArgs.getOrDefault("deviceId", "") as String
        val timeout =  mapArgs.getOrDefault("timeout", 5000) as Number
        val characteristic = getCharacteristic(mapArgs, events)
        if (characteristic == null) {
            events?.success(mapOf("status" to "error", "description"  to "startNotifications(): bad characteristic"))
            return
        }
        manager.startNotifications(
            deviceId,
            characteristic.first,
            characteristic.second,
            { success: Boolean ->
                if (success) {
                    events?.success(null)
                } else {
                    events?.success(mapOf("status" to "error", "description"  to "startNotifications(): failed to set notifications"))
                }
            }, { data: ByteArray ->
                events?.success(mapOf("value" to bytesToString(data)))
            },
            timeout.toLong()
        )
    }
}