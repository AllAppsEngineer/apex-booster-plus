package com.allappsengineer.apex_booster_plus

import android.util.AtomicFile
import java.io.File
import java.io.FileNotFoundException

/**
 * Raw string I/O for one index.json file. Production is backed by
 * [AtomicFileClipIndexStorage]; JVM tests inject an in-memory fake instead —
 * this interface is the seam that keeps ClipIndexStore testable without
 * Robolectric.
 */
interface ClipIndexStorage {
    fun readRaw(): String?
    fun writeRaw(content: String)
}

/**
 * Assumes the parent directory already exists — every current call site
 * (registerClip/registerCapture) creates it before touching the index,
 * matching the pre-U2.4 behavior.
 */
class AtomicFileClipIndexStorage(private val file: File) : ClipIndexStorage {
    override fun readRaw(): String? {
        return try {
            String(AtomicFile(file).readFully(), Charsets.UTF_8)
        } catch (e: FileNotFoundException) {
            null
        }
    }

    override fun writeRaw(content: String) {
        val atomicFile = AtomicFile(file)
        val stream = atomicFile.startWrite()
        try {
            stream.write(content.toByteArray(Charsets.UTF_8))
            atomicFile.finishWrite(stream)
        } catch (e: Exception) {
            atomicFile.failWrite(stream)
            throw e
        }
    }
}
