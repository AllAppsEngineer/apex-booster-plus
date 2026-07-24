package com.allappsengineer.apex_booster_plus

import org.json.JSONArray
import org.json.JSONObject

/**
 * Converts between the on-disk JSON array and List<ClipEntry>.
 *
 * [JsonClipIndexCodec] is exercised only via the physical on-device test —
 * JVM unit tests use a fake that never touches org.json, keeping
 * ClipIndexMutator/ClipIndexStore tests independent of the Android
 * unit-test stub jar.
 */
interface ClipIndexCodec {
    fun decode(raw: String?): List<ClipEntry>
    fun encode(entries: List<ClipEntry>): String
}

class JsonClipIndexCodec : ClipIndexCodec {
    private val knownKeys = setOf("path", "timestamp", "type", "id", "audioState", "audioProcessingStartedAt")

    override fun decode(raw: String?): List<ClipEntry> {
        if (raw.isNullOrBlank()) return emptyList()
        val array = JSONArray(raw)
        val result = ArrayList<ClipEntry>(array.length())
        for (i in 0 until array.length()) {
            val obj = array.optJSONObject(i) ?: continue
            val path = obj.optString("path", "")
            if (path.isEmpty()) continue
            if (!obj.has("timestamp")) continue
            val timestamp = obj.optLong("timestamp", -1L)
            if (timestamp < 0L) continue

            val unknown = LinkedHashMap<String, Any?>()
            val keys = obj.keys()
            while (keys.hasNext()) {
                val key = keys.next()
                if (key !in knownKeys) {
                    unknown[key] = fromJson(obj.get(key))
                }
            }

            result.add(
                ClipEntry(
                    path = path,
                    timestamp = timestamp,
                    type = if (obj.has("type")) obj.optString("type") else null,
                    id = if (obj.has("id")) obj.optString("id") else null,
                    audioState = if (obj.has("audioState")) obj.optString("audioState") else null,
                    audioProcessingStartedAt =
                        if (obj.has("audioProcessingStartedAt")) obj.optLong("audioProcessingStartedAt") else null,
                    unknownFields = unknown,
                ),
            )
        }
        return result
    }

    override fun encode(entries: List<ClipEntry>): String {
        val array = JSONArray()
        for (entry in entries) {
            val obj = JSONObject()
            obj.put("path", entry.path)
            obj.put("timestamp", entry.timestamp)
            entry.type?.let { obj.put("type", it) }
            entry.id?.let { obj.put("id", it) }
            entry.audioState?.let { obj.put("audioState", it) }
            entry.audioProcessingStartedAt?.let { obj.put("audioProcessingStartedAt", it) }
            for ((key, value) in entry.unknownFields) {
                obj.put(key, toJson(value))
            }
            array.put(obj)
        }
        return array.toString()
    }

    private fun fromJson(value: Any?): Any? = if (value == JSONObject.NULL) null else value

    private fun toJson(value: Any?): Any = value ?: JSONObject.NULL
}
