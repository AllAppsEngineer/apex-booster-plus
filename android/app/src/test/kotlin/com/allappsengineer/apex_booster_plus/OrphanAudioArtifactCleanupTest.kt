package com.allappsengineer.apex_booster_plus

import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

/**
 * AUDIO-CAPTURE-U2.7: covers only the pure decision function
 * (candidatesToDelete) — the real filesystem sweep (sweep()) walks
 * getExternalFilesDir() directories and requires physical/on-device
 * validation instead (no Robolectric/MockK in this project).
 */
class OrphanAudioArtifactCleanupTest {

    private val now = 1_000_000L
    private val minAge = 120_000L

    @Test
    fun `m4a antigo e orfao e candidato a exclusao`() {
        val path = "/data/apex_audio_poc/apex_audio_poc_1.m4a"
        val result = OrphanAudioArtifactCleanup.candidatesToDelete(
            candidatePaths = listOf(path),
            protectedPaths = emptySet(),
            lastModifiedMillisByPath = mapOf(path to now - minAge - 1L),
            nowMillis = now,
            minAgeMs = minAge,
        )
        assertEquals(listOf(path), result)
    }

    @Test
    fun `arquivo recente nunca e candidato mesmo se o padrao de nome bater`() {
        val path = "/data/apex_audio_poc/apex_audio_poc_1.m4a"
        val result = OrphanAudioArtifactCleanup.candidatesToDelete(
            candidatePaths = listOf(path),
            protectedPaths = emptySet(),
            lastModifiedMillisByPath = mapOf(path to now - 1_000L),
            nowMillis = now,
            minAgeMs = minAge,
        )
        assertTrue(result.isEmpty())
    }

    @Test
    fun `path referenciado pelo index nunca e candidato mesmo se antigo`() {
        val path = "/data/apex_clips/apex_clip_1_av.mp4.part"
        val result = OrphanAudioArtifactCleanup.candidatesToDelete(
            candidatePaths = listOf(path),
            protectedPaths = setOf(path),
            lastModifiedMillisByPath = mapOf(path to now - minAge - 1L),
            nowMillis = now,
            minAgeMs = minAge,
        )
        assertTrue(result.isEmpty())
    }

    @Test
    fun `mp4 original nunca e candidato independente da idade`() {
        val path = "/data/apex_clips/apex_clip_1.mp4"
        val result = OrphanAudioArtifactCleanup.candidatesToDelete(
            candidatePaths = listOf(path),
            protectedPaths = emptySet(),
            lastModifiedMillisByPath = mapOf(path to now - minAge - 1L),
            nowMillis = now,
            minAgeMs = minAge,
        )
        assertTrue(result.isEmpty())
    }

    @Test
    fun `av mp4 final nunca e candidato independente da idade`() {
        val path = "/data/apex_clips/apex_clip_1_av.mp4"
        val result = OrphanAudioArtifactCleanup.candidatesToDelete(
            candidatePaths = listOf(path),
            protectedPaths = emptySet(),
            lastModifiedMillisByPath = mapOf(path to now - minAge - 1L),
            nowMillis = now,
            minAgeMs = minAge,
        )
        assertTrue(result.isEmpty())
    }

    @Test
    fun `wav part antigo e candidato a exclusao`() {
        val path = "/data/apex_audio_poc/apex_audio_poc_1.wav.part"
        val result = OrphanAudioArtifactCleanup.candidatesToDelete(
            candidatePaths = listOf(path),
            protectedPaths = emptySet(),
            lastModifiedMillisByPath = mapOf(path to now - minAge - 1L),
            nowMillis = now,
            minAgeMs = minAge,
        )
        assertEquals(listOf(path), result)
    }

    @Test
    fun `lista mista filtra apenas os elegiveis`() {
        val orphanM4a = "/data/apex_audio_poc/a.m4a"
        val protectedAvPart = "/data/apex_clips/b_av.mp4.part"
        val originalMp4 = "/data/apex_clips/c.mp4"
        val result = OrphanAudioArtifactCleanup.candidatesToDelete(
            candidatePaths = listOf(orphanM4a, protectedAvPart, originalMp4),
            protectedPaths = setOf(protectedAvPart),
            lastModifiedMillisByPath = mapOf(
                orphanM4a to now - minAge - 1L,
                protectedAvPart to now - minAge - 1L,
                originalMp4 to now - minAge - 1L,
            ),
            nowMillis = now,
            minAgeMs = minAge,
        )
        assertEquals(listOf(orphanM4a), result)
    }
}
