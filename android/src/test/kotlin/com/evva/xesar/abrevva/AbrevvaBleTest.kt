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
}

