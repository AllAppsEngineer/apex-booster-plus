package com.allappsengineer.apex_booster_plus

import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

/**
 * AUDIO-CAPTURE-U2.7: covers only the pure, JVM-testable RMS/silence
 * companion function of InternalAudioRecorder — start()/readLoop()/
 * finalizeAndRelease() use android.media.* and, like the rest of this
 * class, require physical/on-device validation instead (no Robolectric/
 * MockK in this project).
 */
class InternalAudioRecorderTest {

    @Test
    fun `zero amostras e tratado como silencio`() {
        assertTrue(InternalAudioRecorder.computeSilenceDetected(totalSamples = 0L, sumSquares = 0.0))
    }

    @Test
    fun `rms abaixo do limiar e silencio`() {
        // rms = sqrt(sumSquares / totalSamples) = sqrt(10.0 / 10) = 1.0, bem abaixo de 50.0
        assertTrue(InternalAudioRecorder.computeSilenceDetected(totalSamples = 10L, sumSquares = 10.0))
    }

    @Test
    fun `rms acima do limiar nao e silencio`() {
        // rms = sqrt(40000.0 / 10) = 63.2, acima de 50.0
        assertFalse(InternalAudioRecorder.computeSilenceDetected(totalSamples = 10L, sumSquares = 40_000.0))
    }

    @Test
    fun `rms exatamente no limiar nao e silencio pois o corte e estritamente menor que`() {
        // rms = sqrt(25000.0 / 10) = 50.0 (nao estritamente menor que o limiar)
        assertFalse(InternalAudioRecorder.computeSilenceDetected(totalSamples = 10L, sumSquares = 25_000.0))
    }
}
