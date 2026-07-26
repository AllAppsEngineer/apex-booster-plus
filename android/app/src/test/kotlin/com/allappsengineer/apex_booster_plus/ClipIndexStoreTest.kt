package com.allappsengineer.apex_booster_plus

import java.io.IOException
import java.util.concurrent.CyclicBarrier
import java.util.concurrent.atomic.AtomicBoolean
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test

/** In-memory storage fake — no AtomicFile, no android.util.*. */
private class FakeClipIndexStorage(initial: String? = null) : ClipIndexStorage {
    var current: String? = initial
        private set
    var writeCount = 0
        private set

    @Volatile
    var failNextWriteWith: String? = null

    override fun readRaw(): String? = current

    @Synchronized
    override fun writeRaw(content: String) {
        val failure = failNextWriteWith
        if (failure != null) {
            failNextWriteWith = null
            throw IOException(failure)
        }
        current = content
        writeCount++
    }
}

/**
 * Token-based fake codec: encode(x) stores [entries] under a fresh token,
 * decode(token) returns the exact same List<ClipEntry> back. Doesn't
 * exercise real JSON text — that is JsonClipIndexCodec's job, covered by
 * the physical on-device test, not this JVM suite.
 */
private class FakeClipIndexCodec : ClipIndexCodec {
    private val store = mutableMapOf<String, List<ClipEntry>>()
    private var counter = 0

    override fun encode(entries: List<ClipEntry>): String {
        val token = "token-${counter++}"
        store[token] = entries
        return token
    }

    override fun decode(raw: String?): List<ClipEntry> {
        if (raw == null) return emptyList()
        if (raw == "INVALID") throw IllegalArgumentException("malformed index content")
        return store[raw] ?: emptyList()
    }

    fun seed(entries: List<ClipEntry>): String = encode(entries)
}

private class FixedClock(private val fixedMillis: Long) : ClipClock {
    override fun nowMillis(): Long = fixedMillis
}

class ClipIndexStoreTest {

    private fun newStore(
        clipsStorage: ClipIndexStorage = FakeClipIndexStorage(),
        capturesStorage: ClipIndexStorage = FakeClipIndexStorage(),
        codec: ClipIndexCodec = FakeClipIndexCodec(),
        clock: ClipClock = FixedClock(1_000_000L),
    ) = ClipIndexStore(clipsStorage, capturesStorage, codec, clock)

    // ---- registro ----

    @Test
    fun `registerVideoClip grava id novo e audioState READY_WITHOUT_AUDIO por padrao`() {
        val codec = FakeClipIndexCodec()
        val storage = FakeClipIndexStorage()
        val store = newStore(clipsStorage = storage, codec = codec)

        val result = store.registerVideoClip(path = "/a.mp4", timestamp = 1L) as ClipIndexResult.Success

        assertTrue(!result.id.isNullOrBlank())
        assertEquals("/a.mp4", result.path)
        assertEquals("READY_WITHOUT_AUDIO", codec.decode(storage.readRaw()).single().audioState)
    }

    @Test
    fun `registerVideoClip aceita audioState explicito`() {
        val codec = FakeClipIndexCodec()
        val storage = FakeClipIndexStorage()
        val store = newStore(clipsStorage = storage, codec = codec)

        store.registerVideoClip(path = "/a.mp4", timestamp = 1L, audioState = AudioState.PROCESSING)

        assertEquals("PROCESSING", codec.decode(storage.readRaw()).single().audioState)
    }

    @Test
    fun `duas chamadas consecutivas de registerVideoClip preservam ambas as entradas`() {
        val codec = FakeClipIndexCodec()
        val storage = FakeClipIndexStorage()
        val store = newStore(clipsStorage = storage, codec = codec)

        store.registerVideoClip(path = "/a.mp4", timestamp = 1L)
        store.registerVideoClip(path = "/b.mp4", timestamp = 2L)

        val paths = codec.decode(storage.readRaw()).map { it.path }.toSet()
        assertEquals(setOf("/a.mp4", "/b.mp4"), paths)
    }

