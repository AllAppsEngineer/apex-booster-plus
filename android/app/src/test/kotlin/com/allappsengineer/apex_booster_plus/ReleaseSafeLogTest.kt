package com.allappsengineer.apex_booster_plus

import org.junit.Assert.assertEquals
import org.junit.Test

/**
 * RELEASE-LOG-HARDENING-D1: covers only releaseSafeDetail — the pure,
 * JVM-testable half of this file's logging policy. logFallbackError calls
 * android.util.Log directly and, like every other Log call in this project,
 * requires physical/on-device validation instead (no Robolectric/MockK).
 */
class ReleaseSafeLogTest {

    @Test
    fun `debug build inclui o fragmento de detalhe`() {
        assertEquals(" path=/data/user/0/app/file.wav", releaseSafeDetail(true, "path", "/data/user/0/app/file.wav"))
    }

    @Test
    fun `release build omite o fragmento de detalhe por completo`() {
        assertEquals("", releaseSafeDetail(false, "path", "/data/user/0/app/file.wav"))
    }

    @Test
    fun `release build omite mesmo quando o valor e nulo`() {
        assertEquals("", releaseSafeDetail(false, "path", null))
    }

    @Test
    fun `debug build formata valores nao string normalmente`() {
        assertEquals(" framesQueued=1024", releaseSafeDetail(true, "framesQueued", 1024L))
    }
}
