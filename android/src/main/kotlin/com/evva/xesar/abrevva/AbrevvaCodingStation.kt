package com.evva.xesar.abrevva

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel


class AbrevvaCodingStation : MethodChannel.MethodCallHandler {

    private var codingString = AbrevvaCodingStation()

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

    fun register(call: MethodCall, result: MethodChannel.Result) {

    }

    fun connect(call: MethodCall, result: MethodChannel.Result) {
    }

    fun write(call: MethodCall, result: MethodChannel.Result) {
    }

    fun disconnect(call: MethodCall, result: MethodChannel.Result) {
    }
}