    @Test
    fun `registerVideoClip com indice existente invalido retorna Failure e nao escreve`() {
        val storage = FakeClipIndexStorage(initial = "INVALID")
        val store = newStore(clipsStorage = storage)

        val result = store.registerVideoClip(path = "/a.mp4", timestamp = 1L)

        assertTrue(result is ClipIndexResult.Failure)
        assertEquals(0, storage.writeCount)
        assertEquals("INVALID", storage.readRaw())
    }

    @Test
    fun `entradas legadas de screenshot e video sobrevivem intactas a uma nova insercao`() {
        val codec = FakeClipIndexCodec()
        val legacyShot = ClipEntry(path = "/legacy.png", timestamp = 10L)
        val legacyVideo = ClipEntry(path = "/legacy.mp4", timestamp = 20L, type = "video")
        val storage = FakeClipIndexStorage(initial = codec.seed(listOf(legacyShot, legacyVideo)))
        val store = newStore(clipsStorage = storage, codec = codec)

        store.registerVideoClip(path = "/new.mp4", timestamp = 30L)

        val entries = codec.decode(storage.readRaw())
        assertEquals(3, entries.size)
        assertTrue(entries.contains(legacyShot))
        assertTrue(entries.contains(legacyVideo))
    }

    // ---- campo desconhecido (requisito desta rodada) ----

    @Test
    fun `campo desconhecido de entrada legada sobrevive a insercao de outra entrada`() {
        val codec = FakeClipIndexCodec()
        val legacy = ClipEntry(
            path = "/legacy.mp4",
            timestamp = 10L,
            type = "video",
            unknownFields = mapOf("legacyFlag" to true, "customNote" to "manter"),
        )
        val storage = FakeClipIndexStorage(initial = codec.seed(listOf(legacy)))
        val store = newStore(clipsStorage = storage, codec = codec)

        store.registerVideoClip(path = "/new.mp4", timestamp = 20L)

        val preserved = codec.decode(storage.readRaw()).first { it.path == "/legacy.mp4" }
        assertEquals(mapOf("legacyFlag" to true, "customNote" to "manter"), preserved.unknownFields)
    }

    @Test
    fun `campo desconhecido de entrada legada sobrevive a atualizacao de outra entrada`() {
        val codec = FakeClipIndexCodec()
        val legacy = ClipEntry(
            path = "/legacy.mp4", timestamp = 10L, type = "video",
            unknownFields = mapOf("legacyFlag" to true),
        )
        val other = ClipEntry(path = "/other.mp4", timestamp = 20L, type = "video", id = "other-id")
        val storage = FakeClipIndexStorage(initial = codec.seed(listOf(legacy, other)))
        val store = newStore(clipsStorage = storage, codec = codec)

        store.updateAudioState(id = "other-id", newState = AudioState.PROCESSING)

        val preserved = codec.decode(storage.readRaw()).first { it.path == "/legacy.mp4" }
        assertEquals(mapOf("legacyFlag" to true), preserved.unknownFields)
    }

    @Test
    fun `campo desconhecido de entrada legada sobrevive a exclusao de outra entrada`() {
        val codec = FakeClipIndexCodec()
        val legacy = ClipEntry(
            path = "/legacy.mp4", timestamp = 10L, type = "video",
            unknownFields = mapOf("legacyFlag" to true),
        )
        val other = ClipEntry(path = "/other.mp4", timestamp = 20L, type = "video", id = "other-id")
        val storage = FakeClipIndexStorage(initial = codec.seed(listOf(legacy, other)))
        val store = newStore(clipsStorage = storage, codec = codec)

        store.deleteById("other-id")

        val entries = codec.decode(storage.readRaw())
        assertEquals(1, entries.size)
        assertEquals(mapOf("legacyFlag" to true), entries.single().unknownFields)
    }

    // ---- deleteById ----

