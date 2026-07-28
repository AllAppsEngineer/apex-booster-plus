package com.allappsengineer.apex_booster_plus

import java.io.File
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

/**
 * AUDIO-CAPTURE-U2.6: covers only the pure, JVM-testable companion functions
 * of ClipAudioMuxer (computeAudioCandidateEligible/computeMuxTimeoutMs) —
 * muxSynchronously itself uses android.media.* and, like the rest of this
 * class, requires physical/on-device validation instead (no Robolectric/
 * MockK in this project).
 */
class ClipAudioMuxerTest {

    // ---- computeAudioCandidateEligible ----

    @Test
    fun `sem candidato de audio nunca e elegivel`() {
        assertFalse(
            ClipAudioMuxer.computeAudioCandidateEligible(
                hasAudioCandidate = false,
                silenceDetected = false,
                muxTimelineEligible = true,
            ),
        )
    }

    @Test
    fun `candidato silencioso nunca e elegivel`() {
        assertFalse(
            ClipAudioMuxer.computeAudioCandidateEligible(
                hasAudioCandidate = true,
                silenceDetected = true,
                muxTimelineEligible = true,
            ),
        )
    }

    @Test
    fun `timeline inelegivel nunca e elegivel mesmo com audio presente e nao silencioso`() {
        assertFalse(
            ClipAudioMuxer.computeAudioCandidateEligible(
                hasAudioCandidate = true,
                silenceDetected = false,
                muxTimelineEligible = false,
            ),
        )
    }

    @Test
    fun `audio presente nao silencioso e timeline elegivel resulta em elegivel`() {
        assertTrue(
            ClipAudioMuxer.computeAudioCandidateEligible(
                hasAudioCandidate = true,
                silenceDetected = false,
                muxTimelineEligible = true,
            ),
        )
    }

    // ---- computeMuxTimeoutMs ----

    @Test
    fun `sessao curta usa o piso de 15s`() {
        assertEquals(15_000L, ClipAudioMuxer.computeMuxTimeoutMs(realSessionDurationMs = 4_000L))
    }

    @Test
    fun `sessao longa usa o teto de 30s`() {
        assertEquals(30_000L, ClipAudioMuxer.computeMuxTimeoutMs(realSessionDurationMs = 120_000L))
    }

    @Test
    fun `sessao intermediaria usa metade da duracao real`() {
        assertEquals(20_000L, ClipAudioMuxer.computeMuxTimeoutMs(realSessionDurationMs = 40_000L))
    }

    // ---- cleanupPartFileIfNeeded (AUDIO-CAPTURE-U2.7) ----

    @Test
    fun `release apaga o part apos falha`() {
        val part = File.createTempFile("apex_clip_test", "_av.mp4.part")
        assertTrue(part.exists())

        ClipAudioMuxer.cleanupPartFileIfNeeded(part, diagnosticsEnabled = false)

        assertFalse(part.exists())
    }

    @Test
    fun `debug preserva o part apos falha`() {
        val part = File.createTempFile("apex_clip_test", "_av.mp4.part")
        try {
            assertTrue(part.exists())

            ClipAudioMuxer.cleanupPartFileIfNeeded(part, diagnosticsEnabled = true)

            assertTrue(part.exists())
        } finally {
            part.delete()
        }
    }

    @Test
    fun `release com part inexistente nao lanca excecao`() {
        val part = File.createTempFile("apex_clip_test", "_av.mp4.part")
        part.delete()
        assertFalse(part.exists())

        ClipAudioMuxer.cleanupPartFileIfNeeded(part, diagnosticsEnabled = false)
    }
}
