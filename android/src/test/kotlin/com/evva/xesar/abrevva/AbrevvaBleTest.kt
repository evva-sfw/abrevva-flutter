package com.evva.xesar.abrevva

import android.os.ParcelUuid
import android.view.View
import io.mockk.MockKAnnotations
import io.mockk.every
import io.mockk.mockk
import io.mockk.mockkStatic
import io.mockk.spyk
import no.nordicsemi.android.common.core.DataByteArray
import no.nordicsemi.android.kotlin.ble.core.ServerDevice
import no.nordicsemi.android.kotlin.ble.core.scanner.BleScanRecord
import no.nordicsemi.android.kotlin.ble.core.scanner.BleScanResult
import no.nordicsemi.android.kotlin.ble.core.scanner.BleScanResultData
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test

class AbrevvaBleTest {
    private lateinit var abrevvaBleModule: AbrevvaBle

    @BeforeEach
    fun beforeEach() {
        MockKAnnotations.init(this)

        mockkStatic(View::class)
        every { View.generateViewId() } returns 0
            abrevvaBleModule = AbrevvaBle()
    }

    @Test
    fun `getBleDeviceFromNordic should save data from BleScanResult in new map`() {
        val name = "name"
        val address = "deviceAddress"
        val bleScanResult = mockk<BleScanResult>(relaxed = true)
        val device = mockk<ServerDevice>()
        every { bleScanResult.device } returns device
        every { device.hasName } returns true
        every { device.name } returns name
        every { device.address } returns address

        val result = abrevvaBleModule.getBleDeviceFromNordic(bleScanResult)

        val ref =
            mutableMapOf(
                "deviceId" to address,
                "name" to name,
            )
        assert(ref == result)
    }

    @Test
    fun `getScanResultFromNordic should construct ReadableMap from ScanResult`() {
        val name = "name"
        val deviceId = "deviceId"
        val txPower = 10
        val bleSpy = spyk(AbrevvaBle())
        val result = mockk<BleScanResult>()
        val data = mockk<BleScanResultData>()
        val device = mockk<ServerDevice>()
        val scanRecord = mockk<BleScanRecord>()
        val bytes = DataByteArray(byteArrayOf(0x01, 0x02, 0x03, 0x04, 0x05, 0x07, 0x08, 0x09, 0x10))
        val parcelUuid = mockk<ParcelUuid>(relaxed = true)
        val serviceData = mapOf(
            parcelUuid to DataByteArray(
                byteArrayOf(
                    0x01,
                    0x02,
                    0x03,
                    0x04,
                    0x05,
                    0x07,
                    0x08,
                    0x09,
                    0x10
                )
            )
        )
        val bleDevice = mutableMapOf(
            "deviceId" to deviceId,
            "name" to name
        )

        every { result.data } returns null andThen data
        every { result.device } returns device
        every { result.device.hasName } returns true
        every { result.device.name } returns "name"
        every { data.txPower } returns txPower
        every { data.scanRecord } returns scanRecord
        every { scanRecord.bytes } returns bytes
        every { scanRecord.serviceData } returns serviceData
        every { scanRecord.serviceUuids } returns null
        every { bleSpy.getBleDeviceFromNordic(any()) } returns bleDevice

        val ret = bleSpy.getScanResultFromNordic(result)

        val ref = mutableMapOf(
            "device" to bleDevice,
            "localName" to name,
            "txPower" to txPower,
            "manufacturerData" to mutableMapOf("2055" to "09 10"),
            "rawAdvertisement" to "(0x) 01:02:03:04:05:07:08:09:10",
            "serviceData" to mutableMapOf(parcelUuid.toString() to "01 02 03 04 05 07 08 09 10")
        )

        assert(ref == ret)
    }
}