    @Test
    fun `deleteById remove somente a entrada daquele id e devolve o path armazenado`() {
        val codec = FakeClipIndexCodec()
        val storage = FakeClipIndexStorage()
        val store = newStore(clipsStorage = storage, codec = codec)
        val a = store.registerVideoClip(path = "/a.mp4", timestamp = 1L) as ClipIndexResult.Success
        store.registerVideoClip(path = "/b.mp4", timestamp = 2L)

        val result = store.deleteById(a.id!!) as ClipIndexResult.Success

        assertEquals("/a.mp4", result.path)
        assertEquals(listOf("/b.mp4"), codec.decode(storage.readRaw()).map { it.path })
    }

    @Test
    fun `id de A acompanhado de path de B nunca afeta B`() {
        val codec = FakeClipIndexCodec()
        val storage = FakeClipIndexStorage()
        val store = newStore(clipsStorage = storage, codec = codec)
        val a = store.registerVideoClip(path = "/a.mp4", timestamp = 1L) as ClipIndexResult.Success
        store.registerVideoClip(path = "/b.mp4", timestamp = 2L)

        // deleteById nunca consulta um path externo — só devolve o path que
        // está de fato gravado junto do id removido.
        val result = store.deleteById(a.id!!) as ClipIndexResult.Success

        assertEquals("/a.mp4", result.path)
        assertTrue(codec.decode(storage.readRaw()).any { it.path == "/b.mp4" })
    }

    @Test
    fun `deleteById de id inexistente retorna NotFound e nao altera o indice`() {
        val codec = FakeClipIndexCodec()
        val storage = FakeClipIndexStorage()
        val store = newStore(clipsStorage = storage, codec = codec)
        store.registerVideoClip(path = "/a.mp4", timestamp = 1L)
        val before = storage.readRaw()

        val result = store.deleteById("nao-existe")

        assertEquals(ClipIndexResult.NotFound, result)
        assertEquals(before, storage.readRaw())
    }

    @Test
    fun `deleteById apos exclusao nao recria a entrada`() {
        val codec = FakeClipIndexCodec()
        val storage = FakeClipIndexStorage()
        val store = newStore(clipsStorage = storage, codec = codec)
        val a = store.registerVideoClip(path = "/a.mp4", timestamp = 1L) as ClipIndexResult.Success
        store.deleteById(a.id!!)

        val second = store.deleteById(a.id!!)

        assertEquals(ClipIndexResult.NotFound, second)
        assertTrue(codec.decode(storage.readRaw()).isEmpty())
    }

    // ---- deleteByPath ----

    @Test
    fun `deleteByPath remove entrada legada sem id pelo path`() {
        val codec = FakeClipIndexCodec()
        val legacy = ClipEntry(path = "/legacy.png", timestamp = 10L)
        val storage = FakeClipIndexStorage(initial = codec.seed(listOf(legacy)))
        val store = newStore(capturesStorage = storage, codec = codec)

        val result = store.deleteByPath(ClipKind.SCREENSHOT, "/legacy.png") as ClipIndexResult.Success

        assertEquals("/legacy.png", result.path)
        assertTrue(codec.decode(storage.readRaw()).isEmpty())
    }

    @Test
    fun `deleteByPath ignora entrada que possui id mesmo com path coincidente`() {
        val codec = FakeClipIndexCodec()
        val withId = ClipEntry(path = "/a.mp4", timestamp = 1L, type = "video", id = "abc")
        val storage = FakeClipIndexStorage(initial = codec.seed(listOf(withId)))
        val store = newStore(clipsStorage = storage, codec = codec)

        val result = store.deleteByPath(ClipKind.VIDEO, "/a.mp4")

        assertEquals(ClipIndexResult.NotFound, result)
        assertEquals(1, codec.decode(storage.readRaw()).size)
    }

    // ---- updateAudioState ----

