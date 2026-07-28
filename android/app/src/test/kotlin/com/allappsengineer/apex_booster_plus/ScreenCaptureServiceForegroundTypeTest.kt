package com.allappsengineer.apex_booster_plus

import android.content.pm.ServiceInfo
import org.junit.Assert.assertEquals
import org.junit.Test

/**
 * AUDIO-CAPTURE-U2.7: covers only the pure companion function that decides
 * which foregroundServiceType flags to pass to startForeground() — the
 * actual startForeground()/Service lifecycle requires physical/on-device
 * validation instead (no Robolectric/MockK in this project). ServiceInfo's
 * FOREGROUND_SERVICE_TYPE_* fields are compile-time int constants, safe to
 * reference from a plain JVM unit test.
 */
class ScreenCaptureServiceForegroundTypeTest {

    @Test
    fun `sem audio solicitado usa somente MEDIA_PROJECTION`() {
        assertEquals(
            ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PROJECTION,
            ScreenCaptureService.foregroundServiceTypeFor(audioRequested = false),
        )
    }

    @Test
    fun `com audio solicitado combina MEDIA_PROJECTION e MICROPHONE`() {
        val expected =
            ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PROJECTION or ServiceInfo.FOREGROUND_SERVICE_TYPE_MICROPHONE
        assertEquals(expected, ScreenCaptureService.foregroundServiceTypeFor(audioRequested = true))
    }
}
