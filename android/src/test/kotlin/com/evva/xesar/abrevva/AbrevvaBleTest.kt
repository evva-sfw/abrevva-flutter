package com.evva.xesar.abrevva

import android.os.ParcelUuid
import android.view.View
import com.evva.xesar.abrevva.ble.BleDevice
import com.evva.xesar.abrevva.ble.BleDeviceAdvertisementData
import com.evva.xesar.abrevva.ble.BleDeviceManufacturerData
import com.evva.xesar.abrevva.crypto.X25519Wrapper
import io.mockk.MockKAnnotations
import io.mockk.every
import io.mockk.mockk
import io.mockk.mockkStatic
import io.mockk.spyk
import io.mockk.verify
import no.nordicsemi.android.common.core.DataByteArray
import no.nordicsemi.android.kotlin.ble.core.ServerDevice
import no.nordicsemi.android.kotlin.ble.core.scanner.BleScanRecord
import no.nordicsemi.android.kotlin.ble.core.scanner.BleScanResult
import no.nordicsemi.android.kotlin.ble.core.scanner.BleScanResultData
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import kotlin.test.assertEquals
import kotlin.test.expect

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
  fun `getBleDeviceData() should map AdvertisementData correctly`() {

    val device = mockk<BleDevice>(relaxed = true)
    val advertData = mockk<BleDeviceAdvertisementData>(relaxed = true)
    val mfData = BleDeviceManufacturerData(
      2153u,
      version = 1.toUByte(),
      componentType = 98.toUByte(),
      mainFirmwareVersionMajor = 1.toUByte(),
      mainFirmwareVersionMinor = 2.toUByte(),
      mainFirmwareVersionPatch = 3.toUShort(),
      componentHAL = 4,
      batteryStatus = true,
      mainConstructionMode = false,
      subConstructionMode = true,
      isOnline = true,
      officeModeEnabled = false,
      twoFactorRequired = false,
      officeModeActive =false,
      reservedBits = 0,
      identifier = "identifier",
      subFirmwareVersionMajor = 4.toUByte(),
      subFirmwareVersionMinor = 5.toUByte(),
      subFirmwareVersionPatch = 6.toUShort(),
      subComponentIdentifier = "String",
    )
    every { device.address } returns "address"
    every { device.localName } returns "localname"
    every { device.advertisementData } returns advertData
    every { advertData.rssi } returns 1
    every { advertData.isConnectable } returns true
    every { advertData.rawData } returns hashMapOf()
    every { advertData.manufacturerData } returns mfData

    val output = abrevvaBleModule.getBleDeviceData(device)

    assertEquals("address", output["deviceId"])
    assertEquals("localname", output["name"])
    val advertDataOutput = output["advertisementData"] as Map<*,*>
    assertEquals(1, advertDataOutput["rssi"])
    assertEquals(true, advertDataOutput["isConnectable"])
    val mfOutput = advertDataOutput["manufacturerData"] as Map<*, *>
    assertEquals(2153, mfOutput["companyIdentifier"])
    assertEquals(false, mfOutput["mainConstructionMode"])
    assertEquals(true, mfOutput["isOnline"])
  }
}