    @Test
    fun `updateAudioState para PROCESSING grava audioProcessingStartedAt apenas na primeira vez`() {
        val codec = FakeClipIndexCodec()
        val storage = FakeClipIndexStorage()
        val store = newStore(clipsStorage = storage, codec = codec, clock = FixedClock(5_000L))
        val a = store.registerVideoClip(path = "/a.mp4", timestamp = 1L) as ClipIndexResult.Success

        store.updateAudioState(a.id!!, AudioState.PROCESSING)

        val entry = codec.decode(storage.readRaw()).single()
        assertEquals("PROCESSING", entry.audioState)
        assertEquals(5_000L, entry.audioProcessingStartedAt)
    }

    @Test
    fun `updateAudioState para READY_WITH_AUDIO preserva audioProcessingStartedAt gravado em PROCESSING`() {
        val codec = FakeClipIndexCodec()
        val storage = FakeClipIndexStorage()
        val store = newStore(clipsStorage = storage, codec = codec, clock = FixedClock(5_000L))
        val a = store.registerVideoClip(path = "/a.mp4", timestamp = 1L) as ClipIndexResult.Success
        store.updateAudioState(a.id!!, AudioState.PROCESSING)

        store.updateAudioState(a.id!!, AudioState.READY_WITH_AUDIO)

        val entry = codec.decode(storage.readRaw()).single()
        assertEquals("READY_WITH_AUDIO", entry.audioState)
        assertEquals(5_000L, entry.audioProcessingStartedAt)
    }

    @Test
    fun `clipe que nunca entrou em PROCESSING mantem audioProcessingStartedAt ausente`() {
        val codec = FakeClipIndexCodec()
        val storage = FakeClipIndexStorage()
        val store = newStore(clipsStorage = storage, codec = codec)

        store.registerVideoClip(path = "/a.mp4", timestamp = 1L, audioState = AudioState.READY_WITHOUT_AUDIO)

        assertNull(codec.decode(storage.readRaw()).single().audioProcessingStartedAt)
    }

    @Test
    fun `updateAudioState de id inexistente retorna NotFound`() {
        val store = newStore()
        assertEquals(ClipIndexResult.NotFound, store.updateAudioState("nao-existe", AudioState.PROCESSING))
    }

    // ---- falha de escrita ----

    @Test
    fun `falha simulada em writeRaw mantem conteudo anterior legivel`() {
        val codec = FakeClipIndexCodec()
        val storage = FakeClipIndexStorage()
        val store = newStore(clipsStorage = storage, codec = codec)
        store.registerVideoClip(path = "/a.mp4", timestamp = 1L)
        val before = storage.readRaw()
        storage.failNextWriteWith = "disco cheio"

        val result = store.registerVideoClip(path = "/b.mp4", timestamp = 2L)

        assertTrue(result is ClipIndexResult.Failure)
        assertEquals(before, storage.readRaw())
        assertEquals(1, codec.decode(storage.readRaw()).size)
    }

    // ---- concorrencia cross-classe ----

    @Test
    fun `registro pelo servico e exclusao pela activity contra a mesma instancia nao perdem atualizacoes`() {
        val codec = FakeClipIndexCodec()
        val storage = FakeClipIndexStorage()
        val store = newStore(clipsStorage = storage, codec = codec) // instancia unica compartilhada
        val existing = store.registerVideoClip(path = "/existing.mp4", timestamp = 1L) as ClipIndexResult.Success

        val barrier = CyclicBarrier(2)
        val serviceThread = Thread {
            barrier.await()
            store.registerVideoClip(path = "/new.mp4", timestamp = 2L) // simula ScreenCaptureService
        }
        val activityThread = Thread {
            barrier.await()
            store.deleteById(existing.id!!) // simula MainActivity
        }
        serviceThread.start()
        activityThread.start()
        serviceThread.join()
        activityThread.join()

        val finalPaths = codec.decode(storage.readRaw()).map { it.path }.toSet()
        assertEquals(setOf("/new.mp4"), finalPaths)
    }

    // ---- AUDIO-CAPTURE-U2.6: elegibilidade decidida antes do registro ----

    @Test
    fun `candidato silencioso e registrado direto como READY_WITHOUT_AUDIO sem passar por PROCESSING`() {
        val codec = FakeClipIndexCodec()
        val storage = FakeClipIndexStorage()
        val store = newStore(clipsStorage = storage, codec = codec)
        val eligible = ClipAudioMuxer.computeAudioCandidateEligible(
            hasAudioCandidate = true,
            silenceDetected = true,
            muxTimelineEligible = true,
        )

        store.registerVideoClip(
            path = "/a.mp4",
            timestamp = 1L,
            audioState = if (eligible) AudioState.PROCESSING else AudioState.READY_WITHOUT_AUDIO,
        )

        val entry = codec.decode(storage.readRaw()).single()
        assertEquals("READY_WITHOUT_AUDIO", entry.audioState)
        assertNull(entry.audioProcessingStartedAt)
    }

    @Test
    fun `timeline inelegivel e registrado direto como READY_WITHOUT_AUDIO`() {
        val codec = FakeClipIndexCodec()
        val storage = FakeClipIndexStorage()
        val store = newStore(clipsStorage = storage, codec = codec)
        val eligible = ClipAudioMuxer.computeAudioCandidateEligible(
            hasAudioCandidate = true,
            silenceDetected = false,
            muxTimelineEligible = false,
        )

        store.registerVideoClip(
            path = "/a.mp4",
            timestamp = 1L,
            audioState = if (eligible) AudioState.PROCESSING else AudioState.READY_WITHOUT_AUDIO,
        )

        val entry = codec.decode(storage.readRaw()).single()
        assertEquals("READY_WITHOUT_AUDIO", entry.audioState)
        assertNull(entry.audioProcessingStartedAt)
    }

    // ---- updateClipFile / rollback ----

    @Test
    fun `rollback via updateClipFile restaura path size e duration originais`() {
        val codec = FakeClipIndexCodec()
        val storage = FakeClipIndexStorage()
        val store = newStore(clipsStorage = storage, codec = codec, clock = FixedClock(5_000L))
        val reg = store.registerVideoClip(
            path = "/a.mp4",
            timestamp = 1L,
            audioState = AudioState.PROCESSING,
            sizeBytes = 1_000L,
            durationMs = 4_000L,
        ) as ClipIndexResult.Success
        val before = store.findVideoClipById(reg.id!!)!!

        // Promoção (simula sucesso do mux).
        store.updateClipFile(
            id = reg.id,
            path = "/a_av.mp4",
            sizeBytes = 1_200L,
            durationMs = 4_050L,
            audioState = AudioState.READY_WITH_AUDIO,
        )
        assertEquals("/a_av.mp4", store.findVideoClipById(reg.id)!!.path)

        // Confirmação falhou — rollback completo para os valores originais.
        store.updateClipFile(
            id = reg.id,
            path = before.path,
            sizeBytes = before.size,
            durationMs = before.durationMs,
            audioState = AudioState.READY_WITHOUT_AUDIO,
        )

        val restored = store.findVideoClipById(reg.id)!!
        assertEquals("/a.mp4", restored.path)
        assertEquals(1_000L, restored.size)
        assertEquals(4_000L, restored.durationMs)
        assertEquals("READY_WITHOUT_AUDIO", restored.audioState)
        // audioProcessingStartedAt (gravado na criação, em PROCESSING) sobrevive intacto.
        assertEquals(5_000L, restored.audioProcessingStartedAt)
    }

    // ---- recoverStaleAudioProcessing ----

    @Test
    fun `recoverStaleAudioProcessing rebaixa PROCESSING mais antigo que o timeout preservando o path`() {
        val codec = FakeClipIndexCodec()
        val storage = FakeClipIndexStorage()
        val store = newStore(clipsStorage = storage, codec = codec, clock = FixedClock(1_000L))
        val reg = store.registerVideoClip(
            path = "/a.mp4",
            timestamp = 1L,
            audioState = AudioState.PROCESSING,
        ) as ClipIndexResult.Success

        val recovered = store.recoverStaleAudioProcessing(now = 1_000L + 120_000L + 1L, timeoutMs = 120_000L)

        assertEquals(listOf(reg.id!!), recovered)
        val entry = store.findVideoClipById(reg.id)!!
        assertEquals("READY_WITHOUT_AUDIO", entry.audioState)
        assertEquals("/a.mp4", entry.path)
    }

    @Test
    fun `recoverStaleAudioProcessing mantem PROCESSING recente intacto`() {
        val codec = FakeClipIndexCodec()
        val storage = FakeClipIndexStorage()
        val store = newStore(clipsStorage = storage, codec = codec, clock = FixedClock(1_000L))
        val reg = store.registerVideoClip(
            path = "/a.mp4",
            timestamp = 1L,
            audioState = AudioState.PROCESSING,
        ) as ClipIndexResult.Success

        val recovered = store.recoverStaleAudioProcessing(now = 1_000L + 60_000L, timeoutMs = 120_000L)

        assertTrue(recovered.isEmpty())
        assertEquals("PROCESSING", store.findVideoClipById(reg.id!!)!!.audioState)
        assertEquals(1, storage.writeCount) // apenas o write do registro inicial, nenhum write da varredura
    }

    // ---- corrida vencedor unico (AtomicBoolean) ----

    @Test
    fun `duas resolucoes concorrentes guardadas por um unico AtomicBoolean mutam o indice uma so vez`() {
        val codec = FakeClipIndexCodec()
        val storage = FakeClipIndexStorage()
        val store = newStore(clipsStorage = storage, codec = codec)
        val reg = store.registerVideoClip(
            path = "/a.mp4",
            timestamp = 1L,
            audioState = AudioState.PROCESSING,
        ) as ClipIndexResult.Success
        val writesBeforeRace = storage.writeCount

        val resolved = AtomicBoolean(false)
        val barrier = CyclicBarrier(2)
        // Simula maybeMuxClipAudio: lado do timeout rebaixa para
        // READY_WITHOUT_AUDIO; lado da thread de mux (sucesso tardio)
        // promove para READY_WITH_AUDIO — só um dos dois pode vencer.
        val timeoutThread = Thread {
            barrier.await()
            if (resolved.compareAndSet(false, true)) {
                store.updateAudioState(reg.id!!, AudioState.READY_WITHOUT_AUDIO)
            }
        }
        val lateSuccessThread = Thread {
            barrier.await()
            if (resolved.compareAndSet(false, true)) {
                store.updateClipFile(reg.id!!, "/a_av.mp4", 1_200L, 4_050L, AudioState.READY_WITH_AUDIO)
            }
        }
        timeoutThread.start()
        lateSuccessThread.start()
        timeoutThread.join()
        lateSuccessThread.join()

        assertEquals(1, storage.writeCount - writesBeforeRace)
        val entry = store.findVideoClipById(reg.id!!)!!
        assertTrue(
            (entry.audioState == "READY_WITHOUT_AUDIO" && entry.path == "/a.mp4") ||
                (entry.audioState == "READY_WITH_AUDIO" && entry.path == "/a_av.mp4"),
        )
    }

    // ---- promoção concorrente com exclusão ----

    @Test
    fun `promocao concorrente com exclusao pelo id nao recria a entrada`() {
        val codec = FakeClipIndexCodec()
        val storage = FakeClipIndexStorage()
        val store = newStore(clipsStorage = storage, codec = codec) // instancia unica compartilhada
        val reg = store.registerVideoClip(
            path = "/a.mp4",
            timestamp = 1L,
            audioState = AudioState.PROCESSING,
        ) as ClipIndexResult.Success

        val barrier = CyclicBarrier(2)
        val promoteThread = Thread {
            barrier.await()
            store.updateClipFile(reg.id!!, "/a_av.mp4", 1_200L, 4_050L, AudioState.READY_WITH_AUDIO)
        }
        val deleteThread = Thread {
            barrier.await()
            store.deleteById(reg.id!!)
        }
        promoteThread.start()
        deleteThread.start()
        promoteThread.join()
        deleteThread.join()

        val entries = codec.decode(storage.readRaw())
        assertEquals(0, entries.count { it.id == reg.id })
    }
}
